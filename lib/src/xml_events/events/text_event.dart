library xml_events.events.text_event;

import 'package:xml/xml.dart' show XmlNodeType;

import '../event.dart';
import '../visitor.dart';

class XmlTextEvent extends XmlEvent {
  XmlTextEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitTextEvent(this);

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) => other is XmlTextEvent && other.text == text;
}
