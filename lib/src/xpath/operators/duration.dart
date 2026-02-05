import '../exceptions/evaluation_exception.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
XPathSequence opDurationEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.toXPathDuration();
  final d2 = right.toXPathDuration();
  return XPathSequence.single(d1.compareTo(d2) == 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
XPathSequence opYearMonthDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDuration().compareTo(right.toXPathDuration()) < 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
XPathSequence opYearMonthDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDuration().compareTo(right.toXPathDuration()) > 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
XPathSequence opDayTimeDurationLessThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDuration().compareTo(right.toXPathDuration()) < 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
XPathSequence opDayTimeDurationGreaterThan(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDuration().compareTo(right.toXPathDuration()) > 0,
  );
}

XPathSequence opAddDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.toXPathDuration() + right.toXPathDuration()).toXPathDuration(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
XPathSequence opAddYearMonthDurations(
  XPathSequence left,
  XPathSequence right,
) => opAddDurations(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
XPathSequence opAddDayTimeDurations(XPathSequence left, XPathSequence right) =>
    opAddDurations(left, right);

XPathSequence opSubtractDurations(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.toXPathDuration() - right.toXPathDuration()).toXPathDuration(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
XPathSequence opSubtractYearMonthDurations(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurations(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
XPathSequence opSubtractDayTimeDurations(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurations(left, right);

XPathSequence opMultiplyDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.toXPathDuration() * right.toXPathNumber()).toXPathDuration(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
XPathSequence opMultiplyYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) => opMultiplyDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
XPathSequence opMultiplyDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opMultiplyDuration(left, right);

XPathSequence opDivideDuration(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    (left.toXPathDuration() ~/ right.toXPathNumber().toInt()).toXPathDuration(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
XPathSequence opDivideYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
XPathSequence opDivideDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDuration(left, right);

XPathSequence opDivideDurationByDuration(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final d1 = left.toXPathDuration();
  final d2 = right.toXPathDuration();
  if (d2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(d1.inMicroseconds / d2.inMicroseconds);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
XPathSequence opDivideYearMonthDurationByYearMonthDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
XPathSequence opDivideDayTimeDurationByDayTimeDuration(
  XPathSequence left,
  XPathSequence right,
) => opDivideDurationByDuration(left, right);
