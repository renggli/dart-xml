import 'dart:math' as math;
import 'package:collection/collection.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
const opNumericAdd = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-add',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericAdd,
);

XPathSequence _opNumericAdd(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1 + arg2);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
const opNumericSubtract = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-subtract',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericSubtract,
);

XPathSequence _opNumericSubtract(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1 - arg2);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
const opNumericMultiply = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-multiply',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericMultiply,
);

XPathSequence _opNumericMultiply(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1 * arg2);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
const opNumericDivide = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-divide',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericDivide,
);

XPathSequence _opNumericDivide(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1 / arg2);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
const opNumericIntegerDivide = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-integer-divide',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericIntegerDivide,
);

XPathSequence _opNumericIntegerDivide(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single((arg1 / arg2).truncate());

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
const opNumericMod = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-mod',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericMod,
);

XPathSequence _opNumericMod(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1 % arg2);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
const opNumericUnaryPlus = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-unary-plus',
  requiredArguments: [XPathArgumentDefinition(name: 'arg', type: XPathNumber)],
  function: _opNumericUnaryPlus,
);

XPathSequence _opNumericUnaryPlus(XPathContext context, XPathNumber arg) =>
    XPathSequence.single(arg);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
const opNumericUnaryMinus = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-unary-minus',
  requiredArguments: [XPathArgumentDefinition(name: 'arg', type: XPathNumber)],
  function: _opNumericUnaryMinus,
);

XPathSequence _opNumericUnaryMinus(XPathContext context, XPathNumber arg) =>
    XPathSequence.single(-arg);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
const opNumericEqual = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-equal',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericEqual,
);

XPathSequence _opNumericEqual(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1.compareTo(arg2) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
const opNumericLessThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-less-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericLessThan,
);

XPathSequence _opNumericLessThan(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1.compareTo(arg2) < 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
const opNumericGreaterThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'numeric-greater-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathNumber),
    XPathArgumentDefinition(name: 'arg2', type: XPathNumber),
  ],
  function: _opNumericGreaterThan,
);

XPathSequence _opNumericGreaterThan(
  XPathContext context,
  XPathNumber arg1,
  XPathNumber arg2,
) => XPathSequence.single(arg1.compareTo(arg2) > 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
const fnFormatInteger = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-integer',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'language',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatInteger,
);

XPathSequence _fnFormatInteger(
  XPathContext context,
  XPathNumber? value,
  XPathString picture, [
  XPathString? language,
]) {
  if (value == null) return XPathSequence.empty;
  // Basic implementation ignoring picture string intricacies
  // TODO: Add proper picture string parsing support
  return XPathSequence.single(XPathString(value.toInt().toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-number
const fnFormatNumber = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-number',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'picture', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'decimal-format-name',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnFormatNumber,
);

XPathSequence _fnFormatNumber(
  XPathContext context,
  XPathNumber? value,
  XPathString picture, [
  XPathString? decimalFormatName,
]) {
  if (value == null) return XPathSequence.empty;
  // Basic implementation
  // TODO: Add proper picture string parsing support
  return XPathSequence.single(XPathString(value.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
const fnAbs = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'abs',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnAbs,
);

XPathSequence _fnAbs(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.abs());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ceiling
const fnCeiling = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'ceiling',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnCeiling,
);

XPathSequence _fnCeiling(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.ceil());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
const fnFloor = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'floor',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnFloor,
);

XPathSequence _fnFloor(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.floor());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round
const fnRound = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'round',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'precision',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnRound,
);

XPathSequence _fnRound(
  XPathContext context,
  XPathNumber? arg, [
  Object? precision = _missing,
]) {
  if (arg == null) return XPathSequence.empty;
  if (arg.isNaN || arg.isInfinite) return XPathSequence.single(arg);
  final p = precision is XPathNumber ? precision.toInt() : 0;
  if (p == 0) return XPathSequence.single(arg.round());
  final factor = math.pow(10, p);
  return XPathSequence.single((arg * factor).round() / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
const fnRoundHalfToEven = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'round-half-to-even',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'precision',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnRoundHalfToEven,
);

XPathSequence _fnRoundHalfToEven(
  XPathContext context,
  XPathNumber? arg, [
  Object? precision = _missing,
]) {
  if (arg == null) return XPathSequence.empty;
  if (arg.isNaN || arg.isInfinite) return XPathSequence.single(arg);
  final p = precision is XPathNumber ? precision.toInt() : 0;
  final factor = math.pow(10, p);
  final value = arg * factor;
  final rounded = value.roundToDouble();
  final result = ((value - rounded).abs() == 0.5 && rounded % 2 != 0)
      ? rounded - (rounded > value ? 1.0 : -1.0)
      : rounded;
  return XPathSequence.single(result / factor);
}

const _missing = Object();

/// https://www.w3.org/TR/xpath-functions-31/#func-number
const fnNumber = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'number',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ), // Manually handle to check for empty
  ],
  function: _fnNumber,
);

