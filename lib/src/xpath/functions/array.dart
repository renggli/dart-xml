import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
const fnArraySize = XPathFunctionItem.fn1(
  XmlName.qualified('array:size'),
  _fnArraySize,
);

XPathSequence _fnArraySize(XPathContext context, XPathSequence arraySeq) {
  final array = arraySeq.first as XPathArray;
  return XPathSequence.single(XPathInteger.fromInt(array.length));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
const fnArrayGet = XPathFunctionItem.fn2(
  XmlName.qualified('array:get'),
  _fnArrayGet,
);

XPathSequence _fnArrayGet(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence positionSeq,
) {
  final array = arraySeq.first as XPathArray;
  final position = positionSeq.first as XPathInteger;
  final index = position.asInt - 1;
  if (index < 0 || index >= array.length) {
    throw XPathEvaluationException(
      'Array index out of bounds: ${position.asInt}',
    );
  }
  return array[index];
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
const fnArrayPut = XPathFunctionItem.fn3(
  XmlName.qualified('array:put'),
  _fnArrayPut,
);

XPathSequence _fnArrayPut(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence positionSeq,
  XPathSequence member,
) {
  final array = arraySeq.first as XPathArray;
  final position = positionSeq.first as XPathInteger;
  final index = position.asInt - 1;
  if (index < 0 || index >= array.length) {
    throw XPathEvaluationException(
      'Array index out of bounds: ${position.asInt}',
    );
  }
  final members = List<XPathSequence>.from(array.members);
  members[index] = member;
  return XPathSequence.single(XPathArray(members));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
const fnArrayAppend = XPathFunctionItem.fn2(
  XmlName.qualified('array:append'),
  _fnArrayAppend,
);

XPathSequence _fnArrayAppend(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence member,
) {
  final array = arraySeq.first as XPathArray;
  return XPathSequence.single(XPathArray([...array.members, member]));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
const fnArraySubarray = XPathFunctionItem.overloaded(
  XmlName.qualified('array:subarray'),
  {
    2: XPathFunctionItem.fn2(
      XmlName.qualified('array:subarray'),
      _fnArraySubarray2,
    ),
    3: XPathFunctionItem.fn3(
      XmlName.qualified('array:subarray'),
      _fnArraySubarray3,
    ),
  },
);

XPathSequence _fnArraySubarray2(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence startSeq,
) => _evalSubarray(
  arraySeq.first as XPathArray,
  startSeq.first as XPathInteger,
  null,
);

XPathSequence _fnArraySubarray3(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence startSeq,
  XPathSequence lengthSeq,
) => _evalSubarray(
  arraySeq.first as XPathArray,
  startSeq.first as XPathInteger,
  lengthSeq.firstOrNull as XPathInteger?,
);

XPathSequence _evalSubarray(
  XPathArray array,
  XPathInteger start,
  XPathInteger? length,
) {
  final s = start.asInt - 1;
  final l = length?.asInt ?? (array.length - s);
  if (s < 0 || s > array.length || l < 0 || s + l > array.length) {
    throw XPathEvaluationException(
      'Invalid subarray range: ${start.asInt}, ${length?.asInt}',
    );
  }
  return XPathSequence.single(XPathArray(array.members.sublist(s, s + l)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
const fnArrayRemove = XPathFunctionItem.fn2(
  XmlName.qualified('array:remove'),
  _fnArrayRemove,
);

XPathSequence _fnArrayRemove(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence positions,
) {
  final array = arraySeq.first as XPathArray;
  final indices = positions
      .atomize()
      .map((p) => (p as XPathInteger).asInt - 1)
      .toSet();
  for (final index in indices) {
    if (index < 0 || index >= array.length) {
      throw XPathEvaluationException('Array index out of bounds: ${index + 1}');
    }
  }
  final result = <XPathSequence>[];
  for (var i = 0; i < array.length; i++) {
    if (!indices.contains(i)) {
      result.add(array[i]);
    }
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-insert-before
const fnArrayInsertBefore = XPathFunctionItem.fn3(
  XmlName.qualified('array:insert-before'),
  _fnArrayInsertBefore,
);

XPathSequence _fnArrayInsertBefore(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence positionSeq,
  XPathSequence member,
) {
  final array = arraySeq.first as XPathArray;
  final position = positionSeq.first as XPathInteger;
  final index = position.asInt - 1;
  if (index < 0 || index > array.length) {
    throw XPathEvaluationException(
      'Array index out of bounds: ${position.asInt}',
    );
  }
  final result = List<XPathSequence>.from(array.members);
  result.insert(index, member);
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
const fnArrayHead = XPathFunctionItem.fn1(
  XmlName.qualified('array:head'),
  _fnArrayHead,
);

XPathSequence _fnArrayHead(XPathContext context, XPathSequence arraySeq) {
  final array = arraySeq.first as XPathArray;
  if (array.isEmpty) {
    throw XPathEvaluationException('Empty array');
  }
  return array.members.first;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
const fnArrayTail = XPathFunctionItem.fn1(
  XmlName.qualified('array:tail'),
  _fnArrayTail,
);

XPathSequence _fnArrayTail(XPathContext context, XPathSequence arraySeq) {
  final array = arraySeq.first as XPathArray;
  if (array.isEmpty) {
    throw XPathEvaluationException('Empty array');
  }
  return XPathSequence.single(XPathArray(array.members.sublist(1)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
const fnArrayReverse = XPathFunctionItem.fn1(
  XmlName.qualified('array:reverse'),
  _fnArrayReverse,
);

XPathSequence _fnArrayReverse(XPathContext context, XPathSequence arraySeq) {
  final array = arraySeq.first as XPathArray;
  return XPathSequence.single(XPathArray(array.members.reversed.toList()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
const fnArrayJoin = XPathFunctionItem.fn1(
  XmlName.qualified('array:join'),
  _fnArrayJoin,
);

XPathSequence _fnArrayJoin(XPathContext context, XPathSequence arrays) {
  final result = <XPathSequence>[];
  for (final item in arrays) {
    result.addAll((item as XPathArray).members);
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-flatten
const fnArrayFlatten = XPathFunctionItem.fn1(
  XmlName.qualified('array:flatten'),
  _fnArrayFlatten,
);

XPathSequence _fnArrayFlatten(XPathContext context, XPathSequence input) =>
    XPathSequence(_fnArrayFlattenSync(context, input));

Iterable<XPathItem> _fnArrayFlattenSync(
  XPathContext context,
  XPathSequence input,
) sync* {
  for (final item in input) {
    if (item is XPathArray) {
      for (final member in item.members) {
        yield* _fnArrayFlattenSync(context, member);
      }
    } else {
      yield item;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each
const fnArrayForEach = XPathFunctionItem.fn2(
  XmlName.qualified('array:for-each'),
  _fnArrayForEach,
);

XPathSequence _fnArrayForEach(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence actionSeq,
) {
  final array = arraySeq.first as XPathArray;
  final action = actionSeq.first as XPathFunctionItem;
  final result = <XPathSequence>[];
  for (final item in array.members) {
    final value = action.call(context, [item]);
    result.add(value);
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-filter
const fnArrayFilter = XPathFunctionItem.fn2(
  XmlName.qualified('array:filter'),
  _fnArrayFilter,
);

XPathSequence _fnArrayFilter(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence predicateSeq,
) {
  final array = arraySeq.first as XPathArray;
  final predicate = predicateSeq.first as XPathFunctionItem;
  final result = <XPathSequence>[];
  for (final item in array.members) {
    final value = predicate.call(context, [item]);
    if (value.effectiveBooleanValue) result.add(item);
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-left
const fnArrayFoldLeft = XPathFunctionItem.fn3(
  XmlName.qualified('array:fold-left'),
  _fnArrayFoldLeft,
);

XPathSequence _fnArrayFoldLeft(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence zero,
  XPathSequence actionSeq,
) {
  final array = arraySeq.first as XPathArray;
  final action = actionSeq.first as XPathFunctionItem;
  var result = zero;
  for (final item in array.members) {
    result = action.call(context, [result, item]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-right
const fnArrayFoldRight = XPathFunctionItem.fn3(
  XmlName.qualified('array:fold-right'),
  _fnArrayFoldRight,
);

XPathSequence _fnArrayFoldRight(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence zero,
  XPathSequence actionSeq,
) {
  final array = arraySeq.first as XPathArray;
  final action = actionSeq.first as XPathFunctionItem;
  var result = zero;
  for (var i = array.members.length - 1; i >= 0; i--) {
    result = action.call(context, [array.members[i], result]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each-pair
const fnArrayForEachPair = XPathFunctionItem.fn3(
  XmlName.qualified('array:for-each-pair'),
  _fnArrayForEachPair,
);

XPathSequence _fnArrayForEachPair(
  XPathContext context,
  XPathSequence array1Seq,
  XPathSequence array2Seq,
  XPathSequence actionSeq,
) {
  final array1 = array1Seq.first as XPathArray;
  final array2 = array2Seq.first as XPathArray;
  final action = actionSeq.first as XPathFunctionItem;
  final result = <XPathSequence>[];
  final len = array1.length < array2.length ? array1.length : array2.length;
  for (var i = 0; i < len; i++) {
    final value = action.call(context, [array1[i], array2[i]]);
    result.add(value);
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-sort
const fnArraySort = XPathFunctionItem.overloaded(
  XmlName.qualified('array:sort'),
  {
    1: XPathFunctionItem.fn1(XmlName.qualified('array:sort'), _fnArraySort1),
    2: XPathFunctionItem.fn2(XmlName.qualified('array:sort'), _fnArraySort2),
    3: XPathFunctionItem.fn3(XmlName.qualified('array:sort'), _fnArraySort3),
  },
);

XPathSequence _fnArraySort1(XPathContext context, XPathSequence arraySeq) =>
    _evalArraySort(context, arraySeq.first as XPathArray, null, null);

XPathSequence _fnArraySort2(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence collationSeq,
) => _evalArraySort(
  context,
  arraySeq.first as XPathArray,
  collationSeq.firstOrNull as XPathString?,
  null,
);

XPathSequence _fnArraySort3(
  XPathContext context,
  XPathSequence arraySeq,
  XPathSequence collationSeq,
  XPathSequence keySeq,
) => _evalArraySort(
  context,
  arraySeq.first as XPathArray,
  collationSeq.firstOrNull as XPathString?,
  keySeq.firstOrNull as XPathFunctionItem?,
);

XPathSequence _evalArraySort(
  XPathContext context,
  XPathArray array,
  XPathString? collation,
  XPathFunctionItem? key,
) {
  final result = List<XPathSequence>.from(array.members);
  result.sort((a, b) {
    final ka = key != null ? _evalSortKey(context, key, a) : a;
    final kb = key != null ? _evalSortKey(context, key, b) : b;
    final atomA = ka.atomize().firstOrNull;
    final atomB = kb.atomize().firstOrNull;
    if (atomA == null && atomB == null) return 0;
    if (atomA == null) return -1;
    if (atomB == null) return 1;
    return atomA.compareTo(atomB);
  });
  return XPathSequence.single(XPathArray(result));
}

XPathSequence _evalSortKey(
  XPathContext context,
  XPathFunctionItem key,
  XPathSequence item,
) => key.call(context, [item]);
