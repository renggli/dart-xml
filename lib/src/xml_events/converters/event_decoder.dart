import 'dart:convert'
    show Converter, StringConversionSink, StringConversionSinkBase;

import 'package:petitparser/petitparser.dart';

import '../../xml/entities/default_mapping.dart';
import '../../xml/entities/entity_mapping.dart';
import '../../xml/exceptions/namespace_exception.dart';
import '../../xml/exceptions/parser_exception.dart';
import '../../xml/exceptions/tag_exception.dart';
import '../annotations/annotator.dart';
import '../event.dart';
import '../parser.dart';
import '../utils/conversion_sink.dart';

extension XmlEventDecoderExtension on Stream<String> {
  /// Converts a [String] to a sequence of [XmlEvent] objects.
  ///
  /// See [XmlEventDecoder] for information about the parameters.
  Stream<List<XmlEvent>> toXmlEvents({
    XmlEntityMapping? entityMapping,
    bool validateDocument = false,
    bool validateNamespace = false,
    bool validateNesting = false,
    bool withLocation = false,
    bool withNamespace = false,
    bool withParent = false,
  }) => transform(
    XmlEventDecoder(
      entityMapping: entityMapping,
      validateDocument: validateDocument,
      validateNamespace: validateNamespace,
      validateNesting: validateNesting,
      withLocation: withLocation,
      withNamespace: withNamespace,
      withParent: withParent,
    ),
  );
}

/// A converter that decodes a [String] to a sequence of [XmlEvent] objects.
class XmlEventDecoder extends Converter<String, List<XmlEvent>> {
  /// Creates a new [XmlEventDecoder].
  ///
  /// If [validateDocument] is `true`, the parser validates that the root elements
  /// of the input follow the requirements of an XML document. This means the
  /// document consists of an optional declaration, an optional doctype, and a
  /// single root element.
  ///
  /// If [validateNamespace] is `true`, the parser validates the declaration and
  /// use of namespaces and throws a [XmlNamespaceException] if there is a
  /// problem.
  ///
  /// If [validateNesting] is `true`, the parser validates the nesting of tags and
  /// throws an [XmlTagException] if there is a mismatch or tags are not closed.
  /// Again, in case of an error iteration can be resumed with the next event.
  ///
  /// Furthermore, the following annotations can be enabled if needed:
  ///
  /// - If [withLocation] is `true`, each event is annotated with the starting
  ///   and stopping position (exclusive) of the event in the input buffer.
  /// - If [withNamespace] is `true`, the namespace of the element is resolved
  ///   and added to the event.
  /// - If [withParent] is `true`, each event is annotated with its logical
  ///   parent event.
  XmlEventDecoder({
    XmlEntityMapping? entityMapping,
    this.validateDocument = false,
    this.validateNamespace = false,
    this.validateNesting = false,
    this.withLocation = false,
    this.withNamespace = false,
    this.withParent = false,
  }) : entityMapping = entityMapping ?? defaultEntityMapping;

  final XmlEntityMapping entityMapping;
  final bool validateDocument;
  final bool validateNamespace;
  final bool validateNesting;
  final bool withLocation;
  final bool withNamespace;
  final bool withParent;

  @override
  List<XmlEvent> convert(String input, [int start = 0, int? end]) {
    final list = <XmlEvent>[];
    final sink = ConversionSink<List<XmlEvent>>(list.addAll);
    startChunkedConversion(
      sink,
    ).addSlice(input, start, end ?? input.length, true);
    return list;
  }

  @override
  StringConversionSink startChunkedConversion(Sink<List<XmlEvent>> sink) =>
      _XmlEventDecoderSink(
        sink,
        entityMapping,
        XmlAnnotator(
          validateDocument: validateDocument,
          validateNamespace: validateNamespace,
          validateNesting: validateNesting,
          withBuffer: false,
          withLocation: withLocation,
          withNamespace: withNamespace,
          withParent: withParent,
        ),
      );
}

class _XmlEventDecoderSink extends StringConversionSinkBase {
  _XmlEventDecoderSink(
    this.sink,
    XmlEntityMapping entityMapping,
    this.annotator,
  ) : eventParser = eventParserCache[entityMapping];

  final Sink<List<XmlEvent>> sink;
  final Parser<XmlEvent> eventParser;
  final XmlAnnotator annotator;

  String carry = '';
  int offset = 0;

  @override
  void addSlice(String str, int start, int end, bool isLast) {
    end = RangeError.checkValidRange(start, end, str.length);
    if (start == end) {
      if (isLast) {
        close();
      }
      return;
    }
    final result = <XmlEvent>[];
    Result<XmlEvent> previous = Failure(
      carry + str.substring(start, end),
      0,
      '',
    );
    for (;;) {
      final current = eventParser.parseOn(previous);
      if (current is Success) {
        final event = current.value;
        annotator.annotate(
          event,
          start: offset + previous.position,
          stop: offset + current.position,
        );
        result.add(event);
        previous = current;
      } else {
        carry = previous.buffer.substring(previous.position);
        offset += previous.position;
        break;
      }
    }
    if (result.isNotEmpty) {
      sink.add(result);
    }
    if (isLast) {
      close();
    }
  }

  @override
  void close() {
    if (carry.isNotEmpty) {
      final context = eventParser.parseOn(Failure(carry, 0, ''));
      if (context is Failure) {
        throw XmlParserException(
          context.message,
          position: offset + context.position,
        );
      }
    }
    annotator.close(position: offset);
    sink.close();
  }
}
