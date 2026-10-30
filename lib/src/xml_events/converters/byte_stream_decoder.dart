import 'dart:async';
import 'dart:convert';

import '../../xml/entities/entity_mapping.dart';
import '../converters/event_decoder.dart';
import '../event.dart';

/// Extension for byte stream decoding.
extension XmlByteStreamDecoderExtension on Stream<List<int>> {
  /// Decodes a byte stream into a string stream, automatically detecting and
  /// stripping byte order marks (BOM) and resolving encoding declarations.
  Stream<String> decodeXmlStream({Encoding? defaultEncoding}) =>
      cast<List<int>>().transform(
        XmlByteStreamDecoder(defaultEncoding: defaultEncoding),
      );

  /// Converts a byte stream into a sequence of [XmlEvent] objects.
  Stream<List<XmlEvent>> toXmlEvents({
    Encoding? defaultEncoding,
    XmlEntityMapping? entityMapping,
    bool validateDocument = false,
    bool validateNamespace = false,
    bool validateNesting = false,
    bool validateAttributes = false,
    bool withLocation = false,
    bool withNamespace = false,
    bool withParent = false,
  }) => decodeXmlStream(defaultEncoding: defaultEncoding).toXmlEvents(
    entityMapping: entityMapping,
    validateDocument: validateDocument,
    validateNamespace: validateNamespace,
    validateNesting: validateNesting,
    validateAttributes: validateAttributes,
    withLocation: withLocation,
    withNamespace: withNamespace,
    withParent: withParent,
  );
}

/// A [StreamTransformer] that decodes a byte stream to a string stream,
/// detecting and stripping Byte Order Marks (BOM) and sniffing XML encoding.
class XmlByteStreamDecoder extends StreamTransformerBase<List<int>, String> {
  const new({this.defaultEncoding});

  /// Fallback encoding when no BOM or declaration encoding is found.
  final Encoding? defaultEncoding;

  @override
  Stream<String> bind(Stream<List<int>> stream) {
    late StreamSubscription<List<int>> subscription;
    final controller = StreamController<String>(sync: true);

    var initialized = false;
    final initialBuffer = <int>[];
    Sink<List<int>>? standardSink;
    var isUtf16Le = false;
    var isUtf16Be = false;
    int? pendingByte;

    void processUtf16(List<int> bytes) {
      if (bytes.isEmpty) return;
      var offset = 0;
      final codeUnits = <int>[];
      if (pendingByte != null) {
        final b0 = pendingByte!;
        final b1 = bytes[0];
        pendingByte = null;
        offset = 1;
        codeUnits.add(isUtf16Le ? (b1 << 8) | b0 : (b0 << 8) | b1);
      }
      final remaining = bytes.length - offset;
      final pairs = remaining ~/ 2;
      for (var i = 0; i < pairs; i++) {
        final b0 = bytes[offset++];
        final b1 = bytes[offset++];
        codeUnits.add(isUtf16Le ? (b1 << 8) | b0 : (b0 << 8) | b1);
      }
      if (offset < bytes.length) {
        pendingByte = bytes[offset];
      }
      if (codeUnits.isNotEmpty) {
        controller.add(String.fromCharCodes(codeUnits));
      }
    }

    void initializeDecoder(List<int> bytes) {
      var sliceOffset = 0;
      if (bytes.length >= 3 &&
          bytes[0] == 0xEF &&
          bytes[1] == 0xBB &&
          bytes[2] == 0xBF) {
        // UTF-8 BOM
        sliceOffset = 3;
        standardSink = utf8.decoder.startChunkedConversion(
          StringConversionSink.from(controller),
        );
      } else if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
        // UTF-16 BE BOM
        sliceOffset = 2;
        isUtf16Be = true;
      } else if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
        // UTF-16 LE BOM
        sliceOffset = 2;
        isUtf16Le = true;
      } else {
        // Sniff <?xml ... encoding="..."?>
        final header = ascii.decode(
          bytes.take(128).where((b) => b > 0 && b < 128).toList(),
          allowInvalid: true,
        );
        final encodingMatch = RegExp(
          r'''<\?xml[^>]+encoding\s*=\s*["']([^"']+)["']''',
          caseSensitive: false,
        ).firstMatch(header);
        final encodingName = encodingMatch?.group(1)?.toLowerCase();
        if (encodingName == 'iso-8859-1' || encodingName == 'latin1') {
          standardSink = latin1.decoder.startChunkedConversion(
            StringConversionSink.from(controller),
          );
        } else if (encodingName == 'us-ascii' || encodingName == 'ascii') {
          standardSink = ascii.decoder.startChunkedConversion(
            StringConversionSink.from(controller),
          );
        } else if (encodingName == 'utf-16' || encodingName == 'utf-16be') {
          isUtf16Be = true;
        } else if (encodingName == 'utf-16le') {
          isUtf16Le = true;
        } else {
          final enc = defaultEncoding ?? utf8;
          standardSink = enc.decoder.startChunkedConversion(
            StringConversionSink.from(controller),
          );
        }
      }

      initialized = true;
      final remaining = bytes.sublist(sliceOffset);
      if (remaining.isNotEmpty) {
        if (isUtf16Be || isUtf16Le) {
          processUtf16(remaining);
        } else {
          standardSink!.add(remaining);
        }
      }
    }

    controller.onListen = () {
      subscription = stream.listen(
        (data) {
          if (!initialized) {
            initialBuffer.addAll(data);
            if (initialBuffer.length >= 4) {
              initializeDecoder(initialBuffer);
            }
          } else {
            if (isUtf16Be || isUtf16Le) {
              processUtf16(data);
            } else {
              standardSink!.add(data);
            }
          }
        },
        onError: controller.addError,
        onDone: () {
          if (!initialized) {
            initializeDecoder(initialBuffer);
          }
          if (standardSink != null) {
            standardSink!.close();
          }
          controller.close();
        },
        cancelOnError: false,
      );
    };

    controller.onPause = () => subscription.pause();
    controller.onResume = () => subscription.resume();
    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }
}
