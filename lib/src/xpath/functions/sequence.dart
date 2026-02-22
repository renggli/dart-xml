import 'package:collection/collection.dart';

import '../../../xml.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../operators/comparison.dart';
import '../types/any.dart';
import '../types/duration.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
const fnEmpty = XPathFunctionDefinition(
  name: XmlName.qualified('fn:empty'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnEmpty,
);

XPathSequence _fnEmpty(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.isEmpty);

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
const fnExists = XPathFunctionDefinition(
  name: XmlName.qualified('fn:exists'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnExists,
);

XPathSequence _fnExists(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.isNotEmpty);

/// https://www.w3.org/TR/xpath-functions-31/#func-head
const fnHead = XPathFunctionDefinition(
  name: XmlName.qualified('fn:head'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnHead,
);

XPathSequence _fnHead(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(arg.first);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
const fnTail = XPathFunctionDefinition(
  name: XmlName.qualified('fn:tail'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:insert-before'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'target',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'position', type: xsNumeric),
    XPathArgumentDefinition(
      name: 'inserts',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:remove'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'target',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:reverse'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnReverse,
);

XPathSequence _fnReverse(XPathContext context, XPathSequence arg) =>
    XPathSequence(arg.toList().reversed);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
const fnFormatInteger = XPathFunctionDefinition(
  name: XmlName.qualified('fn:format-integer'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
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
  name: XmlName.qualified('fn:format-number'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'value',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrOne,
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
  name: XmlName.qualified('fn:subsequence'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceSeq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'startingLoc', type: xsInteger),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'length', type: xsInteger)],
  function: _fnSubsequence,
);

XPathSequence _fnSubsequence(
  XPathContext context,
  XPathSequence sourceSeq,
  int startingLoc, [
  int? length,
]) {
  final start = startingLoc;
  final len = length;
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
  name: XmlName.qualified('fn:unordered'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceSeq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnUnordered,
);

XPathSequence _fnUnordered(XPathContext context, XPathSequence sourceSeq) =>
    sourceSeq;

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
const fnDistinctValues = XPathFunctionDefinition(
  name: XmlName.qualified('fn:distinct-values'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:index-of'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:deep-equal'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'parameter1',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'parameter2',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:zero-or-one'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:one-or-more'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:exactly-one'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  name: XmlName.qualified('fn:count'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnCount,
);

XPathSequence _fnCount(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
const fnAvg = XPathFunctionDefinition(
  name: XmlName.qualified('fn:avg'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNumeric,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnAvg,
);

XPathSequence _fnAvg(XPathContext context, XPathSequence arg) {
  final iterator = arg.iterator;
  if (!iterator.moveNext()) return XPathSequence.empty;
  var sum = xsNumeric.cast(iterator.current);
  var count = 1;
  while (iterator.moveNext()) {
    sum += xsNumeric.cast(iterator.current);
    count++;
  }
  return XPathSequence.single(sum / count);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-max
const fnMax = XPathFunctionDefinition(
  name: XmlName.qualified('fn:max'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  final iterator = arg
      .map((item) => item is XmlNode ? xsNumeric.cast(item) : item)
      .iterator;
  if (!iterator.moveNext()) return XPathSequence.empty;
  var max = iterator.current;
  if (max is num && max.isNaN) return XPathSequence.nan;
  while (iterator.moveNext()) {
    final item = iterator.current;
    if (item is num && item.isNaN) return XPathSequence.nan;
    if (compare(item, max) > 0) {
      max = item;
    }
  }
  return XPathSequence.single(max);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
const fnMin = XPathFunctionDefinition(
  name: XmlName.qualified('fn:min'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
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
  final iterator = arg
      .map((item) => item is XmlNode ? xsNumeric.cast(item) : item)
      .iterator;
  if (!iterator.moveNext()) return XPathSequence.empty;
  var min = iterator.current;
  if (min is num && min.isNaN) return XPathSequence.nan;
  while (iterator.moveNext()) {
    final item = iterator.current;
    if (item is num && item.isNaN) return XPathSequence.nan;
    if (compare(item, min) < 0) {
      min = item;
    }
  }
  return XPathSequence.single(min);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
const fnSum = XPathFunctionDefinition(
  name: XmlName.qualified('fn:sum'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'zero', type: xsAny)],
  function: _fnSum,
);

XPathSequence _fnSum(XPathContext context, XPathSequence arg, [Object? zero]) {
  final iterator = arg.iterator;
  if (!iterator.moveNext()) return XPathSequence.single(zero ?? 0);
  final first = iterator.current;
  if (xsDuration.matches(first)) {
    var sum = xsDuration.cast(first);
    while (iterator.moveNext()) {
      sum += xsDuration.cast(iterator.current);
    }
    return XPathSequence.single(sum);
  } else {
    var sum = xsNumeric.cast(first);
    while (iterator.moveNext()) {
      sum += xsNumeric.cast(iterator.current);
    }
    return XPathSequence.single(sum);
  }
}
