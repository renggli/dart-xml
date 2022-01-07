import '../xml/entities/entity_mapping.dart';
import 'event.dart';
import 'iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  XmlEventIterable(this.input, this.entityMapping);

  final String input;
  final XmlEntityMapping entityMapping;

  @override
  Iterator<XmlEvent> get iterator => XmlEventIterator(input, entityMapping);
}
