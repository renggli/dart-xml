import 'dart:math' as math;

import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/array.dart';
import '../types/boolean.dart';
import '../types/function.dart';
import '../types/item.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
const arraySize = XPathFunctionDefinition(
  namespace: 'array',
  name: 'size',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: XPathArray)],
  function: _arraySize,
);

XPathSequence _arraySize(XPathContext context, XPathArray array) =>
    XPathSequence.single(array.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
const arrayGet = XPathFunctionDefinition(
  namespace: 'array',
  name: 'get',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'position', type: XPathNumber),
  ],
  function: _arrayGet,
);

XPathSequence _arrayGet(
  XPathContext context,
  XPathArray array,
  XPathNumber position,
) {
  final pos = position.toInt();
  if (pos < 1 || pos > array.length) {
    throw XPathEvaluationException('array:get: Index out of bounds: $pos');
  }
  return array[pos - 1].toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
const arrayPut = XPathFunctionDefinition(
  namespace: 'array',
  name: 'put',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'position', type: XPathNumber),
    XPathArgumentDefinition(
      name: 'member',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _arrayPut,
);

XPathSequence _arrayPut(
  XPathContext context,
  XPathArray array,
  XPathNumber position,
  XPathSequence member,
) {
  final pos = position.toInt();
  if (pos < 1 || pos > array.length) {
    throw XPathEvaluationException('array:put: Index out of bounds: $pos');
  }
  final result = List.of(array);
  result[pos - 1] = member.toAtomicValue();
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
const arrayAppend = XPathFunctionDefinition(
  namespace: 'array',
  name: 'append',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(
      name: 'member',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _arrayAppend,
);

XPathSequence _arrayAppend(
  XPathContext context,
  XPathArray array,
  XPathSequence member,
) {
  final result = List.of(array);
  result.add(member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
const arraySubarray = XPathFunctionDefinition(
  namespace: 'array',
  name: 'subarray',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'start', type: XPathNumber),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'length',
      type: XPathNumber,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _arraySubarray,
);

XPathSequence _arraySubarray(
  XPathContext context,
  XPathArray array,
  XPathNumber start, [
  XPathNumber? length,
]) {
  final startPos = start.toInt();
  final lenVal = length == null ? array.length - startPos + 1 : length.toInt();

  if (startPos < 1 || startPos > array.length + 1) {
    throw XPathEvaluationException('array:subarray: Start out of bounds');
  }
  if (lenVal < 0) {
    throw XPathEvaluationException('array:subarray: Negative length');
  }
  if (startPos + lenVal - 1 > array.length) {
    throw XPathEvaluationException('array:subarray: Range out of bounds');
  }
  return XPathSequence.single(
    array.sublist(startPos - 1, startPos + lenVal - 1),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
const arrayRemove = XPathFunctionDefinition(
  namespace: 'array',
  name: 'remove',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(
      name: 'positions',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _arrayRemove,
);

XPathSequence _arrayRemove(
  XPathContext context,
  XPathArray array,
  XPathSequence positions,
) {
  final positionsList = positions
      .map((pos) => pos.toXPathNumber().toInt())
      .toList();
  positionsList.sort();
  final result = List.of(array);
  for (final position in positionsList.reversed) {
    if (position < 1 || position > result.length) {
      throw XPathEvaluationException('array:remove: Index out of bounds');
    }
    result.removeAt(position - 1);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-insert-before
const arrayInsertBefore = XPathFunctionDefinition(
  namespace: 'array',
  name: 'insert-before',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'position', type: XPathNumber),
    XPathArgumentDefinition(
      name: 'member',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _arrayInsertBefore,
);

XPathSequence _arrayInsertBefore(
  XPathContext context,
  XPathArray array,
  XPathNumber position,
  XPathSequence member,
) {
  final pos = position.toInt();
  if (pos < 1 || pos > array.length + 1) {
    throw XPathEvaluationException('array:insert-before: Index out of bounds');
  }
  final result = List.of(array);
  result.insert(pos - 1, member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
const arrayHead = XPathFunctionDefinition(
  namespace: 'array',
  name: 'head',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: XPathArray)],
  function: _arrayHead,
);

XPathSequence _arrayHead(XPathContext context, XPathArray array) {
  if (array.isEmpty) {
    throw XPathEvaluationException('array:head: Array is empty');
  }
  return array.first.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
const arrayTail = XPathFunctionDefinition(
  namespace: 'array',
  name: 'tail',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: XPathArray)],
  function: _arrayTail,
);

XPathSequence _arrayTail(XPathContext context, XPathArray array) {
  if (array.isEmpty) {
    throw XPathEvaluationException('array:tail: Array is empty');
  }
  return XPathSequence.single(array.sublist(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
const arrayReverse = XPathFunctionDefinition(
  namespace: 'array',
  name: 'reverse',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: XPathArray)],
  function: _arrayReverse,
);

XPathSequence _arrayReverse(XPathContext context, XPathArray array) =>
    XPathSequence.single(array.reversed.toList());

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
const arrayJoin = XPathFunctionDefinition(
  namespace: 'array',
  name: 'join',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arrays',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _arrayJoin,
);

XPathSequence _arrayJoin(XPathContext context, XPathSequence arrays) =>
    XPathSequence.single(
      arrays.expand((array) => array.toXPathArray()).toList(),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each
const arrayForEach = XPathFunctionDefinition(
  namespace: 'array',
  name: 'for-each',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'action', type: XPathFunction),
  ],
  function: _arrayForEach,
);

XPathSequence _arrayForEach(
  XPathContext context,
  XPathArray array,
  XPathFunction action,
) {
  final result = <Object>[];
  for (final member in array) {
    result.add(action(context, [member.toXPathSequence()]));
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-filter
const arrayFilter = XPathFunctionDefinition(
  namespace: 'array',
  name: 'filter',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _arrayFilter,
);

XPathSequence _arrayFilter(
  XPathContext context,
  XPathArray array,
  XPathFunction function,
) {
  final result = <Object>[];
  for (final member in array) {
    if (function(context, [member.toXPathSequence()]).toXPathBoolean()) {
      result.add(member);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-left
const arrayFoldLeft = XPathFunctionDefinition(
  namespace: 'array',
  name: 'fold-left',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'zero', type: XPathSequence),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _arrayFoldLeft,
);

XPathSequence _arrayFoldLeft(
  XPathContext context,
  XPathArray array,
  XPathSequence zero,
  XPathFunction function,
) {
  var result = zero;
  for (final member in array) {
    result = function(context, [result, member.toXPathSequence()]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-right
const arrayFoldRight = XPathFunctionDefinition(
  namespace: 'array',
  name: 'fold-right',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array', type: XPathArray),
    XPathArgumentDefinition(name: 'zero', type: XPathSequence),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _arrayFoldRight,
);

XPathSequence _arrayFoldRight(
  XPathContext context,
  XPathArray array,
  XPathSequence zero,
  XPathFunction function,
) {
  var result = zero;
  for (final member in array.reversed) {
    result = function(context, [member.toXPathSequence(), result]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each-pair
const arrayForEachPair = XPathFunctionDefinition(
  namespace: 'array',
  name: 'for-each-pair',
  requiredArguments: [
    XPathArgumentDefinition(name: 'array1', type: XPathArray),
    XPathArgumentDefinition(name: 'array2', type: XPathArray),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _arrayForEachPair,
);

XPathSequence _arrayForEachPair(
  XPathContext context,
  XPathArray array1,
  XPathArray array2,
  XPathFunction function,
) {
  final result = <Object>[];
  final minLen = math.min(array1.length, array2.length);
  for (var i = 0; i < minLen; i++) {
    result.add(
      function(context, [
        array1[i].toXPathSequence(),
        array2[i].toXPathSequence(),
      ]),
    );
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-sort
const arraySort = XPathFunctionDefinition(
  namespace: 'array',
  name: 'sort',
  requiredArguments: [XPathArgumentDefinition(name: 'array', type: XPathArray)],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'key',
      type: XPathFunction,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _arraySort,
);

XPathSequence _arraySort(
  XPathContext context,
  XPathArray array, [
  XPathString? collation,
  XPathFunction? key,
]) {
  // ignore: unused_local_variable
  final coll = collation; // ignored
  final keyFunc = key;

  final list = List.of(array);
  list.sort((a, b) {
    if (keyFunc != null) {
      final keyA = keyFunc(context, [a.toXPathSequence()]).toAtomicValue();
      final keyB = keyFunc(context, [b.toXPathSequence()]).toAtomicValue();
      if (keyA is Comparable && keyB is Comparable) {
        try {
          return keyA.compareTo(keyB);
        } catch (_) {}
      }
      return keyA.toString().compareTo(keyB.toString());
    }
    final valA = a.toAtomicValue();
    final valB = b.toAtomicValue();
    if (valA is Comparable && valB is Comparable) {
      try {
        return valA.compareTo(valB);
      } catch (_) {}
    }
    return valA.toString().compareTo(valB.toString());
  });
  return XPathSequence.single(list);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-flatten
const arrayFlatten = XPathFunctionDefinition(
  namespace: 'array',
  name: 'flatten',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _arrayFlatten,
);

XPathSequence _arrayFlatten(XPathContext context, XPathSequence input) {
  final result = <Object>[];
  void flatten(XPathArray array) {
    for (final value in array) {
      if (value is XPathArray) {
        flatten(value);
      } else {
        result.add(value);
      }
    }
  }

  // Previous impl: flatten(XPathArray(input.toList()));
  // input is sequence. Items in sequence might be arrays?
  // array:flatten((1, [2, 3], [[4]])) -> 1, 2, 3, 4
  // If item is array, flatten recursively. If not, add.
  // Actually spec says input is sequence.
  // The function flattens ANY usage of arrays within the sequence.
  // Original impl wrapped input in array then flattened? No, it called `XPathArray(input.toList())`.
  // That created a single array of items.
  // Then `flatten` traversed it.
  // If `input` contained `[1, 2]`, `flatten` encountered it.
  // So logic is:
  for (final item in input) {
    if (item is XPathArray) {
      flatten(item); // uses same flatten helper
    } else {
      result.add(item);
    }
  }
  return XPathSequence(result);
}
