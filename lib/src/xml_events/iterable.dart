import '../xml/entities/default_mapping.dart';
import '../xml/entities/entity_mapping.dart';
import '../xml/exceptions/namespace_exception.dart';
import '../xml/exceptions/parser_exception.dart';
import '../xml/exceptions/tag_exception.dart';
import 'annotations/annotator.dart';
import 'event.dart';
import 'iterator.dart';

/// An [Iterable] of [XmlEvent] instances over an XML input string.
///
/// Iteration can throw an [XmlParserException] if the input is malformed,
/// an [XmlTagException] if tag nesting is invalid and [validateNesting] is `true`,
/// or an [XmlNamespaceException] if namespace constraints are violated and
/// [validateNamespace] is `true`.
///
/// When [validateDocument] is `false` (default), the input may contain arbitrary
/// XML fragments or multiple sibling root elements. When `true`, input must follow
/// full XML document structure.
class XmlEventIterable extends Iterable<XmlEvent> {
  /// Creates an iterable of [XmlEvent]s over the given [input] string.
  new(
    this.input, {
    XmlEntityMapping? entityMapping,
    this.validateNesting = false,
    this.validateNamespace = false,
    this.validateDocument = false,
    this.validateAttributes = false,
    this.withBuffer = false,
    this.withLocation = false,
    this.withNamespace = false,
    this.withParent = false,
  }) : entityMapping = entityMapping ?? defaultEntityMapping;

  final String input;
  final XmlEntityMapping entityMapping;
  final bool validateNesting;
  final bool validateNamespace;
  final bool validateDocument;
  final bool validateAttributes;
  final bool withBuffer;
  final bool withLocation;
  final bool withNamespace;
  final bool withParent;

  @override
  Iterator<XmlEvent> get iterator => XmlEventIterator(
    input,
    entityMapping,
    XmlAnnotator(
      validateNesting: validateNesting,
      validateNamespace: validateNamespace,
      validateDocument: validateDocument,
      validateAttributes: validateAttributes,
      withBuffer: withBuffer,
      withLocation: withLocation,
      withNamespace: withNamespace,
      withParent: withParent,
    ),
  );
}
