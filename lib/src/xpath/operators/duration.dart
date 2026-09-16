import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
///
/// Two xs:duration values are equal iff their year-month parts are equal AND
/// their day-time parts are equal (XPath 3.1 §10.3.2).
XPathSequence opDurationEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathAbstractDuration;
  final d2 = right.single as XPathAbstractDuration;
  return d1 == d2 ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathYearMonthDuration) <
          (right.single as XPathYearMonthDuration)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathYearMonthDuration) >
          (right.single as XPathYearMonthDuration)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathDayTimeDuration) <
          (right.single as XPathDayTimeDuration)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathDayTimeDuration) >
          (right.single as XPathDayTimeDuration)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

XPathSequence opAddDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
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
  final d1 = left.single as XPathYearMonthDuration;
  final d2 = right.single as XPathYearMonthDuration;
  return XPathSequence.single(d1 + d2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDayTimeDuration;
  final d2 = right.single as XPathDayTimeDuration;
  return XPathSequence.single(d1 + d2);
}

XPathSequence opSubtractDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDuration;
  final d2 = right.single as XPathDuration;
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
  final d1 = left.single as XPathYearMonthDuration;
  final d2 = right.single as XPathYearMonthDuration;
  return XPathSequence.single(d1 - d2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathDayTimeDuration;
  final d2 = right.single as XPathDayTimeDuration;
  return XPathSequence.single(d1 - d2);
}

XPathSequence opMultiplyDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final duration = left.single as XPathDuration;
  final factor = (right.single as XPathNumeric).toDouble();
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
  final duration = left.single as XPathYearMonthDuration;
  final factor = (right.single as XPathNumeric).toDouble();
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
  final duration = left.single as XPathDayTimeDuration;
  final factor = (right.single as XPathNumeric).toDouble();
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
  final duration = left.single as XPathDuration;
  final divisor = (right.single as XPathNumeric).toDouble();
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
  final duration = left.single as XPathYearMonthDuration;
  final divisor = (right.single as XPathNumeric).toDouble();
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
  final duration = left.single as XPathDayTimeDuration;
  final divisor = (right.single as XPathNumeric).toDouble();
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
  final d1 = left.single as XPathDayTimeDuration;
  final divisor = right.single as XPathDayTimeDuration;
  if (divisor.totalMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(
    XPathDouble(d1.totalMicroseconds / divisor.totalMicroseconds),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.single as XPathYearMonthDuration;
  final divisor = right.single as XPathYearMonthDuration;
  if (divisor.totalMonths == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(
    XPathDouble(d1.totalMonths / divisor.totalMonths),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);
