import '../types/date_time.dart';
import '../types/duration.dart';
import '../types/sequence.dart';

// ---------------------------------------------------------------------------
// DateTime comparison
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-equal
XPathSequence opDateTimeEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDateTime.cast(left).compareTo(xsDateTime.cast(right)) == 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-less-than
XPathSequence opDateTimeLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDateTime.cast(left).compareTo(xsDateTime.cast(right)) < 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-greater-than
XPathSequence opDateTimeGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDateTime.cast(left).compareTo(xsDateTime.cast(right)) > 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-date-equal
XPathSequence opDateEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDate.cast(left).compareTo(xsDate.cast(right)) == 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-date-less-than
XPathSequence opDateLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDate.cast(left).compareTo(xsDate.cast(right)) < 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-date-greater-than
XPathSequence opDateGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDate.cast(left).compareTo(xsDate.cast(right)) > 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-time-equal
XPathSequence opTimeEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsTime.cast(left).compareTo(xsTime.cast(right)) == 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-time-less-than
XPathSequence opTimeLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsTime.cast(left).compareTo(xsTime.cast(right)) < 0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-time-greater-than
XPathSequence opTimeGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsTime.cast(left).compareTo(xsTime.cast(right)) > 0,
  );
}

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

// ---------------------------------------------------------------------------
// DateTime subtraction (returns xs:dayTimeDuration)
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dateTimes
XPathSequence opSubtractDateTimes(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = xsDateTime.cast(left).difference(xsDateTime.cast(right));
  return XPathSequence.single(XPathDayTimeDuration(diff));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dates
XPathSequence opSubtractDates(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = xsDate.cast(left).difference(xsDate.cast(right));
  return XPathSequence.single(XPathDayTimeDuration(diff));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-times
XPathSequence opSubtractTimes(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = xsTime.cast(left).difference(xsTime.cast(right));
  return XPathSequence.single(XPathDayTimeDuration(diff));
}

// ---------------------------------------------------------------------------
// DateTime + duration arithmetic
// ---------------------------------------------------------------------------

/// Adds [months] to a [DateTime] using calendar arithmetic.
DateTime _addMonthsToDateTime(DateTime dt, int months) {
  var newYear = dt.year;
  var newMonth = dt.month + months;
  // Normalize month overflow/underflow.
  while (newMonth > 12) {
    newMonth -= 12;
    newYear++;
  }
  while (newMonth < 1) {
    newMonth += 12;
    newYear--;
  }
  // Clamp day to max days in new month.
  final maxDay = _daysInMonth(newYear, newMonth);
  final newDay = dt.day > maxDay ? maxDay : dt.day;
  if (dt.isUtc) {
    return DateTime.utc(
      newYear,
      newMonth,
      newDay,
      dt.hour,
      dt.minute,
      dt.second,
      dt.millisecond,
      dt.microsecond,
    );
  }
  return DateTime(
    newYear,
    newMonth,
    newDay,
    dt.hour,
    dt.minute,
    dt.second,
    dt.millisecond,
    dt.microsecond,
  );
}

int _daysInMonth(int year, int month) {
  const days = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  if (month == 2) {
    final isLeap = (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
    return isLeap ? 29 : 28;
  }
  return days[month];
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-duration-to-dateTime
XPathSequence opAddDurationToDateTime(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final dur = xsDuration.cast(right);
  var result = _addMonthsToDateTime(dt, dur.months);
  result = result.add(dur.dayTime);
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-duration-from-dateTime
XPathSequence opSubtractDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final dur = xsDuration.cast(right);
  var result = _addMonthsToDateTime(dt, -dur.months);
  result = result.subtract(dur.dayTime);
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDuration-to-dateTime
XPathSequence opAddYearMonthDurationToDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final months = xsYearMonthDuration.cast(right).totalMonths;
  return XPathSequence.single(_addMonthsToDateTime(dt, months));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-dateTime
XPathSequence opAddDayTimeDurationToDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDateTime.cast(left).add(xsDayTimeDuration.cast(right)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-dateTime
XPathSequence opSubtractYearMonthDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final months = xsYearMonthDuration.cast(right).totalMonths;
  return XPathSequence.single(_addMonthsToDateTime(dt, -months));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-dateTime
XPathSequence opSubtractDayTimeDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    xsDateTime.cast(left).subtract(xsDayTimeDuration.cast(right)),
  );
}

// ---------------------------------------------------------------------------
// xs:date arithmetic — results must be xs:date
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDuration-to-date
XPathSequence opAddYearMonthDurationToDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = xsDate.cast(left);
  final months = xsYearMonthDuration.cast(right).totalMonths;
  return XPathSequence.single(XPathDate(_addMonthsToDateTime(date, months)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-date
///
/// Adding a dayTimeDuration to a date: only the day component contributes;
/// the result is the date advanced by that many whole days.
XPathSequence opAddDayTimeDurationToDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = xsDate.cast(left);
  final dur = xsDayTimeDuration.cast(right);
  // XPath spec: add duration, then strip time to midnight.
  final added = date.add(dur.dayTime);
  return XPathSequence.single(
    XPathDate(DateTime(added.year, added.month, added.day)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-date
XPathSequence opSubtractYearMonthDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = xsDate.cast(left);
  final months = xsYearMonthDuration.cast(right).totalMonths;
  return XPathSequence.single(XPathDate(_addMonthsToDateTime(date, -months)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-date
XPathSequence opSubtractDayTimeDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = xsDate.cast(left);
  final dur = xsDayTimeDuration.cast(right);
  final subtracted = date.subtract(dur.dayTime);
  return XPathSequence.single(
    XPathDate(DateTime(subtracted.year, subtracted.month, subtracted.day)),
  );
}

// ---------------------------------------------------------------------------
// xs:time arithmetic — results must be xs:time
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-time
XPathSequence opAddDayTimeDurationToTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final time = xsTime.cast(left);
  final dur = xsDayTimeDuration.cast(right);
  // Add duration to a reference date carrying the time, then extract time.
  final added = time.add(dur.dayTime);
  return XPathSequence.single(
    XPathTime(
      DateTime(
        1970,
        1,
        1,
        added.hour,
        added.minute,
        added.second,
        added.millisecond,
        added.microsecond,
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-time
XPathSequence opSubtractDayTimeDurationFromTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final time = xsTime.cast(left);
  final dur = xsDayTimeDuration.cast(right);
  final subtracted = time.subtract(dur.dayTime);
  return XPathSequence.single(
    XPathTime(
      DateTime(
        1970,
        1,
        1,
        subtracted.hour,
        subtracted.minute,
        subtracted.second,
        subtracted.millisecond,
        subtracted.microsecond,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// xs:dateTime subtractYearMonth (returns xs:dateTime)
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-dateTime
XPathSequence opSubtractYearMonthDurationFromDateTimeSeq(
  XPathSequence left,
  XPathSequence right,
) => opSubtractYearMonthDurationFromDateTime(left, right);

XPathSequence opSubtractDayTimeDurationFromDateTimeSeq(
  XPathSequence left,
  XPathSequence right,
) => opSubtractDayTimeDurationFromDateTime(left, right);
