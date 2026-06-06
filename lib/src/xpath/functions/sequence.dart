import '../../../xml.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../operators/comparison.dart';
import '../types/any.dart';
import '../types/array.dart';
import '../types/duration.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/node.dart';
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
    XPathArgumentDefinition(name: 'startingLoc', type: xsDouble),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'length', type: xsDouble)],
  function: _fnSubsequence,
);

XPathSequence _fnSubsequence(
  XPathContext context,
  XPathSequence sourceSeq,
  double startingLoc, [
  double? length,
]) {
  if (startingLoc.isNaN || (length != null && length.isNaN)) {
    return XPathSequence.empty;
  }

  final startRound = startingLoc.isInfinite
      ? startingLoc
      : startingLoc.roundToDouble();

  final lengthRound = length == null
      ? null
      : (length.isInfinite ? length : length.roundToDouble());

  final endRound = lengthRound != null
      ? startRound + lengthRound
      : double.infinity;

  if (endRound.isNaN ||
      endRound <= 1.0 ||
      (startRound.isInfinite && startRound > 0)) {
    return XPathSequence.empty;
  }

  var skipCount = 0;
  if (startRound > 1.0) {
    if (startRound > 9007199254740992.0) {
      return XPathSequence.empty;
    }
    skipCount = (startRound - 1.0).toInt();
  }

  int? takeCount;
  if (endRound != double.infinity) {
    if (endRound > 9007199254740992.0) {
      takeCount = null;
    } else {
      final take = (endRound - 1.0).toInt() - skipCount;
      if (take <= 0) return XPathSequence.empty;
      takeCount = take;
    }
  }

  Iterable<Object> iter = sourceSeq;
  if (skipCount > 0) {
    iter = iter.skip(skipCount);
  }
  if (takeCount != null) {
    iter = iter.take(takeCount);
  }

  return XPathSequence(iter);
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
  XPathSequence(seq.atomize())
      .toList()
      .asMap()
      .entries
      .where((e) {
        try {
          return compare(e.value, search) == 0;
        } catch (_) {
          return false;
        }
      })
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

bool _deepEqual(Object? a, Object? b) {
  if (a is Function ||
      b is Function ||
      a is XPathFunction ||
      b is XPathFunction) {
    throw XPathEvaluationException(
      'Cannot compare function items with deep-equal',
    );
  }
  if (identical(a, b) && a is! List && a is! Map && a is! XPathSequence) {
    return true;
  }
  if (a == null || b == null) return false;

  // Handle sequences
  if (a is XPathSequence && b is XPathSequence) {
    if (a.length != b.length) return false;
    final it1 = a.iterator;
    final it2 = b.iterator;
    while (it1.moveNext() && it2.moveNext()) {
      if (!_deepEqual(it1.current, it2.current)) return false;
    }
    return true;
  }

  // Handle lists (arrays)
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEqual(a[i], b[i])) return false;
    }
    return true;
  }

  // Handle maps
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final keyA in a.keys) {
      Object? foundKeyB;
      for (final keyB in b.keys) {
        if (_deepEqual(keyA, keyB)) {
          foundKeyB = keyB;
          break;
        }
      }
      if (foundKeyB == null) return false;
      if (!_deepEqual(a[keyA], b[foundKeyB])) return false;
    }
    return true;
  }

  // Handle XmlNode
  if (a is XmlNode && b is XmlNode) {
    if (a.nodeType != b.nodeType) return false;
    if (a is XmlElement && b is XmlElement) {
      if (a.name != b.name) return false;
      if (a.attributes.length != b.attributes.length) return false;
      for (final attrA in a.attributes) {
        final attrB = b.getAttributeNode(attrA.name.qualified);
        if (attrB == null || attrB.value != attrA.value) return false;
      }
      if (a.children.length != b.children.length) return false;
      for (var i = 0; i < a.children.length; i++) {
        if (!_deepEqual(a.children[i], b.children[i])) return false;
      }
      return true;
    }
    if (a is XmlAttribute && b is XmlAttribute) {
      return a.name == b.name && a.value == b.value;
    }
    return a.value == b.value;
  }

  // Handle atomic comparison
  try {
    return compare(a, b) == 0;
  } catch (_) {
    return a == b;
  }
}

XPathSequence _fnDeepEqual(
  XPathContext context,
  XPathSequence parameter1,
  XPathSequence parameter2, [
  String? collation,
]) {
  try {
    return _deepEqual(parameter1, parameter2)
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  } on XPathEvaluationException {
    rethrow;
  } catch (_) {
    return XPathSequence.falseSequence;
  }
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
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnAvg,
);

