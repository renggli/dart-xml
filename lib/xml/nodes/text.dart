library xml.nodes.text;

import 'package:xml/xml/nodes/data.dart' show XmlData;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML text node.
class XmlText extends XmlData {
  /// Create a text node with `text`.
  XmlText(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  E accept<E>(XmlVisitor<E> visitor) => visitor.visitText(this);
}
