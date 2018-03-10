library xml.nodes.comment;

import 'package:xml/xml/nodes/data.dart' show XmlData;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML comment node.
class XmlComment extends XmlData {
  /// Create a comment section with `text`.
  XmlComment(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitComment(this);
}
