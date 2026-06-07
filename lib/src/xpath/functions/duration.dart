import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/duration.dart';
import '../values/duration.dart';
import '../values/sequence.dart';

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

XPathSequence _fnYearsFromDuration(
  XPathContext context,
  XPathAbstractDuration? arg,
) {
  if (arg == null) return XPathSequence.empty;
  final years = arg.years ?? 0;
  return XPathSequence.single(arg.isNegative ? -years : years);
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

XPathSequence _fnMonthsFromDuration(
  XPathContext context,
  XPathAbstractDuration? arg,
) {
  if (arg == null) return XPathSequence.empty;
  final months = arg.months ?? 0;
  return XPathSequence.single(arg.isNegative ? -months : months);
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

XPathSequence _fnDaysFromDuration(
  XPathContext context,
  XPathAbstractDuration? arg,
) {
  if (arg == null) return XPathSequence.empty;
  final days = arg.days ?? 0;
  return XPathSequence.single(arg.isNegative ? -days : days);
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

XPathSequence _fnHoursFromDuration(
  XPathContext context,
  XPathAbstractDuration? arg,
) {
  if (arg == null) return XPathSequence.empty;
  final hours = arg.hours ?? 0;
  return XPathSequence.single(arg.isNegative ? -hours : hours);
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

XPathSequence _fnMinutesFromDuration(
  XPathContext context,
  XPathAbstractDuration? arg,
) {
  if (arg == null) return XPathSequence.empty;
  final minutes = arg.minutes ?? 0;
  return XPathSequence.single(arg.isNegative ? -minutes : minutes);
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

XPathSequence _fnSecondsFromDuration(
  XPathContext context,
  XPathAbstractDuration? arg,
) {
  if (arg == null) return XPathSequence.empty;
  final s = arg.seconds ?? 0;
  final ms = arg.milliseconds ?? 0;
  final us = arg.microseconds ?? 0;
  final seconds = s + ms / 1000.0 + us / 1000000.0;
  return XPathSequence.single(arg.isNegative ? -seconds : seconds);
}
