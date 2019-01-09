library xml_events.events.cdata_event;

import 'package:xml/xml/utils/node_type.dart';

import '../event.dart';

class XmlCDATAEvent extends XmlEvent {
  XmlCDATAEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  String toString() => '$runtimeType($text)';
}
