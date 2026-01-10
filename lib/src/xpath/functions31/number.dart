import 'dart:math' as math;

import '../evaluation/context.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-add
XPathSequence opNumericAdd(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 + val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-subtract
XPathSequence opNumericSubtract(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 - val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-multiply
XPathSequence opNumericMultiply(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 * val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-divide
XPathSequence opNumericDivide(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 / val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-integer-divide
XPathSequence opNumericIntegerDivide(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single((val1 / val2).truncate());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-mod
XPathSequence opNumericMod(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 % val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-plus
XPathSequence opNumericUnaryPlus(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(val);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-unary-minus
XPathSequence opNumericUnaryMinus(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(-val);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-equal
XPathSequence opNumericEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 == val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-less-than
XPathSequence opNumericLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 < val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-numeric-greater-than
XPathSequence opNumericGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull?.toXPathNumber();
  final val2 = arg2.firstOrNull?.toXPathNumber();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 > val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
XPathSequence fnFormatInteger(
  XPathContext context,
  XPathSequence value,
  XPathSequence picture, [
  XPathSequence? language,
]) {
  final val = value.firstOrNull?.toXPathNumber();
  final pic = picture.firstOrNull?.toString();
  if (val == null || pic == null) return XPathSequence.empty;
  // TODO: Implement full picture string parsing.
  // This is a basic implementation for common cases.
  return XPathSequence.single(val.toInt().toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
XPathSequence fnAbs(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull;
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.toXPathNumber().abs());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ceiling
XPathSequence fnCeiling(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull;
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.toXPathNumber().ceil());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
XPathSequence fnFloor(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull;
  if (value == null) return XPathSequence.empty;
  return XPathSequence.single(value.toXPathNumber().floor());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round
XPathSequence fnRound(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? precision,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  final value = arg.first.toXPathNumber();
  if (precision == null) {
    if (value.isNaN || value.isInfinite) return XPathSequence.single(value);
    return XPathSequence.single(value.round());
  }
  // TODO: Implement precision argument for fn:round
  return XPathSequence.single(value.round());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
XPathSequence fnRoundHalfToEven(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? precision,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  final value = arg.first.toXPathNumber();
  if (value.isNaN || value.isInfinite) return XPathSequence.single(value);
  // Simple implementation for precision 0
  final rounded = value.round();
  if ((value - rounded).abs() == 0.5) {
    if (rounded.isEven) return XPathSequence.single(rounded);
    final floor = value.floor();
    final ceil = value.ceil();
    return XPathSequence.single(floor == rounded ? ceil : floor);
  }
  return XPathSequence.single(rounded);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-number
XPathSequence fnNumber(XPathContext context, [XPathSequence? arg]) {
  final valueSequence = arg ?? context.value.toXPathSequence();
  if (valueSequence.isEmpty) return XPathSequence.single(double.nan);
  return XPathSequence.single(valueSequence.first.toXPathNumber());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pi
XPathSequence mathPi(XPathContext context) => XPathSequence.single(math.pi);

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp
XPathSequence mathExp(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.exp(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp10
XPathSequence mathExp10(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(10, val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log
XPathSequence mathLog(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log10
XPathSequence mathLog10(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(val) / math.ln10);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pow
XPathSequence mathPow(XPathContext context, XPathSequence x, XPathSequence y) {
  final xVal = x.firstOrNull?.toXPathNumber();
  final yVal = y.firstOrNull?.toXPathNumber();
  if (xVal == null || yVal == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(xVal, yVal));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sqrt
XPathSequence mathSqrt(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.sqrt(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sin
XPathSequence mathSin(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.sin(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-cos
XPathSequence mathCos(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.cos(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-tan
XPathSequence mathTan(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.tan(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-asin
XPathSequence mathAsin(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.asin(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-acos
XPathSequence mathAcos(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.acos(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan
XPathSequence mathAtan(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull?.toXPathNumber();
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(math.atan(val));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan2
XPathSequence mathAtan2(
  XPathContext context,
  XPathSequence yArg,
  XPathSequence xArg,
) {
  final y = yArg.firstOrNull?.toXPathNumber();
  final x = xArg.firstOrNull?.toXPathNumber();
  if (x == null || y == null) return XPathSequence.empty;
  return XPathSequence.single(math.atan2(y, x));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-random-number-generator
XPathSequence fnRandomNumberGenerator(
  XPathContext context, [
  XPathSequence? seed,
]) {
  // This is a simplified implementation. The standard suggests returning a map
  // with 'number', 'next', and 'permute' functions.
  // For now, we just return a sequence with a single random number.
  final seedValue = seed?.toXPathNumber().toInt();
  final random = math.Random(seedValue);
  return XPathSequence.single(random.nextDouble());
}
