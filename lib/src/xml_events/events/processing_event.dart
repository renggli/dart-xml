library xml_events.event.processing_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlProcessingEvent extends XmlEvent {
  XmlProcessingEvent(this.target, this.text);

  final String target;

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  dynamic accept(XmlEventVisitor visitor) => visitor.visitProcessingEvent(this);
}
