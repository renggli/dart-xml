import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';

import '../types/sequence.dart';
import 'accessor.dart';

/// https://www.w3.org/TR/xpath-31/#doc-xpath31-ValueComp
XPathSequence opValueEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('eq', arguments, 2);
  final item1 = _atomizeSingle(context, arguments[0]);
  final item2 = _atomizeSingle(context, arguments[1]);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  return XPathSequence.single(item1 == item2);
}

XPathSequence opValueNotEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('ne', arguments, 2);
  final item1 = _atomizeSingle(context, arguments[0]);
  final item2 = _atomizeSingle(context, arguments[1]);
  if (item1 == null || item2 == null) return XPathSequence.empty;
  return XPathSequence.single(item1 != item2);
}

XPathSequence opValueLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('lt', arguments, 2);
  return _compareValue(
    context,
    arguments,
    (a, b) => a < b,
    (a, b) => a.compareTo(b) < 0,
  );
}

XPathSequence opValueLessThanOrEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('le', arguments, 2);
  return _compareValue(
    context,
    arguments,
    (a, b) => a <= b,
    (a, b) => a.compareTo(b) <= 0,
  );
}

XPathSequence opValueGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('gt', arguments, 2);
  return _compareValue(
    context,
    arguments,
    (a, b) => a > b,
    (a, b) => a.compareTo(b) > 0,
  );
}

XPathSequence opValueGreaterThanOrEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('ge', arguments, 2);
  return _compareValue(
    context,
    arguments,
    (a, b) => a >= b,
    (a, b) => a.compareTo(b) >= 0,
  );
}

Object? _atomizeSingle(XPathContext context, XPathSequence seq) {
  final data = fnData(context, [seq]);
  if (data.isEmpty) return null;
  if (data.length > 1) {
    throw XPathEvaluationException(
      'Sequence contains more than one item: $data',
    );
  }
  return data.first;
}

XPathSequence _compareValue(
  XPathContext context,
  List<XPathSequence> arguments,
  bool Function(num, num) numComparator,
  bool Function(String, String) stringComparator,
) {
  final item1 = _atomizeSingle(context, arguments[0]);
  final item2 = _atomizeSingle(context, arguments[1]);
  if (item1 == null || item2 == null) return XPathSequence.empty;

  if (item1 is num && item2 is num) {
    return XPathSequence.single(numComparator(item1, item2));
  } else if (item1 is String && item2 is String) {
    return XPathSequence.single(stringComparator(item1, item2));
  } else {
    throw XPathEvaluationException('Cannot compare $item1 and $item2');
  }
}
