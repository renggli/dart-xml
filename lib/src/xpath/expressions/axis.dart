import 'package:meta/meta.dart';

import '../../xml/enums/node_type.dart';
import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/following.dart';
import '../../xml/extensions/preceding.dart';
import '../../xml/extensions/sibling.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';

/// Determines whether [node] is a recognized node in the XPath 3.1 Data Model (XDM).
bool isXPathNode(XmlNode node) => switch (node.nodeType) {
  XmlNodeType.DECLARATION ||
  XmlNodeType.DOCUMENT_TYPE ||
  XmlNodeType.ENTITY ||
  XmlNodeType.NOTATION => false,
  _ => true,
};

@immutable
sealed class Axis {
  /// Return all nodes selected by this axis in document order.
  Iterable<XmlNode> find(XmlNode node);
}

/// Marker interface for axes that are indexed in reverse document order. This
/// includes the ancestor, ancestor-or-self, preceding, and preceding-sibling
/// axes: https://www.w3.org/TR/1999/REC-xpath-19991116/#predicates
@immutable
sealed class ReverseAxis;

class AncestorAxis implements Axis, ReverseAxis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.ancestors.where(isXPathNode).toList().reversed;
}

class AncestorOrSelfAxis implements Axis, ReverseAxis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    final ancestors = node.ancestors.where(isXPathNode).toList().reversed;
    return isXPathNode(node) ? ancestors.followedBy([node]) : ancestors;
  }
}

class AttributeAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) =>
      node.attributes.where((attr) => !attr.isNamespaceDeclaration);
}

class ChildAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    final children = node.children;
    if (node is XmlDocument) {
      return children.where((child) => isXPathNode(child) && child is! XmlText);
    }
    return children.where(isXPathNode);
  }
}

class DescendantAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) => node.descendants.where(
    (XmlNode each) =>
        each.nodeType != XmlNodeType.ATTRIBUTE &&
        isXPathNode(each) &&
        (each.parent is! XmlDocument || each is! XmlText),
  );
}

class DescendantOrSelfAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) =>
      [if (isXPathNode(node)) node].followedBy(
        node.descendants.where(
          (XmlNode each) =>
              each.nodeType != XmlNodeType.ATTRIBUTE &&
              isXPathNode(each) &&
              (each.parent is! XmlDocument || each is! XmlText),
        ),
      );
}

class FollowingAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) => node.following.where(
    (XmlNode each) =>
        each.nodeType != XmlNodeType.ATTRIBUTE &&
        isXPathNode(each) &&
        (each.parent is! XmlDocument || each is! XmlText),
  );
}

class FollowingSiblingAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    final range = siblings.getRange(index + 1, siblings.length);
    if (node.parent is XmlDocument) {
      return range.where((each) => isXPathNode(each) && each is! XmlText);
    }
    return range.where(isXPathNode);
  }
}

class NamespaceAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    if (node is! XmlElement) return const [];
    return node.namespaces.map((ns) => ns.copy()..attachParent(node));
  }
}

class ParentAxis implements Axis, ReverseAxis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    final parent = node.parent;
    return parent != null && isXPathNode(parent) ? [parent] : const [];
  }
}

class PrecedingAxis implements Axis, ReverseAxis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    final ancestors = node.ancestors.toSet();
    return node.preceding.where(
      (XmlNode each) =>
          !ancestors.contains(each) &&
          each.nodeType != XmlNodeType.ATTRIBUTE &&
          isXPathNode(each) &&
          (each.parent is! XmlDocument || each is! XmlText),
    );
  }
}

class PrecedingSiblingAxis implements Axis, ReverseAxis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) {
    final siblings = node.siblings;
    final index = siblings.indexOf(node);
    final range = siblings.getRange(0, index);
    if (node.parent is XmlDocument) {
      return range.where((each) => isXPathNode(each) && each is! XmlText);
    }
    return range.where(isXPathNode);
  }
}

class SelfAxis implements Axis {
  const new();

  @override
  Iterable<XmlNode> find(XmlNode node) => isXPathNode(node) ? [node] : const [];
}
