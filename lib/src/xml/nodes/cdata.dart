import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML CDATA node.
class XmlCDATA extends XmlData {
  /// Create a CDATA section with `text`.
  XmlCDATA(super.value);

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  XmlCDATA copy() => XmlCDATA(value);

  @override
  void accept(XmlVisitor visitor) => visitor.visitCDATA(this);
}
