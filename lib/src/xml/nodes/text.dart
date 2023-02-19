import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML text node.
class XmlText extends XmlData {
  /// Create a text node with `value`.
  XmlText(super.value);

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  XmlText copy() => XmlText(value);

  @override
  void accept(XmlVisitor visitor) => visitor.visitText(this);
}
