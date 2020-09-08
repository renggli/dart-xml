import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML comment node.
class XmlComment extends XmlData {
  /// Create a comment section with `text`.
  XmlComment(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  XmlComment copy() => XmlComment(text);

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitComment(this);
}
