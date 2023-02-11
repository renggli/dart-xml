import '../../xml/nodes/node.dart';
import '../resolver.dart';

class SequenceResolver implements Resolver {
  SequenceResolver(this.resolvers);

  final List<Resolver> resolvers;

  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => resolvers
      .fold<Iterable<XmlNode>>(nodes, (elements, current) => current(elements));
}

class DeduplicateResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.toSet().toList(growable: false);
}
