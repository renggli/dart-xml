import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML comment node.
class XmlComment extends XmlData {
  /// Create a comment section with `value`.
  XmlComment(super.value);

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  XmlComment copy() => XmlComment(value);

  @override
  void accept(XmlVisitor visitor) => visitor.visitComment(this);
}
