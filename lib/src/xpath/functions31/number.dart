import 'dart:math' as math;

import 'package:collection/collection.dart';

import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 + val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 - val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 * val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 / val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single((val1 / val2).truncate());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 % val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(XPathContext context, XPathSequence arg) {
  final val = XPathEvaluationException.checkExactlyOne(arg).toXPathNumber();
  return XPathSequence.single(val);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(XPathContext context, XPathSequence arg) {
  final val = XPathEvaluationException.checkExactlyOne(arg).toXPathNumber();
  return XPathSequence.single(-val);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
XPathSequence opNumericEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 == val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
XPathSequence opNumericLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 < val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
XPathSequence opNumericGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathNumber();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathNumber();
  return XPathSequence.single(val1 > val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
XPathSequence fnFormatInteger(
  XPathContext context,
  XPathSequence value,
  XPathSequence picture, [
  XPathSequence? language,
]) {
  final valueOpt = XPathEvaluationException.checkZeroOrOne(
    value,
  )?.toXPathNumber();
  if (valueOpt == null) return XPathSequence.empty;
  // TODO: Implement picture parameter.
  // TODO: Implement language parameter.
  return XPathSequence.single(valueOpt.toInt().toXPathString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-number
XPathSequence fnFormatNumber(
  XPathContext context,
  XPathSequence value,
  XPathSequence picture, [
  XPathSequence? language,
]) {
  final valueOpt = XPathEvaluationException.checkZeroOrOne(
    value,
  )?.toXPathNumber();
  if (valueOpt == null) return XPathSequence.empty;
  // TODO: Implement picture parameter.
  // TODO: Implement language parameter.
  return XPathSequence.single(valueOpt.toInt().toXPathString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
XPathSequence fnAbs(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(valOpt.abs());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ceiling
XPathSequence fnCeiling(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(valOpt.ceil());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
XPathSequence fnFloor(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(valOpt.floor());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round
XPathSequence fnRound(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? precision,
]) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (argOpt == null) return XPathSequence.empty;
  if (argOpt.isNaN || argOpt.isInfinite) return XPathSequence.single(argOpt);
  final precisionVal = precision == null
      ? 0
      : XPathEvaluationException.checkExactlyOne(
          precision,
        ).toXPathNumber().toInt();
  if (precisionVal == 0) return XPathSequence.single(argOpt.round());
  final factor = math.pow(10, precisionVal);
  return XPathSequence.single((argOpt * factor).round() / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
XPathSequence fnRoundHalfToEven(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? precision,
]) {
  final argOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (argOpt == null) return XPathSequence.empty;
  if (argOpt.isNaN || argOpt.isInfinite) return XPathSequence.single(argOpt);
  final precisionVal = precision == null
      ? 0
      : XPathEvaluationException.checkExactlyOne(
          precision,
        ).toXPathNumber().toInt();
  final factor = math.pow(10, precisionVal);
  final value = argOpt * factor;
  final rounded = value.roundToDouble();
  final result = ((value - rounded).abs() == 0.5 && rounded % 2 != 0)
      ? rounded - (rounded > value ? 1.0 : -1.0)
      : rounded;
  return XPathSequence.single(result / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-number
XPathSequence fnNumber(XPathContext context, [XPathSequence? arg]) {
  final valueSequence = arg ?? context.value.toXPathSequence();
  if (valueSequence.isEmpty) return XPathSequence.single(double.nan);
  return XPathSequence.single(
    XPathEvaluationException.checkZeroOrOne(valueSequence)!.toXPathNumber(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pi
XPathSequence mathPi(XPathContext context) => XPathSequence.single(math.pi);

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp
XPathSequence mathExp(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.exp(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp10
XPathSequence mathExp10(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(10, valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log
XPathSequence mathLog(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log10
XPathSequence mathLog10(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(valOpt) / math.ln10);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pow
XPathSequence mathPow(XPathContext context, XPathSequence x, XPathSequence y) {
  final xVal = XPathEvaluationException.checkZeroOrOne(x)?.toXPathNumber();
  final yVal = XPathEvaluationException.checkExactlyOne(y).toXPathNumber();
  if (xVal == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(xVal, yVal));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sqrt
XPathSequence mathSqrt(XPathContext context, XPathSequence arg) {
  final val = XPathEvaluationException.checkExactlyOne(arg).toXPathNumber();
  return XPathSequence.single(math.sqrt(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sin
XPathSequence mathSin(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.sin(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-cos
XPathSequence mathCos(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.cos(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-tan
XPathSequence mathTan(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.tan(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-asin
XPathSequence mathAsin(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.asin(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-acos
XPathSequence mathAcos(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.acos(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan
XPathSequence mathAtan(XPathContext context, XPathSequence arg) {
  final valOpt = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathNumber();
  if (valOpt == null) return XPathSequence.empty;
  return XPathSequence.single(math.atan(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan2
XPathSequence mathAtan2(
  XPathContext context,
  XPathSequence yArg,
  XPathSequence xArg,
) {
  final y = XPathEvaluationException.checkExactlyOne(yArg).toXPathNumber();
  final x = XPathEvaluationException.checkExactlyOne(xArg).toXPathNumber();
  return XPathSequence.single(math.atan2(y, x));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-random-number-generator
XPathSequence fnRandomNumberGenerator(
  XPathContext context, [
  XPathSequence? seed,
]) {
  final seedVal = seed == null
      ? null
      : XPathEvaluationException.checkZeroOrOne(seed)?.hashCode;
  final random = math.Random(seedVal);
  final generator = <String, Object>{};
  generator['number'] = random.nextDouble();
  generator['next'] = (XPathContext context) =>
      generator['number'] = random.nextDouble();
  generator['permute'] = (XPathContext context, XPathSequence sequence) =>
      XPathSequence(sequence.shuffled(random));
  return XPathSequence.single(generator);
}
