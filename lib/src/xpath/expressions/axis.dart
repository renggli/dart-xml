import 'package:meta/meta.dart';

import '../../xml/enums/node_type.dart';
import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/following.dart';
import '../../xml/extensions/preceding.dart';
import '../../xml/extensions/sibling.dart';
import '../types/node.dart';

@immutable
sealed class Axis {
  /// Return all nodes selected by this axis in document order.
  Iterable<XPathNode> find(XPathNode node);
}

/// Marker interface for axes that are indexed in reverse document order. This
/// includes the ancestor, ancestor-or-self, preceding, and preceding-sibling
/// axes: https://www.w3.org/TR/1999/REC-xpath-19991116/#predicates
@immutable
sealed class ReverseAxis {}

class AncestorAxis implements Axis, ReverseAxis {
  const AncestorAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) => node.ancestors.toList().reversed;
}

class AncestorOrSelfAxis implements Axis, ReverseAxis {
  const AncestorOrSelfAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) =>
      node.ancestors.toList().reversed.followedBy([node]);
}

class AttributeAxis implements Axis {
  const AttributeAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) => node.attributes;
}

class ChildAxis implements Axis {
  const ChildAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) => node.children;
}

class DescendantAxis implements Axis {
  const DescendantAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) =>
      node.descendants.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE);
}

class DescendantOrSelfAxis implements Axis {
  const DescendantOrSelfAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) => [node].followedBy(
    node.descendants.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE),
  );
}

class FollowingAxis implements Axis {
  const FollowingAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) =>
      node.following.where((each) => each.nodeType != XmlNodeType.ATTRIBUTE);
}

class FollowingSiblingAxis implements Axis {
  const FollowingSiblingAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    return siblings.getRange(index + 1, siblings.length);
  }
}

class ParentAxis implements Axis, ReverseAxis {
  const ParentAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) {
    final parent = node.parent;
    return parent == null ? [] : [parent];
  }
}

class PrecedingAxis implements Axis, ReverseAxis {
  const PrecedingAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) {
    final ancestors = node.ancestors.toSet();
    return node.preceding.where(
      (each) =>
          !ancestors.contains(each) && each.nodeType != XmlNodeType.ATTRIBUTE,
    );
  }
}

class PrecedingSiblingAxis implements Axis, ReverseAxis {
  const PrecedingSiblingAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    return siblings.getRange(0, index);
  }
}

class SelfAxis implements Axis {
  const SelfAxis();

  @override
  Iterable<XPathNode> find(XPathNode node) => [node];
}
