library xml_events.events.comment_event;

import 'package:xml/xml.dart' show XmlNodeType;

import '../event.dart';
import '../visitor.dart';

class XmlCommentEvent extends XmlEvent {
  XmlCommentEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitCommentEvent(this);

  @override
  int get hashCode => text.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlCommentEvent && other.text == text;
}
