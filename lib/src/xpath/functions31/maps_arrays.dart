import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/array.dart';
import '../types31/map.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
XPathSequence mapMerge(
  XPathContext context,
  XPathSequence maps, [
  XPathSequence? options,
]) {
  final result = <Object?, Object?>{};
  for (final item in maps) {
    if (item is Map) {
      result.addAll(item);
    } else {
      throw XPathEvaluationException('Item is not a map: $item');
    }
  }
  // TODO: Handle options (duplicates handling)
  return XPathSequence.single(result.cast<Object, Object>().toXPathMap());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
XPathSequence mapSize(XPathContext context, XPathSequence map) {
  final item = map.toXPathMap();
  return XPathSequence.single(item.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-size
XPathSequence arraySize(XPathContext context, XPathSequence array) {
  final item = array.toXPathArray();
  return XPathSequence.single(item.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
XPathSequence mapKeys(XPathContext context, XPathSequence map) {
  final item = map.toXPathMap();
  // Keys in Dart map can be null, but XPath keys are usually atomic values.
  // We filter simple nulls or convert to logic.
  // XPathSequence expects Object (non-nullable).
  return XPathSequence(item.keys.whereType<Object>());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
XPathSequence mapContains(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
) {
  final item = map.toXPathMap();
  final keyVal = key.firstOrNull;
  return XPathSequence.single(item.containsKey(keyVal));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
XPathSequence mapGet(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
) {
  final item = map.toXPathMap();
  final keyVal = key.firstOrNull;
  final val = item[keyVal];
  return val != null
      ? (val is XPathSequence ? val : XPathSequence.single(val))
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-find
XPathSequence mapFind(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
) => mapGet(context, map, key);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
XPathSequence mapPut(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
  XPathSequence value,
) {
  final item = map.toXPathMap();
  final newMap = Map.of(item);
  final keyVal = key.single;
  newMap[keyVal] = value.length == 1 ? value.first : value;
  return XPathSequence.single(newMap.cast<Object, Object>().toXPathMap());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
XPathSequence mapEntry(
  XPathContext context,
  XPathSequence key,
  XPathSequence value,
) {
  final keyVal = key.single;
  final val = value.length == 1 ? value.first : value;
  // Storing value sequence as the value.
  return XPathSequence.single(
    {keyVal: val}.cast<Object, Object>().toXPathMap(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
XPathSequence mapRemove(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
) {
  final item = map.toXPathMap();
  final newMap = Map.of(item);
  for (final k in key) {
    newMap.remove(k);
  }
  return XPathSequence.single(newMap.cast<Object, Object>().toXPathMap());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-for-each
XPathSequence mapForEach(
  XPathContext context,
  XPathSequence map,
  XPathSequence action,
) {
  // Requires function calling mechanism (higher order).
  throw UnimplementedError('map:for-each');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-get
XPathSequence arrayGet(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
) {
  final item = array.toXPathArray();
  final pos = position.firstOrNull?.toXPathNumber().toInt();
  if (pos == null || pos < 1 || pos > item.length) {
    throw XPathEvaluationException('Array index out of bounds: $pos');
  }
  final member = item[pos - 1];
  return member is XPathSequence ? member : XPathSequence.single(member);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-put
XPathSequence arrayPut(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
  XPathSequence member,
) {
  final item = array.toXPathArray();
  final pos = position.firstOrNull?.toXPathNumber().toInt();
  if (pos == null || pos < 1 || pos > item.length) {
    throw XPathEvaluationException('Array index out of bounds: $pos');
  }
  final newList = List.of(item);
  newList[pos - 1] = member.length == 1 ? member.first : member;
  return XPathSequence.single(newList.toXPathArray());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-append
XPathSequence arrayAppend(
  XPathContext context,
  XPathSequence array,
  XPathSequence member,
) {
  final item = array.toXPathArray();
  final newList = List.of(item);
  newList.add(member.length == 1 ? member.first : member);
  return XPathSequence.single(newList.toXPathArray());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-subarray
XPathSequence arraySubarray(
  XPathContext context,
  XPathSequence array,
  XPathSequence start, [
  XPathSequence? length,
]) {
  final item = array.toXPathArray();
  final s = start.firstOrNull?.toXPathNumber().toInt() ?? 1;
  final l = length?.firstOrNull?.toXPathNumber().toInt();

  if (s < 1) throw XPathEvaluationException('Start index must be >= 1');
  final startIndex = s - 1;
  if (startIndex > item.length) {
    return XPathSequence.single([]);
  }

  final endIndex = l != null ? startIndex + l : item.length;
  if (endIndex > item.length) {
    // Spec says error or truncate? Spec: "If $start+$length > array size + 1, error"
    // Actually spec says: if $start + $length > size($array) + 1 raise error FOAY0001
    if (l != null) throw XPathEvaluationException('Subarray out of bounds');
    // If length omitted, to end.
  }

  return XPathSequence.single(
    item.sublist(startIndex, l != null ? endIndex : null).toXPathArray(),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-remove
XPathSequence arrayRemove(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
) {
  final item = array.toXPathArray();
  final newList = List.of(item);
  // position can be sequence of integers.
  // Sort positions descending to remove correctly?
  // Simplification: assume single position for now or handle list.
  final sortedPositions =
      position.map((p) => p.toXPathNumber().toInt()).toList()
        ..sort((a, b) => b.compareTo(a));

  for (final pos in sortedPositions) {
    if (pos >= 1 && pos <= newList.length) {
      newList.removeAt(pos - 1);
    } else {
      throw XPathEvaluationException('Index out of bounds: $pos');
    }
  }
  return XPathSequence.single(newList.toXPathArray());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-insert-before
XPathSequence arrayInsertBefore(
  XPathContext context,
  XPathSequence array,
  XPathSequence position,
  XPathSequence member,
) {
  final item = array.toXPathArray();
  final pos = position.firstOrNull?.toXPathNumber().toInt();
  if (pos == null || pos < 1 || pos > item.length + 1) {
    throw XPathEvaluationException('Index out of bounds: $pos');
  }
  final newList = List.of(item);
  newList.insert(pos - 1, member.length == 1 ? member.first : member);
  return XPathSequence.single(newList.toXPathArray());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-head
XPathSequence arrayHead(XPathContext context, XPathSequence array) {
  final item = array.toXPathArray();
  if (item.isEmpty) throw XPathEvaluationException('Array is empty');
  final member = item.first;
  return member is XPathSequence ? member : XPathSequence.single(member);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-tail
XPathSequence arrayTail(XPathContext context, XPathSequence array) {
  final item = array.toXPathArray();
  if (item.isEmpty) throw XPathEvaluationException('Array is empty');
  final newList = item.sublist(1);
  return XPathSequence.single(newList.toXPathArray());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-reverse
XPathSequence arrayReverse(XPathContext context, XPathSequence array) {
  final item = array.toXPathArray();
  return XPathSequence.single(item.reversed.toList().toXPathArray());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-array-join
XPathSequence arrayJoin(
  XPathContext context,
  XPathSequence array, [
  XPathSequence? separator,
]) {
  final item = array.toXPathArray();
  final sep = separator?.firstOrNull?.toString() ?? '';
  // Spec: flatten each member string value, join.
  // This is simplified.
  return XPathSequence.single(item.join(sep));
}

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
XPathSequence arrayFlatten(XPathContext context, XPathSequence array) {
  final item = array.firstOrNull;
  if (item is! XPathArray) {
    // Flatten works on sequence of arrays, but here single arg?
    // Spec: function array:flatten($input as item()*) as item()*
    // "Replaces any array appearing in the sequence... by its members"
    // Recursive.
  }
  // This logic works on the sequence $array which might contain arrays.
  // Actually array:flatten argument is "input".
  // Note: the function signature in this file says `XPathSequence array`, meaning the whole sequence.
  // So we iterate over `array`, if item is List (array), recurse. Else keep.

  final result = <Object>[];
  void flatten(Iterable<Object> input) {
    for (final i in input) {
      if (i is XPathArray) {
        // Safely cast or filter nulls from nested list
        flatten(i.whereType<Object>());
      } else {
        result.add(i);
      }
    }
  }

  flatten(array);
  return XPathSequence(result);
}
