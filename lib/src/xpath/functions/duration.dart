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

XPathSequence _fnYearsFromDuration(XPathContext context, Duration? arg) {
  if (arg == null) return XPathSequence.empty;
  final months = arg.abs().inDays ~/ 30;
  final years = months ~/ 12;
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

XPathSequence _fnMonthsFromDuration(XPathContext context, Duration? arg) {
  if (arg == null) return XPathSequence.empty;
  final months = arg.abs().inDays ~/ 30;
  final remainingMonths = months.remainder(12);
  return XPathSequence.single(
    arg.isNegative ? -remainingMonths : remainingMonths,
  );
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

XPathSequence _fnDaysFromDuration(XPathContext context, Duration? arg) {
  if (arg == null) return XPathSequence.empty;
  final days = arg.abs().inDays;
  final remainingDays = days % 30;
  return XPathSequence.single(arg.isNegative ? -remainingDays : remainingDays);
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

XPathSequence _fnHoursFromDuration(XPathContext context, Duration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inHours % 24);
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

XPathSequence _fnMinutesFromDuration(XPathContext context, Duration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inMinutes % 60);
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

XPathSequence _fnSecondsFromDuration(XPathContext context, Duration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.inSeconds % 60 + (arg.inMicroseconds % 1000000) / 1000000.0,
  );
}
