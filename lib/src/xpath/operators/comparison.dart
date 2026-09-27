import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/functions/array.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueEqual(XPathSequence left, XPathSequence right) {
  final a = _atomizeSingle(left);
  final b = _atomizeSingle(right);
  if (a == null || b == null) return XPathSequence.empty;
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return XPathSequence.falseSequence;
  }
  if (a is XPathQName || b is XPathQName) {
    if (a is XPathQName && b is XPathQName) {
      return a == b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare $a and $b',
    );
  }
  if (a is XPathDuration && b is XPathDuration) {
    return a == b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
  if (a is XPathBinary && b is XPathBinary && a.type == b.type) {
    return a == b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
  return compare(a, b) == 0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueNotEqual(XPathSequence left, XPathSequence right) {
  final a = _atomizeSingle(left);
  final b = _atomizeSingle(right);
  if (a == null || b == null) return XPathSequence.empty;
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return XPathSequence.trueSequence;
  }
  if (a is XPathQName || b is XPathQName) {
    if (a is XPathQName && b is XPathQName) {
      return a != b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare $a and $b',
    );
  }
  if (a is XPathDuration && b is XPathDuration) {
    return a != b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
  if (a is XPathBinary && b is XPathBinary && a.type == b.type) {
    return a != b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
  return compare(a, b) != 0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueLessThan(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (c) => c < 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueLessThanOrEqual(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (c) => c <= 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueGreaterThan(XPathSequence left, XPathSequence right) =>
    _compareValue(left, right, (c) => c > 0);

/// https://www.w3.org/TR/xpath-31/#id-value-comparisons
XPathSequence opValueGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) => _compareValue(left, right, (c) => c >= 0);

XPathAtomic? _atomizeSingle(XPathSequence seq) {
  if (seq.isEmpty) return null;
  final single = seq.singleOrNull;
  if (single != null && single is! XPathArray) {
    if (single is XPathUntypedAtomic) {
      return XPathString(single.value);
    }
    if (single is XPathNode) {
      return XPathString(single.stringValue);
    }
    if (single is XPathAtomic) {
      return single;
    }
    return single.atomize();
  }
  final it = seq.atomize().iterator;
  if (!it.moveNext()) return null;
  final first = it.current;
  if (it.moveNext()) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Sequence contains more than one item',
    );
  }
  return first is XPathUntypedAtomic ? XPathString(first.value) : first;
}

XPathSequence _compareValue(
  XPathSequence left,
  XPathSequence right,
  bool Function(int) test,
) {
  final a = _atomizeSingle(left);
  final b = _atomizeSingle(right);
  if (a == null || b == null) return XPathSequence.empty;
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return XPathSequence.falseSequence;
  }
  if (a is XPathQName || b is XPathQName) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare QNames for order',
    );
  }
  return test(compare(a, b))
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// Compares two XPath atomic values.
int compare(XPathAtomic a, XPathAtomic b) {
  if (a is XPathNumeric && b is XPathNumeric) {
    return a.compareTo(b);
  }
  if (a is XPathString && b is XPathString) {
    return a.value.compareTo(b.value);
  }
  if (a is XPathAnyUri && b is XPathAnyUri) {
    return a.value.compareTo(b.value);
  }
  if ((a is XPathString && b is XPathAnyUri) ||
      (a is XPathAnyUri && b is XPathString)) {
    return a.stringValue.compareTo(b.stringValue);
  }
  if (a is XPathBoolean && b is XPathBoolean) {
    return a.compareTo(b);
  }
  if (a is XPathDateTime && b is XPathDateTime) {
    return a.compareTo(b);
  }
  if (a is XPathDuration && b is XPathDuration) {
    if (a.isYearMonth && b.isYearMonth) {
      return a.totalMonths.compareTo(b.totalMonths);
    }
    if (a.isDayTime && b.isDayTime) {
      return a.totalMicroseconds.compareTo(b.totalMicroseconds);
    }
  }
  if (a is XPathBinary && b is XPathBinary && a.type == b.type) {
    return a.compareTo(b);
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Cannot compare ${a.type} and ${b.type}',
  );
}
