library xml_events.event.end_element_event;

import 'package:xml/xml.dart';

import '../event.dart';

class XmlEndElementEvent extends XmlEvent {
  XmlEndElementEvent(this.name);

  final String name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void encode(StringBuffer buffer) {
    buffer.write(XmlToken.openEndElement);
    buffer.write(name);
    buffer.write(XmlToken.closeElement);
  }
}
