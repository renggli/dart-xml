import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../operators/comparison.dart';
import '../types/any.dart';
import '../types/array.dart';
import '../types/boolean.dart';
import '../types/function.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
const fnArraySize = XPathFunctionDefinition(
  name: XmlName.qualified('array:size'),
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArraySize,
);

XPathSequence _fnArraySize(XPathContext context, XPathArray array) =>
    XPathSequence.single(array.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
const fnArrayGet = XPathFunctionDefinition(
  name: XmlName.qualified('array:get'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'position', type: xsInteger),
  ],
  function: _fnArrayGet,
);

XPathSequence _fnArrayGet(
  XPathContext context,
  XPathArray array,
  int position,
) {
  final index = position - 1;
  if (index < 0 || index >= array.length) {
    throw XPathEvaluationException('Array index out of bounds: $position');
  }
  return array[index].toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
const fnArrayPut = XPathFunctionDefinition(
  name: XmlName.qualified('array:put'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'position', type: xsInteger),
    XPathArgumentDefinition(
      name: 'member',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnArrayPut,
);

XPathSequence _fnArrayPut(
  XPathContext context,
  XPathArray array,
  int position,
  XPathSequence member,
) {
  final index = position - 1;
  if (index < 0 || index >= array.length) {
    throw XPathEvaluationException('Array index out of bounds: $position');
  }
  final result = XPathArray.from(array);
  result[index] = member.toAtomicValue();
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
const fnArrayAppend = XPathFunctionDefinition(
  name: XmlName.qualified('array:append'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(
      name: 'member',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnArrayAppend,
);

XPathSequence _fnArrayAppend(
  XPathContext context,
  XPathArray array,
  XPathSequence member,
) => XPathSequence.single([...array, member.toAtomicValue()]);

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
const fnArraySubarray = XPathFunctionDefinition(
  name: XmlName.qualified('array:subarray'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'start', type: xsInteger),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'length', type: xsInteger)],
  function: _fnArraySubarray,
);

XPathSequence _fnArraySubarray(
  XPathContext context,
  XPathArray array,
  int start, [
  int? length,
]) {
  final s = start - 1;
  final l = length ?? (array.length - s);
  if (s < 0 || s > array.length || l < 0 || s + l > array.length) {
    throw XPathEvaluationException('Invalid subarray range: $start, $length');
  }
  return XPathSequence.single(array.sublist(s, s + l));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
const fnArrayRemove = XPathFunctionDefinition(
  name: XmlName.qualified('array:remove'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(
      name: 'positions',
      type: xsInteger,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnArrayRemove,
);

XPathSequence _fnArrayRemove(
  XPathContext context,
  XPathArray array,
  XPathSequence positions,
) {
  final indices = positions.map((p) => (p as int) - 1).toSet();
  for (final index in indices) {
    if (index < 0 || index >= array.length) {
      throw XPathEvaluationException('Array index out of bounds: ${index + 1}');
    }
  }
  final result = <Object>[];
  for (var i = 0; i < array.length; i++) {
    if (!indices.contains(i)) {
      result.add(array[i]);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-insert-before
const fnArrayInsertBefore = XPathFunctionDefinition(
  name: XmlName.qualified('array:insert-before'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'position', type: xsInteger),
    XPathArgumentDefinition(
      name: 'member',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnArrayInsertBefore,
);

XPathSequence _fnArrayInsertBefore(
  XPathContext context,
  XPathArray array,
  int position,
  XPathSequence member,
) {
  final index = position.toInt() - 1;
  if (index < 0 || index > array.length) {
    throw XPathEvaluationException('Array index out of bounds: $position');
  }
  final result = XPathArray.from(array);
  result.insert(index, member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
const fnArrayHead = XPathFunctionDefinition(
  name: XmlName.qualified('array:head'),
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArrayHead,
);

XPathSequence _fnArrayHead(XPathContext context, XPathArray array) {
  if (array.isEmpty) {
    throw XPathEvaluationException('Empty array');
  }
  return array.first.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
const fnArrayTail = XPathFunctionDefinition(
  name: XmlName.qualified('array:tail'),
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArrayTail,
);

XPathSequence _fnArrayTail(XPathContext context, XPathArray array) {
  if (array.isEmpty) {
    throw XPathEvaluationException('Empty array');
  }
  return XPathSequence.single(array.sublist(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
const fnArrayReverse = XPathFunctionDefinition(
  name: XmlName.qualified('array:reverse'),
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArrayReverse,
);

XPathSequence _fnArrayReverse(XPathContext context, XPathArray array) =>
    XPathSequence.single(array.reversed.toList());

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
const fnArrayJoin = XPathFunctionDefinition(
  name: XmlName.qualified('array:join'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arrays',
      type: xsArray,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnArrayJoin,
);

XPathSequence _fnArrayJoin(XPathContext context, XPathSequence arrays) {
  final result = <Object>[];
  for (final item in arrays) {
    if (item is XPathArray) {
      result.addAll(item);
    } else {
      result.add(item);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-flatten
const fnArrayFlatten = XPathFunctionDefinition(
  name: XmlName.qualified('array:flatten'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnArrayFlatten,
);

XPathSequence _fnArrayFlatten(XPathContext context, XPathSequence input) =>
    XPathSequence(_fnArrayFlattenSync(context, input));

Iterable<Object> _fnArrayFlattenSync(
  XPathContext context,
  XPathSequence input,
) sync* {
  for (final item in input) {
    if (item is Iterable) {
      yield* _fnArrayFlattenSync(context, XPathSequence(item.cast()));
    } else {
      yield item;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each
const fnArrayForEach = XPathFunctionDefinition(
  name: XmlName.qualified('array:for-each'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayForEach,
);

XPathSequence _fnArrayForEach(
  XPathContext context,
  XPathArray array,
  XPathFunction action,
) {
  final result = <Object>[];
  for (final item in array) {
    final value = action(context, [xsSequence.cast(item)]);
    result.add(value.toAtomicValue());
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-filter
const fnArrayFilter = XPathFunctionDefinition(
  name: XmlName.qualified('array:filter'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'predicate', type: xsFunction),
  ],
  function: _fnArrayFilter,
);

XPathSequence _fnArrayFilter(
  XPathContext context,
  XPathArray array,
  XPathFunction predicate,
) {
  final result = <Object>[];
  for (final item in array) {
    final value = predicate(context, [xsSequence.cast(item)]);
    if (xsBoolean.cast(value)) {
      result.add(item);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-left
const fnArrayFoldLeft = XPathFunctionDefinition(
  name: XmlName.qualified('array:fold-left'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'zero', type: xsAny),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayFoldLeft,
);

XPathSequence _fnArrayFoldLeft(
  XPathContext context,
  XPathArray array,
  Object zero,
  XPathFunction action,
) {
  var result = xsSequence.cast(zero);
  for (final item in array) {
    result = action(context, [result, XPathSequence.single(item)]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-right
const fnArrayFoldRight = XPathFunctionDefinition(
  name: XmlName.qualified('array:fold-right'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'zero', type: xsAny),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayFoldRight,
);

XPathSequence _fnArrayFoldRight(
  XPathContext context,
  XPathArray array,
  Object zero,
  XPathFunction action,
) {
  var result = xsSequence.cast(zero);
  for (var i = array.length - 1; i >= 0; i--) {
    result = action(context, [XPathSequence.single(array[i]), result]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each-pair
const fnArrayForEachPair = XPathFunctionDefinition(
  name: XmlName.qualified('array:for-each-pair'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'array1', type: xsArray),
    XPathArgumentDefinition(name: 'array2', type: xsArray),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayForEachPair,
);

XPathSequence _fnArrayForEachPair(
  XPathContext context,
  XPathArray array1,
  XPathArray array2,
  XPathFunction action,
) {
  final result = <Object>[];
  final len = array1.length < array2.length ? array1.length : array2.length;
  for (var i = 0; i < len; i++) {
    final value = action(context, [
      xsSequence.cast(array1[i]),
      xsSequence.cast(array2[i]),
    ]);
    result.add(value.toAtomicValue());
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-sort
const fnArraySort = XPathFunctionDefinition(
  name: XmlName.qualified('array:sort'),
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'key', type: xsFunction),
  ],
  function: _fnArraySort,
);

XPathSequence _fnArraySort(
  XPathContext context,
  XPathArray array, [
  String? collation,
  XPathFunction? key,
]) {
  final result = XPathArray.from(array);
  result.sort((a, b) {
    final ka = key != null
        ? key(context, [XPathSequence.single(a)]).toAtomicValue()
        : a;
    final kb = key != null
        ? key(context, [XPathSequence.single(b)]).toAtomicValue()
        : b;
    return compare(ka, kb);
  });
  return XPathSequence.single(result);
}
