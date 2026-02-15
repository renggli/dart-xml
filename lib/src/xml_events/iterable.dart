import '../xml/entities/entity_mapping.dart';
import 'annotations/annotator.dart';
import 'event.dart';
import 'iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  XmlEventIterable(
    this.input, {
    required this.entityMapping,
    required this.validateNesting,
    required this.validateNamespace,
    required this.validateDocument,
    required this.withBuffer,
    required this.withLocation,
    required this.withNamespace,
    required this.withParent,
  });

  final String input;
  final XmlEntityMapping entityMapping;
  final bool validateNesting;
  final bool validateNamespace;
  final bool validateDocument;
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
      withBuffer: withBuffer,
      withLocation: withLocation,
      withNamespace: withNamespace,
      withParent: withParent,
    ),
  );
}
