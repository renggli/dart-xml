library xml_events.event.doctype_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlDoctypeEvent extends XmlEvent {
  XmlDoctypeEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  dynamic accept(XmlEventVisitor visitor) => visitor.visitDoctypeEvent(this);
}
