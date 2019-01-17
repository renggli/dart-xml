library xml_events.event.end_element_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlEndElementEvent extends XmlEvent {
  XmlEndElementEvent(this.name);

  final String name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  dynamic accept(XmlEventVisitor visitor) => visitor.visitEndElementEvent(this);
}
