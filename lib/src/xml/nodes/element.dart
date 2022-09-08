import 'package:collection/collection.dart';

import '../enums/node_type.dart';
import '../mixins/has_attributes.dart';
import '../mixins/has_children.dart';
import '../mixins/has_name.dart';
import '../mixins/has_parent.dart';
import '../utils/name.dart';
import '../utils/namespace.dart';
import '../visitors/visitor.dart';
import 'attribute.dart';
import 'comment.dart';
import 'node.dart';
import 'text.dart';

/// XML element node.
class XmlElement extends XmlNode
    with
        XmlHasName,
        XmlHasParent<XmlNode>,
        XmlHasAttributes,
        XmlHasChildren<XmlNode> {
  /// Create an element node with the provided [name], [attributes], and
  /// [children].
  XmlElement(this.name,
      [Iterable<XmlAttribute> attributesIterable = const [],
      Iterable<XmlNode> childrenIterable = const [],
      this.isSelfClosing = true]) {
    name.attachParent(this);
    attributes.initialize(this, attributeNodeTypes);
    attributes.addAll(attributesIterable);
    children.initialize(this, childrenNodeTypes);
    children.addAll(childrenIterable);
  }

  /// Defines whether the element should be self-closing when empty.
  bool isSelfClosing;

  @override
  final XmlName name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  XmlElement copy() => XmlElement(
      name.copy(),
      attributes.map((each) => each.copy()),
      children.map((each) => each.copy()),
      isSelfClosing);

  @override
  void accept(XmlVisitor visitor) => visitor.visitElement(this);

  @override
  List<Object?> get comparable => [
        name,
        // when comparing two xml data models, it is not at all relevant how
        // particular namespaces are prefixed. Only the data should be compared.
        // Removing all namespace declarations hence
        attributes
            .whereNot(
              (attribute) =>
                  attribute.name.prefix == xmlns ||
                  (attribute.name.prefix == null &&
                      attribute.name.local == xmlns),
            )
            .toList()
          // the order of attributes does not affect the data structure
          ..sort(),
        // empty text nodes and comments are not relevant for the data structure
        children
            .whereNot(
              (element) =>
                  (element is XmlText && element.text.trim().isEmpty) ||
                  element is XmlComment,
            )
            .toList(),
        isSelfClosing,
      ];
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
