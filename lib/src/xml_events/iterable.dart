import '../xml/entities/entity_mapping.dart';
import 'event.dart';
import 'iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  final String input;
  final XmlEntityMapping entityMapping;

  XmlEventIterable(this.input, this.entityMapping);

  @override
  Iterator<XmlEvent> get iterator => XmlEventIterator(input, entityMapping);
}
