import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/casting_matrix.dart';
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
XPathSequence opGeneralEqual(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, _generalEqual);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralNotEqual(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, _generalNotEqual);

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThan(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) {
      if (a is XPathDouble && a.value.isNaN ||
          b is XPathDouble && b.value.isNaN) {
        return false;
      }
      if (a is XPathQName || b is XPathQName) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Cannot compare QNames for order',
        );
      }
      return compare(a, b) < 0;
    });

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThan(XPathSequence left, XPathSequence right) =>
    _compareGeneral(left, right, (a, b) {
      if (a is XPathDouble && a.value.isNaN ||
          b is XPathDouble && b.value.isNaN) {
        return false;
      }
      if (a is XPathQName || b is XPathQName) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Cannot compare QNames for order',
        );
      }
      return compare(a, b) > 0;
    });

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralLessThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) => _compareGeneral(left, right, (a, b) {
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
});

/// https://www.w3.org/TR/xpath-31/#id-general-comparisons
XPathSequence opGeneralGreaterThanOrEqual(
  XPathSequence left,
  XPathSequence right,
) => _compareGeneral(left, right, (a, b) {
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
});

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

XPathSequence _compareGeneral(
  XPathSequence left,
  XPathSequence right,
  bool Function(XPathAtomic, XPathAtomic) comparator,
) {
  final seq1 = left.atomize().toList();
  final seq2 = right.atomize().toList();
  if (seq1.isEmpty || seq2.isEmpty) return XPathSequence.falseSequence;

  Object? typeError;
  for (final item1 in seq1) {
    for (final item2 in seq2) {
      try {
        final (c1, c2) = _coerceForGeneralComp(item1, item2);
        if (comparator(c1, c2)) return XPathSequence.trueSequence;
      } catch (error) {
        typeError ??= error;
      }
    }
  }
  if (typeError != null) throw typeError;
  return XPathSequence.falseSequence;
}

(XPathAtomic, XPathAtomic) _coerceForGeneralComp(XPathAtomic a, XPathAtomic b) {
  if (a is XPathUntypedAtomic && b is XPathUntypedAtomic) {
    return (XPathString(a.value), XPathString(b.value));
  }
  if (a is XPathUntypedAtomic) {
    return (_coerceUntyped(a, b), b);
  }
  if (b is XPathUntypedAtomic) {
    return (a, _coerceUntyped(b, a));
  }
  return _validateComparable(a, b);
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

(XPathAtomic, XPathAtomic) _validateComparable(XPathAtomic a, XPathAtomic b) {
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
    return (a, b);
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Cannot compare ${a.type} and ${b.type}',
  );
}
