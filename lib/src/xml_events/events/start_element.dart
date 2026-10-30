import 'package:collection/collection.dart' show ListEquality;

import '../../xml/enums/node_type.dart';
import '../annotations/has_name.dart';
import '../event.dart';
import '../utils/event_attribute.dart';
import '../visitor.dart';

/// Event of an XML start element node.
class XmlStartElementEvent extends XmlEvent with XmlHasName {
  /// Creates a start element event with [name], [attributes], and [isSelfClosing].
  new(this.name, this.attributes, this.isSelfClosing);

  @override
  final String name;

  /// The attributes of this start element.
  final List<XmlEventAttribute> attributes;

  /// Whether the start element is self-closing.
  final bool isSelfClosing;

  /// Returns the attribute value with the given [name], or `null`.
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to
  /// match anything. If no [namespaceUri] is provided, the fully qualified
  /// name is compared; otherwise only the local name is considered.
  String? getAttribute(String name, {String? namespaceUri}) =>
      getAttributeNode(name, namespaceUri: namespaceUri)?.value;

  /// Returns the attribute event with the given [name], or `null`.
  ///
  /// Both [name] and [namespaceUri] can be a specific [String]; or `'*'` to
  /// match anything. If no [namespaceUri] is provided, the fully qualified
  /// name is compared; otherwise only the local name is considered.
  XmlEventAttribute? getAttributeNode(String name, {String? namespaceUri}) {
    for (final attribute in attributes) {
      if (name == '*') {
        if (namespaceUri == null || namespaceUri == '*') {
          return attribute;
        } else if (attribute.namespaceUri == namespaceUri) {
          return attribute;
        }
      } else {
        if (namespaceUri == null) {
          if (attribute.qualifiedName == name) return attribute;
        } else if (namespaceUri == '*') {
          if (attribute.localName == name) return attribute;
        } else {
          if (attribute.localName == name &&
              attribute.namespaceUri == namespaceUri) {
            return attribute;
          }
        }
      }
    }
    return null;
  }

  /// Whether this element has an attribute with the given [name] and optional [namespaceUri].
  bool hasAttribute(String name, {String? namespaceUri}) =>
      getAttributeNode(name, namespaceUri: namespaceUri) != null;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitStartElementEvent(this);

  @override
  int get hashCode => Object.hash(
    nodeType,
    name,
    isSelfClosing,
    const ListEquality<XmlEventAttribute>().hash(attributes),
  );

  @override
  bool operator ==(Object other) =>
      other is XmlStartElementEvent &&
      other.name == name &&
      other.isSelfClosing == isSelfClosing &&
      const ListEquality<XmlEventAttribute>().equals(
        other.attributes,
        attributes,
      );
}
