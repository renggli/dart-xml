import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-years-from-duration
const fnYearsFromDuration = XPathFunctionItem.fn1(
  XmlName.qualified('fn:years-from-duration'),
  _fnYearsFromDuration,
);

XPathSequence _fnYearsFromDuration(XPathContext context, XPathSequence arg) {
  final item = arg.firstOrNull;
  if (item == null) return XPathSequence.empty;
  final duration = item as XPathDuration;
  final years = duration.years;
  return XPathSequence.single(
    XPathInteger.fromInt(duration.isNegative ? -years : years),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-months-from-duration
const fnMonthsFromDuration = XPathFunctionItem.fn1(
  XmlName.qualified('fn:months-from-duration'),
  _fnMonthsFromDuration,
);

XPathSequence _fnMonthsFromDuration(XPathContext context, XPathSequence arg) {
  final item = arg.firstOrNull;
  if (item == null) return XPathSequence.empty;
  final duration = item as XPathDuration;
  final months = duration.months;
  return XPathSequence.single(
    XPathInteger.fromInt(duration.isNegative ? -months : months),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-days-from-duration
const fnDaysFromDuration = XPathFunctionItem.fn1(
  XmlName.qualified('fn:days-from-duration'),
  _fnDaysFromDuration,
);

XPathSequence _fnDaysFromDuration(XPathContext context, XPathSequence arg) {
  final item = arg.firstOrNull;
  if (item == null) return XPathSequence.empty;
  final duration = item as XPathDuration;
  final days = duration.days;
  return XPathSequence.single(
    XPathInteger.fromInt(duration.isNegative ? -days : days),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-duration
const fnHoursFromDuration = XPathFunctionItem.fn1(
  XmlName.qualified('fn:hours-from-duration'),
  _fnHoursFromDuration,
);

XPathSequence _fnHoursFromDuration(XPathContext context, XPathSequence arg) {
  final item = arg.firstOrNull;
  if (item == null) return XPathSequence.empty;
  final duration = item as XPathDuration;
  final hours = duration.hours;
  return XPathSequence.single(
    XPathInteger.fromInt(duration.isNegative ? -hours : hours),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-duration
const fnMinutesFromDuration = XPathFunctionItem.fn1(
  XmlName.qualified('fn:minutes-from-duration'),
  _fnMinutesFromDuration,
);

XPathSequence _fnMinutesFromDuration(XPathContext context, XPathSequence arg) {
  final item = arg.firstOrNull;
  if (item == null) return XPathSequence.empty;
  final duration = item as XPathDuration;
  final minutes = duration.minutes;
  return XPathSequence.single(
    XPathInteger.fromInt(duration.isNegative ? -minutes : minutes),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-duration
const fnSecondsFromDuration = XPathFunctionItem.fn1(
  XmlName.qualified('fn:seconds-from-duration'),
  _fnSecondsFromDuration,
);

XPathSequence _fnSecondsFromDuration(XPathContext context, XPathSequence arg) {
  final item = arg.firstOrNull;
  if (item == null) return XPathSequence.empty;
  final duration = item as XPathDuration;
  final s = duration.seconds;
  final ms = duration.milliseconds;
  final us = duration.microseconds;
  final seconds = s + ms / 1000.0 + us / 1000000.0;
  final value = duration.isNegative ? -seconds : seconds;
  return XPathSequence.single(XPathDecimal.fromNum(value));
}
