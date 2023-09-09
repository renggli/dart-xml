import '../context.dart';
import '../resolver.dart';
import '../values.dart';

class SequenceResolver implements Resolver {
  SequenceResolver._(this.resolvers);

  static Resolver fromList(List<Resolver> resolvers) =>
      resolvers.length == 1 ? resolvers.single : SequenceResolver._(resolvers);

  final List<Resolver> resolvers;

  @override
  Value call(Context context, Value value) => resolvers.fold<Value>(
      value, (innerValue, current) => current(context, innerValue));
}
