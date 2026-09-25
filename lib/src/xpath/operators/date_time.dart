import '../xdm/atomic/date_time.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/sequence.dart';

// ---------------------------------------------------------------------------
// DateTime comparison
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-equal
XPathSequence opDateTimeEqual(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathDateTime).compareTo(
            right.single as XPathDateTime,
          ) ==
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-less-than
XPathSequence opDateTimeLessThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathDateTime).compareTo(
            right.single as XPathDateTime,
          ) <
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime-greater-than
XPathSequence opDateTimeGreaterThan(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  return (left.single as XPathDateTime).compareTo(
            right.single as XPathDateTime,
          ) >
          0
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
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

// ---------------------------------------------------------------------------
// DateTime subtraction (returns xs:dayTimeDuration)
// ---------------------------------------------------------------------------

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dateTimes
XPathSequence opSubtractDateTimes(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = (left.single as XPathDateTime).toDateTime().difference(
    (right.single as XPathDateTime).toDateTime(),
  );
  return XPathSequence.single(XPathDuration.dayTime(diff.inMicroseconds));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dates
XPathSequence opSubtractDates(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = (left.single as XPathDateTime).toDateTime().difference(
    (right.single as XPathDateTime).toDateTime(),
  );
  return XPathSequence.single(XPathDuration.dayTime(diff.inMicroseconds));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-times
XPathSequence opSubtractTimes(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final diff = (left.single as XPathDateTime).toDateTime().difference(
    (right.single as XPathDateTime).toDateTime(),
  );
  return XPathSequence.single(XPathDuration.dayTime(diff.inMicroseconds));
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

XPathDateTime _wrapDateTime(DateTime result, XPathDateTime original) {
  final offset = original.timezoneOffsetMinutes;
  return XPathDateTime.fromParts(
    year: original.year != null ? result.year : null,
    month: original.month != null ? result.month : null,
    day: original.day != null ? result.day : null,
    hour: original.hour != null ? result.hour : null,
    minute: original.minute != null ? result.minute : null,
    second: original.second != null ? result.second : null,
    millisecond: result.millisecond,
    microsecond: result.microsecond,
    timezoneOffsetMinutes: offset,
    type: original.type,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-duration-to-dateTime
XPathSequence opAddDurationToDateTime(XPathSequence left, XPathSequence right) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = left.single as XPathDateTime;
  final dur = right.single as XPathDuration;
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
  final dt = left.single as XPathDateTime;
  final dur = right.single as XPathDuration;
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
  final dt = left.single as XPathDateTime;
  final months = (right.single as XPathDuration).totalMonths;
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
  final dt = left.single as XPathDateTime;
  final result = dt.toDateTime().add(
    (right.single as XPathDuration).toDuration(),
  );
  return XPathSequence.single(_wrapDateTime(result, dt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-dateTime
XPathSequence opSubtractYearMonthDurationFromDateTime(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final dt = left.single as XPathDateTime;
  final months = (right.single as XPathDuration).totalMonths;
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
  final dt = left.single as XPathDateTime;
  final result = dt.toDateTime().subtract(
    (right.single as XPathDuration).toDuration(),
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
  final date = left.single as XPathDateTime;
  final months = (right.single as XPathDuration).totalMonths;
  return XPathSequence.single(
    XPathDateTime.fromDateTime(
      _addMonthsToDateTime(date.toDateTime(), months),
      date.timezoneOffsetMinutes,
      date.type,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDuration-to-date
XPathSequence opAddDayTimeDurationToDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = left.single as XPathDateTime;
  final dur = right.single as XPathDuration;
  final added = date.toDateTime().add(dur.toDuration());
  return XPathSequence.single(
    XPathDateTime.date(
      added.year,
      added.month,
      added.day,
      date.timezoneOffsetMinutes,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDuration-from-date
XPathSequence opSubtractYearMonthDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = left.single as XPathDateTime;
  final months = (right.single as XPathDuration).totalMonths;
  return XPathSequence.single(
    XPathDateTime.fromDateTime(
      _addMonthsToDateTime(date.toDateTime(), -months),
      date.timezoneOffsetMinutes,
      date.type,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDuration-from-date
XPathSequence opSubtractDayTimeDurationFromDate(
  XPathSequence left,
  XPathSequence right,
) {
  if (left.isEmpty || right.isEmpty) return XPathSequence.empty;
  final date = left.single as XPathDateTime;
  final dur = right.single as XPathDuration;
  final subtracted = date.toDateTime().subtract(dur.toDuration());
  return XPathSequence.single(
    XPathDateTime.date(
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
  final time = left.single as XPathDateTime;
  final dur = right.single as XPathDuration;
  final added = time.toDateTime().add(dur.toDuration());
  return XPathSequence.single(
    XPathDateTime.time(
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
  final time = left.single as XPathDateTime;
  final dur = right.single as XPathDuration;
  final subtracted = time.toDateTime().subtract(dur.toDuration());
  return XPathSequence.single(
    XPathDateTime.time(
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
