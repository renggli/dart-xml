import '../../xml/enums/node_type.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';

abstract class NodePredicateExpression implements XPathExpression {
  @override
  XPathValue call(XPathContext context) =>
      XPathBoolean(matches(context, context.node));

  bool matches(XPathContext context, XmlNode node);
}

class CommentTypeExpression extends NodePredicateExpression {
  @override
  bool matches(XPathContext context, XmlNode node) =>
      node.nodeType == XmlNodeType.COMMENT;
}

class NodeTypeExpression extends NodePredicateExpression {
  @override
  bool matches(XPathContext context, XmlNode node) => true;
}

class ProcessingTypeExpression extends NodePredicateExpression {
  ProcessingTypeExpression(this.target);

  final String? target;

  @override
  bool matches(XPathContext context, XmlNode node) =>
      node is XmlProcessing && (target == null || node.target == target);
}

class TextTypeExpression extends NodePredicateExpression {
  @override
  bool matches(XPathContext context, XmlNode node) =>
      node.nodeType == XmlNodeType.TEXT || node.nodeType == XmlNodeType.CDATA;
}

class HasNameExpression extends NodePredicateExpression {
  @override
  bool matches(XPathContext context, XmlNode node) => node is XmlHasName;
}

class QualifiedNameExpression extends NodePredicateExpression {
  QualifiedNameExpression(this.qualifiedName);

  final String qualifiedName;

  @override
  bool matches(XPathContext context, XmlNode node) =>
      node is XmlHasName && (node as XmlHasName).qualifiedName == qualifiedName;
}
