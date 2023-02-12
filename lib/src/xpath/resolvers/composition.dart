import '../../xml/nodes/node.dart';
import '../resolver.dart';

class SequenceResolver implements Resolver {
  SequenceResolver._(this.resolvers);

  static Resolver fromList(List<Resolver> resolvers) =>
      resolvers.length == 1 ? resolvers.single : SequenceResolver._(resolvers);

  final List<Resolver> resolvers;

  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => resolvers
      .fold<Iterable<XmlNode>>(nodes, (elements, current) => current(elements));
}
