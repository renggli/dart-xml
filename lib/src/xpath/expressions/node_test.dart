import 'package:meta/meta.dart';

import '../../xml/enums/node_type.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';

@immutable
sealed class NodeTest {
  bool matches(XmlNode node);
}

class CommentTypeNodeTest implements NodeTest {
  const CommentTypeNodeTest();

  @override
  bool matches(XmlNode node) => node.nodeType == XmlNodeType.COMMENT;
}

class NodeTypeNodeTest implements NodeTest {
  const NodeTypeNodeTest();

  @override
  bool matches(XmlNode node) => true;
}

class ProcessingTypeNodeTest implements NodeTest {
  const ProcessingTypeNodeTest(this.target);

  final String? target;

  @override
  bool matches(XmlNode node) =>
      node is XmlProcessing && (target == null || node.target == target);
}

class TextTypeNodeTest implements NodeTest {
  const TextTypeNodeTest();

  @override
  bool matches(XmlNode node) =>
      node.nodeType == XmlNodeType.TEXT || node.nodeType == XmlNodeType.CDATA;
}

class NameNodeTest implements NodeTest {
  const NameNodeTest();

  @override
  bool matches(XmlNode node) =>
      node is XmlHasName && matchesName(node as XmlHasName);

  bool matchesName(XmlHasName node) => true;
}

class QualifiedNameNodeTest extends NameNodeTest {
  const QualifiedNameNodeTest(this.qualifiedName);

  final String qualifiedName;

  @override
  bool matchesName(XmlHasName node) => node.qualifiedName == qualifiedName;
}

class NamespaceUriAndLocalNameNodeTest extends NameNodeTest {
  const NamespaceUriAndLocalNameNodeTest(this.namespaceUri, this.localName);

  final String namespaceUri;
  final String localName;

  @override
  bool matchesName(XmlHasName node) =>
      node.namespaceUri == namespaceUri && node.localName == localName;
}

class NamespacePrefixNameNodeTest extends NameNodeTest {
  const NamespacePrefixNameNodeTest(this.namespacePrefix);

  final String namespacePrefix;

  @override
  bool matchesName(XmlHasName node) => node.namespacePrefix == namespacePrefix;
}

class LocalNameNodeTest extends NameNodeTest {
  const LocalNameNodeTest(this.localName);

  final String localName;

  @override
  bool matchesName(XmlHasName node) => node.localName == localName;
}

class NamespaceUriNodeTest extends NameNodeTest {
  const NamespaceUriNodeTest(this.namespaceUri);

  final String namespaceUri;

  @override
  bool matchesName(XmlHasName node) => node.namespaceUri == namespaceUri;
}
