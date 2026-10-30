import '../xml/entities/default_mapping.dart';
import '../xml/entities/entity_mapping.dart';
import 'annotations/annotator.dart';
import 'event.dart';
import 'iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  new(
    this.input, {
    XmlEntityMapping? entityMapping,
    this.validateNesting = false,
    this.validateNamespace = false,
    this.validateDocument = false,
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
