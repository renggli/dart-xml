import '../xml/entities/entity_mapping.dart';
import 'annotations/annotator.dart';
import 'event.dart';
import 'iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  XmlEventIterable(
    this.input, {
    required this.entityMapping,
    required this.withBuffer,
    required this.withLocation,
    required this.withParent,
    required this.validateNesting,
  });

  final String input;
  final XmlEntityMapping entityMapping;
  final bool validateNesting;
  final bool withBuffer;
  final bool withLocation;
  final bool withParent;

  @override
  Iterator<XmlEvent> get iterator => XmlEventIterator(
        input,
        entityMapping,
        XmlAnnotator(
          validateNesting: validateNesting,
          withBuffer: withBuffer,
          withLocation: withLocation,
          withParent: withParent,
        ),
      );
}
