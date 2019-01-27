library xml.nodes.doctype;

import 'package:xml/src/xml/nodes/data.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// XML doctype node.
class XmlDoctype extends XmlData {
  /// Create a doctype section with `text`.
  XmlDoctype(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDoctype(this);
}
