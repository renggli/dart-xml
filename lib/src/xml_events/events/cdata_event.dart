library xml_events.events.cdata_event;

import 'package:xml/xml.dart' show XmlNodeType;

import '../event.dart';
import '../visitor.dart';

class XmlCDATAEvent extends XmlEvent {
  XmlCDATAEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitCDATAEvent(this);

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlCDATAEvent && other.text == text;
}
