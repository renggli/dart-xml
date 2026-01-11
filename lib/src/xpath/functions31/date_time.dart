import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
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
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDateTime();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(
    DateTime(
      arg1Opt.year,
      arg1Opt.month,
      arg1Opt.day,
      arg2Opt.hour,
      arg2Opt.minute,
      arg2Opt.second,
      arg2Opt.millisecond,
      arg2Opt.microsecond,
    ).toXPathDateTime(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-dateTime
XPathSequence fnYearFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-dateTime
XPathSequence fnMonthFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-dateTime
XPathSequence fnDayFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-dateTime
XPathSequence fnHoursFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-dateTime
XPathSequence fnMinutesFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-dateTime
XPathSequence fnSecondsFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(
    argOpt.second +
        argOpt.millisecond / 1000.0 +
        argOpt.microsecond / 1000000.0,
  );
}

// Operators
XPathSequence opDateTimeEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDateTime();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(arg1Opt.isAtSameMomentAs(arg2Opt));
}

XPathSequence opDateTimeLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDateTime();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(arg1Opt.isBefore(arg2Opt));
}

XPathSequence opDateTimeGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDateTime();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(arg1Opt.isAfter(arg2Opt));
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
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDateTime();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(arg1Opt.difference(arg2Opt).toXPathDuration());
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
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDuration();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(arg1Opt.add(arg2Opt).toXPathDateTime());
}

XPathSequence opSubtractDurationFromDateTime(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final arg1Opt = XPathEvaluationException.checkZeroOrOne(
    arg1,
  )?.toXPathDateTime();
  final arg2Opt = XPathEvaluationException.checkZeroOrOne(
    arg2,
  )?.toXPathDuration();
  if (arg1Opt == null || arg2Opt == null) return XPathSequence.empty;
  return XPathSequence.single(arg1Opt.subtract(arg2Opt).toXPathDateTime());
}

// Extraction functions

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-dateTime
XPathSequence fnTimezoneFromDateTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-year-from-date
XPathSequence fnYearFromDate(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.year);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-month-from-date
XPathSequence fnMonthFromDate(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.month);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-day-from-date
XPathSequence fnDayFromDate(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.day);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-date
XPathSequence fnTimezoneFromDate(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.timeZoneOffset.toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-time
XPathSequence fnHoursFromTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.hour);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-time
XPathSequence fnMinutesFromTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.minute);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-time
XPathSequence fnSecondsFromTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(
    argOpt.second +
        argOpt.millisecond / 1000.0 +
        argOpt.microsecond / 1000000.0,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-timezone-from-time
XPathSequence fnTimezoneFromTime(XPathContext context, XPathSequence arg) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(
    arg,
  )?.toXPathDateTime();
  if (argOpt == null) return XPathSequence.empty;
  return XPathSequence.single(argOpt.timeZoneOffset.toXPathDuration());
}

// Missing operators
XPathSequence opGYearMonthEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

XPathSequence opGYearEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

XPathSequence opGMonthDayEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

XPathSequence opGMonthEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

XPathSequence opGDayEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) => opDateTimeEqual(context, arg1, arg2);

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-dateTime-to-timezone
XPathSequence fnAdjustDateTimeToTimezone(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? timezone,
]) {
  // TODO: Implement timezone adjustment
  throw UnimplementedError('fn:adjust-dateTime-to-timezone');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-date-to-timezone
XPathSequence fnAdjustDateToTimezone(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? timezone,
]) {
  // TODO: Implement timezone adjustment
  throw UnimplementedError('fn:adjust-date-to-timezone');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-adjust-time-to-timezone
XPathSequence fnAdjustTimeToTimezone(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? timezone,
]) {
  // TODO: Implement timezone adjustment
  throw UnimplementedError('fn:adjust-time-to-timezone');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-dateTime
XPathSequence fnFormatDateTime(
  XPathContext context,
  XPathSequence value,
  XPathSequence picture, [
  XPathSequence? language,
  XPathSequence? calendar,
  XPathSequence? place,
]) {
  // TODO: Implement dateTime formatting
  throw UnimplementedError('fn:format-dateTime');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-date
XPathSequence fnFormatDate(
  XPathContext context,
  XPathSequence value,
  XPathSequence picture, [
  XPathSequence? language,
  XPathSequence? calendar,
  XPathSequence? place,
]) {
  // TODO: Implement date formatting
  throw UnimplementedError('fn:format-date');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-time
XPathSequence fnFormatTime(
  XPathContext context,
  XPathSequence value,
  XPathSequence picture, [
  XPathSequence? language,
  XPathSequence? calendar,
  XPathSequence? place,
]) {
  // TODO: Implement time formatting
  throw UnimplementedError('fn:format-time');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-ietf-date
XPathSequence fnParseIetfDate(XPathContext context, XPathSequence value) {
  // TODO: Implement parsing
  throw UnimplementedError('fn:parse-ietf-date');
}
