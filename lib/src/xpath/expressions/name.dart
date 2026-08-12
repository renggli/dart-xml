import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import 'node.dart';

/// Abstract superclass for all named node tests.
abstract class NameTest implements NodeTest {
  const new();

  @override
  bool matches(XmlNode node) =>
      node is XmlHasName && matchesName(node as XmlHasName);

  bool matchesName(XmlHasName node);
}

/// `*` matches any named node.
class NodeNameTest extends NameTest {
  const new();

  @override
  bool matchesName(XmlHasName node) => true;
}

/// `ns:name` matches a node with a fully qualified name.
class QualifiedNameTest extends NameTest {
  const new(this.qualifiedName);

  final String qualifiedName;

  @override
  bool matchesName(XmlHasName node) => node.qualifiedName == qualifiedName;
}

/// `Q{http://http://www.w3.org/1999/xhtml}body` matches a node with a namespace
/// URI and a local name.
class NamespaceUriAndLocalNameTest extends NameTest {
  const new(this.namespaceUri, this.localName);

  final String namespaceUri;
  final String localName;

  @override
  bool matchesName(XmlHasName node) =>
      node.namespaceUri == namespaceUri && node.localName == localName;
}

/// `xhtml:*` matches a node with a namespace prefix, ignoring the local name.
class NamespacePrefixNameTest extends NameTest {
  const new(this.namespacePrefix);

  final String namespacePrefix;

  @override
  bool matchesName(XmlHasName node) => node.namespacePrefix == namespacePrefix;
}

/// `*:person` matches a node with a local name, ignoring the namespace.
class LocalNameTest extends NameTest {
  const new(this.localName);

  final String localName;

  @override
  bool matchesName(XmlHasName node) => node.localName == localName;
}

/// `Q{http://http://www.w3.org/1999/xhtml}*` matches a node with a namespace
/// URI, ignoring the local name.
class NamespaceUriTest extends NameTest {
  const new(this.namespaceUri);

  final String namespaceUri;

  @override
  bool matchesName(XmlHasName node) => node.namespaceUri == namespaceUri;
}
