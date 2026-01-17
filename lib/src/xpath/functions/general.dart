import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/boolean.dart';
import '../types/sequence.dart';
import 'accessor.dart';

/// https://www.w3.org/TR/xpath-31/#doc-xpath31-AndExpr
XPathSequence opAnd(XPathContext context, List<XPathSequence> arguments) {
  for (final argument in arguments) {
    if (!argument.toXPathBoolean()) {
      return XPathSequence.falseSequence;
    }
  }
  return XPathSequence.trueSequence;
}

/// https://www.w3.org/TR/xpath-31/#doc-xpath31-OrExpr
XPathSequence opOr(XPathContext context, List<XPathSequence> arguments) {
  for (final argument in arguments) {
    if (argument.toXPathBoolean()) {
      return XPathSequence.trueSequence;
    }
  }
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-31/#doc-xpath31-GeneralComp
XPathSequence opGeneralEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('=', arguments, 2);
  final seq1 = fnData(context, [arguments[0]]);
  final seq2 = fnData(context, [arguments[1]]);
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      if (item1 == item2) return XPathSequence.trueSequence;
      // TODO: Type promotion and more complex comparison rules
      if (item1.toString() == item2.toString()) {
        return XPathSequence.trueSequence;
      }
    }
  }
  return XPathSequence.falseSequence;
}

XPathSequence opGeneralNotEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('!=', arguments, 2);
  final seq1 = fnData(context, [arguments[0]]);
  final seq2 = fnData(context, [arguments[1]]);
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      if (item1 != item2) return XPathSequence.trueSequence;
      // TODO: Type promotion and more complex comparison rules
      if (item1.toString() != item2.toString()) {
        return XPathSequence.trueSequence;
      }
    }
  }
  return XPathSequence.falseSequence;
}

XPathSequence opGeneralLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('<', arguments, 2);
  return _compareGeneral(context, arguments, (a, b) => a < b);
}

XPathSequence opGeneralGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('>', arguments, 2);
  return _compareGeneral(context, arguments, (a, b) => a > b);
}

XPathSequence opGeneralLessThanOrEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('<=', arguments, 2);
  return _compareGeneral(context, arguments, (a, b) => a <= b);
}

XPathSequence opGeneralGreaterThanOrEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('>=', arguments, 2);
  return _compareGeneral(context, arguments, (a, b) => a >= b);
}

XPathSequence _compareGeneral(
  XPathContext context,
  List<XPathSequence> arguments,
  bool Function(num, num) comparator,
) {
  final seq1 = fnData(context, [arguments[0]]);
  final seq2 = fnData(context, [arguments[1]]);
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      if (item1 is num && item2 is num) {
        if (comparator(item1, item2)) return XPathSequence.trueSequence;
      }
      // TODO: String comparison, etc.
    }
  }
  return XPathSequence.falseSequence;
}
