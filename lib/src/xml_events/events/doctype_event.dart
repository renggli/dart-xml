library xml_events.events.doctype_event;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType;

/// Event of an XML doctype node.
class XmlDoctypeEvent extends XmlEvent {
  XmlDoctypeEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitDoctypeEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ text.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlDoctypeEvent && other.text == text;
}
