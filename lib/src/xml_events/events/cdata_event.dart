library xml_events.events.cdata_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlCDATAEvent extends XmlEvent {
  XmlCDATAEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitCDATAEvent(this);
}
