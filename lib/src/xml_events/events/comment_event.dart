library xml_events.events.comment_event;

import 'package:xml/xml.dart';

import '../event.dart';
import '../visitor.dart';

class XmlCommentEvent extends XmlEvent {
  XmlCommentEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  dynamic accept(XmlEventVisitor visitor) => visitor.visitCommentEvent(this);
}
