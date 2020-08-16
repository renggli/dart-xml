import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML doctype node.
class XmlDoctype extends XmlData {
  /// Create a doctype section with `text`.
  XmlDoctype(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDoctype(this);
}
