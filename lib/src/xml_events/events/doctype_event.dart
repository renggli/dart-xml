library xml_events.events.doctype_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlDoctypeEvent extends XmlEvent {
  XmlDoctypeEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitDoctypeEvent(this);
}
