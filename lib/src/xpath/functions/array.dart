import '../evaluation/context.dart';
import '../evaluation/types.dart';
import '../exceptions/evaluation_exception.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
const fnArraySize = XPathFunctionDefinition(
  namespace: 'array',
  name: 'size',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArraySize,
);

XPathSequence _fnArraySize(XPathContext context, List<Object> array) =>
    XPathSequence.single(array.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
const fnArrayGet = XPathFunctionDefinition(
  namespace: 'array',
  name: 'get',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'position', type: xsNumeric),
  ],
  function: _fnArrayGet,
);

XPathSequence _fnArrayGet(
  XPathContext context,
  List<Object> array,
  num position,
) {
  final index = position.toInt() - 1;
  if (index < 0 || index >= array.length) {
    throw XPathEvaluationException('Array index out of bounds: $position');
  }
  return array[index].toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
const fnArrayPut = XPathFunctionDefinition(
  namespace: 'array',
  name: 'put',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'position', type: xsNumeric),
    XPathArgumentDefinition(
      name: 'member',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnArrayPut,
);

XPathSequence _fnArrayPut(
  XPathContext context,
  List<Object> array,
  num position,
  XPathSequence member,
) {
  final index = position.toInt() - 1;
  if (index < 0 || index >= array.length) {
    throw XPathEvaluationException('Array index out of bounds: $position');
  }
  final result = List<Object>.from(array);
  result[index] = member.length == 1 ? member.first : member;
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
const fnArrayAppend = XPathFunctionDefinition(
  namespace: 'array',
  name: 'append',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(
      name: 'member',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnArrayAppend,
);

XPathSequence _fnArrayAppend(
  XPathContext context,
  List<Object> array,
  XPathSequence member,
) => XPathSequence.single([
  ...array,
  member.length == 1 ? member.first : member,
]);

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
const fnArraySubarray = XPathFunctionDefinition(
  namespace: 'array',
  name: 'subarray',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'start', type: xsNumeric),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'length', type: xsNumeric)],
  function: _fnArraySubarray,
);

