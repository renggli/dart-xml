import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/duration.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-years-from-duration
const fnYearsFromDuration = XPathFunctionDefinition(
  name: 'fn:years-from-duration',
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
  return const XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-months-from-duration
const fnMonthsFromDuration = XPathFunctionDefinition(
  name: 'fn:months-from-duration',
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
  return const XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-days-from-duration
const fnDaysFromDuration = XPathFunctionDefinition(
  name: 'fn:days-from-duration',
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
  return XPathSequence.single(arg.inDays);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-duration
const fnHoursFromDuration = XPathFunctionDefinition(
  name: 'fn:hours-from-duration',
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
  name: 'fn:minutes-from-duration',
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
  name: 'fn:seconds-from-duration',
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
