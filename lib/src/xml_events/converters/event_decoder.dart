import 'dart:convert' show Converter, StringConversionSink;

import 'package:petitparser/stream.dart';

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
  new({
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
    startChunkedConversion(sink)
        .addSlice(input, start, end ?? input.length, true);
    return list;
  }

  @override
  StringConversionSink startChunkedConversion(Sink<List<XmlEvent>> sink) {
    final annotator = XmlAnnotator(
      validateDocument: validateDocument,
      validateNamespace: validateNamespace,
      validateNesting: validateNesting,
      withBuffer: false,
      withLocation: withLocation,
      withNamespace: withNamespace,
      withParent: withParent,
    );
    return ParseDecoderSink<XmlEvent>(
      eventParserCache[entityMapping],
      sink,
      contiguous: true,
      onMatch: (event, {required start, required stop, required buffer}) {
        annotator.annotate(event, start: start, stop: stop);
      },
      onError: (failure) {
        throw XmlParserException(failure.message, position: failure.position);
      },
      onClose: ({required position, required buffer}) {
        annotator.close(position: position);
      },
    );
  }
}
