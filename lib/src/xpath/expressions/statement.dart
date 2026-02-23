import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../types/sequence.dart';

typedef XPathBinding = ({String name, XPathExpression expression});

class ForExpression implements XPathExpression {
  const ForExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathSequence call(XPathContext context) {
    Iterable<Object> loop(int index, XPathContext currentContext) sync* {
      if (index < bindings.length) {
        final binding = bindings[index];
        final sequence = binding.expression(currentContext);
        for (final item in sequence) {
          final nextContext = currentContext.copy(
            variables: {binding.name: XPathSequence.single(item)},
          );
          yield* loop(index + 1, nextContext);
        }
      } else {
        yield* body(currentContext);
      }
    }

    return XPathSequence(loop(0, context));
  }
}

class LetExpression implements XPathExpression {
  const LetExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathSequence call(XPathContext context) {
    var inner = context;
    for (final binding in bindings) {
      inner = inner.copy(variables: {binding.name: binding.expression(inner)});
    }
    return body(inner);
  }
}

class SomeExpression implements XPathExpression {
  const SomeExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathSequence call(XPathContext context) {
    bool loop(int index, XPathContext currentContext) {
      if (index < bindings.length) {
        final binding = bindings[index];
        final sequence = binding.expression(currentContext);
        for (final item in sequence) {
          final nextContext = currentContext.copy(
            variables: {binding.name: XPathSequence.single(item)},
          );
          if (loop(index + 1, nextContext)) {
            return true;
          }
        }
        return false;
      } else {
        return body(currentContext).ebv;
      }
    }

    return loop(0, context)
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
}

class EveryExpression implements XPathExpression {
  const EveryExpression(this.bindings, this.body);

  final List<XPathBinding> bindings;
  final XPathExpression body;

  @override
  XPathSequence call(XPathContext context) {
    bool loop(int index, XPathContext currentContext) {
      if (index < bindings.length) {
        final binding = bindings[index];
        final sequence = binding.expression(currentContext);
        for (final item in sequence) {
          final nextContext = currentContext.copy(
            variables: {binding.name: XPathSequence.single(item)},
          );
          if (!loop(index + 1, nextContext)) {
            return false;
          }
        }
        return true;
      } else {
        return body(currentContext).ebv;
      }
    }

    return loop(0, context)
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
}

class IfExpression implements XPathExpression {
  const IfExpression(this.condition, this.trueExpression, this.falseExpression);

  final XPathExpression condition;
  final XPathExpression trueExpression;
  final XPathExpression falseExpression;

  @override
  XPathSequence call(XPathContext context) => condition(context).ebv
      ? trueExpression(context)
      : falseExpression(context);
}
