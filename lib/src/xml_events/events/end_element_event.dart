library xml_events.events.end_element_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlEndElementEvent extends XmlEvent {
  XmlEndElementEvent(this.name);

  final String name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitEndElementEvent(this);
}
