import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML comment node.
class XmlComment extends XmlData {
  /// Creates a comment node with [value].
  new(super.value);

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  XmlComment copy() => XmlComment(value);

  @override
  void accept(XmlVisitor visitor) => visitor.visitComment(this);
}
