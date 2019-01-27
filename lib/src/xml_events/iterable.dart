library xml_events.iterable;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/iterator.dart';

class XmlEventIterable extends Iterable<XmlEvent> {
  XmlEventIterable(this.input);

  final String input;

  @override
  Iterator<XmlEvent> get iterator => XmlEventIterator(input);
}
