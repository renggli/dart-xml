library xml_events.events.start_element_event;

import 'package:collection/collection.dart' show ListEquality;
import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/events/named.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType, XmlAttributeType;

/// Event of an XML start element node.
class XmlStartElementEvent extends XmlEvent with XmlNamed {
  XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing);

  @override
  final String name;

  final List<XmlElementAttribute> attributes;

  final bool isSelfClosing;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitStartElementEvent(this);

  @override
  int get hashCode =>
      nodeType.hashCode ^
      name.hashCode ^
      isSelfClosing.hashCode ^
      const ListEquality().hash(attributes);

  @override
  bool operator ==(Object other) =>
      other is XmlStartElementEvent &&
      other.name == name &&
      other.isSelfClosing == isSelfClosing &&
      const ListEquality().equals(other.attributes, attributes);
}

/// Attributes of an [XmlStartElementEvent].
class XmlElementAttribute with XmlNamed {
  XmlElementAttribute(this.name, this.value, this.attributeType);

  @override
  final String name;

  final String value;

  final XmlAttributeType attributeType;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlElementAttribute &&
      other.name == name &&
      other.value == value &&
      other.attributeType == attributeType;
}
