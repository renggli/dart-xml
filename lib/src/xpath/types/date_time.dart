import '../../../xml.dart';
import '../definitions/type.dart';
import '../exceptions/evaluation_exception.dart';
import '../values/date_time.dart';
import '../values/sequence.dart';
import 'string.dart';

/// The XPath dateTime type.
const xsDateTime = _XPathDateTimeType();

class _XPathDateTimeType extends XPathType<XPathDateTime> {
  const _XPathDateTimeType();

  @override
  String get name => 'xs:dateTime';

  @override
  bool matches(Object value) =>
      value is XPathDateTime ||
      value is XPathDateTimeStamp ||
      value is DateTime;

  @override
  XPathDateTime cast(Object value) => switch (value) {
    XPathDateTime() => value,
    DateTime() => XPathDateTime.fromDateTime(
      value,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathDate() => XPathDateTime(
      value.year,
      value.month,
      value.day,
      0,
      0,
      0,
      0,
      0,
      value.timezoneOffsetMinutes,
    ),
    XPathTime() => XPathDateTime(
      1970,
      1,
      1,
      value.hour,
      value.minute,
      value.second,
      value.millisecond,
      value.microsecond,
      value.timezoneOffsetMinutes,
    ),
    XPathAbstractDateTime() => XPathDateTime(
      value.year ?? 1970,
      value.month ?? 1,
      value.day ?? 1,
      value.hour ?? 0,
      value.minute ?? 0,
      value.second ?? 0,
      value.millisecond ?? 0,
      value.microsecond ?? 0,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseDateTime(value.trim()),
    XmlNode() => _parseDateTime(xsString.cast(value).trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDateTime _parseDateTime(String value) =>
      XPathDateTime.tryParse(value) ??
      (throw XPathEvaluationException.unsupportedCast(this, value));

  @override
  String castToString(XPathDateTime value) => value.toString();
}

/// The XPath dateTimeStamp type.
const xsDateTimeStamp = _XPathDateTimeStampType();

class _XPathDateTimeStampType extends XPathType<XPathDateTimeStamp> {
  const _XPathDateTimeStampType();

  @override
  String get name => 'xs:dateTimeStamp';

  @override
  bool matches(Object value) =>
      value is XPathDateTimeStamp || (value is DateTime && value.isUtc);

  @override
  XPathDateTimeStamp cast(Object value) => switch (value) {
    XPathDateTimeStamp() => value,
    DateTime() when value.isUtc => XPathDateTimeStamp.fromDateTime(value, 0),
    DateTime() => XPathDateTimeStamp.fromDateTime(
      value,
      value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() when value.timezoneOffsetMinutes != null =>
      XPathDateTimeStamp(
        value.year ?? 1970,
        value.month ?? 1,
        value.day ?? 1,
        value.hour ?? 0,
        value.minute ?? 0,
        value.second ?? 0,
        value.millisecond ?? 0,
        value.microsecond ?? 0,
        value.timezoneOffsetMinutes!,
      ),
    String() => _parseDateTimeStamp(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDateTimeStamp _parseDateTimeStamp(String trimmed) =>
      XPathDateTimeStamp.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathDateTimeStamp value) => value.toString();
}

/// The XPath date type.
const xsDate = _XPathDateType();

class _XPathDateType extends XPathType<XPathDate> {
  const _XPathDateType();

  @override
  String get name => 'xs:date';

  @override
  bool matches(Object value) => value is XPathDate || value is DateTime;

  @override
  XPathDate cast(Object value) => switch (value) {
    XPathDate() => value,
    DateTime() => XPathDate.fromDateTime(
      value,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathDate(
      value.year ?? 1970,
      value.month ?? 1,
      value.day ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseDate(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDate _parseDate(String trimmed) =>
      XPathDate.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathDate value) => value.toString();
}

/// The XPath time type.
const xsTime = _XPathTimeType();

class _XPathTimeType extends XPathType<XPathTime> {
  const _XPathTimeType();

  @override
  String get name => 'xs:time';

  @override
  bool matches(Object value) => value is XPathTime || value is DateTime;

  @override
  XPathTime cast(Object value) => switch (value) {
    XPathTime() => value,
    DateTime() => XPathTime.fromDateTime(
      value,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathTime(
      value.hour ?? 0,
      value.minute ?? 0,
      value.second ?? 0,
      value.millisecond ?? 0,
      value.microsecond ?? 0,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseTime(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathTime _parseTime(String trimmed) =>
      XPathTime.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathTime value) => value.toString();
}

/// The XPath gYearMonth type.
const xsYearMonth = _XPathYearMonthType();

class _XPathYearMonthType extends XPathType<XPathYearMonth> {
  const _XPathYearMonthType();

  @override
  String get name => 'xs:gYearMonth';

  @override
  bool matches(Object value) => value is XPathYearMonth || value is DateTime;

  @override
  XPathYearMonth cast(Object value) => switch (value) {
    XPathYearMonth() => value,
    DateTime() => XPathYearMonth(
      value.year,
      value.month,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathYearMonth(
      value.year ?? 1970,
      value.month ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseYearMonth(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathYearMonth _parseYearMonth(String trimmed) =>
      XPathYearMonth.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathYearMonth value) => value.toString();
}

/// The XPath gYear type.
const xsYear = _XPathYearType();

class _XPathYearType extends XPathType<XPathYear> {
  const _XPathYearType();

  @override
  String get name => 'xs:gYear';

  @override
  bool matches(Object value) => value is XPathYear || value is DateTime;

  @override
  XPathYear cast(Object value) => switch (value) {
    XPathYear() => value,
    DateTime() => XPathYear(
      value.year,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathYear(
      value.year ?? 1970,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseYear(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathYear _parseYear(String trimmed) =>
      XPathYear.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathYear value) => value.toString();
}

/// The XPath gMonthDay type.
const xsMonthDay = _XPathMonthDayType();

class _XPathMonthDayType extends XPathType<XPathMonthDay> {
  const _XPathMonthDayType();

  @override
  String get name => 'xs:gMonthDay';

  @override
  bool matches(Object value) => value is XPathMonthDay || value is DateTime;

  @override
  XPathMonthDay cast(Object value) => switch (value) {
    XPathMonthDay() => value,
    DateTime() => XPathMonthDay(
      value.month,
      value.day,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathMonthDay(
      value.month ?? 1,
      value.day ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseMonthDay(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathMonthDay _parseMonthDay(String trimmed) =>
      XPathMonthDay.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathMonthDay value) => value.toString();
}

/// The XPath gMonth type.
const xsMonth = _XPathMonthType();

class _XPathMonthType extends XPathType<XPathMonth> {
  const _XPathMonthType();

  @override
  String get name => 'xs:gMonth';

  @override
  bool matches(Object value) => value is XPathMonth || value is DateTime;

  @override
  XPathMonth cast(Object value) => switch (value) {
    XPathMonth() => value,
    DateTime() => XPathMonth(
      value.month,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathMonth(
      value.month ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseMonth(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathMonth _parseMonth(String trimmed) =>
      XPathMonth.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathMonth value) => value.toString();
}

/// The XPath gDay type.
const xsDay = _XPathDayType();

class _XPathDayType extends XPathType<XPathDay> {
  const _XPathDayType();

  @override
  String get name => 'xs:gDay';

  @override
  bool matches(Object value) => value is XPathDay || value is DateTime;

  @override
  XPathDay cast(Object value) => switch (value) {
    XPathDay() => value,
    DateTime() => XPathDay(
      value.day,
      value.isUtc ? 0 : value.timeZoneOffset.inMinutes,
    ),
    XPathAbstractDateTime() => XPathDay(
      value.day ?? 1,
      value.timezoneOffsetMinutes,
    ),
    String() => _parseDay(value.trim()),
    XPathSequence(singleOrNull: final item?) => cast(item),
    _ => throw XPathEvaluationException.unsupportedCast(this, value),
  };

  XPathDay _parseDay(String trimmed) =>
      XPathDay.tryParse(trimmed) ??
      (throw XPathEvaluationException.unsupportedCast(this, trimmed));

  @override
  String castToString(XPathDay value) => value.toString();
}
