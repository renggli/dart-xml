library xml_events.events.processing_event;

import 'package:xml/xml.dart' show XmlNodeType;

import '../event.dart';
import '../visitor.dart';

class XmlProcessingEvent extends XmlEvent {
  XmlProcessingEvent(this.target, this.text);

  final String target;

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitProcessingEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ text.hashCode ^ target.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlProcessingEvent &&
      other.target == target &&
      other.text == text;
}
