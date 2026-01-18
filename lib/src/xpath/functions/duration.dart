import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-duration-equal
const opDurationEqual = XPathFunctionDefinition(
  namespace: 'op',
  name: 'duration-equal',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDurationEqual,
);

XPathSequence _opDurationEqual(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.compareTo(arg2) == 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-less-than
const opYearMonthDurationLessThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'yearMonthDuration-less-than',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opYearMonthDurationLessThan,
);

XPathSequence _opYearMonthDurationLessThan(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.compareTo(arg2) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-yearMonthDuration-greater-than
const opYearMonthDurationGreaterThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'yearMonthDuration-greater-than',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opYearMonthDurationGreaterThan,
);

XPathSequence _opYearMonthDurationGreaterThan(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.compareTo(arg2) > 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-less-than
const opDayTimeDurationLessThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'dayTimeDuration-less-than',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDayTimeDurationLessThan,
);

XPathSequence _opDayTimeDurationLessThan(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.compareTo(arg2) < 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-dayTimeDuration-greater-than
const opDayTimeDurationGreaterThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'dayTimeDuration-greater-than',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDayTimeDurationGreaterThan,
);

XPathSequence _opDayTimeDurationGreaterThan(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single(arg1.compareTo(arg2) > 0);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-yearMonthDurations
const opAddYearMonthDurations = XPathFunctionDefinition(
  namespace: 'op',
  name: 'add-yearMonthDurations',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opAddDurations,
);

XPathSequence _opAddDurations(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 + arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-yearMonthDurations
const opSubtractYearMonthDurations = XPathFunctionDefinition(
  namespace: 'op',
  name: 'subtract-yearMonthDurations',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opSubtractDurations,
);

XPathSequence _opSubtractDurations(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 - arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-yearMonthDuration
const opMultiplyYearMonthDuration = XPathFunctionDefinition(
  namespace: 'op',
  name: 'multiply-yearMonthDuration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opMultiplyDuration,
);

XPathSequence _opMultiplyDuration(
  XPathContext context,
  XPathDuration? arg1,
  XPathNumber? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 * arg2).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration
const opDivideYearMonthDuration = XPathFunctionDefinition(
  namespace: 'op',
  name: 'divide-yearMonthDuration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDivideDuration,
);

XPathSequence _opDivideDuration(
  XPathContext context,
  XPathDuration? arg1,
  XPathNumber? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  return XPathSequence.single((arg1 ~/ arg2.toInt()).toXPathDuration());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-yearMonthDuration-by-yearMonthDuration
const opDivideYearMonthDurationByYearMonthDuration = XPathFunctionDefinition(
  namespace: 'op',
  name: 'divide-yearMonthDuration-by-yearMonthDuration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDivideDurationByDuration,
);

XPathSequence _opDivideDurationByDuration(
  XPathContext context,
  XPathDuration? arg1,
  XPathDuration? arg2,
) {
  if (arg1 == null || arg2 == null) return XPathSequence.empty;
  if (arg2.inMicroseconds == 0) {
    throw XPathEvaluationException('Division by zero');
  }
  return XPathSequence.single(arg1.inMicroseconds / arg2.inMicroseconds);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-add-dayTimeDurations
const opAddDayTimeDurations = XPathFunctionDefinition(
  namespace: 'op',
  name: 'add-dayTimeDurations',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opAddDurations,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-subtract-dayTimeDurations
const opSubtractDayTimeDurations = XPathFunctionDefinition(
  namespace: 'op',
  name: 'subtract-dayTimeDurations',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opSubtractDurations,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-multiply-dayTimeDuration
const opMultiplyDayTimeDuration = XPathFunctionDefinition(
  namespace: 'op',
  name: 'multiply-dayTimeDuration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opMultiplyDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration
const opDivideDayTimeDuration = XPathFunctionDefinition(
  namespace: 'op',
  name: 'divide-dayTimeDuration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDivideDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-divide-dayTimeDuration-by-dayTimeDuration
const opDivideDayTimeDurationByDayTimeDuration = XPathFunctionDefinition(
  namespace: 'op',
  name: 'divide-dayTimeDuration-by-dayTimeDuration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _opDivideDurationByDuration,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-years-from-duration
const fnYearsFromDuration = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'years-from-duration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnYearsFromDuration,
);

XPathSequence _fnYearsFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  return const XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-months-from-duration
const fnMonthsFromDuration = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'months-from-duration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMonthsFromDuration,
);

XPathSequence _fnMonthsFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  return const XPathSequence.single(0); // Not supported in Dart
}

/// https://www.w3.org/TR/xpath-functions-31/#func-days-from-duration
const fnDaysFromDuration = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'days-from-duration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDaysFromDuration,
);

XPathSequence _fnDaysFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inDays);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-hours-from-duration
const fnHoursFromDuration = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'hours-from-duration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnHoursFromDuration,
);

XPathSequence _fnHoursFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inHours % 24);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-minutes-from-duration
const fnMinutesFromDuration = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'minutes-from-duration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMinutesFromDuration,
);

XPathSequence _fnMinutesFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.inMinutes % 60);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-seconds-from-duration
const fnSecondsFromDuration = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'seconds-from-duration',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathDuration,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSecondsFromDuration,
);

XPathSequence _fnSecondsFromDuration(XPathContext context, XPathDuration? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(
    arg.inSeconds % 60 + (arg.inMicroseconds % 1000000) / 1000000.0,
  );
}
