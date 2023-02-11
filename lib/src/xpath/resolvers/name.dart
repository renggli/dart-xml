import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import '../resolver.dart';

class HasNameResolver implements Resolver {
  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((node) => node is XmlHasName && true);
}

class QualifiedNameResolver implements Resolver {
  QualifiedNameResolver(this.qualifiedName);

  final String qualifiedName;

  @override
  Iterable<XmlNode> call(Iterable<XmlNode> nodes) =>
      nodes.where((Object node) =>
          node is XmlHasName && node.qualifiedName == qualifiedName);
}
