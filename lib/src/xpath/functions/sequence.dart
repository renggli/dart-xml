import 'package:collection/collection.dart';

import '../evaluation/context.dart';
import '../evaluation/types.dart';
import '../exceptions/evaluation_exception.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
const fnEmpty = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'empty',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnEmpty,
);

XPathSequence _fnEmpty(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.isEmpty);

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
const fnExists = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'exists',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnExists,
);

XPathSequence _fnExists(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.isNotEmpty);

/// https://www.w3.org/TR/xpath-functions-31/#func-head
const fnHead = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'head',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnHead,
);

XPathSequence _fnHead(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) return XPathSequence.empty;
  return arg.first.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
const fnTail = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'tail',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnTail,
);

XPathSequence _fnTail(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) return XPathSequence.empty;
  return XPathSequence(arg.skip(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-insert-before
const fnInsertBefore = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'insert-before',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'target',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'position', type: xsNumeric),
    XPathArgumentDefinition(
      name: 'inserts',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnInsertBefore,
);

XPathSequence _fnInsertBefore(
  XPathContext context,
  XPathSequence target,
  num position,
  XPathSequence inserts,
) => XPathSequence(_fnInsertBeforeSync(target, position, inserts));

Iterable<Object> _fnInsertBeforeSync(
  XPathSequence target,
  num position,
  XPathSequence inserts,
) sync* {
  var index = 1;
  final pos = position.toInt();
  if (pos <= 0) {
    yield* inserts;
    yield* target;
    return;
  }
  var inserted = false;
  for (final item in target) {
    if (index == pos) {
      yield* inserts;
      inserted = true;
    }
    yield item;
    index++;
  }
  if (!inserted) {
    yield* inserts;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-remove
const fnRemove = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'remove',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'target',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'position', type: xsNumeric),
  ],
  function: _fnRemove,
);

XPathSequence _fnRemove(
  XPathContext context,
  XPathSequence target,
  num position,
) => XPathSequence(_fnRemoveSync(target, position));

Iterable<Object> _fnRemoveSync(XPathSequence target, num position) sync* {
  var index = 1;
  final pos = position.toInt();
  for (final item in target) {
    if (index != pos) {
      yield item;
    }
    index++;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-reverse
const fnReverse = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'reverse',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnReverse,
);

XPathSequence _fnReverse(XPathContext context, XPathSequence arg) =>
    XPathSequence(arg.toList().reversed);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
const fnFormatInteger = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-integer',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
    XPathArgumentDefinition(name: 'picture', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'language', type: xsString),
  ],
  function: _fnFormatInteger,
);

XPathSequence _fnFormatInteger(
  XPathContext context,
  num? value,
  String picture, [
  String? language,
]) {
  if (value == null) return XPathSequence.empty;
  // TODO: Proper implementation
  return XPathSequence.single(value.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-number
const fnFormatNumber = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'format-number',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
    XPathArgumentDefinition(name: 'picture', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'decimal-format-name', type: xsString),
  ],
  function: _fnFormatNumber,
);

XPathSequence _fnFormatNumber(
  XPathContext context,
  num? value,
  String picture, [
  String? decimalFormatName,
]) {
  if (value == null) return XPathSequence.empty;
  // TODO: Proper implementation
  return XPathSequence.single(value.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subsequence
const fnSubsequence = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'subsequence',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceSeq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'startingLoc', type: xsNumeric),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'length', type: xsNumeric)],
  function: _fnSubsequence,
);

XPathSequence _fnSubsequence(
  XPathContext context,
  XPathSequence sourceSeq,
  num startingLoc, [
  num? length,
]) {
  final start = startingLoc.round();
  final len = length?.round();
  if (len != null) {
    final end = start + len;
    return XPathSequence(
      sourceSeq.toList().whereIndexed((int index, Object item) {
        final pos = index + 1;
        return pos >= start && pos < end;
      }),
    );
  }
  return XPathSequence(
    sourceSeq.toList().whereIndexed(
      (int index, Object item) => index + 1 >= start,
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unordered
const fnUnordered = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unordered',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceSeq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnUnordered,
);

XPathSequence _fnUnordered(XPathContext context, XPathSequence sourceSeq) =>
    sourceSeq;

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
const fnDistinctValues = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'distinct-values',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnDistinctValues,
);

XPathSequence _fnDistinctValues(
  XPathContext context,
  XPathSequence arg, [
  String? collation,
]) => XPathSequence(arg.toSet());

/// https://www.w3.org/TR/xpath-functions-31/#func-index-of
const fnIndexOf = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'index-of',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'search', type: xsAny),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnIndexOf,
);

XPathSequence _fnIndexOf(
  XPathContext context,
  XPathSequence seq,
  Object search, [
  String? collation,
]) => XPathSequence(
  seq
      .toList()
      .asMap()
      .entries
      .where((e) => e.value == search)
      .map((e) => e.key + 1),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-deep-equal
const fnDeepEqual = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'deep-equal',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'parameter1',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(
      name: 'parameter2',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnDeepEqual,
);

XPathSequence _fnDeepEqual(
  XPathContext context,
  XPathSequence parameter1,
  XPathSequence parameter2, [
  String? collation,
]) {
  if (parameter1.length != parameter2.length) {
    return XPathSequence.falseSequence;
  }
  final it1 = parameter1.iterator;
  final it2 = parameter2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    if (it1.current != it2.current) {
      // TODO: Proper deep comparison for nodes, maps, etc.
      return XPathSequence.falseSequence;
    }
  }
  return XPathSequence.trueSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-zero-or-one
const fnZeroOrOne = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'zero-or-one',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnZeroOrOne,
);

XPathSequence _fnZeroOrOne(XPathContext context, XPathSequence arg) {
  if (arg.length > 1) {
    throw XPathEvaluationException('Sequence has more than one item');
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-one-or-more
const fnOneOrMore = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'one-or-more',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnOneOrMore,
);

XPathSequence _fnOneOrMore(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) {
    throw XPathEvaluationException('Sequence is empty');
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exactly-one
const fnExactlyOne = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'exactly-one',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnExactlyOne,
);

XPathSequence _fnExactlyOne(XPathContext context, XPathSequence arg) {
  if (arg.length != 1) {
    throw XPathEvaluationException('Sequence does not have exactly one item');
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-count
const fnCount = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'count',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnCount,
);

XPathSequence _fnCount(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
const fnAvg = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'avg',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnAvg,
);

XPathSequence _fnAvg(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) return XPathSequence.empty;
  final nums = arg.cast<num>();
  return XPathSequence.single(nums.sum / nums.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-max
const fnMax = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'max',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnMax,
);

XPathSequence _fnMax(
  XPathContext context,
  XPathSequence arg, [
  String? collation,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    arg.map((item) => item.toXPathNumber()).cast<num>().max,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
const fnMin = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'min',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnMin,
);

XPathSequence _fnMin(
  XPathContext context,
  XPathSequence arg, [
  String? collation,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(
    arg.map((item) => item.toXPathNumber()).cast<num>().min,
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
const fnSum = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'sum',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'zero', type: xsAny)],
  function: _fnSum,
);

XPathSequence _fnSum(XPathContext context, XPathSequence arg, [Object? zero]) {
  if (arg.isEmpty) return (zero ?? 0).toXPathSequence();
  return XPathSequence.single(
    arg.map((item) => item.toXPathNumber()).cast<num>().sum,
  );
}
