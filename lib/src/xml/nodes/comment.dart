library xml.nodes.comment;

import 'package:xml/src/xml/nodes/data.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// XML comment node.
class XmlComment extends XmlData {
  /// Create a comment section with `text`.
  XmlComment(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.COMMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitComment(this);
}
