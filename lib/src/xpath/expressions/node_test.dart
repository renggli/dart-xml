import 'package:meta/meta.dart';

import '../../xml/enums/node_type.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';

@immutable
sealed class NodeTest {
  bool matches(XmlNode node);
}

/// `node()` matches any node.
class NodeTypeNodeTest implements NodeTest {
  const NodeTypeNodeTest();

  @override
  bool matches(XmlNode node) => true;
}

/// `text()` matches any text node.
class TextTypeNodeTest implements NodeTest {
  const TextTypeNodeTest();

  @override
  bool matches(XmlNode node) =>
      node.nodeType == XmlNodeType.TEXT || node.nodeType == XmlNodeType.CDATA;
}

/// `comment()` matches any comment node.
class CommentTypeNodeTest implements NodeTest {
  const CommentTypeNodeTest();

  @override
  bool matches(XmlNode node) => node.nodeType == XmlNodeType.COMMENT;
}

/// `element()` matches any element node.
class ElementTypeNodeTest implements NodeTest {
  const ElementTypeNodeTest();

  @override
  bool matches(XmlNode node) => node is XmlElement;
}

/// `attribute()` matches any attribute node.
class AttributeTypeNodeTest implements NodeTest {
  const AttributeTypeNodeTest();

  @override
  bool matches(XmlNode node) => node is XmlAttribute;
}

/// `document-node()` matches any document node.
class DocumentTypeNodeTest implements NodeTest {
  const DocumentTypeNodeTest();

  @override
  bool matches(XmlNode node) => node is XmlDocument;
}

/// `processing-instruction()` matches any processing-instruction node.
class ProcessingTypeNodeTest implements NodeTest {
  const ProcessingTypeNodeTest(this.target);

  final String? target;

  @override
  bool matches(XmlNode node) =>
      node is XmlProcessing && (target == null || node.target == target);
}

/// `*` matches any named node.
class NameNodeTest implements NodeTest {
  const NameNodeTest();

  @override
  bool matches(XmlNode node) =>
      node is XmlHasName && matchesName(node as XmlHasName);

  bool matchesName(XmlHasName node) => true;
}

/// `ns:name` matches a node with a fully qualified name.
class QualifiedNameNodeTest extends NameNodeTest {
  const QualifiedNameNodeTest(this.qualifiedName);

  final String qualifiedName;

  @override
  bool matchesName(XmlHasName node) => node.qualifiedName == qualifiedName;
}

/// `Q{http://http://www.w3.org/1999/xhtml}body` matches a node with a namespace
/// URI and a local name.
class NamespaceUriAndLocalNameNodeTest extends NameNodeTest {
  const NamespaceUriAndLocalNameNodeTest(this.namespaceUri, this.localName);

  final String namespaceUri;
  final String localName;

  @override
  bool matchesName(XmlHasName node) =>
      node.namespaceUri == namespaceUri && node.localName == localName;
}

/// `xhtml:*` matches a node with a namespace prefix, ignoring the local name.
class NamespacePrefixNameNodeTest extends NameNodeTest {
  const NamespacePrefixNameNodeTest(this.namespacePrefix);

  final String namespacePrefix;

  @override
  bool matchesName(XmlHasName node) => node.namespacePrefix == namespacePrefix;
}

/// `*:person` matches a node with a local name, ignoring the namespace.
class LocalNameNodeTest extends NameNodeTest {
  const LocalNameNodeTest(this.localName);

  final String localName;

  @override
  bool matchesName(XmlHasName node) => node.localName == localName;
}

/// `Q{http://http://www.w3.org/1999/xhtml}*` matches a node with a namespace
/// URI, ignoring the local name.
class NamespaceUriNodeTest extends NameNodeTest {
  const NamespaceUriNodeTest(this.namespaceUri);

  final String namespaceUri;

  @override
  bool matchesName(XmlHasName node) => node.namespaceUri == namespaceUri;
}
