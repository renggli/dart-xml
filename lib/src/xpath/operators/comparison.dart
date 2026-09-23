import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
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
  if (a is XPathAbstractDuration && b is XPathAbstractDuration) {
    return a == b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
  if ((a is XPathBase64Binary && b is XPathBase64Binary) ||
      (a is XPathHexBinary && b is XPathHexBinary)) {
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
  if (a is XPathAbstractDuration && b is XPathAbstractDuration) {
    return a != b ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  }
  if ((a is XPathBase64Binary && b is XPathBase64Binary) ||
      (a is XPathHexBinary && b is XPathHexBinary)) {
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
  final data = seq.atomize().toList();
  if (data.isEmpty) return null;
  if (data.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Sequence contains more than one item: (${data.join(', ')})',
    );
  }
  final item = data.first;
  if (item is XPathUntypedAtomic) {
    return XPathString(item.value);
  }
  return item;
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
  if (a is XPathAbstractDateTime && b is XPathAbstractDateTime) {
    return a.compareTo(b);
  }
  if (a is XPathYearMonthDuration && b is XPathYearMonthDuration) {
    return a.totalMonths.compareTo(b.totalMonths);
  }
  if (a is XPathDayTimeDuration && b is XPathDayTimeDuration) {
    return a.totalMicroseconds.compareTo(b.totalMicroseconds);
  }
  if (a is XPathHexBinary && b is XPathHexBinary) {
    return a.compareTo(b);
  }
  if (a is XPathBase64Binary && b is XPathBase64Binary) {
    return a.compareTo(b);
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Cannot compare ${a.type} and ${b.type}',
  );
}
