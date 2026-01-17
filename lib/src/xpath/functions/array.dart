import 'dart:math' as math;
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/array.dart';
import '../types/boolean.dart';
import '../types/function.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
XPathSequence arraySize(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:size', arguments, 1);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:size',
    'array',
    arguments[0],
  ).toXPathArray();
  return XPathSequence.single(array.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
XPathSequence arrayGet(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:get', arguments, 2);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:get',
    'array',
    arguments[0],
  ).toXPathArray();
  final position = XPathEvaluationException.extractExactlyOne(
    'array:get',
    'position',
    arguments[1],
  ).toXPathNumber().toInt();
  if (position < 1 || position > array.length) {
    throw XPathEvaluationException('array:get: Index out of bounds: $position');
  }
  return array[position - 1].toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
XPathSequence arrayPut(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:put', arguments, 3);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:put',
    'array',
    arguments[0],
  ).toXPathArray();
  final position = XPathEvaluationException.extractExactlyOne(
    'array:put',
    'position',
    arguments[1],
  ).toXPathNumber().toInt();
  final member = arguments[2];
  if (position < 1 || position > array.length) {
    throw XPathEvaluationException('array:put: Index out of bounds: $position');
  }
  final result = List.of(array);
  result[position - 1] = member.toAtomicValue();
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
XPathSequence arrayAppend(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:append', arguments, 2);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:append',
    'array',
    arguments[0],
  ).toXPathArray();
  final member = arguments[1];
  final result = List.of(array);
  result.add(member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
XPathSequence arraySubarray(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'array:subarray',
    arguments,
    2,
    3,
  );
  final array = XPathEvaluationException.extractExactlyOne(
    'array:subarray',
    'array',
    arguments[0],
  ).toXPathArray();
  final start = XPathEvaluationException.extractExactlyOne(
    'array:subarray',
    'start',
    arguments[1],
  ).toXPathNumber().toInt();
  final lengthArg = arguments.length > 2 ? arguments[2] : null;
  final length = lengthArg != null
      ? XPathEvaluationException.extractExactlyOne(
          'array:subarray',
          'length',
          lengthArg,
        ).toXPathNumber().toInt()
      : array.length - start + 1;
  if (start < 1 || start > array.length + 1) {
    throw XPathEvaluationException('array:subarray: Start out of bounds');
  }
  if (length < 0) {
    throw XPathEvaluationException('array:subarray: Negative length');
  }
  if (start + length - 1 > array.length) {
    throw XPathEvaluationException('array:subarray: Range out of bounds');
  }
  return XPathSequence.single(array.sublist(start - 1, start + length - 1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
XPathSequence arrayRemove(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:remove', arguments, 2);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:remove',
    'array',
    arguments[0],
  ).toXPathArray();
  final positions = arguments[1];
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
XPathSequence arrayInsertBefore(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'array:insert-before',
    arguments,
    3,
  );
  final array = XPathEvaluationException.extractExactlyOne(
    'array:insert-before',
    'array',
    arguments[0],
  ).toXPathArray();
  final position = XPathEvaluationException.extractExactlyOne(
    'array:insert-before',
    'position',
    arguments[1],
  ).toXPathNumber().toInt();
  final member = arguments[2];
  if (position < 1 || position > array.length + 1) {
    throw XPathEvaluationException('array:insert-before: Index out of bounds');
  }
  final result = List.of(array);
  result.insert(position - 1, member.toAtomicValue());
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
XPathSequence arrayHead(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:head', arguments, 1);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:head',
    'array',
    arguments[0],
  ).toXPathArray();
  if (array.isEmpty) {
    throw XPathEvaluationException('array:head: Array is empty');
  }
  return array.first.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
XPathSequence arrayTail(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:tail', arguments, 1);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:tail',
    'array',
    arguments[0],
  ).toXPathArray();
  if (array.isEmpty) {
    throw XPathEvaluationException('array:tail: Array is empty');
  }
  return XPathSequence.single(array.sublist(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
XPathSequence arrayReverse(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('array:reverse', arguments, 1);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:reverse',
    'array',
    arguments[0],
  ).toXPathArray();
  return XPathSequence.single(array.reversed.toList());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
XPathSequence arrayJoin(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:join', arguments, 1);
  final arrays = arguments[0];
  return XPathSequence.single(
    arrays.expand((array) => array.toXPathArray()).toList(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each
XPathSequence arrayForEach(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('array:for-each', arguments, 2);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:for-each',
    'array',
    arguments[0],
  ).toXPathArray();
  final action = XPathEvaluationException.extractExactlyOne(
    'array:for-each',
    'action',
    arguments[1],
  ).toXPathFunction();
  final result = <Object>[];
  for (final member in array) {
    result.add(action(context, [member.toXPathSequence()]));
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-filter
XPathSequence arrayFilter(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:filter', arguments, 2);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:filter',
    'array',
    arguments[0],
  ).toXPathArray();
  final function = XPathEvaluationException.extractExactlyOne(
    'array:filter',
    'function',
    arguments[1],
  ).toXPathFunction();
  final result = <Object>[];
  for (final member in array) {
    if (function(context, [member.toXPathSequence()]).toXPathBoolean()) {
      result.add(member);
    }
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-left
XPathSequence arrayFoldLeft(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('array:fold-left', arguments, 3);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:fold-left',
    'array',
    arguments[0],
  ).toXPathArray();
  var zero = arguments[1];
  final function = XPathEvaluationException.extractExactlyOne(
    'array:fold-left',
    'function',
    arguments[2],
  ).toXPathFunction();
  for (final member in array) {
    zero = function(context, [zero, member.toXPathSequence()]);
  }
  return zero;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-fold-right
XPathSequence arrayFoldRight(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('array:fold-right', arguments, 3);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:fold-right',
    'array',
    arguments[0],
  ).toXPathArray();
  var zero = arguments[1];
  final function = XPathEvaluationException.extractExactlyOne(
    'array:fold-right',
    'function',
    arguments[2],
  ).toXPathFunction();
  for (final member in array.reversed) {
    zero = function(context, [member.toXPathSequence(), zero]);
  }
  return zero;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-for-each-pair
XPathSequence arrayForEachPair(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'array:for-each-pair',
    arguments,
    3,
  );
  final array1 = XPathEvaluationException.extractExactlyOne(
    'array:for-each-pair',
    'array1',
    arguments[0],
  ).toXPathArray();
  final array2 = XPathEvaluationException.extractExactlyOne(
    'array:for-each-pair',
    'array2',
    arguments[1],
  ).toXPathArray();
  final action = XPathEvaluationException.extractExactlyOne(
    'array:for-each-pair',
    'function',
    arguments[2],
  ).toXPathFunction();
  final result = <Object>[];
  final minLen = math.min(array1.length, array2.length);
  for (var i = 0; i < minLen; i++) {
    result.add(
      action(context, [
        array1[i].toXPathSequence(),
        array2[i].toXPathSequence(),
      ]),
    );
  }
  return XPathSequence.single(XPathArray(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-sort
XPathSequence arraySort(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('array:sort', arguments, 1, 3);
  final array = XPathEvaluationException.extractExactlyOne(
    'array:sort',
    'array',
    arguments[0],
  ).toXPathArray();
  // ignore: unused_local_variable
  final collation = arguments.length > 1
      ? XPathEvaluationException.extractZeroOrOne(
          'array:sort',
          'collation',
          arguments[1],
        )?.toXPathString()
      : null;
  final key = arguments.length > 2
      ? XPathEvaluationException.extractExactlyOne(
          'array:sort',
          'key',
          arguments[2],
        ).toXPathFunction()
      : null;
  final list = List.of(array);
  list.sort((a, b) {
    if (key != null) {
      final keyA = key(context, [a.toXPathSequence()]).toAtomicValue();
      final keyB = key(context, [b.toXPathSequence()]).toAtomicValue();
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
  return XPathSequence.single(XPathArray(list));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-flatten
XPathSequence arrayFlatten(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('array:flatten', arguments, 1);
  final input = arguments[0];
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
