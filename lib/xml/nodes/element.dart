library xml.nodes.element;

import 'dart:collection';

import 'package:xml/xml/nodes/attribute.dart' show XmlAttribute;
import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/nodes/parent.dart' show XmlParent;
import 'package:xml/xml/utils/name.dart' show XmlName;
import 'package:xml/xml/utils/name_matcher.dart' show createNameMatcher;
import 'package:xml/xml/utils/named.dart' show XmlNamed;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// XML element node.
class XmlElement extends XmlParent implements XmlNamed {
  @override
  final XmlName name;

  @override
  final List<XmlAttribute> attributes;

  /// Create an [XmlElement] with the given `name`, `attributes`, and `children`.
  XmlElement(this.name, Iterable<XmlAttribute> attributes, Iterable<XmlNode> children)
      : attributes = new UnmodifiableListView(attributes.toList(growable: false)),
        super(children) {
    name.adoptParent(this);
    for (var attribute in this.attributes) {
      attribute.adoptParent(this);
    }
  }

  /// Return the attribute value with the given `name`.
  String getAttribute(String name, {String namespace}) {
    var attribute = getAttributeNode(name, namespace: namespace);
    return attribute != null ? attribute.value : null;
  }

  /// Return the attribute node with the given `name`.
  XmlAttribute getAttributeNode(String name, {String namespace}) =>
      attributes.firstWhere(createNameMatcher(name, namespace), orElse: () => null);

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  E accept<E>(XmlVisitor<E> visitor) => visitor.visitElement(this);
}
