import '../../../xml.dart';
import '../context.dart';
import '../resolver.dart';
import '../values.dart';

class AncestorAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) => NodesValue(
      value.nodes.expand((node) => node.ancestors.toList().reversed));
}

class AncestorOrSelfAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) => NodesValue(value.nodes
      .expand((node) => node.ancestors.toList().reversed.followedBy([node])));
}

class AttributeAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) => node.attributes));
}

class ChildAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) => node.children));
}

class DescendantAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) => node.descendants
          .where((node) => node.nodeType != XmlNodeType.ATTRIBUTE)));
}

class DescendantOrSelfAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) => [node].followedBy(node.descendants
          .where((node) => node.nodeType != XmlNodeType.ATTRIBUTE))));
}

class FollowingAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) => node.following
          .where((node) => node.nodeType != XmlNodeType.ATTRIBUTE)));
}

class FollowingSiblingAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) {
        final siblings = node.siblings.toList();
        final index = siblings.indexOf(node);
        return siblings.getRange(index + 1, siblings.length);
      }));
}

class ParentAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.map((node) => node.parent).whereType<XmlNode>());
}

class PrecedingAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) {
        final ancestors = node.ancestors.toSet();
        return node.preceding.where((node) =>
            !ancestors.contains(node) &&
            node.nodeType != XmlNodeType.ATTRIBUTE);
      }));
}

class PrecedingSiblingAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.expand((node) {
        final siblings = node.siblings.toList();
        final index = siblings.indexOf(node);
        return siblings.getRange(0, index);
      }));
}

class RootAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.map((node) => node.root));
}

class SelfAxisResolver implements Resolver {
  @override
  Value call(Context context, Value value) => NodesValue(value.nodes);
}
