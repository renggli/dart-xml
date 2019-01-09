library xml_events.events.start_element_event;

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
      attribute.encode(buffer);
    }
    buffer.write(
        isSelfClosing ? XmlToken.closeEndElement : XmlToken.closeElement);
  }
}
