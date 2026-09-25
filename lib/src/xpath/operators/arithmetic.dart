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

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) + _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) - _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) * _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) / _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    _toNumeric(left.single).idiv(_toNumeric(right.single)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(left.single) % _toNumeric(right.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(XPathSequence arg) => arg.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(_toNumeric(arg.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(XPathSequence arg) => arg.isEmpty
    ? XPathSequence.empty
    : XPathSequence.single(-_toNumeric(arg.single));

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
XPathSequence opNumericEqual(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : (_toNumeric(left.single).compareTo(_toNumeric(right.single)) == 0
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
XPathSequence opNumericLessThan(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : (_toNumeric(left.single).compareTo(_toNumeric(right.single)) < 0
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
XPathSequence opNumericGreaterThan(XPathSequence left, XPathSequence right) =>
    left.isEmpty || right.isEmpty
    ? XPathSequence.empty
    : (_toNumeric(left.single).compareTo(_toNumeric(right.single)) > 0
          ? XPathSequence.trueSequence
          : XPathSequence.falseSequence);

/// Dispatches the `+` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opAdd(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (a is XPathDuration && b is XPathDuration) {
    if (a.isYearMonth && b.isYearMonth) {
      return opAddYearMonthDurations(left, right);
    } else if (a.isDayTime && b.isDayTime) {
      return opAddDayTimeDurations(left, right);
    } else if (a.type == xsDuration && b.type == xsDuration) {
      return opAddDurations(left, right);
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot add ${a.type} and ${b.type}',
    );
  } else if (a is XPathDateTime && b is XPathDuration) {
    if (a.type.isSubtypeOf(xsDateTime)) {
      return opAddDurationToDateTime(left, right);
    } else if (a.type == xsDate) {
      if (b.type.isSubtypeOf(xsYearMonthDuration)) {
        return opAddYearMonthDurationToDate(left, right);
      } else if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opAddDayTimeDurationToDate(left, right);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot add ${b.type} to xs:date',
      );
    } else if (a.type == xsTime) {
      if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opAddDayTimeDurationToTime(left, right);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot add ${b.type} to xs:time',
      );
    }
  } else if (a is XPathDuration && b is XPathDateTime) {
    return opAdd(right, left);
  }
  return opNumericAdd(left, right);
}

/// Dispatches the `-` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opSubtract(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  if (a is XPathDuration && b is XPathDuration) {
    if (a.isYearMonth && b.isYearMonth) {
      return opSubtractYearMonthDurations(left, right);
    } else if (a.isDayTime && b.isDayTime) {
      return opSubtractDayTimeDurations(left, right);
    } else if (a.type == xsDuration && b.type == xsDuration) {
      return opSubtractDurations(left, right);
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot subtract ${b.type} from ${a.type}',
    );
  } else if (a is XPathDateTime && b is XPathDuration) {
    if (a.type.isSubtypeOf(xsDateTime)) {
      return opSubtractDurationFromDateTime(left, right);
    } else if (a.type == xsDate) {
      if (b.type.isSubtypeOf(xsYearMonthDuration)) {
        return opSubtractYearMonthDurationFromDate(left, right);
      } else if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opSubtractDayTimeDurationFromDate(left, right);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot subtract ${b.type} from xs:date',
      );
    } else if (a.type == xsTime) {
      if (b.type.isSubtypeOf(xsDayTimeDuration)) {
        return opSubtractDayTimeDurationFromTime(left, right);
      }
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Cannot subtract ${b.type} from xs:time',
      );
    }
  } else if (a is XPathDateTime && b is XPathDateTime) {
    if (a.type.isSubtypeOf(xsDateTime) && b.type.isSubtypeOf(xsDateTime)) {
      return opSubtractDateTimes(left, right);
    } else if (a.type == xsDate && b.type == xsDate) {
      return opSubtractDates(left, right);
    } else if (a.type == xsTime && b.type == xsTime) {
      return opSubtractTimes(left, right);
    }
  }
  return opNumericSubtract(left, right);
}

/// Dispatches the `*` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opMultiply(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  final aIsNum = a is XPathNumeric || a is XPathUntypedAtomic;
  final bIsNum = b is XPathNumeric || b is XPathUntypedAtomic;
  if (a is XPathDuration && bIsNum) {
    return opMultiplyDuration(left, XPathSequence.single(_toNumeric(b)));
  } else if (aIsNum && b is XPathDuration) {
    return opMultiplyDuration(right, XPathSequence.single(_toNumeric(a)));
  }
  return opNumericMultiply(left, right);
}

/// Dispatches the `div` operator based on operand types.
///
/// https://www.w3.org/TR/xpath-31/#id-arithmetic
XPathSequence opDivide(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final a = left.single;
  final b = right.single;
  final bIsNum = b is XPathNumeric || b is XPathUntypedAtomic;
  if (a is XPathDuration && b is XPathDuration) {
    if (a.isYearMonth && b.isYearMonth) {
      return opDivideYearMonthDurationByYearMonthDuration(left, right);
    } else if (a.isDayTime && b.isDayTime) {
      return opDivideDayTimeDurationByDayTimeDuration(left, right);
    } else if (a.type == xsDuration && b.type == xsDuration) {
      return opDivideDurationByDuration(left, right);
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Cannot divide ${a.type} by ${b.type}',
    );
  } else if (a is XPathDuration && bIsNum) {
    return opDivideDuration(left, XPathSequence.single(_toNumeric(b)));
  }
  return opNumericDivide(left, right);
}
