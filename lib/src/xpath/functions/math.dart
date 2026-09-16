import 'dart:math' as math;

import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pi
const mathPi = XPathFunctionItem.fn0(XmlName.qualified('math:pi'), _mathPi);

XPathSequence _mathPi(XPathContext context) =>
    const XPathSequence.single(XPathDouble(math.pi));

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp
const mathExp = XPathFunctionItem.fn1(XmlName.qualified('math:exp'), _mathExp);

XPathSequence _mathExp(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.exp((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp10
const mathExp10 = XPathFunctionItem.fn1(
  XmlName.qualified('math:exp10'),
  _mathExp10,
);

XPathSequence _mathExp10(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.pow(10, (val as XPathNumeric).toDouble()).toDouble()),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log
const mathLog = XPathFunctionItem.fn1(XmlName.qualified('math:log'), _mathLog);

XPathSequence _mathLog(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.log((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log10
const mathLog10 = XPathFunctionItem.fn1(
  XmlName.qualified('math:log10'),
  _mathLog10,
);

XPathSequence _mathLog10(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.log((val as XPathNumeric).toDouble()) / math.ln10),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pow
const mathPow = XPathFunctionItem.fn2(XmlName.qualified('math:pow'), _mathPow);

XPathSequence _mathPow(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = arg1.firstOrNull;
  if (val1 == null) return XPathSequence.empty;
  final val2 = arg2.first as XPathNumeric;
  return XPathSequence.single(
    XPathDouble(
      math.pow((val1 as XPathNumeric).toDouble(), val2.toDouble()).toDouble(),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sqrt
const mathSqrt = XPathFunctionItem.fn1(
  XmlName.qualified('math:sqrt'),
  _mathSqrt,
);

XPathSequence _mathSqrt(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.sqrt((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sin
const mathSin = XPathFunctionItem.fn1(XmlName.qualified('math:sin'), _mathSin);

XPathSequence _mathSin(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.sin((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-cos
const mathCos = XPathFunctionItem.fn1(XmlName.qualified('math:cos'), _mathCos);

XPathSequence _mathCos(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.cos((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-tan
const mathTan = XPathFunctionItem.fn1(XmlName.qualified('math:tan'), _mathTan);

XPathSequence _mathTan(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.tan((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-asin
const mathAsin = XPathFunctionItem.fn1(
  XmlName.qualified('math:asin'),
  _mathAsin,
);

XPathSequence _mathAsin(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.asin((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-acos
const mathAcos = XPathFunctionItem.fn1(
  XmlName.qualified('math:acos'),
  _mathAcos,
);

XPathSequence _mathAcos(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.acos((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan
const mathAtan = XPathFunctionItem.fn1(
  XmlName.qualified('math:atan'),
  _mathAtan,
);

XPathSequence _mathAtan(XPathContext context, XPathSequence arg) {
  final val = arg.firstOrNull;
  if (val == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathDouble(math.atan((val as XPathNumeric).toDouble())),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan2
const mathAtan2 = XPathFunctionItem.fn2(
  XmlName.qualified('math:atan2'),
  _mathAtan2,
);

XPathSequence _mathAtan2(
  XPathContext context,
  XPathSequence y,
  XPathSequence x,
) {
  final valY = y.first as XPathNumeric;
  final valX = x.first as XPathNumeric;
  return XPathSequence.single(
    XPathDouble(math.atan2(valY.toDouble(), valX.toDouble())),
  );
}
