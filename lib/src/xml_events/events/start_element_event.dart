library xml_events.events.start_element_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlStartElementEvent extends XmlEvent {
  XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing);

  final String name;

  final List<XmlElementAttribute> attributes;

  final bool isSelfClosing;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitStartElementEvent(this);
}

class XmlElementAttribute {
  XmlElementAttribute(this.name, this.value, this.attributeType);

  final String name;

  final String value;

  final XmlAttributeType attributeType;
}
