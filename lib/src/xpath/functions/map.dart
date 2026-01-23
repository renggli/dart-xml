import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/atomic.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-same-key
const opSameKey = XPathFunctionDefinition(
  namespace: 'op',
  name: 'same-key',
  requiredArguments: [
    XPathArgumentDefinition(name: 'k1', type: XPathSequence),
    XPathArgumentDefinition(name: 'k2', type: XPathSequence),
  ],
  function: _opSameKey,
);

XPathSequence _opSameKey(
  XPathContext context,
  XPathSequence k1Seq,
  XPathSequence k2Seq,
) {
  final k1 = k1Seq.toAtomicValue();
  final k2 = k2Seq.toAtomicValue();
  // TODO: Handle timezone, etc.
  if (k1 is num && (k1 as num).isNaN && k2 is num && (k2 as num).isNaN) {
    return XPathSequence.trueSequence;
  }
  return XPathSequence.single(k1 == k2);
}

Object _defaultMapMergeOptions(XPathContext context) => const XPathMap({});

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
const mapMerge = XPathFunctionDefinition(
  namespace: 'map',
  name: 'merge',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'maps',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'options',
      type: XPathMap,
      cardinality: XPathArgumentCardinality.zeroOrOne,
      defaultValue: _defaultMapMergeOptions,
    ),
  ],
  function: _mapMerge,
);

XPathSequence _mapMerge(
  XPathContext context,
  XPathSequence maps, [
  XPathMap? options,
]) {
  // arguments[1] is options, currently ignored (TODO)
  final result = <Object?, Object?>{};
  for (final item in maps) {
    result.addAll(item.toXPathMap());
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
const mapSize = XPathFunctionDefinition(
  namespace: 'map',
  name: 'size',
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: XPathMap)],
  function: _mapSize,
);

XPathSequence _mapSize(XPathContext context, XPathMap map) =>
    XPathSequence.single(map.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
const mapKeys = XPathFunctionDefinition(
  namespace: 'map',
  name: 'keys',
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: XPathMap)],
  function: _mapKeys,
);

XPathSequence _mapKeys(XPathContext context, XPathMap map) =>
    XPathSequence(map.keys);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
const mapContains = XPathFunctionDefinition(
  namespace: 'map',
  name: 'contains',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: XPathMap),
    XPathArgumentDefinition(name: 'key', type: XPathSequence),
  ],
  function: _mapContains,
);

XPathSequence _mapContains(
  XPathContext context,
  XPathMap map,
  XPathSequence key,
) {
  final keyValue = key.toAtomicValue();
  return XPathSequence.single(map.containsKey(keyValue));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
const mapGet = XPathFunctionDefinition(
  namespace: 'map',
  name: 'get',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: XPathMap),
    XPathArgumentDefinition(name: 'key', type: XPathSequence),
  ],
  function: _mapGet,
);

XPathSequence _mapGet(XPathContext context, XPathMap map, XPathSequence key) {
  final keyValue = key.toAtomicValue();
  return map[keyValue]?.toXPathSequence() ?? XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-find
const mapFind =
    mapGet; // map:find is alias for map:get (Wait, strictly separate?)
// Actually in spec they are same signature.
// Reuse implementation? Or alias definition?
// Map find: The function returns the value associated with a key ...
// Same as get. But might be better to have distinct definition for correct name reporting?
// But definition name is reported in error?
// Let's define it explicitly.

const mapFindDef = XPathFunctionDefinition(
  namespace: 'map',
  name: 'find',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: XPathMap),
    XPathArgumentDefinition(name: 'key', type: XPathSequence),
  ],
  function: _mapGet, // reuse impl
);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
const mapPut = XPathFunctionDefinition(
  namespace: 'map',
  name: 'put',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: XPathMap),
    XPathArgumentDefinition(name: 'key', type: XPathSequence),
    XPathArgumentDefinition(name: 'value', type: XPathSequence),
  ],
  function: _mapPut,
);

XPathSequence _mapPut(
  XPathContext context,
  XPathMap map,
  XPathSequence key,
  XPathSequence value,
) {
  final keyValue = key.toAtomicValue();
  final valueValue = value.toAtomicValue();
  final result = Map.of(map);
  result[keyValue] = valueValue;
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
const mapEntry = XPathFunctionDefinition(
  namespace: 'map',
  name: 'entry',
  requiredArguments: [
    XPathArgumentDefinition(name: 'key', type: XPathSequence),
    XPathArgumentDefinition(name: 'value', type: XPathSequence),
  ],
  function: _mapEntry,
);

XPathSequence _mapEntry(
  XPathContext context,
  XPathSequence key,
  XPathSequence value,
) {
  final keyValue = key.toAtomicValue();
  final valueValue = value.toAtomicValue();
  return XPathSequence.single({keyValue: valueValue});
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
const mapRemove = XPathFunctionDefinition(
  namespace: 'map',
  name: 'remove',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: XPathMap),
    XPathArgumentDefinition(
      name: 'keys',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _mapRemove,
);

XPathSequence _mapRemove(
  XPathContext context,
  XPathMap map,
  XPathSequence keys,
) {
  final result = Map.of(map);
  for (final key in keys) {
    result.remove(key);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-for-each
const mapForEach = XPathFunctionDefinition(
  namespace: 'map',
  name: 'for-each',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: XPathMap),
    XPathArgumentDefinition(name: 'action', type: XPathFunction),
  ],
  function: _mapForEach,
);

XPathSequence _mapForEach(
  XPathContext context,
  XPathMap map,
  XPathFunction action,
) {
  final result = <Object>[];
  for (final entry in map.entries) {
    result.addAll(
      action(context, [
        XPathSequence.single(entry.key),
        entry.value.toXPathSequence(),
      ]),
    );
  }
  return XPathSequence(result);
}
