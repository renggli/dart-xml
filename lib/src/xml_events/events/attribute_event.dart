library xml_events.events.attribute_event;

import 'package:xml/xml.dart';

import '../event.dart';

class XmlElementAttribute extends XmlEvent {
  XmlElementAttribute(this.name, this.value, this.attributeType);

  final String name;

  final String value;

  final XmlAttributeType attributeType;

  @override
  XmlNodeType get nodeType => XmlNodeType.ATTRIBUTE;

  @override
  void encode(StringBuffer buffer) {
    buffer.write(name);
    buffer.write(XmlToken.equals);
    buffer.write(encodeXmlAttributeValueWithQuotes(value, attributeType));
  }
}