XPathSequence _fnNumber(XPathContext context, [Object? arg = _missing]) {
  if (identical(arg, _missing)) {
    return XPathSequence.single(context.value.toXPathNumber());
  }
  if (arg == null) {
    return const XPathSequence.single(double.nan); // Empty sequence
  }
  final sequence = arg as XPathSequence;
  if (sequence.isEmpty) return const XPathSequence.single(double.nan);
  return XPathSequence.single(sequence.toXPathNumber());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pi
const mathPi = XPathFunctionDefinition(
  namespace: 'math',
  name: 'pi',
  function: _mathPi,
);

XPathSequence _mathPi(XPathContext context) =>
    const XPathSequence.single(math.pi);

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp
const mathExp = XPathFunctionDefinition(
  namespace: 'math',
  name: 'exp',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathExp,
);

XPathSequence _mathExp(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.exp(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp10
const mathExp10 = XPathFunctionDefinition(
  namespace: 'math',
  name: 'exp10',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathExp10,
);

XPathSequence _mathExp10(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(10, arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log
const mathLog = XPathFunctionDefinition(
  namespace: 'math',
  name: 'log',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathLog,
);

XPathSequence _mathLog(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log10
const mathLog10 = XPathFunctionDefinition(
  namespace: 'math',
  name: 'log10',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathLog10,
);

XPathSequence _mathLog10(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(arg) / math.ln10);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pow
const mathPow = XPathFunctionDefinition(
  namespace: 'math',
  name: 'pow',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'x',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'y', type: XPathNumber),
  ],
  function: _mathPow,
);

XPathSequence _mathPow(XPathContext context, XPathNumber? x, XPathNumber y) {
  if (x == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(x, y));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sqrt
const mathSqrt = XPathFunctionDefinition(
  namespace: 'math',
  name: 'sqrt',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathSqrt,
);

XPathSequence _mathSqrt(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.sqrt(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sin
const mathSin = XPathFunctionDefinition(
  namespace: 'math',
  name: 'sin',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathSin,
);

XPathSequence _mathSin(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.sin(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-cos
const mathCos = XPathFunctionDefinition(
  namespace: 'math',
  name: 'cos',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathCos,
);

XPathSequence _mathCos(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.cos(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-tan
const mathTan = XPathFunctionDefinition(
  namespace: 'math',
  name: 'tan',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathTan,
);

XPathSequence _mathTan(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.tan(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-asin
const mathAsin = XPathFunctionDefinition(
  namespace: 'math',
  name: 'asin',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathAsin,
);

XPathSequence _mathAsin(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.asin(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-acos
const mathAcos = XPathFunctionDefinition(
  namespace: 'math',
  name: 'acos',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathAcos,
);

XPathSequence _mathAcos(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.acos(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan
const mathAtan = XPathFunctionDefinition(
  namespace: 'math',
  name: 'atan',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _mathAtan,
);

XPathSequence _mathAtan(XPathContext context, XPathNumber? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.atan(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan2
const mathAtan2 = XPathFunctionDefinition(
  namespace: 'math',
  name: 'atan2',
  requiredArguments: [
    XPathArgumentDefinition(name: 'y', type: XPathNumber),
    XPathArgumentDefinition(name: 'x', type: XPathNumber),
  ],
  function: _mathAtan2,
);

XPathSequence _mathAtan2(XPathContext context, XPathNumber y, XPathNumber x) =>
    XPathSequence.single(math.atan2(y, x));

/// https://www.w3.org/TR/xpath-functions-31/#func-random-number-generator
const fnRandomNumberGenerator = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'random-number-generator',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'seed',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnRandomNumberGenerator,
);

XPathSequence _fnRandomNumberGenerator(
  XPathContext context, [
  XPathSequence? seed,
]) {
  final seedCode = seed != null && seed.isNotEmpty ? seed.first.hashCode : null;
  final random = math.Random(seedCode);
  final generator = <String, Object>{};
  generator['number'] = random.nextDouble();
  generator['next'] = (XPathContext context, List<XPathSequence> args) =>
      generator['number'] = random.nextDouble();
  generator['permute'] = (XPathContext context, List<XPathSequence> args) =>
      XPathSequence(args[0].shuffled(random));
  return XPathSequence.single(generator);
}
