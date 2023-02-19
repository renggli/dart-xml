import '../../xml/nodes/node.dart';
import '../resolver.dart';

class IndexPredicateResolver implements Resolver {
  IndexPredicateResolver(this.position);

  final int position;

  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) {
    final list = nodes.toList(growable: false);
    final index = position < 0 ? list.length + position : position - 1;
    return 0 <= index && index < list.length ? [list[index]] : [];
  }
}

class InnerPredicateResolver implements Resolver {
  InnerPredicateResolver(this.resolver, this.value);

  final Resolver resolver;

  final String? value;

  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) => nodes.where((node) {
        final result = resolver([node]);
        if (value == null) return result.isNotEmpty;
        return result.any((each) => each.value == value);
      });
}
