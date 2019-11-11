library xml_events.iterable;

import 'event.dart';
import 'iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  XmlEventIterable(this.input);

  final String input;

  @override
  Iterator<XmlEvent> get iterator => XmlEventIterator(input);
}
