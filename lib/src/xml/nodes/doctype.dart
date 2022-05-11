import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML doctype node.
class XmlDoctype extends XmlData {
  /// Create a doctype section with `text`.
  XmlDoctype(super.text);

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  XmlDoctype copy() => XmlDoctype(text);

  @override
  void accept(XmlVisitor visitor) => visitor.visitDoctype(this);
}
