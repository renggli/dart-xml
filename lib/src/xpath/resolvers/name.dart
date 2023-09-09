import '../../xml/mixins/has_name.dart';
import '../context.dart';
import '../resolver.dart';
import '../values.dart';

class HasNameResolver implements Resolver {
  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.where((node) => node is XmlHasName && true));
}

class QualifiedNameResolver implements Resolver {
  QualifiedNameResolver(this.qualifiedName);

  final String qualifiedName;

  @override
  Value call(Context context, Value value) =>
      NodesValue(value.nodes.where((Object node) =>
          node is XmlHasName && node.qualifiedName == qualifiedName));
}
