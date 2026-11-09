import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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

  // A declaration can span multiple byte chunks. Bound the amount buffered
  // before falling back to the default encoding.
  static const _maxPrologBytes = 4096;
  static final _encodingPattern = RegExp(
    r'''<\?xml[^>]+encoding\s*=\s*["']([^"']+)["']''',
    caseSensitive: false,
  );

  static bool _readyToDecode(List<int> bytes) {
    if (bytes.length < 4) return false;
    if (bytes.length >= _maxPrologBytes) return true;

    // An XML declaration is the only reason to delay decoding. Wait for its
    // closing ?> even when it is divided into single-byte stream chunks.
    if (bytes[0] != 0x3C ||
        bytes[1] != 0x3F ||
        bytes[2] != 0x78 ||
        bytes[3] != 0x6D) {
      return true;
    }
    if (bytes.length < 5) return false;
    if (bytes[4] != 0x6C) return true;
    if (bytes.length < 6) return false;
    final firstAfterName = bytes[5];
    if (firstAfterName != 0x20 &&
        firstAfterName != 0x09 &&
        firstAfterName != 0x0A &&
        firstAfterName != 0x0D) {
      return true;
    }
    for (var i = 6; i < bytes.length - 1; i++) {
      if (bytes[i] == 0x3F && bytes[i + 1] == 0x3E) return true;
    }
    return false;
  }

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

    void processBytes(List<int> bytes, [int offset = 0]) {
      if (offset >= bytes.length) return;
      List<int> data = bytes;
      if (offset != 0) {
        // A large Uint8List first chunk should not be copied just to skip
        // the XML declaration.
        if (bytes is Uint8List) {
          data = Uint8List.sublistView(bytes, offset);
        } else {
          data = bytes.sublist(offset);
        }
      }
      if (isUtf16Be || isUtf16Le) {
        processUtf16(data);
      } else {
        standardSink!.add(data);
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
      } else if (bytes.length >= 4 &&
          bytes[0] == 0x00 &&
          bytes[1] == 0x3C) {
        // UTF-16 BE starts with '<' even without an XML declaration.
        isUtf16Be = true;
      } else if (bytes.length >= 4 &&
          bytes[0] == 0x3C &&
          bytes[1] == 0x00 &&
          (bytes[2] != 0x00 || bytes[3] != 0x00)) {
        // UTF-16 LE starts with '<'. Exclude the UTF-32 LE signature.
        isUtf16Le = true;
      } else {
        // The ASCII XML prolog may be longer than one byte-stream chunk.
        final header = ascii.decode(
          bytes.take(_maxPrologBytes).toList(),
          allowInvalid: true,
        );
        final encodingMatch = _encodingPattern.firstMatch(header);
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
      processBytes(bytes, sliceOffset);
    }

    controller.onListen = () {
      subscription = stream.listen(
        (data) {
          if (initialized) {
            processBytes(data);
            return;
          }
          // Copy only as many bytes as are needed to recognize the prolog,
          // not the entire first chunk (which may be several megabytes).
          var index = 0;
          while (!initialized && index < data.length) {
            initialBuffer.add(data[index++]);
            if (_readyToDecode(initialBuffer)) {
              initializeDecoder(initialBuffer);
            }
          }
          if (initialized) processBytes(data, index);
        },
        onError: controller.addError,
        onDone: () {
          if (!initialized) {
            initializeDecoder(initialBuffer);
          }
          if (pendingByte != null) {
            controller.addError(
              const FormatException('Incomplete UTF-16 code unit'),
            );
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
