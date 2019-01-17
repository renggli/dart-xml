library xml_events.event.text_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlTextEvent extends XmlEvent {
  XmlTextEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  dynamic accept(XmlEventVisitor visitor) => visitor.visitTextEvent(this);
}
