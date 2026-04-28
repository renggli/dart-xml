import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/duration.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-years-from-duration
const fnYearsFromDuration = XPathFunctionDefinition(
  name: XmlName.qualified('fn:years-from-duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnYearsFromDuration,
);

XPathSequence _fnYearsFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  final absMonths = arg.months.abs();
  final years = absMonths ~/ 12;
  return XPathSequence.single(arg.months < 0 ? -years : years);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-months-from-duration
const fnMonthsFromDuration = XPathFunctionDefinition(
  name: XmlName.qualified('fn:months-from-duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonthsFromDuration,
);

XPathSequence _fnMonthsFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  final absMonths = arg.months.abs();
  final remaining = absMonths.remainder(12);
  return XPathSequence.single(arg.months < 0 ? -remaining : remaining);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-days-from-duration
const fnDaysFromDuration = XPathFunctionDefinition(
  name: XmlName.qualified('fn:days-from-duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDaysFromDuration,
);

XPathSequence _fnDaysFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  // days-from-duration only counts the day part of the dayTime component.
  final days = arg.dayTime.abs().inDays;
  return XPathSequence.single(arg.dayTime.isNegative ? -days : days);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-duration
const fnHoursFromDuration = XPathFunctionDefinition(
  name: XmlName.qualified('fn:hours-from-duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnHoursFromDuration,
);

XPathSequence _fnHoursFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  final hours = arg.dayTime.abs().inHours.remainder(24);
  return XPathSequence.single(arg.dayTime.isNegative ? -hours : hours);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-duration
const fnMinutesFromDuration = XPathFunctionDefinition(
  name: XmlName.qualified('fn:minutes-from-duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutesFromDuration,
);

XPathSequence _fnMinutesFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  final minutes = arg.dayTime.abs().inMinutes.remainder(60);
  return XPathSequence.single(arg.dayTime.isNegative ? -minutes : minutes);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-duration
const fnSecondsFromDuration = XPathFunctionDefinition(
  name: XmlName.qualified('fn:seconds-from-duration'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsDuration,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnSecondsFromDuration,
);

XPathSequence _fnSecondsFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  final abs = arg.dayTime.abs();
  final wholeSeconds = abs.inSeconds.remainder(60);
  final microRemainder = abs.inMicroseconds.remainder(
    Duration.microsecondsPerSecond,
  );
  final seconds =
      wholeSeconds + microRemainder / Duration.microsecondsPerSecond;
  return XPathSequence.single(arg.dayTime.isNegative ? -seconds : seconds);
}
