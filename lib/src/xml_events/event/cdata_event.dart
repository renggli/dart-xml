library xml_events.event.cdata_event;

import 'package:xml/xml.dart';

import '../event.dart';

class XmlCDATAEvent extends XmlEvent {
  XmlCDATAEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  void encode(StringBuffer buffer) {
    buffer.write(XmlToken.openCDATA);
    buffer.write(text);
    buffer.write(XmlToken.closeCDATA);
  }
}
