import '../../../xml.dart';
import '../resolver.dart';

class AncestorAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.ancestors);
}

class AncestorOrSelfAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => [node].followedBy(node.ancestors));
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
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.descendants);
}

class DescendantOrSelfAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => [node].followedBy(node.descendants));
}

class FollowingAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.following);
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
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.expand((node) => node.preceding);
}

class PrecedingSiblingAxisResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.expand((node) {
        final siblings = node.siblings.toList();
        final index = siblings.indexOf(node);
        return siblings.getRange(0, index - 1);
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
