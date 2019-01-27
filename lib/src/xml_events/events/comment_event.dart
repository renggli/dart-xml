library xml_events.events.comment_event;

import 'package:xml/src/xml_events/event.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType;

/// Event of an XML comment node.
class XmlCommentEvent extends XmlEvent {
  XmlCommentEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitCommentEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ text.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlCommentEvent && other.text == text;
}
