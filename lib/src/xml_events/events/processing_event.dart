library xml_events.events.processing_event;

import 'package:xml/xml/utils/node_type.dart';

import '../event.dart';

class XmlProcessingEvent extends XmlEvent {
  XmlProcessingEvent(this.target, this.text);

  final String target;

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  String toString() => '$runtimeType($target, $text)';
}
