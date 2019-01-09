library xml_events.events.end_element_event;

import 'package:xml/xml/utils/node_type.dart';

import '../event.dart';

class XmlEndElementEvent extends XmlEvent {
  XmlEndElementEvent(this.name);

  final String name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  String toString() => '$runtimeType($name)';
}
