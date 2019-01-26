library xml_events.events.end_element_event;

import 'package:xml/xml.dart' show XmlNodeType;

import '../event.dart';
import '../visitor.dart';
import 'named.dart';

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
