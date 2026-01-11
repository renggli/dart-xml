import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/array.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
XPathSequence arraySize(XPathContext context, XPathSequence array) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  return XPathSequence.single(arrayVal.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
XPathSequence arrayGet(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  final positionVal = XPathEvaluationException.checkExactlyOne(
    position,
  ).toXPathNumber().toInt();
  if (positionVal < 1 || positionVal > arrayVal.length) {
    throw XPathEvaluationException(
      'array:get: Index out of bounds: $positionVal',
    );
  }
  return arrayVal[positionVal - 1].toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
XPathSequence arrayPut(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
  XPathSequence member,
) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  final positionVal = XPathEvaluationException.checkExactlyOne(
    position,
  ).toXPathNumber().toInt();
  if (positionVal < 1 || positionVal > arrayVal.length) {
    throw XPathEvaluationException(
      'array:put: Index out of bounds: $positionVal',
    );
  }
  final result = List.of(arrayVal);
  result[positionVal - 1] = member.toAtomicValue();
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
XPathSequence arrayAppend(
  XPathContext context,
  XPathSequence array,
  XPathSequence member,
) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  final result = List.of(arrayVal);
  result.add(member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
XPathSequence arraySubarray(
  XPathContext context,
  XPathSequence array,
  XPathSequence start, [
  XPathSequence? length,
]) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  final startVal = XPathEvaluationException.checkExactlyOne(
    start,
  ).toXPathNumber().toInt();
  final lengthVal = length != null
      ? XPathEvaluationException.checkExactlyOne(length).toXPathNumber().toInt()
      : arrayVal.length - startVal + 1;
  if (startVal < 1 || startVal > arrayVal.length + 1) {
    throw XPathEvaluationException('array:subarray: Start out of bounds');
  }
  if (lengthVal < 0) {
    throw XPathEvaluationException('array:subarray: Negative length');
  }
  if (startVal + lengthVal - 1 > arrayVal.length) {
    throw XPathEvaluationException('array:subarray: Range out of bounds');
  }
  return XPathSequence.single(
    arrayVal.sublist(startVal - 1, startVal + lengthVal - 1),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
XPathSequence arrayRemove(
  XPathContext context,
  XPathSequence array,
  XPathSequence positions,
) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  final positionsList = positions
      .map((pos) => pos.toXPathNumber().toInt())
      .toList();
  positionsList.sort();
  final result = List.of(arrayVal);
  for (final position in positionsList.reversed) {
    if (position < 1 || position > result.length) {
      throw XPathEvaluationException('array:remove: Index out of bounds');
    }
    result.removeAt(position - 1);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-insert-before
XPathSequence arrayInsertBefore(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
  XPathSequence member,
) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  final positionVal = XPathEvaluationException.checkExactlyOne(
    position,
  ).toXPathNumber().toInt();
  if (positionVal < 1 || positionVal > arrayVal.length + 1) {
    throw XPathEvaluationException('array:insert-before: Index out of bounds');
  }
  final result = List.of(arrayVal);
  result.insert(positionVal - 1, member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
XPathSequence arrayHead(XPathContext context, XPathSequence array) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  if (arrayVal.isEmpty) {
    throw XPathEvaluationException('array:head: Array is empty');
  }
  return arrayVal.first.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
XPathSequence arrayTail(XPathContext context, XPathSequence array) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  if (arrayVal.isEmpty) {
    throw XPathEvaluationException('array:tail: Array is empty');
  }
  return XPathSequence.single(arrayVal.sublist(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
XPathSequence arrayReverse(XPathContext context, XPathSequence array) {
  final arrayVal = XPathEvaluationException.checkExactlyOne(
    array,
  ).toXPathArray();
  return XPathSequence.single(arrayVal.reversed.toList());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
XPathSequence arrayJoin(XPathContext context, XPathSequence arrays) =>
    XPathSequence.single(
      arrays.expand((array) => array.toXPathArray()).toList(),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each
XPathSequence arrayForEach(
  XPathContext context,
  XPathSequence array,
  XPathSequence action,
) {
  throw UnimplementedError('array:for-each');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-filter
XPathSequence arrayFilter(
  XPathContext context,
  XPathSequence array,
  XPathSequence function,
) {
  throw UnimplementedError('array:filter');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-left
XPathSequence arrayFoldLeft(
  XPathContext context,
  XPathSequence array,
  XPathSequence zero,
  XPathSequence function,
) {
  throw UnimplementedError('array:fold-left');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-right
XPathSequence arrayFoldRight(
  XPathContext context,
  XPathSequence array,
  XPathSequence zero,
  XPathSequence function,
) {
  throw UnimplementedError('array:fold-right');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each-pair
XPathSequence arrayForEachPair(
  XPathContext context,
  XPathSequence array1,
  XPathSequence array2,
  XPathSequence function,
) {
  throw UnimplementedError('array:for-each-pair');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-sort
XPathSequence arraySort(
  XPathContext context,
  XPathSequence array, [
  XPathSequence? collation,
  XPathSequence? key,
]) {
  // Sort requires evaluating key function so complex.
  throw UnimplementedError('array:sort');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-flatten
XPathSequence arrayFlatten(XPathContext context, XPathSequence input) {
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

  flatten(XPathArray(input.toList()));
  return XPathSequence(result);
}
