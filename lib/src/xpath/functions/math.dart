import 'dart:math' as math;

import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/number.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pi
const mathPi = XPathFunctionDefinition(
  name: XmlName.qualified('math:pi'),
  function: _mathPi,
);

XPathSequence _mathPi(XPathContext context) =>
    const XPathSequence.single(math.pi);

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp
const mathExp = XPathFunctionDefinition(
  name: XmlName.qualified('math:exp'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathExp,
);

XPathSequence _mathExp(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.exp(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-exp10
const mathExp10 = XPathFunctionDefinition(
  name: XmlName.qualified('math:exp10'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathExp10,
);

XPathSequence _mathExp10(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(10, arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log
const mathLog = XPathFunctionDefinition(
  name: XmlName.qualified('math:log'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathLog,
);

XPathSequence _mathLog(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-log10
const mathLog10 = XPathFunctionDefinition(
  name: XmlName.qualified('math:log10'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathLog10,
);

XPathSequence _mathLog10(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.log(arg) / math.ln10);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-pow
const mathPow = XPathFunctionDefinition(
  name: XmlName.qualified('math:pow'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'arg2', type: xsNumeric),
  ],
  function: _mathPow,
);

XPathSequence _mathPow(XPathContext context, num? arg1, num arg2) {
  if (arg1 == null) return XPathSequence.empty;
  return XPathSequence.single(math.pow(arg1, arg2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sqrt
const mathSqrt = XPathFunctionDefinition(
  name: XmlName.qualified('math:sqrt'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathSqrt,
);

XPathSequence _mathSqrt(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.sqrt(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-sin
const mathSin = XPathFunctionDefinition(
  name: XmlName.qualified('math:sin'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathSin,
);

XPathSequence _mathSin(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.sin(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-cos
const mathCos = XPathFunctionDefinition(
  name: XmlName.qualified('math:cos'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathCos,
);

XPathSequence _mathCos(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.cos(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-tan
const mathTan = XPathFunctionDefinition(
  name: XmlName.qualified('math:tan'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathTan,
);

XPathSequence _mathTan(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.tan(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-asin
const mathAsin = XPathFunctionDefinition(
  name: XmlName.qualified('math:asin'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathAsin,
);

XPathSequence _mathAsin(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.asin(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-acos
const mathAcos = XPathFunctionDefinition(
  name: XmlName.qualified('math:acos'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathAcos,
);

XPathSequence _mathAcos(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.acos(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan
const mathAtan = XPathFunctionDefinition(
  name: XmlName.qualified('math:atan'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _mathAtan,
);

XPathSequence _mathAtan(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(math.atan(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-math-atan2
const mathAtan2 = XPathFunctionDefinition(
  name: XmlName.qualified('math:atan2'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'y', type: xsNumeric),
    XPathArgumentDefinition(name: 'x', type: xsNumeric),
  ],
  function: _mathAtan2,
);

XPathSequence _mathAtan2(XPathContext context, num y, num x) =>
    XPathSequence.single(math.atan2(y, x));
