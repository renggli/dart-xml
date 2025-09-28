import '../../xml/enums/node_type.dart';
import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/following.dart';
import '../../xml/extensions/preceding.dart';
import '../../xml/extensions/sibling.dart';
import '../../xml/nodes/node.dart';

sealed class Axis {
  Iterable<XmlNode> find(XmlNode node);
}

/// https://www.w3.org/TR/1999/REC-xpath-19991116/#predicates
/// The ancestor, ancestor-or-self, preceding, and preceding-sibling axes are reverse axes.
/// The proximity position of a member of a node-set with respect to an axis is defined to be the position of the node in the node-set
/// ordered in reverse document order if the axis is a reverse axis.
sealed class ReverseAxis implements Axis {}

class AncestorAxis extends ReverseAxis {
  @override
  Iterable<XmlNode> find(XmlNode node) => node.ancestors;
}

class AncestorOrSelfAxis extends ReverseAxis {
  @override
  Iterable<XmlNode> find(XmlNode node) => [node].followedBy(node.ancestors);
}

class PrecedingAxis extends ReverseAxis {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final ancestors = node.ancestors.toSet();
    return node.preceding
        .where(
          (each) =>
              !ancestors.contains(each) &&
              each.nodeType != XmlNodeType.ATTRIBUTE,
        )
        .toList()
        .reversed;
  }
}

class PrecedingSiblingAxis extends ReverseAxis {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    return siblings.getRange(0, index).toList().reversed;
  }
}

class SelfAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) => [node];
}

class AttributeAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) => node.attributes;
}

class ChildAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) => node.children;
}

class DescendantAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.descendants.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE);
}

class DescendantOrSelfAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) => [node].followedBy(
    node.descendants.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE),
  );
}

class FollowingAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.following.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE);
}

class FollowingSiblingAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    return siblings.getRange(index + 1, siblings.length);
  }
}

class ParentAxis extends Axis {
  @override
  Iterable<XmlNode> find(XmlNode node) {
    final parent = node.parent;
    return parent == null ? [] : [parent];
  }
}
