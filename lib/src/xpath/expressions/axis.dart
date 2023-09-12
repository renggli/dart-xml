import '../../../xml.dart';
import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';

abstract class AxisExpression implements XPathExpression {
  @override
  XPathValue call(XPathContext context) =>
      XPathNodeSet(find(context.node), isUnique: true, isSorted: true);

  Iterable<XmlNode> find(XmlNode node);
}

class AncestorAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) => node.ancestors.toList().reversed;
}

class AncestorOrSelfAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.ancestors.toList().reversed.followedBy([node]);
}

class AttributeAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) => node.attributes;
}

class ChildAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) => node.children;
}

class DescendantAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.descendants.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE);
}

class DescendantOrSelfAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) => [node].followedBy(
      node.descendants.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE));
}

class FollowingAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.following.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE);
}

class FollowingSiblingAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    return siblings.getRange(index + 1, siblings.length);
  }
}

class ParentAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final parent = node.parent;
    return parent == null ? [] : [parent];
  }
}

class PrecedingAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final ancestors = node.ancestors.toSet();
    return node.preceding.where((each) =>
        !ancestors.contains(each) && each.nodeType != XmlNodeType.ATTRIBUTE);
  }
}

class PrecedingSiblingAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    return siblings.getRange(0, index);
  }
}

class RootAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) => [node.root];
}

class SelfAxisExpression extends AxisExpression {
  @override
  Iterable<XmlNode> find(XmlNode node) => [node];
}
