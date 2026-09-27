import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/casting_matrix.dart';
import '../xdm/functions/array.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';
import 'comparison.dart';

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opAnd(XPathSequence left, XPathSequence right) =>
    left.ebv && right.ebv
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-31/#id-logical-expressions
XPathSequence opOr(XPathSequence left, XPathSequence right) =>
    left.ebv || right.ebv
    ? XPathSequence.trueSequence
    : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;
  final item1 = left.singleOrNull;
  final item2 = right.singleOrNull;
  if (item1 != null &&
      item2 != null &&
      item1 is! XPathArray &&
      item2 is! XPathArray) {
    return _generalEqualSingle(item1.atomize(), item2.atomize());
  }
  return _compareGeneral(left, right, _generalEqual);
}

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralNotEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;
  final item1 = left.singleOrNull;
  final item2 = right.singleOrNull;
  if (item1 != null &&
      item2 != null &&
      item1 is! XPathArray &&
      item2 is! XPathArray) {
    return _generalNotEqualSingle(item1.atomize(), item2.atomize());
  }
  return _compareGeneral(left, right, _generalNotEqual);
}

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;
  final item1 = left.singleOrNull;
  final item2 = right.singleOrNull;
  if (item1 != null &&
      item2 != null &&
      item1 is! XPathArray &&
      item2 is! XPathArray) {
    return _generalRelationalSingle(
      item1.atomize(),
      item2.atomize(),
      _RelationalOp.lt,
    );
  }
  return _compareGeneral(left, right, _generalLessThan);
}

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;
  final item1 = left.singleOrNull;
  final item2 = right.singleOrNull;
  if (item1 != null &&
      item2 != null &&
      item1 is! XPathArray &&
      item2 is! XPathArray) {
    return _generalRelationalSingle(
      item1.atomize(),
      item2.atomize(),
      _RelationalOp.gt,
    );
  }
  return _compareGeneral(left, right, _generalGreaterThan);
}

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;
  final item1 = left.singleOrNull;
  final item2 = right.singleOrNull;
  if (item1 != null &&
      item2 != null &&
      item1 is! XPathArray &&
      item2 is! XPathArray) {
    return _generalRelationalSingle(
      item1.atomize(),
      item2.atomize(),
      _RelationalOp.le,
    );
  }
  return _compareGeneral(left, right, _generalLessThanOrEqual);
}

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;
  final item1 = left.singleOrNull;
  final item2 = right.singleOrNull;
  if (item1 != null &&
      item2 != null &&
      item1 is! XPathArray &&
      item2 is! XPathArray) {
    return _generalRelationalSingle(
      item1.atomize(),
      item2.atomize(),
      _RelationalOp.ge,
    );
  }
  return _compareGeneral(left, right, _generalGreaterThanOrEqual);
}

enum _RelationalOp { lt, le, gt, ge }

XPathSequence _applyRelational(int c, _RelationalOp op) {
  final match = switch (op) {
    _RelationalOp.lt => c < 0,
    _RelationalOp.le => c <= 0,
    _RelationalOp.gt => c > 0,
    _RelationalOp.ge => c >= 0,
  };
  return match ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

bool _generalEqual(XPathAtomic a, XPathAtomic b) {
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return false;
  }
  if (a is XPathQName && b is XPathQName) {
    return a == b;
  }
  if (a is XPathDuration && b is XPathDuration) {
    return a == b;
  }
  if (a is XPathBinary && b is XPathBinary && a.type == b.type) {
    return a == b;
  }
  return compare(a, b) == 0;
}

bool _generalNotEqual(XPathAtomic a, XPathAtomic b) {
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return true;
  }
  if (a is XPathQName && b is XPathQName) {
    return a != b;
  }
  if (a is XPathDuration && b is XPathDuration) {
    return a != b;
  }
  if (a is XPathBinary && b is XPathBinary && a.type == b.type) {
    return a != b;
  }
  return compare(a, b) != 0;
}

bool _generalLessThan(XPathAtomic a, XPathAtomic b) {
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return false;
  }
  if (a is XPathQName || b is XPathQName) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare QNames for order',
    );
  }
  return compare(a, b) < 0;
}

bool _generalGreaterThan(XPathAtomic a, XPathAtomic b) {
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return false;
  }
  if (a is XPathQName || b is XPathQName) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare QNames for order',
    );
  }
  return compare(a, b) > 0;
}

bool _generalLessThanOrEqual(XPathAtomic a, XPathAtomic b) {
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return false;
  }
  if (a is XPathQName || b is XPathQName) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare QNames for order',
    );
  }
  return compare(a, b) <= 0;
}

bool _generalGreaterThanOrEqual(XPathAtomic a, XPathAtomic b) {
  if (a is XPathDouble && a.value.isNaN || b is XPathDouble && b.value.isNaN) {
    return false;
  }
  if (a is XPathQName || b is XPathQName) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare QNames for order',
    );
  }
  return compare(a, b) >= 0;
}

