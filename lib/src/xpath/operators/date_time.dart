import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-equal
XPathSequence opDateTimeEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDateTime().compareTo(right.toXPathDateTime()) == 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-less-than
XPathSequence opDateTimeLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDateTime().compareTo(right.toXPathDateTime()) < 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-greater-than
XPathSequence opDateTimeGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDateTime().compareTo(right.toXPathDateTime()) > 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-date-equal
XPathSequence opDateEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-date-less-than
XPathSequence opDateLessThan(XPathSequence left, XPathSequence right) =>
    opDateTimeLessThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-date-greater-than
XPathSequence opDateGreaterThan(XPathSequence left, XPathSequence right) =>
    opDateTimeGreaterThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-time-equal
XPathSequence opTimeEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-time-less-than
XPathSequence opTimeLessThan(XPathSequence left, XPathSequence right) =>
    opDateTimeLessThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-time-greater-than
XPathSequence opTimeGreaterThan(XPathSequence left, XPathSequence right) =>
    opDateTimeGreaterThan(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYearMonth-equal
XPathSequence opGYearMonthEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-gYear-equal
XPathSequence opGYearEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonthDay-equal
XPathSequence opGMonthDayEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-gMonth-equal
XPathSequence opGMonthEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-gDay-equal
XPathSequence opGDayEqual(XPathSequence left, XPathSequence right) =>
    opDateTimeEqual(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dateTimes
XPathSequence opSubtractDateTimes(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left
        .toXPathDateTime()
        .difference(right.toXPathDateTime())
        .toXPathDuration(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dates
XPathSequence opSubtractDates(XPathSequence left, XPathSequence right) =>
    opSubtractDateTimes(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-times
XPathSequence opSubtractTimes(XPathSequence left, XPathSequence right) =>
    opSubtractDateTimes(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-duration-to-dateTime
XPathSequence opAddDurationToDateTime(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDateTime().add(right.toXPathDuration()).toXPathDateTime(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-duration-from-dateTime
XPathSequence opSubtractDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    left.toXPathDateTime().subtract(right.toXPathDuration()).toXPathDateTime(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDuration-to-dateTime
XPathSequence opAddYearMonthDurationToDateTime(
  XPathSequence left,
  XPathSequence right,
) => opAddDurationToDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-dateTime
XPathSequence opAddDayTimeDurationToDateTime(
  XPathSequence left,
  XPathSequence right,
) => opAddDurationToDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-dateTime
XPathSequence opSubtractYearMonthDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurationFromDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-dateTime
XPathSequence opSubtractDayTimeDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurationFromDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDuration-to-date
XPathSequence opAddYearMonthDurationToDate(
  XPathSequence left,
  XPathSequence right,
) => opAddDurationToDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-date
XPathSequence opAddDayTimeDurationToDate(
  XPathSequence left,
  XPathSequence right,
) => opAddDurationToDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-date
XPathSequence opSubtractYearMonthDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurationFromDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-date
XPathSequence opSubtractDayTimeDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurationFromDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-time
XPathSequence opAddDayTimeDurationToTime(
  XPathSequence left,
  XPathSequence right,
) => opAddDurationToDateTime(left, right);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-time
XPathSequence opSubtractDayTimeDurationFromTime(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDurationFromDateTime(left, right);