XPathSequence _fnArraySubarray(
  XPathContext context,
  List<Object> array,
  num start, [
  num? length,
]) {
  final s = start.toInt() - 1;
  final l = length?.toInt() ?? (array.length - s);
  if (s < 0 || s > array.length || l < 0 || s + l > array.length) {
    throw XPathEvaluationException('Invalid subarray range: $start, $length');
  }
  return XPathSequence.single(array.sublist(s, s + l));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
const fnArrayRemove = XPathFunctionDefinition(
  namespace: 'array',
  name: 'remove',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(
      name: 'positions',
      type: XPathSequenceType(
        xsNumeric,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnArrayRemove,
);

XPathSequence _fnArrayRemove(
  XPathContext context,
  List<Object> array,
  List<num> positions,
) {
  final indices = positions.map((p) => p.toInt() - 1).toSet();
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
  namespace: 'array',
  name: 'insert-before',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'position', type: xsNumeric),
    XPathArgumentDefinition(
      name: 'member',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnArrayInsertBefore,
);

XPathSequence _fnArrayInsertBefore(
  XPathContext context,
  List<Object> array,
  num position,
  XPathSequence member,
) {
  final index = position.toInt() - 1;
  if (index < 0 || index > array.length) {
    throw XPathEvaluationException('Array index out of bounds: $position');
  }
  final result = List<Object>.from(array);
  result.insert(index, member.length == 1 ? member.first : member);
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
const fnArrayHead = XPathFunctionDefinition(
  namespace: 'array',
  name: 'head',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArrayHead,
);

XPathSequence _fnArrayHead(XPathContext context, List<Object> array) {
  if (array.isEmpty) {
    throw XPathEvaluationException('Empty array');
  }
  return array.first.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
const fnArrayTail = XPathFunctionDefinition(
  namespace: 'array',
  name: 'tail',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArrayTail,
);

XPathSequence _fnArrayTail(XPathContext context, List<Object> array) {
  if (array.isEmpty) {
    throw XPathEvaluationException('Empty array');
  }
  return XPathSequence.single(array.sublist(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
const fnArrayReverse = XPathFunctionDefinition(
  namespace: 'array',
  name: 'reverse',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  function: _fnArrayReverse,
);

XPathSequence _fnArrayReverse(XPathContext context, List<Object> array) =>
    XPathSequence.single(array.reversed.toList());

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
const fnArrayJoin = XPathFunctionDefinition(
  namespace: 'array',
  name: 'join',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arrays',
      type: XPathSequenceType(
        xsArray,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnArrayJoin,
);

XPathSequence _fnArrayJoin(XPathContext context, XPathSequence arrays) {
  final result = <Object>[];
  for (final item in arrays) {
    if (item is List<Object>) {
      result.addAll(item);
    } else {
      result.add(item);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-flatten
const fnArrayFlatten = XPathFunctionDefinition(
  namespace: 'array',
  name: 'flatten',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
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
    if (item is List<Object>) {
      yield* _fnArrayFlattenSync(context, XPathSequence(item));
    } else {
      yield item;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each
const fnArrayForEach = XPathFunctionDefinition(
  namespace: 'array',
  name: 'for-each',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayForEach,
);

XPathSequence _fnArrayForEach(
  XPathContext context,
  List<Object> array,
  Function action,
) {
  final result = <Object>[];
  for (final item in array) {
    final seq = action(context, [item.toXPathSequence()]) as XPathSequence;
    result.add(seq.length == 1 ? seq.first : seq);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-filter
const fnArrayFilter = XPathFunctionDefinition(
  namespace: 'array',
  name: 'filter',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'predicate', type: xsFunction),
  ],
  function: _fnArrayFilter,
);

XPathSequence _fnArrayFilter(
  XPathContext context,
  List<Object> array,
  Function predicate,
) {
  final result = <Object>[];
  for (final item in array) {
    final res = predicate(context, [XPathSequence.single(item)]) as Object;
    if (res.toXPathBoolean()) {
      result.add(item);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-left
const fnArrayFoldLeft = XPathFunctionDefinition(
  namespace: 'array',
  name: 'fold-left',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'zero', type: xsAny),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayFoldLeft,
);

XPathSequence _fnArrayFoldLeft(
  XPathContext context,
  List<Object> array,
  Object zero,
  Function action,
) {
  var result = zero.toXPathSequence();
  for (final item in array) {
    result =
        action(context, [result, XPathSequence.single(item)]) as XPathSequence;
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-right
const fnArrayFoldRight = XPathFunctionDefinition(
  namespace: 'array',
  name: 'fold-right',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: xsArray),
    XPathArgumentDefinition(name: 'zero', type: xsAny),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayFoldRight,
);

XPathSequence _fnArrayFoldRight(
  XPathContext context,
  List<Object> array,
  Object zero,
  Function action,
) {
  var result = zero.toXPathSequence();
  for (var i = array.length - 1; i >= 0; i--) {
    result =
        action(context, [XPathSequence.single(array[i]), result])
            as XPathSequence;
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each-pair
const fnArrayForEachPair = XPathFunctionDefinition(
  namespace: 'array',
  name: 'for-each-pair',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array1', type: xsArray),
    XPathArgumentDefinition(name: 'array2', type: xsArray),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnArrayForEachPair,
);

XPathSequence _fnArrayForEachPair(
  XPathContext context,
  List<Object> array1,
  List<Object> array2,
  Function action,
) {
  final result = <Object>[];
  final len = array1.length < array2.length ? array1.length : array2.length;
  for (var i = 0; i < len; i++) {
    result.add(
      action(context, [
            array1[i].toXPathSequence(),
            array2[i].toXPathSequence(),
          ])
          as Object,
    );
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-sort
const fnArraySort = XPathFunctionDefinition(
  namespace: 'array',
  name: 'sort',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: xsArray)],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
    XPathArgumentDefinition(name: 'key', type: xsFunction),
  ],
  function: _fnArraySort,
);

XPathSequence _fnArraySort(
  XPathContext context,
  List<Object> array, [
  String? collation,
  Function? key,
]) {
  final result = List<Object>.from(array);
  result.sort((a, b) {
    final ka = key != null
        ? (key(context, [XPathSequence.single(a)]) as Object)
        : a;
    final kb = key != null
        ? (key(context, [XPathSequence.single(b)]) as Object)
        : b;
    return ka.toString().compareTo(kb.toString());
  });
  return XPathSequence.single(result);
}
