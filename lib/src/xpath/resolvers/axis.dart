import '../../../xml.dart';
import '../resolver.dart';

class AncestorAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.ancestors.toList().reversed);
}

class AncestorOrSelfAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes
      .expand((node) => node.ancestors.toList().reversed.followedBy([node]));
}

class AttributeAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.attributes);
}

class ChildAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.children);
}

class DescendantAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.expand((node) =>
      node.descendants.where((node) => node.nodeType != XmlNodeType.ATTRIBUTE));
}

class DescendantOrSelfAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => [node].followedBy(node.descendants
          .where((node) => node.nodeType != XmlNodeType.ATTRIBUTE)));
}

class FollowingAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.expand((node) =>
      node.following.where((node) => node.nodeType != XmlNodeType.ATTRIBUTE));
}

class FollowingSiblingAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.expand((node) {
        final siblings = node.siblings.toList();
        final index = siblings.indexOf(node);
        return siblings.getRange(index + 1, siblings.length);
      });
}

class ParentAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.map((node) => node.parent).whereType<XmlNode>();
}

class PrecedingAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.expand((node) {
        final ancestors = node.ancestors.toSet();
        return node.preceding.where((node) =>
            !ancestors.contains(node) &&
            node.nodeType != XmlNodeType.ATTRIBUTE);
      });
}

class PrecedingSiblingAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.expand((node) {
        final siblings = node.siblings.toList();
        final index = siblings.indexOf(node);
        return siblings.getRange(0, index);
      });
}

class RootAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.map((node) => node.root);
}

class SelfAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes;
}
