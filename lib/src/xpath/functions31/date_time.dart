import '../evaluation/context.dart';
import '../types31/date_time.dart';
import '../types31/duration.dart';
import '../types31/sequence.dart';

// Functions and operators on dates and times

/// https://www.w3.org/TR/xpath-functions-31/#func-dateTime
XPathSequence fnDateTime(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final date = arg1.firstOrNull?.toXPathDateTime();
  final time = arg2.firstOrNull?.toXPathDateTime();
  if (date == null || time == null) return XPathSequence.empty;
  return XPathSequence.single(
    DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
      time.millisecond,
      time.microsecond,
    ).toXPathDateTime(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-dateTime
XPathSequence fnYearFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
XPathSequence fnMonthFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
XPathSequence fnDayFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
XPathSequence fnHoursFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
XPathSequence fnMinutesFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
XPathSequence fnSecondsFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(
    value.second + value.millisecond / 1000.0 + value.microsecond / 1000000.0,
  );
}

// Operators
XPathSequence opDateTimeEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDateTime();
  final val2 = arg2.firstOrNull?.toXPathDateTime();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1.isAtSameMomentAs(val2));
}

XPathSequence opDateTimeLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDateTime();
  final val2 = arg2.firstOrNull?.toXPathDateTime();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1.isBefore(val2));
}

XPathSequence opDateTimeGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDateTime();
  final val2 = arg2.firstOrNull?.toXPathDateTime();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1.isAfter(val2));
}

// TODO: Specialized operators for Date and Time if distinct types are introduced.
// For now, reusing DateTime logic as they are likely represented as DateTime.
XPathSequence opDateEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

XPathSequence opDateLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeLessThan(context, arg1, arg2);

XPathSequence opDateGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeGreaterThan(context, arg1, arg2);

XPathSequence opTimeEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

XPathSequence opTimeLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeLessThan(context, arg1, arg2);

XPathSequence opTimeGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeGreaterThan(context, arg1, arg2);

// Arithmetic
XPathSequence opSubtractDateTimes(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDateTime();
  final val2 = arg2.firstOrNull?.toXPathDateTime();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1.difference(val2).toXPathDuration());
}

XPathSequence opSubtractDates(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opSubtractDateTimes(context, arg1, arg2);

XPathSequence opSubtractTimes(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opSubtractDateTimes(context, arg1, arg2);

XPathSequence opAddDurationToDateTime(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDateTime();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1.add(val2).toXPathDateTime());
}

XPathSequence opSubtractDurationFromDateTime(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathDateTime();
  final val2 = arg2.firstOrNull?.toXPathDuration();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1.subtract(val2).toXPathDateTime());
}

// Extraction functions

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
XPathSequence fnTimezoneFromDateTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.timeZoneOffset);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
XPathSequence fnYearFromDate(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
XPathSequence fnMonthFromDate(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
XPathSequence fnDayFromDate(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
XPathSequence fnTimezoneFromDate(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.timeZoneOffset);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
XPathSequence fnHoursFromTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
XPathSequence fnMinutesFromTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
XPathSequence fnSecondsFromTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(
    value.second + value.millisecond / 1000.0 + value.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
XPathSequence fnTimezoneFromTime(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathDateTime();
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.timeZoneOffset);
}
