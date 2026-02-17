import 'dart:math';

import 'package:collection/collection.dart';

import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/any.dart';
import '../types/number.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-number
const fnNumber = XPathFunctionDefinition(
  name: 'fn:number',
  aliases: ['number'],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsSequence,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnNumber,
);

XPathSequence _fnNumber(XPathContext context, [XPathSequence? arg]) {
  try {
    if (arg == null) return XPathSequence.single(xsNumeric.cast(context.item));
    if (arg.isEmpty) return const XPathSequence.single(double.nan);
    return XPathSequence.single(xsNumeric.cast(arg));
  } on XPathEvaluationException {
    return const XPathSequence.single(double.nan);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
const fnAbs = XPathFunctionDefinition(
  name: 'fn:abs',
  aliases: ['abs'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnAbs,
);

XPathSequence _fnAbs(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.abs());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ceiling
const fnCeiling = XPathFunctionDefinition(
  name: 'fn:ceiling',
  aliases: ['ceiling'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnCeiling,
);

XPathSequence _fnCeiling(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.ceil());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
const fnFloor = XPathFunctionDefinition(
  name: 'fn:floor',
  aliases: ['floor'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnFloor,
);

XPathSequence _fnFloor(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.floor());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round
const fnRound = XPathFunctionDefinition(
  name: 'fn:round',
  aliases: ['round'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'precision', type: xsInteger),
  ],
  function: _fnRound,
);

XPathSequence _fnRound(XPathContext context, num? arg, [int? precision]) {
  if (arg == null) return XPathSequence.empty;
  if (arg.isNaN || arg.isInfinite) return XPathSequence.single(arg);
  final p = precision ?? 0;
  final factor = pow(10, p);
  return XPathSequence.single((arg * factor).round() / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
const fnRoundHalfToEven = XPathFunctionDefinition(
  name: 'fn:round-half-to-even',
  aliases: ['round-half-to-even'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'precision', type: xsNumeric),
  ],
  function: _fnRoundHalfToEven,
);

XPathSequence _fnRoundHalfToEven(
  XPathContext context,
  num? arg, [
  num? precision,
]) {
  if (arg == null) return XPathSequence.empty;
  if (arg.isNaN || arg.isInfinite) return XPathSequence.single(arg);
  // TODO: Proper round-half-to-even implementation
  final p = precision?.toInt() ?? 0;
  final factor = pow(10, p);
  final value = arg * factor;
  final floor = value.floor();
  final diff = value - floor;
  final rounded = diff == 0.5
      ? (floor % 2 == 0 ? floor : floor + 1)
      : value.round();
  return XPathSequence.single(rounded / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-random-number-generator
const fnRandomNumberGenerator = XPathFunctionDefinition(
  name: 'fn:random-number-generator',
  aliases: ['random-number-generator'],
  optionalArguments: [XPathArgumentDefinition(name: 'seed', type: xsAny)],
  function: _fnRandomNumberGenerator,
);

XPathSequence _fnRandomNumberGenerator(XPathContext context, [Object? seed]) {
  final random = Random(seed?.hashCode);
  final object = <String, Object>{};
  object['number'] = random.nextDouble();
  object['next'] = (XPathContext context, List<XPathSequence> args) =>
      XPathSequence.single({...object, 'number': random.nextDouble()});
  object['permute'] = (XPathContext context, List<XPathSequence> args) =>
      XPathSequence(args.single.toList().shuffled(random));
  return XPathSequence.single(object);
}
