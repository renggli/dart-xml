import 'dart:math';

import 'package:collection/collection.dart';

import '../evaluation/context.dart';
import '../evaluation/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-number
const fnNumber = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'number',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnNumber,
);

XPathSequence _fnNumber(XPathContext context, [Object? arg]) {
  final item = arg ?? context.item;
  return item.toXPathNumber().toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-abs
const fnAbs = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'abs',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'ceiling',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnCeiling,
);

XPathSequence _fnCeiling(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.ceilToDouble());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-floor
const fnFloor = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'floor',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  function: _fnFloor,
);

XPathSequence _fnFloor(XPathContext context, num? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence.single(arg.floorToDouble());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round
const fnRound = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'round',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'precision', type: xsNumeric),
  ],
  function: _fnRound,
);

XPathSequence _fnRound(XPathContext context, num? arg, [num? precision]) {
  if (arg == null) return XPathSequence.empty;
  final p = precision?.toInt() ?? 0;
  final factor = pow(10, p);
  return XPathSequence.single((arg * factor).round() / factor);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-round-half-to-even
const fnRoundHalfToEven = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'round-half-to-even',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
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
  namespace: 'fn',
  name: 'random-number-generator',
  optionalArguments: [XPathArgumentDefinition(name: 'seed', type: xsAny)],
  function: _fnRandomNumberGenerator,
);

XPathSequence _fnRandomNumberGenerator(XPathContext context, [Object? seed]) {
  final random = Random(seed?.hashCode);
  return XPathSequence.single({
    'number': random.nextDouble(),
    'next': (XPathContext context) =>
        _fnRandomNumberGenerator(context, random.nextInt(1 << 32)),
    'permute': (XPathContext context, XPathSequence seq) =>
        XPathSequence(seq.toList().shuffled(random)),
  });
}
