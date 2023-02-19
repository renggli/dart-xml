import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an XML comment node.
class XmlCommentEvent extends XmlEvent {
  XmlCommentEvent(this.value);

  final String value;

  @Deprecated('Use `XmlCommentEvent.value` instead.')
  String get text => value;

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitCommentEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, value);

  @override
  bool operator ==(Object other) =>
      other is XmlCommentEvent && other.value == value;
}
