import 'package:meta/meta.dart';

import '../evaluation/context.dart';
import '../evaluation/expression.dart';
import '../evaluation/operators.dart';
import '../operators/comparison.dart' as comparison;
import '../operators/general.dart' as general;
import '../operators/node.dart' as nodes;
import '../xdm/atomic/numeric.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'function.dart';
import 'operators.dart';
import 'path.dart';
import 'sequence.dart';
import 'statement.dart';
import 'step.dart';
import 'types.dart';
import 'variable.dart';

@immutable
class Predicate {
  new(this.expression) : constantIndex = _extractConstantIndex(expression);

  final XPathExpression expression;

  /// Statically determined 1-based index if this predicate is a numeric constant:
  /// - positive integer (`>= 1`): exact 1-based index to match
  /// - `0`: numeric constant that can never match (`<= 0`, `NaN`, fractional)
  /// - `null`: dynamic or non-numeric expression
  final int? constantIndex;

  /// 1-based index if this predicate is a static numeric constant, or `null` otherwise.
  int? get staticPosition => constantIndex;

  /// Returns whether this predicate depends on context position or size,
  /// or can evaluate to a numeric value.
  bool get isPositional => _isPositional(expression);

  /// Returns whether this predicate is provably independent of context position or size,
  /// and does not evaluate to a numeric value.
  bool get isDefinitelyNonPositional => !isPositional;

  static int? _extractConstantIndex(XPathExpression expression) {
    if (expression is SequenceExpression &&
        expression.expressions.length == 1) {
      return _extractConstantIndex(expression.expressions.single);
    }
    if (expression is LiteralExpression) {
      final item = expression.value.singleOrNull;
      if (item is XPathNumeric) {
        if (item is XPathInteger) {
          final val = item.intValue;
          if (val != null) {
            return val > 0 ? val : 0;
          }
          return 0;
        }
        if (item is XPathDouble) {
          final d = item.value;
          if (d.isNaN || d.isInfinite || d <= 0) return 0;
          if (d == d.truncateToDouble()) {
            final val = d.toInt();
            return val > 0 ? val : 0;
          }
          return 0;
        }
        if (item is XPathDecimal) {
          if (item.scale == 0 && item.unscaledValue.isValidInt) {
            final val = item.unscaledValue.toInt();
            return val > 0 ? val : 0;
          }
          return 0;
        }
      }
    }
    return null;
  }

  bool matches(XPathContext context) {
    final value = expression(context);
    final item = value.singleOrNull;
    if (item is XPathNumeric) {
      if (item is XPathInteger) {
        return item.intValue == context.position;
      }
      return item.toDouble() == context.position.toDouble();
    }
    return value.effectiveBooleanValue;
  }
}

class PredicateExpression implements XPathExpression {
  const new(this.expression, this.predicate);

  final XPathExpression expression;
  final Predicate predicate;

  @override
  XPathSequence call(XPathContext context) {
    final constantIndex = predicate.constantIndex;
    if (constantIndex != null) {
      final items = expression(context);
      if (constantIndex <= 0) {
        return XPathSequence.empty;
      }
      final item = items.elementAtOrNull(constantIndex - 1);
      return item != null ? XPathSequence.single(item) : XPathSequence.empty;
    }
    final items = expression(context).toList();
    final inner = context.copy();
    inner.last = items.length;
    final matched = <XPathItem>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      inner.item = item;
      inner.position = i + 1;
      if (predicate.matches(inner)) {
        matched.add(item);
      }
    }
    return XPathSequence(matched);
  }
}

bool _isPositional(XPathExpression expression) =>
    _canBeNumeric(expression) || _dependsOnContextPosition(expression);

const _booleanBinaryOperators = <XPathBinaryOperator>{
  general.opGeneralEqual,
  general.opGeneralNotEqual,
  general.opGeneralLessThan,
  general.opGeneralGreaterThan,
  general.opGeneralLessThanOrEqual,
  general.opGeneralGreaterThanOrEqual,
  comparison.opValueEqual,
  comparison.opValueNotEqual,
  comparison.opValueLessThan,
  comparison.opValueGreaterThan,
  comparison.opValueLessThanOrEqual,
  comparison.opValueGreaterThanOrEqual,
  nodes.opNodeIs,
  nodes.opNodePrecedes,
  nodes.opNodeFollows,
  general.opAnd,
  general.opOr,
};

const _booleanFunctionNames = <String>{
  'not',
  'fn:not',
  'true',
  'fn:true',
  'false',
  'fn:false',
  'boolean',
  'fn:boolean',
  'empty',
  'fn:empty',
  'exists',
  'fn:exists',
  'contains',
  'fn:contains',
  'starts-with',
  'fn:starts-with',
  'ends-with',
  'fn:ends-with',
  'matches',
  'fn:matches',
};

bool _canBeNumeric(XPathExpression expression) {
  if (expression is LiteralExpression) {
    return expression.value.singleOrNull is XPathNumeric;
  }
  if (expression is BinaryOperatorExpression) {
    if (_booleanBinaryOperators.contains(expression.operator)) {
      return false;
    }
    if (expression.operator == nodes.opUnion ||
        expression.operator == nodes.opIntersect ||
        expression.operator == nodes.opExcept) {
      return false;
    }
    return true;
  }
  if (expression is StepExpression ||
      expression is PathExpression ||
      expression is RootNodeExpression ||
      expression is ContextItemExpression) {
    return false;
  }
  if (expression is StringConcatExpression ||
      expression is InstanceofExpression ||
      expression is CastableExpression ||
      expression is SomeExpression ||
      expression is EveryExpression) {
    return false;
  }
  if (expression is SequenceExpression) {
    return expression.expressions.any(_canBeNumeric);
  }
  if (expression is IfExpression) {
    return _canBeNumeric(expression.trueExpression) ||
        _canBeNumeric(expression.falseExpression);
  }
  if (expression is PredicateExpression) {
    return _canBeNumeric(expression.expression);
  }
  if (expression is FunctionExpression &&
      _booleanFunctionNames.contains(expression.name)) {
    return false;
  }
  return true;
}

bool _dependsOnContextPosition(XPathExpression expression) {
  if (expression is LiteralExpression ||
      expression is ContextItemExpression ||
      expression is RootNodeExpression ||
      expression is VariableExpression) {
    return false;
  }
  if (expression is FunctionExpression) {
    if (expression.name == 'position' ||
        expression.name == 'fn:position' ||
        expression.name == 'last' ||
        expression.name == 'fn:last') {
      return true;
    }
    return expression.arguments.any(_dependsOnContextPosition);
  }
  if (expression is BinaryOperatorExpression) {
    return _dependsOnContextPosition(expression.left) ||
        _dependsOnContextPosition(expression.right);
  }
  if (expression is UnaryOperatorExpression) {
    return _dependsOnContextPosition(expression.arg);
  }
  if (expression is StringConcatExpression) {
    return expression.expressions.any(_dependsOnContextPosition);
  }
  if (expression is StepExpression) {
    return false;
  }
  if (expression is PathExpression) {
    return expression.steps.any(_dependsOnContextPosition);
  }
  if (expression is SequenceExpression) {
    return expression.expressions.any(_dependsOnContextPosition);
  }
  if (expression is IfExpression) {
    return _dependsOnContextPosition(expression.condition) ||
        _dependsOnContextPosition(expression.trueExpression) ||
        _dependsOnContextPosition(expression.falseExpression);
  }
  if (expression is PredicateExpression) {
    return _dependsOnContextPosition(expression.expression) ||
        _dependsOnContextPosition(expression.predicate.expression);
  }
  return true;
}
