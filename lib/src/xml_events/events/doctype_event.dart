library xml_events.events.doctype_event;

import 'package:xml/xml.dart';

import '../event.dart';

class XmlDoctypeEvent extends XmlEvent {
  XmlDoctypeEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  void encode(StringBuffer buffer) {
    buffer.write(XmlToken.openDoctype);
    buffer.write(XmlToken.whitespace);
    buffer.write(text);
    buffer.write(XmlToken.closeDoctype);
  }
}
