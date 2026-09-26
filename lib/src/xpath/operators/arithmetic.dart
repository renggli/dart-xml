import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/date_time.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';
import 'date_time.dart';
import 'duration.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, '+');
  if (pair == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(pair.$1) + _toNumeric(pair.$2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, '-');
  if (pair == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(pair.$1) - _toNumeric(pair.$2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, '*');
  if (pair == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(pair.$1) * _toNumeric(pair.$2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, 'div');
  if (pair == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(pair.$1) / _toNumeric(pair.$2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, 'idiv');
  if (pair == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(pair.$1).idiv(_toNumeric(pair.$2)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, 'mod');
  if (pair == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(pair.$1) % _toNumeric(pair.$2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(XPathSequence arg) {
  final item = _atomizeSingle(arg, '+');
  if (item == null) return XPathSequence.empty;
  return XPathSequence.single(_toNumeric(item));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(XPathSequence arg) {
  final item = _atomizeSingle(arg, '-');
  if (item == null) return XPathSequence.empty;
  return XPathSequence.single(-_toNumeric(item));
}

/// Dispatches the `+` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opAdd(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, '+');
  if (pair == null) return XPathSequence.empty;
  final (a, b) = pair;
  final leftSeq = XPathSequence.single(a);
  final rightSeq = XPathSequence.single(b);
  if (a is XPathDuration && b is XPathDuration) {
    if ((a.isYearMonth && b.isYearMonth) ||
        (a.isDayTime && b.isDayTime) ||
        (a.type == xsDuration && b.type == xsDuration)) {
      return opAddDurations(leftSeq, rightSeq);
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot add ${a.type} and ${b.type}',
    );
  } else if (a is XPathDateTime && b is XPathDuration) {
    if (a.type.isSubtypeOf(xsDateTime)) {
      return opAddDurationToDateTime(leftSeq, rightSeq);
    } else if (a.type == xsDate) {
      if (b.type.isSubtypeOf(xsYearMonthDuration)) {
        return opAddYearMonthDurationToDate(leftSeq, rightSeq);
      } else if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opAddDayTimeDurationToDate(leftSeq, rightSeq);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot add ${b.type} to xs:date',
      );
    } else if (a.type == xsTime) {
      if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opAddDayTimeDurationToTime(leftSeq, rightSeq);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot add ${b.type} to xs:time',
      );
    }
  } else if (a is XPathDuration && b is XPathDateTime) {
    return opAdd(rightSeq, leftSeq);
  }
  return opNumericAdd(leftSeq, rightSeq);
}

/// Dispatches the `-` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opSubtract(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, '-');
  if (pair == null) return XPathSequence.empty;
  final (a, b) = pair;
  final leftSeq = XPathSequence.single(a);
  final rightSeq = XPathSequence.single(b);
  if (a is XPathDuration && b is XPathDuration) {
    if ((a.isYearMonth && b.isYearMonth) ||
        (a.isDayTime && b.isDayTime) ||
        (a.type == xsDuration && b.type == xsDuration)) {
      return opSubtractDurations(leftSeq, rightSeq);
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot subtract ${b.type} from ${a.type}',
    );
  } else if (a is XPathDateTime && b is XPathDuration) {
    if (a.type.isSubtypeOf(xsDateTime)) {
      return opSubtractDurationFromDateTime(leftSeq, rightSeq);
    } else if (a.type == xsDate) {
      if (b.type.isSubtypeOf(xsYearMonthDuration)) {
        return opSubtractYearMonthDurationFromDate(leftSeq, rightSeq);
      } else if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opSubtractDayTimeDurationFromDate(leftSeq, rightSeq);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot subtract ${b.type} from xs:date',
      );
    } else if (a.type == xsTime) {
      if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opSubtractDayTimeDurationFromTime(leftSeq, rightSeq);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot subtract ${b.type} from xs:time',
      );
    }
  } else if (a is XPathDateTime && b is XPathDateTime) {
    if (a.type.isSubtypeOf(xsDateTime) && b.type.isSubtypeOf(xsDateTime)) {
      return opSubtractDateTimes(leftSeq, rightSeq);
    } else if (a.type == xsDate && b.type == xsDate) {
      return opSubtractDates(leftSeq, rightSeq);
    } else if (a.type == xsTime && b.type == xsTime) {
      return opSubtractTimes(leftSeq, rightSeq);
    }
  }
  return opNumericSubtract(leftSeq, rightSeq);
}

/// Dispatches the `*` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opMultiply(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, '*');
  if (pair == null) return XPathSequence.empty;
  final (a, b) = pair;
  final aIsNum = a is XPathNumeric || a is XPathUntypedAtomic;
  final bIsNum = b is XPathNumeric || b is XPathUntypedAtomic;
  if (a is XPathDuration && bIsNum) {
    return opMultiplyDuration(
      XPathSequence.single(a),
      XPathSequence.single(_toNumeric(b)),
    );
  } else if (aIsNum && b is XPathDuration) {
    return opMultiplyDuration(
      XPathSequence.single(b),
      XPathSequence.single(_toNumeric(a)),
    );
  }
  return opNumericMultiply(XPathSequence.single(a), XPathSequence.single(b));
}

/// Dispatches the `div` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opDivide(XPathSequence left, XPathSequence right) {
  final pair = _atomizePair(left, right, 'div');
  if (pair == null) return XPathSequence.empty;
  final (a, b) = pair;
  final leftSeq = XPathSequence.single(a);
  final rightSeq = XPathSequence.single(b);
  final bIsNum = b is XPathNumeric || b is XPathUntypedAtomic;
  if (a is XPathDuration && b is XPathDuration) {
    return opDivideDurationByDuration(leftSeq, rightSeq);
  } else if (a is XPathDuration && bIsNum) {
    return opDivideDuration(leftSeq, XPathSequence.single(_toNumeric(b)));
  }
  return opNumericDivide(leftSeq, rightSeq);
}

(XPathItem, XPathItem)? _atomizePair(
  XPathSequence left,
  XPathSequence right,
  String opName,
) {
  final leftAtom = left.atomize();
  final rightAtom = right.atomize();
  if (leftAtom.isEmpty || rightAtom.isEmpty) return null;
  if (leftAtom.length > 1 || rightAtom.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Operator $opName expects sequence of length <= 1',
    );
  }
  return (leftAtom.first, rightAtom.first);
}

XPathItem? _atomizeSingle(XPathSequence arg, String opName) {
  final atom = arg.atomize();
  if (atom.isEmpty) return null;
  if (atom.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Operator $opName expects sequence of length <= 1',
    );
  }
  return atom.first;
}

XPathNumeric _toNumeric(XPathItem item) {
  if (item is XPathNumeric) return item;
  if (item is XPathUntypedAtomic) {
    final d = XPathDouble.tryParse(item.stringValue);
    if (d != null) return d;
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Cannot convert untypedAtomic "${item.stringValue}" to xs:double',
    );
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Expected numeric value, got $item',
  );
}
