library xml_events.event.start_element_event;

import 'package:xml/xml.dart';

import '../event.dart';
import 'attribute_event.dart';

class XmlStartElementEvent extends XmlEvent {
  XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing);

  final String name;

  final List<XmlElementAttribute> attributes;

  final bool isSelfClosing;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void encode(StringBuffer buffer) {
    buffer.write(XmlToken.openElement);
    buffer.write(name);
    for (var attribute in attributes) {
      buffer.write(XmlToken.whitespace);
      attribute.encode(buffer);
    }
    if (isSelfClosing) {
      buffer.write(XmlToken.closeEndElement);
    } else {
      buffer.write(XmlToken.closeElement);
    }
  }
}
