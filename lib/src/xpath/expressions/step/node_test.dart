import '../../../xml/enums/node_type.dart';
import '../../../xml/mixins/has_name.dart';
import '../../../xml/nodes/node.dart';
import '../../../xml/nodes/processing.dart';

sealed class NodeTest {
  bool matches(XmlNode node);
}

class CommentTypeNodeTest extends NodeTest {
  @override
  bool matches(XmlNode node) => node.nodeType == XmlNodeType.COMMENT;
}

class NodeTypeNodeTest extends NodeTest {
  @override
  bool matches(XmlNode node) => true;
}

class ProcessingTypeNodeTest extends NodeTest {
  ProcessingTypeNodeTest(this.target);

  final String? target;

  @override
  bool matches(XmlNode node) =>
      node is XmlProcessing && (target == null || node.target == target);
}

class TextTypeNodeTest extends NodeTest {
  @override
  bool matches(XmlNode node) =>
      node.nodeType == XmlNodeType.TEXT || node.nodeType == XmlNodeType.CDATA;
}

class HasNameNodeTest extends NodeTest {
  @override
  bool matches(XmlNode node) => node is XmlHasName;
}

class QualifiedNameNodeTest extends NodeTest {
  QualifiedNameNodeTest(this.qualifiedName);

  final String qualifiedName;

  @override
  bool matches(XmlNode node) =>
      node is XmlHasName && (node as XmlHasName).qualifiedName == qualifiedName;
}
