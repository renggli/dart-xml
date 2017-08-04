library xml.nodes.cdata;

import 'package:xml/xml/nodes/data.dart' show XmlData;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML CDATA node.
class XmlCDATA extends XmlData {
  /// Create a CDATA section with `text`.
  XmlCDATA(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  E accept<E>(XmlVisitor<E> visitor) => visitor.visitCDATA(this);
}
