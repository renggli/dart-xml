library xml.nodes.element;

import '../utils/name.dart';
import '../utils/name_matcher.dart';
import '../utils/named.dart';
import '../utils/node_list.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'attribute.dart';
import 'node.dart';
import 'parent.dart';

/// XML element node.
class XmlElement extends XmlParent implements XmlNamed {
  /// Create an element node with the provided [name], [attributes], and
  /// [children].
  XmlElement(this.name,
      [Iterable<XmlAttribute> attributes = const [],
      Iterable<XmlNode> children = const [],
      this.isSelfClosing = true])
      : attributes = XmlNodeList(attributeNodeTypes),
        super(childrenNodeTypes, children) {
    this.name.attachParent(this);
    this.attributes.attachParent(this);
    this.attributes.addAll(attributes);
  }

  /// Return the name of the node.
  @override
  final XmlName name;

  /// Return the attribute nodes of this node.
  @override
  final XmlNodeList<XmlAttribute> attributes;

  /// Defines whether the element should be self-closing when empty.
  bool isSelfClosing;

  /// Return the attribute value with the given `name`.
  String getAttribute(String name, {String namespace}) {
    final attribute = getAttributeNode(name, namespace: namespace);
    return attribute != null ? attribute.value : null;
  }

  /// Return the attribute node with the given `name`.
  XmlAttribute getAttributeNode(String name, {String namespace}) => attributes
      .firstWhere(createNameMatcher(name, namespace), orElse: () => null);

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitElement(this);
}

/// Supported child node types.
final Set<XmlNodeType> childrenNodeTypes = Set.from(const [
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
]);

/// Supported attribute node types.
final Set<XmlNodeType> attributeNodeTypes = Set.from(const [
  XmlNodeType.ATTRIBUTE,
]);

/// Used during event based parsing to refer to the start of an [XmlElement].
class XmlStartElement extends XmlNode implements XmlNamed {
  XmlStartElement(this.name, this.attributes, this.isSelfClosing);

  @override
  final XmlName name;

  @override
  final List<XmlAttribute> attributes;

  final bool isSelfClosing;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitStartElement(this);

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;
}

/// Used during event based parsing to refer to the end of an [XmlElement].
class XmlEndElement extends XmlNode implements XmlNamed {
  XmlEndElement(this.name);

  @override
  final XmlName name;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitEndElement(this);

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;
}
