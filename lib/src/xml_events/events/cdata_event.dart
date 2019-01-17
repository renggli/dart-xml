library xml_events.event.cdata_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlCDATAEvent extends XmlEvent {
  XmlCDATAEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  dynamic accept(XmlEventVisitor visitor) => visitor.visitCDATAEvent(this);
}
