library xml_events.events.text_event;

import 'package:xml/xml/utils/node_type.dart';

import '../event.dart';

class XmlTextEvent extends XmlEvent {
  XmlTextEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  String toString() => '$runtimeType($text)';
}
