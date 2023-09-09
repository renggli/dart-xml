import '../context.dart';
import '../resolver.dart';
import '../values.dart';

class VariableOperator extends Resolver {
  VariableOperator(this.name);

  final String name;

  @override
  Value call(Context context, Value value) =>
      throw StateError('Unknown variable \$$name');
}

typedef Evaluator = Value Function(List<Value> args);

class FunctionResolver extends Resolver {
  FunctionResolver(this.args, this.evaluator);

  final List<Resolver> args;
  final Evaluator evaluator;

  @override
  Value call(Context context, Value value) =>
      evaluator(args.map((arg) => arg(context, value)).toList(growable: false));
}

typedef Lazy<T> = T Function();
typedef LazyEvaluator = Value Function(List<Lazy<Value>> args);

class LazyFunctionResolver extends Resolver {
  LazyFunctionResolver(this.args, this.evaluator);

  final List<Resolver> args;
  final LazyEvaluator evaluator;

  @override
  Value call(Context context, Value value) => evaluator(
      args.map((arg) => () => arg(context, value)).toList(growable: false));
}
