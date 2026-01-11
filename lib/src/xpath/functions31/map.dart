import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/map.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
XPathSequence mapMerge(
  XPathContext context,
  XPathSequence maps, [
  XPathSequence? options,
]) {
  final result = <Object?, Object?>{};
  for (final item in maps) {
    result.addAll(item.toXPathMap());
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
XPathSequence mapSize(XPathContext context, XPathSequence map) {
  final item = XPathEvaluationException.checkExactlyOne(map).toXPathMap();
  return XPathSequence.single(item.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
XPathSequence mapKeys(XPathContext context, XPathSequence map) {
  final mapVal = XPathEvaluationException.checkExactlyOne(map).toXPathMap();
  return XPathSequence(mapVal.keys);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
XPathSequence mapContains(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
) {
  final mapVal = XPathEvaluationException.checkExactlyOne(map).toXPathMap();
  final keyVal = XPathEvaluationException.checkExactlyOne(key);
  return XPathSequence.single(mapVal.containsKey(keyVal));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
XPathSequence mapGet(
  XPathContext context,
  XPathSequence map,
  XPathSequence key,
) {
  final mapVal = XPathEvaluationException.checkExactlyOne(map).toXPathMap();
  final keyVal = XPathEvaluationException.checkExactlyOne(key);
  final result = mapVal[keyVal];
  return result != null
      ? (result is XPathSequence ? result : XPathSequence.single(result))
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
  final mapVal = XPathEvaluationException.checkExactlyOne(map).toXPathMap();
  final keyVal = XPathEvaluationException.checkExactlyOne(key);
  final result = Map.of(mapVal);
  result[keyVal] = value.toAtomicValue();
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
XPathSequence mapEntry(
  XPathContext context,
  XPathSequence key,
  XPathSequence value,
) {
  final keyVal = XPathEvaluationException.checkExactlyOne(key);
  final valueVal = value.toAtomicValue();
  return XPathSequence.single({keyVal: valueVal});
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
XPathSequence mapRemove(
  XPathContext context,
  XPathSequence map,
  XPathSequence keys,
) {
  final mapVal = XPathEvaluationException.checkExactlyOne(map).toXPathMap();
  final result = Map.of(mapVal);
  for (final key in keys) {
    result.remove(key);
  }
  return XPathSequence.single(result);
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
