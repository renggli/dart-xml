import '../nodes/node.dart';

extension XmlNodesExtension on XmlNode {
  /// A lazy [Iterable] of the direct descendants of this [XmlNode]
  /// (attributes, children) in document order.
  Iterable<XmlNode> get nodes sync* {
    yield* attributes;
    yield* children;
  }
}
