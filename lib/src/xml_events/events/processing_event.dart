library xml_events.events.processing_event;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType;

/// Event of an XML processing node.
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