XPathSequence _generalEqualSingle(XPathAtomic a, XPathAtomic b) {
  if (a is XPathUntypedAtomic && b is XPathUntypedAtomic) {
    return a.value == b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathUntypedAtomic && (b is XPathString || b is XPathAnyUri)) {
    return a.value == b.stringValue
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (b is XPathUntypedAtomic && (a is XPathString || a is XPathAnyUri)) {
    return a.stringValue == b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathUntypedAtomic && b is XPathNumeric) {
    return _untypedNumericEqual(a, b);
  }
  if (b is XPathUntypedAtomic && a is XPathNumeric) {
    return _untypedNumericEqual(b, a);
  }
  if (a is XPathInteger && b is XPathInteger) {
    if (a.intValue != null && b.intValue != null) {
      return a.equalsInt(b.intValue!)
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence;
    }
    return a.value == b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathDouble && b is XPathDouble) {
    if (a.value.isNaN || b.value.isNaN) return XPathSequence.falseSequence;
    return a.value == b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathString && b is XPathString) {
    return a.value == b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathBoolean && b is XPathBoolean) {
    return a.value == b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  var c1 = a;
  var c2 = b;
  if (c1 is XPathUntypedAtomic) {
    c1 = _coerceUntyped(c1, c2);
  } else if (c2 is XPathUntypedAtomic) {
    c2 = _coerceUntyped(c2, c1);
  } else {
    _validateComparableTypes(c1, c2);
  }
  return _generalEqual(c1, c2)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence _generalNotEqualSingle(XPathAtomic a, XPathAtomic b) {
  if (a is XPathUntypedAtomic && b is XPathUntypedAtomic) {
    return a.value != b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathUntypedAtomic && (b is XPathString || b is XPathAnyUri)) {
    return a.value != b.stringValue
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (b is XPathUntypedAtomic && (a is XPathString || a is XPathAnyUri)) {
    return a.stringValue != b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathUntypedAtomic && b is XPathNumeric) {
    return _untypedNumericNotEqual(a, b);
  }
  if (b is XPathUntypedAtomic && a is XPathNumeric) {
    return _untypedNumericNotEqual(b, a);
  }
  if (a is XPathInteger && b is XPathInteger) {
    if (a.intValue != null && b.intValue != null) {
      return !a.equalsInt(b.intValue!)
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence;
    }
    return a.value != b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathDouble && b is XPathDouble) {
    if (a.value.isNaN || b.value.isNaN) return XPathSequence.trueSequence;
    return a.value != b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathString && b is XPathString) {
    return a.value != b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  if (a is XPathBoolean && b is XPathBoolean) {
    return a.value != b.value
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  var c1 = a;
  var c2 = b;
  if (c1 is XPathUntypedAtomic) {
    c1 = _coerceUntyped(c1, c2);
  } else if (c2 is XPathUntypedAtomic) {
    c2 = _coerceUntyped(c2, c1);
  } else {
    _validateComparableTypes(c1, c2);
  }
  return _generalNotEqual(c1, c2)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence _generalRelationalSingle(
  XPathAtomic a,
  XPathAtomic b,
  _RelationalOp op,
) {
  if (a is XPathQName || b is XPathQName) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot compare QNames for order',
    );
  }
  if (a is XPathUntypedAtomic && b is XPathUntypedAtomic) {
    return _applyRelational(a.value.compareTo(b.value), op);
  }
  if (a is XPathUntypedAtomic && (b is XPathString || b is XPathAnyUri)) {
    return _applyRelational(a.value.compareTo(b.stringValue), op);
  }
  if (b is XPathUntypedAtomic && (a is XPathString || a is XPathAnyUri)) {
    return _applyRelational(a.stringValue.compareTo(b.value), op);
  }
  if (a is XPathUntypedAtomic && b is XPathNumeric) {
    return _untypedNumericRelational(a, b, op, reversed: false);
  }
  if (b is XPathUntypedAtomic && a is XPathNumeric) {
    return _untypedNumericRelational(b, a, op, reversed: true);
  }
  if (a is XPathInteger && b is XPathInteger) {
    if (a.intValue != null && b.intValue != null) {
      return _applyRelational(a.intValue!.compareTo(b.intValue!), op);
    }
    return _applyRelational(a.value.compareTo(b.value), op);
  }
  if (a is XPathDouble && b is XPathDouble) {
    if (a.value.isNaN || b.value.isNaN) return XPathSequence.falseSequence;
    if (a.value == b.value) return _applyRelational(0, op);
    return _applyRelational(a.value.compareTo(b.value), op);
  }
  if (a is XPathString && b is XPathString) {
    return _applyRelational(a.value.compareTo(b.value), op);
  }
  if (a is XPathBoolean && b is XPathBoolean) {
    return _applyRelational(a.compareTo(b), op);
  }
  var c1 = a;
  var c2 = b;
  if (c1 is XPathUntypedAtomic) {
    c1 = _coerceUntyped(c1, c2);
  } else if (c2 is XPathUntypedAtomic) {
    c2 = _coerceUntyped(c2, c1);
  } else {
    _validateComparableTypes(c1, c2);
  }
  if (c1 is XPathDouble && c1.value.isNaN ||
      c2 is XPathDouble && c2.value.isNaN) {
    return XPathSequence.falseSequence;
  }
  return _applyRelational(compare(c1, c2), op);
}

XPathSequence _untypedNumericEqual(
  XPathUntypedAtomic untyped,
  XPathNumeric numeric,
) {
  final trimmed = untyped.value.trim();
  final d = double.tryParse(trimmed);
  if (d != null) {
    if (d.isNaN) return XPathSequence.falseSequence;
    final targetD = numeric.toDouble();
    if (targetD.isNaN) return XPathSequence.falseSequence;
    return d == targetD
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  final parsed = XPathDouble.tryParse(trimmed);
  if (parsed == null) {
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Cannot cast "${untyped.value}" to xs:double',
    );
  }
  if (parsed.value.isNaN) return XPathSequence.falseSequence;
  final targetD = numeric.toDouble();
  if (targetD.isNaN) return XPathSequence.falseSequence;
  return parsed.value == targetD
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence _untypedNumericNotEqual(
  XPathUntypedAtomic untyped,
  XPathNumeric numeric,
) {
  final trimmed = untyped.value.trim();
  final d = double.tryParse(trimmed);
  if (d != null) {
    if (d.isNaN) return XPathSequence.trueSequence;
    final targetD = numeric.toDouble();
    if (targetD.isNaN) return XPathSequence.trueSequence;
    return d != targetD
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  }
  final parsed = XPathDouble.tryParse(trimmed);
  if (parsed == null) {
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Cannot cast "${untyped.value}" to xs:double',
    );
  }
  if (parsed.value.isNaN) return XPathSequence.trueSequence;
  final targetD = numeric.toDouble();
  if (targetD.isNaN) return XPathSequence.trueSequence;
  return parsed.value != targetD
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence _untypedNumericRelational(
  XPathUntypedAtomic untyped,
  XPathNumeric numeric,
  _RelationalOp op, {
  required bool reversed,
}) {
  final trimmed = untyped.value.trim();
  final d = double.tryParse(trimmed);
  double da;
  if (d != null) {
    da = d;
  } else {
    final parsed = XPathDouble.tryParse(trimmed);
    if (parsed == null) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Cannot cast "${untyped.value}" to xs:double',
      );
    }
    da = parsed.value;
  }
  final targetD = numeric.toDouble();
  if (da.isNaN || targetD.isNaN) return XPathSequence.falseSequence;
  if (da == targetD) {
    return _applyRelational(0, op);
  }
  final c = reversed ? targetD.compareTo(da) : da.compareTo(targetD);
  return _applyRelational(c, op);
}

XPathSequence _compareGeneral(
  XPathSequence left,
  XPathSequence right,
  bool Function(XPathAtomic, XPathAtomic) comparator,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.falseSequence;

  final seq1 = left.atomize().toList();
  final seq2 = right.atomize().toList();
  if (seq1.isEmpty || seq2.isEmpty) return XPathSequence.falseSequence;

  Object? typeError;
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      try {
        if (_comparePair(item1, item2, comparator)) {
          return XPathSequence.trueSequence;
        }
      } catch (error) {
        typeError ??= error;
      }
    }
  }
  if (typeError != null) throw typeError;
  return XPathSequence.falseSequence;
}

bool _comparePair(
  XPathAtomic a,
  XPathAtomic b,
  bool Function(XPathAtomic, XPathAtomic) comparator,
) {
  var c1 = a;
  var c2 = b;
  if (c1 is XPathUntypedAtomic && c2 is XPathUntypedAtomic) {
    c1 = XPathString(c1.value);
    c2 = XPathString(c2.value);
  } else if (c1 is XPathUntypedAtomic) {
    c1 = _coerceUntyped(c1, c2);
  } else if (c2 is XPathUntypedAtomic) {
    c2 = _coerceUntyped(c2, c1);
  } else {
    _validateComparableTypes(c1, c2);
  }
  return comparator(c1, c2);
}

XPathAtomic _coerceUntyped(XPathUntypedAtomic untyped, XPathAtomic target) {
  if (target is XPathNumeric) {
    return castAtomic(untyped, xsDouble);
  }
  if (target is XPathString || target is XPathAnyUri) {
    return XPathString(untyped.value);
  }
  return castAtomic(untyped, target.type);
}

void _validateComparableTypes(XPathAtomic a, XPathAtomic b) {
  if ((a is XPathNumeric && b is XPathNumeric) ||
      (a is XPathString && b is XPathString) ||
      (a is XPathAnyUri && b is XPathAnyUri) ||
      (a is XPathString && b is XPathAnyUri) ||
      (a is XPathAnyUri && b is XPathString) ||
      (a is XPathBoolean && b is XPathBoolean) ||
      (a is XPathDateTime && b is XPathDateTime) ||
      (a is XPathDuration && b is XPathDuration) ||
      (a is XPathQName && b is XPathQName) ||
      (a is XPathBinary && b is XPathBinary && a.type == b.type)) {
    return;
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Cannot compare ${a.type} and ${b.type}',
  );
}
