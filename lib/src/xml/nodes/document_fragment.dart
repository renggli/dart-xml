library xml.nodes.document_fragment;

import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'document.dart';
import 'node.dart';
import 'parent.dart';

/// XML document fragment node.
class XmlDocumentFragment extends XmlParent {
  /// Create a document fragment node with `children`.
  XmlDocumentFragment([Iterable<XmlNode> children = const []])
      : super(childrenNodeTypes, children);

  @override
  XmlDocument get document => null;

  @override
  String get text => null;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_FRAGMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDocumentFragment(this);
}

/// Supported child node types.
final Set<XmlNodeType> childrenNodeTypes = Set.from(const [
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.DOCUMENT_TYPE,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
]);
