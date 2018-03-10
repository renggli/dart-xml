library xml.nodes.doctype;

import 'package:xml/xml/nodes/data.dart' show XmlData;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML doctype node.
class XmlDoctype extends XmlData {
  /// Create a doctype section with `text`.
  XmlDoctype(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDoctype(this);
}
