import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/map.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
XPathSequence mapMerge(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:merge', arguments, 1, 2);
  final maps = arguments[0];
  // arguments[1] is options, currently ignored

  final result = <Object?, Object?>{};
  for (final item in maps) {
    result.addAll(item.toXPathMap());
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
XPathSequence mapSize(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:size', arguments, 1);
  final map = XPathEvaluationException.extractExactlyOne(
    'map:size',
    'map',
    arguments[0],
  ).toXPathMap();
  return XPathSequence.single(map.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
XPathSequence mapKeys(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:keys', arguments, 1);
  final map = XPathEvaluationException.extractExactlyOne(
    'map:keys',
    'map',
    arguments[0],
  ).toXPathMap();
  return XPathSequence(map.keys);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
XPathSequence mapContains(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:contains', arguments, 2);
  final map = XPathEvaluationException.extractExactlyOne(
    'map:contains',
    'map',
    arguments[0],
  ).toXPathMap();
  final key = XPathEvaluationException.extractExactlyOne(
    'map:contains',
    'key',
    arguments[1],
  );
  return XPathSequence.single(map.containsKey(key));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
XPathSequence mapGet(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:get', arguments, 2);
  final map = XPathEvaluationException.extractExactlyOne(
    'map:get',
    'map',
    arguments[0],
  ).toXPathMap();
  final key = XPathEvaluationException.extractExactlyOne(
    'map:get',
    'key',
    arguments[1],
  );
  return map[key]?.toXPathSequence() ?? XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-find
XPathSequence mapFind(XPathContext context, List<XPathSequence> arguments) =>
    mapGet(context, arguments);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
XPathSequence mapPut(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:put', arguments, 3);
  final map = XPathEvaluationException.extractExactlyOne(
    'map:put',
    'map',
    arguments[0],
  ).toXPathMap();
  final key = XPathEvaluationException.extractExactlyOne(
    'map:put',
    'key',
    arguments[1],
  );
  final value = arguments[2];

  final result = Map.of(map);
  result[key] = value.toAtomicValue();
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
XPathSequence mapEntry(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:entry', arguments, 2);
  final key = XPathEvaluationException.extractExactlyOne(
    'map:entry',
    'key',
    arguments[0],
  );
  final value = arguments[1].toAtomicValue();
  return XPathSequence.single({key: value});
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
XPathSequence mapRemove(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('map:remove', arguments, 2);
  final map = XPathEvaluationException.extractExactlyOne(
    'map:remove',
    'map',
    arguments[0],
  ).toXPathMap();
  final keys = arguments[1];

  final result = Map.of(map);
  for (final key in keys) {
    result.remove(key);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-for-each
XPathSequence mapForEach(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('map:for-each');
}
