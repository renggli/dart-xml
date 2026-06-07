import '../types/date_time.dart';
import '../types/duration.dart';
import '../values/date_time.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

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
  final diff = xsDateTime
      .cast(left)
      .toDateTime()
      .difference(xsDateTime.cast(right).toDateTime());
  return XPathSequence.single(XPathDayTimeDuration(diff.inMicroseconds));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dates
XPathSequence opSubtractDates(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = xsDate
      .cast(left)
      .toDateTime()
      .difference(xsDate.cast(right).toDateTime());
  return XPathSequence.single(XPathDayTimeDuration(diff.inMicroseconds));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-times
XPathSequence opSubtractTimes(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = xsTime
      .cast(left)
      .toDateTime()
      .difference(xsTime.cast(right).toDateTime());
  return XPathSequence.single(XPathDayTimeDuration(diff.inMicroseconds));
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

XPathAbstractDateTime _wrapDateTime(
  DateTime result,
  XPathAbstractDateTime original,
) {
  final offset = original.timezoneOffsetMinutes;
  return switch (original) {
    XPathDateTimeStamp() => XPathDateTimeStamp.fromDateTime(
      result,
      offset ?? 0,
    ),
    XPathDateTime() => XPathDateTime.fromDateTime(result, offset),
    XPathDate() => XPathDate.fromDateTime(result, offset),
    XPathTime() => XPathTime.fromDateTime(result, offset),
    XPathYearMonth() => XPathYearMonth(result.year, result.month, offset),
    XPathYear() => XPathYear(result.year, offset),
    XPathMonthDay() => XPathMonthDay(result.month, result.day, offset),
    XPathMonth() => XPathMonth(result.month, offset),
    XPathDay() => XPathDay(result.day, offset),
    _ => XPathDateTime.fromDateTime(result, offset),
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-duration-to-dateTime
XPathSequence opAddDurationToDateTime(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final dur = xsDuration.cast(right);
  var result = _addMonthsToDateTime(dt.toDateTime(), dur.totalMonths);
  result = result.add(dur.toDuration());
  return XPathSequence.single(_wrapDateTime(result, dt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-duration-from-dateTime
XPathSequence opSubtractDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final dur = xsDuration.cast(right);
  var result = _addMonthsToDateTime(dt.toDateTime(), -dur.totalMonths);
  result = result.subtract(dur.toDuration());
  return XPathSequence.single(_wrapDateTime(result, dt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDuration-to-dateTime
XPathSequence opAddYearMonthDurationToDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final months = xsYearMonthDuration.cast(right).totalMonths;
  return XPathSequence.single(
    _wrapDateTime(_addMonthsToDateTime(dt.toDateTime(), months), dt),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-dateTime
XPathSequence opAddDayTimeDurationToDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final result = dt.toDateTime().add(
    xsDayTimeDuration.cast(right).toDuration(),
  );
  return XPathSequence.single(_wrapDateTime(result, dt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-dateTime
XPathSequence opSubtractYearMonthDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final months = xsYearMonthDuration.cast(right).totalMonths;
  return XPathSequence.single(
    _wrapDateTime(_addMonthsToDateTime(dt.toDateTime(), -months), dt),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-dateTime
XPathSequence opSubtractDayTimeDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = xsDateTime.cast(left);
  final result = dt.toDateTime().subtract(
    xsDayTimeDuration.cast(right).toDuration(),
  );
  return XPathSequence.single(_wrapDateTime(result, dt));
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
  return XPathSequence.single(
    XPathDate.fromDateTime(
      _addMonthsToDateTime(date.toDateTime(), months),
      date.timezoneOffsetMinutes,
    ),
  );
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
  final added = date.toDateTime().add(dur.toDuration());
  return XPathSequence.single(
    XPathDate(added.year, added.month, added.day, date.timezoneOffsetMinutes),
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
  return XPathSequence.single(
    XPathDate.fromDateTime(
      _addMonthsToDateTime(date.toDateTime(), -months),
      date.timezoneOffsetMinutes,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-date
XPathSequence opSubtractDayTimeDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = xsDate.cast(left);
  final dur = xsDayTimeDuration.cast(right);
  final subtracted = date.toDateTime().subtract(dur.toDuration());
  return XPathSequence.single(
    XPathDate(
      subtracted.year,
      subtracted.month,
      subtracted.day,
      date.timezoneOffsetMinutes,
    ),
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
  final added = time.toDateTime().add(dur.toDuration());
  return XPathSequence.single(
    XPathTime(
      added.hour,
      added.minute,
      added.second,
      added.millisecond,
      added.microsecond,
      time.timezoneOffsetMinutes,
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
  final subtracted = time.toDateTime().subtract(dur.toDuration());
  return XPathSequence.single(
    XPathTime(
      subtracted.hour,
      subtracted.minute,
      subtracted.second,
      subtracted.millisecond,
      subtracted.microsecond,
      time.timezoneOffsetMinutes,
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
