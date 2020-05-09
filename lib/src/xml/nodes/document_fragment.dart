library xml.nodes.document_fragment;

import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../mixins/has_children.dart';
import '../utils/exceptions.dart';
import '../utils/node_type.dart';
import '../visitors/visitor.dart';
import 'document.dart';
import 'node.dart';

/// XML document fragment node.
class XmlDocumentFragment extends XmlNode with XmlHasChildren {
  /// Return an [XmlDocumentFragment] for the given [input] string, or throws an
  /// [XmlParserException] if the input is invalid.
  ///
  /// Note: It is the responsibility of the caller to provide a standard Dart
  /// [String] using the default UTF-16 encoding.
  factory XmlDocumentFragment.parse(String input,
          {XmlEntityMapping entityMapping =
              const XmlDefaultEntityMapping.xml()}) =>
      XmlDocumentFragment(
          XmlDocument.parse(input, entityMapping: entityMapping).children);

  /// Create a document fragment node with `children`.
  XmlDocumentFragment([Iterable<XmlNode> childrenIterable = const []]) {
    children.initialize(this, childrenNodeTypes);
    children.addAll(childrenIterable);
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_FRAGMENT;

  @override
  dynamic accept(XmlVisitor visitor) => visitor.visitDocumentFragment(this);
}

/// Supported child node types.
const Set<XmlNodeType> childrenNodeTypes = {
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.DOCUMENT_TYPE,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
};
