library xml_events.events.end_element_event;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/events/named.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType;

/// Event of an closing XML element node.
class XmlEndElementEvent extends XmlEvent with XmlNamed {
  XmlEndElementEvent(this.name);

  @override
  final String name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitEndElementEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlEndElementEvent && other.name == name;
}
