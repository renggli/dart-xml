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
    final quote = attributeType == XmlAttributeType.DOUBLE_QUOTE
        ? XmlToken.doubleQuote
        : XmlToken.singleQuote;
    buffer.write(name);
    buffer.write(XmlToken.equals);
    buffer.write(quote);
    buffer.write(encodeXmlAttributeValue(value, attributeType));
    buffer.write(quote);
  }
}
