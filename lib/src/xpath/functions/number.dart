import 'dart:math' as math;
import 'package:collection/collection.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('op:numeric-add', arguments, 2);
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-add',
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-add',
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single(arg1 + arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:numeric-subtract',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-subtract',
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-subtract',
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single(arg1 - arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:numeric-multiply',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-multiply',
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-multiply',
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single(arg1 * arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:numeric-divide',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-divide',
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-divide',
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single(arg1 / arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:numeric-integer-divide',
    arguments,
    2,
  );
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-integer-divide',
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-integer-divide',
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single((arg1 / arg2).truncate());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('op:numeric-mod', arguments, 2);
  final arg1 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-mod',
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final arg2 = XPathEvaluationException.extractExactlyOne(
    'op:numeric-mod',
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single(arg1 % arg2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:numeric-unary-plus',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractExactlyOne(
    'op:numeric-unary-plus',
    'arg',
    arguments[0],
  ).toXPathNumber();
  return XPathSequence.single(arg);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'op:numeric-unary-minus',
    arguments,
    1,
  );
  final arg = XPathEvaluationException.extractExactlyOne(
    'op:numeric-unary-minus',
    'arg',
    arguments[0],
  ).toXPathNumber();
  return XPathSequence.single(-arg);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
XPathSequence opNumericEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareNumber('op:numeric-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
XPathSequence opNumericLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) =>
    XPathSequence.single(_compareNumber('op:numeric-less-than', arguments) < 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
XPathSequence opNumericGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareNumber('op:numeric-greater-than', arguments) > 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
XPathSequence fnFormatInteger(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:format-integer',
    arguments,
    2,
    3,
  );
  final value = XPathEvaluationException.extractZeroOrOne(
    'fn:format-integer',
    'value',
    arguments[0],
  )?.toXPathNumber();
  // ignore: unused_local_variable
  final picture = XPathEvaluationException.extractExactlyOne(
    'fn:format-integer',
    'picture',
    arguments[1],
  ).toXPathString();
  // ignore: unused_local_variable
  final language = arguments.length > 2
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:format-integer',
          'language',
          arguments[2],
        )?.toXPathString()
      : null;
  if (value == null) return XPathSequence.empty;
  // Basic implementation ignoring picture string intricacies
  // TODO: Add proper picture string parsing support
  return XPathSequence.single(XPathString(value.toInt().toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-number
XPathSequence fnFormatNumber(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:format-number',
    arguments,
    2,
    3,
  );
  final value = XPathEvaluationException.extractZeroOrOne(
    'fn:format-number',
    'value',
    arguments[0],
  )?.toXPathNumber();
  // ignore: unused_local_variable
  final picture = XPathEvaluationException.extractExactlyOne(
    'fn:format-number',
    'picture',
    arguments[1],
  ).toXPathString();
  // ignore: unused_local_variable
  final decimalFormatName = arguments.length > 2
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:format-number',
          'decimal-format-name',
          arguments[2],
        )?.toXPathString()
      : null;
  if (value == null) return XPathSequence.empty;
  // Basic implementation
  // TODO: Add proper picture string parsing support
  return XPathSequence.single(XPathString(value.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
XPathSequence fnAbs(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:abs', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:abs',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.abs());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ceiling
XPathSequence fnCeiling(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:ceiling', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:ceiling',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.ceil());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
XPathSequence fnFloor(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:floor', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:floor',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.floor());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round
XPathSequence fnRound(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:round', arguments, 1, 2);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:round',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  final precision = arguments.length > 1
      ? XPathEvaluationException.extractExactlyOne(
          'fn:round',
          'precision',
          arguments[1],
        ).toXPathNumber().toInt()
      : 0;
  if (arg == null) return XPathSequence.empty;
  if (arg.isNaN || arg.isInfinite) return XPathSequence.single(arg);
  if (precision == 0) return XPathSequence.single(arg.round());
  final factor = math.pow(10, precision);
  return XPathSequence.single((arg * factor).round() / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
XPathSequence fnRoundHalfToEven(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:round-half-to-even',
    arguments,
    1,
    2,
  );
  final arg = XPathEvaluationException.extractZeroOrOne(
    'fn:round-half-to-even',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  final precision = arguments.length > 1
      ? XPathEvaluationException.extractExactlyOne(
          'fn:round-half-to-even',
          'precision',
          arguments[1],
        ).toXPathNumber().toInt()
      : 0;
  if (arg == null) return XPathSequence.empty;
  if (arg.isNaN || arg.isInfinite) return XPathSequence.single(arg);
  final factor = math.pow(10, precision);
  final value = arg * factor;
  final rounded = value.roundToDouble();
  final result = ((value - rounded).abs() == 0.5 && rounded % 2 != 0)
      ? rounded - (rounded > value ? 1.0 : -1.0)
      : rounded;
  return XPathSequence.single(result / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-number
XPathSequence fnNumber(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:number', arguments, 0, 1);
  final arg = arguments.isNotEmpty
      ? arguments[0]
      : context.value.toXPathSequence();
  if (arg.isEmpty) return const XPathSequence.single(double.nan);
  return XPathSequence.single(
    XPathEvaluationException.extractZeroOrOne(
      'fn:number',
      'arg',
      arg,
    )!.toXPathNumber(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pi
XPathSequence mathPi(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:pi', arguments, 0);
  return const XPathSequence.single(math.pi);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp
XPathSequence mathExp(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:exp', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:exp',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.exp(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp10
XPathSequence mathExp10(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:exp10', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:exp10',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(10, arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log
XPathSequence mathLog(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:log', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:log',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log10
XPathSequence mathLog10(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:log10', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:log10',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(arg) / math.ln10);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pow
XPathSequence mathPow(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:pow', arguments, 2);
  final x = XPathEvaluationException.extractZeroOrOne(
    'math:pow',
    'x',
    arguments[0],
  )?.toXPathNumber();
  final y = XPathEvaluationException.extractExactlyOne(
    'math:pow',
    'y',
    arguments[1],
  ).toXPathNumber();
  if (x == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(x, y));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sqrt
XPathSequence mathSqrt(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:sqrt', arguments, 1);
  final arg = XPathEvaluationException.extractExactlyOne(
    'math:sqrt',
    'arg',
    arguments[0],
  ).toXPathNumber();
  return XPathSequence.single(math.sqrt(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sin
XPathSequence mathSin(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:sin', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:sin',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.sin(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-cos
XPathSequence mathCos(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:cos', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:cos',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.cos(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-tan
XPathSequence mathTan(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:tan', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:tan',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.tan(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-asin
XPathSequence mathAsin(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:asin', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:asin',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.asin(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-acos
XPathSequence mathAcos(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:acos', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:acos',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.acos(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan
XPathSequence mathAtan(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:atan', arguments, 1);
  final arg = XPathEvaluationException.extractZeroOrOne(
    'math:atan',
    'arg',
    arguments[0],
  )?.toXPathNumber();
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.atan(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan2
XPathSequence mathAtan2(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('math:atan2', arguments, 2);
  final y = XPathEvaluationException.extractExactlyOne(
    'math:atan2',
    'y',
    arguments[0],
  ).toXPathNumber();
  final x = XPathEvaluationException.extractExactlyOne(
    'math:atan2',
    'x',
    arguments[1],
  ).toXPathNumber();
  return XPathSequence.single(math.atan2(y, x));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-random-number-generator
XPathSequence fnRandomNumberGenerator(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:random-number-generator',
    arguments,
    0,
    1,
  );
  final seed = arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:random-number-generator',
          'seed',
          arguments[0],
        )?.hashCode
      : null;
  final random = math.Random(seed);
  final generator = <String, Object>{};
  generator['number'] = random.nextDouble();
  generator['next'] = (XPathContext context, List<XPathSequence> args) =>
      generator['number'] = random.nextDouble();
  generator['permute'] = (XPathContext context, List<XPathSequence> args) =>
      XPathSequence(args[0].shuffled(random));
  return XPathSequence.single(generator);
}

int _compareNumber(String name, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final value1 = XPathEvaluationException.extractExactlyOne(
    name,
    'arg1',
    arguments[0],
  ).toXPathNumber();
  final value2 = XPathEvaluationException.extractExactlyOne(
    name,
    'arg2',
    arguments[1],
  ).toXPathNumber();
  return value1.compareTo(value2);
}