Iterable<Object> _atomizeSumAvg(Object item) {
  if (item is XPathArray) {
    return item.expand(_atomizeSumAvg);
  }
  if (item is XPathSequence) {
    return item.expand(_atomizeSumAvg);
  }
  if (item is XmlNode) {
    final valStr = xsNode.castToString(item);
    try {
      return [xsDouble.cast(valStr)];
    } catch (_) {
      throw XPathEvaluationException(
        'Cannot cast untypedAtomic "$valStr" to double',
      );
    }
  }
  if (item is XPathMap || item is Function) {
    throw XPathEvaluationException('Cannot atomize a map or function item');
  }
  return [item];
}

int _roundHalfToEven(double value) {
  final floor = value.floor();
  final diff = value - floor;
  if (diff == 0.5) {
    return floor.isEven ? floor : floor + 1;
  }
  return value.round();
}

XPathSequence _fnAvg(XPathContext context, XPathSequence arg) {
  final items = arg.expand(_atomizeSumAvg).toList();
  if (items.isEmpty) return XPathSequence.empty;

  final allNumeric = items.every((e) => e is num);
  final allDuration = items.every((e) => e is XPathDuration);

  if (!allNumeric && !allDuration) {
    throw XPathEvaluationException(
      'fn:avg: mixed or unsupported argument types',
    );
  }

  final count = items.length;

  if (allNumeric) {
    var sum = items.first as num;
    for (var i = 1; i < items.length; i++) {
      sum += items[i] as num;
    }
    return XPathSequence.single(sum / count);
  } else {
    final allYearMonth = items.every((e) => e is XPathYearMonthDuration);
    final allDayTime = items.every((e) => e is XPathDayTimeDuration);

    if (!allYearMonth && !allDayTime) {
      throw XPathEvaluationException(
        'fn:avg: mixed or unsupported duration types',
      );
    }

    try {
      if (allYearMonth) {
        var sumMonths = 0;
        for (final item in items) {
          sumMonths += (item as XPathYearMonthDuration).totalMonths;
        }
        final avgMonths = _roundHalfToEven(sumMonths / count);
        return XPathSequence.single(XPathYearMonthDuration(avgMonths));
      } else {
        var sumMicroseconds = 0;
        for (final item in items) {
          sumMicroseconds += (item as XPathDayTimeDuration).inMicroseconds;
        }
        final avgMicroseconds = _roundHalfToEven(sumMicroseconds / count);
        return XPathSequence.single(
          XPathDayTimeDuration(Duration(microseconds: avgMicroseconds)),
        );
      }
    } catch (e) {
      if (e is XPathEvaluationException) rethrow;
      throw XPathEvaluationException(
        'fn:avg: duration arithmetic overflow: $e',
      );
    }
  }
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

Iterable<Object> _atomizeMaxMin(Object item) {
  if (item is XPathArray) {
    return item.expand(_atomizeMaxMin);
  }
  if (item is XPathSequence) {
    return item.expand(_atomizeMaxMin);
  }
  return [item];
}

XPathSequence _fnMax(
  XPathContext context,
  XPathSequence arg, [
  String? collation,
]) {
  final iterator = XPathSequence(
    arg.expand(_atomizeMaxMin),
  ).map((item) => item is XmlNode ? xsNumeric.cast(item) : item).iterator;
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
  final iterator = XPathSequence(
    arg.expand(_atomizeMaxMin),
  ).map((item) => item is XmlNode ? xsNumeric.cast(item) : item).iterator;
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
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'zero',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnSum,
);

XPathSequence _fnSum(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? zero,
]) {
  final items = arg.expand(_atomizeSumAvg).toList();
  if (items.isEmpty) {
    return zero ?? const XPathSequence.single(0);
  }

  final allNumeric = items.every((e) => e is num);
  final allDuration = items.every((e) => e is XPathDuration);

  if (!allNumeric && !allDuration) {
    throw XPathEvaluationException(
      'fn:sum: mixed or unsupported argument types',
    );
  }

  if (allNumeric) {
    var sum = items.first as num;
    for (var i = 1; i < items.length; i++) {
      sum += items[i] as num;
    }
    return XPathSequence.single(sum);
  } else {
    final allYearMonth = items.every((e) => e is XPathYearMonthDuration);
    final allDayTime = items.every((e) => e is XPathDayTimeDuration);

    if (!allYearMonth && !allDayTime) {
      throw XPathEvaluationException(
        'fn:sum: mixed or unsupported duration types',
      );
    }

    try {
      if (allYearMonth) {
        var sumMonths = 0;
        for (final item in items) {
          sumMonths += (item as XPathYearMonthDuration).totalMonths;
        }
        return XPathSequence.single(XPathYearMonthDuration(sumMonths));
      } else {
        var sumMicroseconds = 0;
        for (final item in items) {
          sumMicroseconds += (item as XPathDayTimeDuration).inMicroseconds;
        }
        return XPathSequence.single(
          XPathDayTimeDuration(Duration(microseconds: sumMicroseconds)),
        );
      }
    } catch (e) {
      if (e is XPathEvaluationException) rethrow;
      throw XPathEvaluationException(
        'fn:sum: duration arithmetic overflow: $e',
      );
    }
  }
}
