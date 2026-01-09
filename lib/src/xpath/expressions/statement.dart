import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/values.dart';

typedef XPathBinding = ({String name, XPathExpression expression});

class ForExpression implements XPathExpression {
  const ForExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathValue call(XPathContext context) => throw UnimplementedError();
}

class LetExpression implements XPathExpression {
  const LetExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathValue call(XPathContext context) {
    final inner = context.copy(variables: {...context.variables});
    for (final binding in bindings) {
      inner.variables[binding.name] = binding.expression(inner);
    }
    return body(inner);
  }
}

class SomeExpression implements XPathExpression {
  const SomeExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathValue call(XPathContext context) => throw UnimplementedError();
}

class EveryExpression implements XPathExpression {
  const EveryExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathValue call(XPathContext context) => throw UnimplementedError();
}

class IfExpression implements XPathExpression {
  const IfExpression(this.condition, this.trueExpression, this.falseExpression);

  final XPathExpression condition;
  final XPathExpression trueExpression;
  final XPathExpression falseExpression;

  @override
  XPathValue call(XPathContext context) => condition(context).boolean
      ? trueExpression(context)
      : falseExpression(context);
}
