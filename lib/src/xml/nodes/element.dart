import '../../shared/names/name.dart';
import '../../shared/names/named.dart';
import '../enums/node_type.dart';
import '../mixins/has_attributes.dart';
import '../mixins/has_children.dart';
import '../mixins/has_parent.dart';
import '../visitors/visitor.dart';
import 'attribute.dart';
import 'node.dart';

/// XML element node.
class XmlElement extends XmlNode
    with
        XmlNamed,
        XmlHasParent<XmlNode>,
        XmlHasAttributes,
        XmlHasChildren<XmlNode> {
  /// Create an element node with the provided [name], [attributes], and
  /// [children].
  XmlElement(this.name, {
    Iterable<XmlAttribute> attributes = const [],
    Iterable<XmlNode> children = const [],
    this.isSelfClosing = true,
  }) {
    this.attributes.initialize(this, attributeNodeTypes);
    this.attributes.addAll(attributes);
    this.children.initialize(this, childrenNodeTypes);
    this.children.addAll(children);
  }

  /// Defines whether the element should be self-closing when empty.
  bool isSelfClosing;

  @override
  final XmlName name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  XmlElement copy() => XmlElement(name,
      attributes: attributes.map((each) => each.copy()),
      children: children.map((each) => each.copy()),
      isSelfClosing: isSelfClosing);

  @override
  void accept(XmlVisitor visitor) => visitor.visitElement(this);
}

/// Supported child node types.
const Set<XmlNodeType> childrenNodeTypes = {
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
};

/// Supported attribute node types.
const Set<XmlNodeType> attributeNodeTypes = {
  XmlNodeType.ATTRIBUTE,
};
