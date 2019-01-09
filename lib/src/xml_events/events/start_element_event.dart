library xml_events.events.start_element_event;

import 'package:xml/xml/utils/attribute_type.dart';
import 'package:xml/xml/utils/node_type.dart';

import '../event.dart';

class XmlStartElementEvent extends XmlEvent {
  XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing);

  final String name;

  final List<XmlAttribute> attributes;

  final bool isSelfClosing;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  String toString() => '$runtimeType($name, $attributes, $isSelfClosing)';
}

class XmlAttribute {
  XmlAttribute(this.name, this.value, this.attributeType);

  final String name;

  final String value;

  final XmlAttributeType attributeType;

  @override
  String toString() => '$runtimeType($name, $value)';
}
