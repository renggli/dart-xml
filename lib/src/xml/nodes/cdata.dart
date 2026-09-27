import '../enums/node_type.dart';
import '../visitors/visitor.dart';
import 'data.dart';

/// XML CDATA node.
class XmlCDATA extends XmlData {
  /// Creates a CDATA section with [value].
  new(super.value);

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  XmlCDATA copy() => XmlCDATA(value);

  @override
  void accept(XmlVisitor visitor) => visitor.visitCDATA(this);
}
