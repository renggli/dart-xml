import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML text node.
class XmlText extends XmlData {
  /// Create a text node with `text`.
  XmlText(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  XmlText copy() => XmlText(text);

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitText(this);
}
