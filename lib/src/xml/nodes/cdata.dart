library xml.nodes.cdata;

import 'package:xml/src/xml/nodes/data.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/visitors/visitor.dart';

/// XML CDATA node.
class XmlCDATA extends XmlData {
  /// Create a CDATA section with `text`.
  XmlCDATA(String text) : super(text);

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitCDATA(this);
}
