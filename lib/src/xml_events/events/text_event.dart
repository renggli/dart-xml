library xml_events.events.text_event;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType;

/// Event of an XML text node.
class XmlTextEvent extends XmlEvent {
  XmlTextEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitTextEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ text.hashCode;

  @override
  bool operator ==(Object other) => other is XmlTextEvent && other.text == text;
}
