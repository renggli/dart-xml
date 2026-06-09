import '../exceptions/evaluation_exception.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
///
/// Two xs:duration values are equal iff their year-month parts are equal AND
/// their day-time parts are equal (XPath 3.1 §10.3.2).
XPathSequence opDurationEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = xsDuration.cast(left);
  final d2 = xsDuration.cast(right);
  return XPathSequence.single(d1 == d2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) < xsYearMonthDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) > xsYearMonthDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) < xsDayTimeDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) > xsDayTimeDuration.cast(right),
  );
}

XPathSequence opAddDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = xsDuration.cast(left);
  final d2 = xsDuration.cast(right);
  return XPathSequence.single(
    XPathDuration.fromValues(
      d1.totalMonths + d2.totalMonths,
      d1.totalMicroseconds + d2.totalMicroseconds,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
XPathSequence opAddYearMonthDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) + xsYearMonthDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) + xsDayTimeDuration.cast(right),
  );
}

XPathSequence opSubtractDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = xsDuration.cast(left);
  final d2 = xsDuration.cast(right);
  return XPathSequence.single(
    XPathDuration.fromValues(
      d1.totalMonths - d2.totalMonths,
      d1.totalMicroseconds - d2.totalMicroseconds,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
XPathSequence opSubtractYearMonthDurations(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsYearMonthDuration.cast(left) - xsYearMonthDuration.cast(right),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDayTimeDuration.cast(left) - xsDayTimeDuration.cast(right),
  );
}

XPathSequence opMultiplyDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = xsDuration.cast(left);
  final factor = xsNumeric.cast(right);
  if (factor.isNaN) {
    throw XPathEvaluationException('NaN multiplier in duration multiplication');
  }
  if (factor.isInfinite) {
    throw XPathEvaluationException(
      'Overflow: duration multiplication by Infinity',
    );
  }
  return XPathSequence.single(
    XPathDuration.fromValues(
      (duration.totalMonths * factor).round(),
      (duration.totalMicroseconds * factor).round(),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
XPathSequence opMultiplyYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = xsYearMonthDuration.cast(left);
  final factor = xsNumeric.cast(right);
  if (factor.isNaN) {
    throw XPathEvaluationException('NaN multiplier in duration multiplication');
  }
  if (factor.isInfinite) {
    throw XPathEvaluationException(
      'Overflow: duration multiplication by Infinity',
    );
  }
  return XPathSequence.single(duration * factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
XPathSequence opMultiplyDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = xsDayTimeDuration.cast(left);
  final factor = xsNumeric.cast(right);
  if (factor.isNaN) {
    throw XPathEvaluationException('NaN multiplier in duration multiplication');
  }
  if (factor.isInfinite) {
    throw XPathEvaluationException(
      'Overflow: duration multiplication by Infinity',
    );
  }
  return XPathSequence.single(duration * factor);
}

XPathSequence opDivideDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = xsDuration.cast(left);
  final divisor = xsNumeric.cast(right);
  if (divisor.isNaN) {
    throw XPathEvaluationException('NaN divisor in duration division');
  }
  if (divisor.isInfinite) {
    return const XPathSequence.single(XPathDuration());
  }
  final rounded = divisor.round();
  if (rounded == 0) throw XPathEvaluationException('Division by zero');
  return XPathSequence.single(
    XPathDuration.fromValues(
      duration.totalMonths ~/ rounded,
      duration.totalMicroseconds ~/ rounded,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
XPathSequence opDivideYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = xsYearMonthDuration.cast(left);
  final divisor = xsNumeric.cast(right);
  if (divisor.isNaN) {
    throw XPathEvaluationException('NaN divisor in duration division');
  }
  if (divisor.isInfinite) {
    return const XPathSequence.single(XPathYearMonthDuration(0));
  }
  final rounded = divisor.round();
  if (rounded == 0) throw XPathEvaluationException('Division by zero');
  return XPathSequence.single(duration ~/ rounded);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
XPathSequence opDivideDayTimeDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = xsDayTimeDuration.cast(left);
  final divisor = xsNumeric.cast(right);
  if (divisor.isNaN) {
    throw XPathEvaluationException('NaN divisor in duration division');
  }
  if (divisor.isInfinite) {
    return const XPathSequence.single(XPathDayTimeDuration(0));
  }
  final rounded = divisor.round();
  if (rounded == 0) throw XPathEvaluationException('Division by zero');
  return XPathSequence.single(duration ~/ rounded);
}

XPathSequence opDivideDurationByDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final divisor = xsDayTimeDuration.cast(right);
  if (divisor.totalMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(
    xsDayTimeDuration.cast(left).totalMicroseconds / divisor.totalMicroseconds,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final divisor = xsYearMonthDuration.cast(right);
  if (divisor.totalMonths == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(
    xsYearMonthDuration.cast(left).divideByDuration(divisor),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);
