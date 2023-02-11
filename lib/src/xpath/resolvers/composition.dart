import '../../xml/nodes/node.dart';
import '../resolver.dart';
import 'axis.dart';

class SequenceResolver implements Resolver {
  SequenceResolver._(this.resolvers);

  static Resolver fromList(List<Resolver> resolvers) => resolvers.isEmpty
      ? EmptyAxisResolver()
      : resolvers.length == 1
          ? resolvers.single
          : SequenceResolver._(resolvers);

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
