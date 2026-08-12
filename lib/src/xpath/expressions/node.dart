import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/cdata.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import 'name.dart';

/// Abstract superclass for all node tests.
abstract class NodeTest {
  const new();

  bool matches(XmlNode node);
}

/// `node()` matches any node.
class NodeTypeTest extends NodeTest {
  const new();

  @override
  bool matches(XmlNode node) => true;
}

/// `text()` matches any text node.
class TextTypeTest extends NodeTest {
  const new();

  @override
  bool matches(XmlNode node) => node is XmlText || node is XmlCDATA;
}

/// `comment()` matches any comment node.
class CommentTypeTest extends NodeTest {
  const new();

  @override
  bool matches(XmlNode node) => node is XmlComment;
}

/// `namespace-node()` matches any namespace node.
class NamespaceNodeTypeTest extends NodeTest {
  const new();

  @override
  bool matches(XmlNode node) => node is XmlNamespace;
}

/// `element()` matches any element node.
class ElementTypeTest extends NodeTest {
  const new({this.nameTest});

  final NameTest? nameTest;

  @override
  bool matches(XmlNode node) =>
      node is XmlElement && (nameTest == null || nameTest!.matchesName(node));
}

/// `attribute()` matches any attribute node.
class AttributeTypeTest extends NodeTest {
  const new({this.nameTest});

  final NameTest? nameTest;

  @override
  bool matches(XmlNode node) =>
      node is XmlAttribute && (nameTest == null || nameTest!.matchesName(node));
}

/// `document-node()` matches any document node.
class DocumentTypeTest extends NodeTest {
  const new({this.rootElementTest});

  final ElementTypeTest? rootElementTest;

  @override
  bool matches(XmlNode node) =>
      node is XmlDocument &&
      (rootElementTest == null || rootElementTest!.matches(node.rootElement));
}

/// `processing-instruction()` matches any processing-instruction node.
class ProcessingTypeTest extends NodeTest {
  const new({this.target});

  final String? target;

  @override
  bool matches(XmlNode node) =>
      node is XmlProcessing && (target == null || target == node.target);
}

/// `schema-element()` an element node against a corresponding declaration.
class SchemaElementTypeTest extends NodeTest {
  const new();

  @override
  bool matches(XmlNode node) => throw UnimplementedError('SchemaElementTest');
}

/// `schema-attribute()` an attribute node against a corresponding declaration.
class SchemaAttributeTypeTest extends NodeTest {
  const new();

  @override
  bool matches(XmlNode node) => throw UnimplementedError('SchemaAttributeNode');
}
