library xml.nodes.document_fragment;

import 'package:xml/xml/nodes/document.dart' show XmlDocument;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/nodes/parent.dart' show XmlParent;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML document fragment node.
class XmlDocumentFragment extends XmlParent {
  /// Create a document node with `children`.
  XmlDocumentFragment(Iterable<XmlNode> children) : super(children);

  @override
  XmlDocument get document => null;

  @override
  String get text => null;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_FRAGMENT;

  @override
  E accept<E>(XmlVisitor<E> visitor) => visitor.visitDocumentFragment(this);
}
