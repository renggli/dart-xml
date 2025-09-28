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

class HasNameNodeTest implements NodeTest {
  const HasNameNodeTest();

  @override
  bool matches(XmlNode node) => node is XmlHasName;
}

class QualifiedNameNodeTest implements NodeTest {
  const QualifiedNameNodeTest(this.qualifiedName);

  final String qualifiedName;

  @override
  bool matches(XmlNode node) =>
      node is XmlHasName && (node as XmlHasName).qualifiedName == qualifiedName;
}
