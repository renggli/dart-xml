import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/any.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
const fnMapSize = XPathFunctionDefinition(
  name: 'map:size',
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: xsMap)],
  function: _fnMapSize,
);

XPathSequence _fnMapSize(XPathContext context, XPathMap map) =>
    XPathSequence.single(map.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
const fnMapGet = XPathFunctionDefinition(
  name: 'map:get',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
  ],
  function: _fnMapGet,
);

XPathSequence _fnMapGet(XPathContext context, XPathMap map, Object key) {
  final value = map[key];
  if (value == null) return XPathSequence.empty;
  return xsSequence.cast(value);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
const fnMapPut = XPathFunctionDefinition(
  name: 'map:put',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnMapPut,
);

XPathSequence _fnMapPut(
  XPathContext context,
  XPathMap map,
  Object key,
  XPathSequence value,
) => XPathSequence.single({...map, key: value.toAtomicValue()});

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
const fnMapContains = XPathFunctionDefinition(
  name: 'map:contains',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
  ],
  function: _fnMapContains,
);

XPathSequence _fnMapContains(XPathContext context, XPathMap map, Object key) =>
    XPathSequence.single(map.containsKey(key));

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
const fnMapRemove = XPathFunctionDefinition(
  name: 'map:remove',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(
      name: 'keys',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnMapRemove,
);

XPathSequence _fnMapRemove(
  XPathContext context,
  XPathMap map,
  XPathSequence keys,
) {
  final result = XPathMap.from(map);
  for (final key in keys) {
    result.remove(key);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
const fnMapKeys = XPathFunctionDefinition(
  name: 'map:keys',
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: xsMap)],
  function: _fnMapKeys,
);

XPathSequence _fnMapKeys(XPathContext context, XPathMap map) =>
    XPathSequence(map.keys);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
const fnMapMerge = XPathFunctionDefinition(
  name: 'map:merge',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'maps',
      type: xsMap,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnMapMerge,
);

XPathSequence _fnMapMerge(
  XPathContext context,
  XPathSequence maps, [
  XPathMap? options,
]) {
  final result = <Object, Object>{};
  for (final item in maps) {
    if (item is XPathMap) {
      result.addAll(item);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-for-each
const fnMapForEach = XPathFunctionDefinition(
  name: 'map:for-each',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnMapForEach,
);

XPathSequence _fnMapForEach(
  XPathContext context,
  XPathMap map,
  XPathFunction action,
) => XPathSequence(_fnMapForEachSync(context, map, action));

Iterable<Object> _fnMapForEachSync(
  XPathContext context,
  XPathMap map,
  XPathFunction action,
) sync* {
  for (final entry in map.entries) {
    yield* action(context, [
      xsSequence.cast(entry.key),
      xsSequence.cast(entry.value),
    ]);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-find
const fnMapFind = XPathFunctionDefinition(
  name: 'map:find',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'key', type: xsAny),
  ],
  function: _fnMapFind,
);

XPathSequence _fnMapFind(
  XPathContext context,
  XPathSequence input,
  Object key,
) => XPathSequence(_fnMapFindSync(context, input, key));

Iterable<Object> _fnMapFindSync(
  XPathContext context,
  XPathSequence input,
  Object key,
) sync* {
  for (final item in input) {
    if (item is Map) {
      if (item.containsKey(
        key is XPathSequence && key.length == 1 ? key.first : key,
      )) {
        yield item[key is XPathSequence && key.length == 1 ? key.first : key]
            as Object;
      }
      yield* _fnMapFindSync(
        context,
        XPathSequence(item.values.cast<Object>()),
        key,
      );
    } else if (item is List<Object>) {
      yield* _fnMapFindSync(context, XPathSequence(item), key);
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
const fnMapEntry = XPathFunctionDefinition(
  name: 'map:entry',
  requiredArguments: [
    XPathArgumentDefinition(name: 'key', type: xsAny),
    XPathArgumentDefinition(
      name: 'value',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnMapEntry,
);

XPathSequence _fnMapEntry(
  XPathContext context,
  Object key,
  XPathSequence value,
) => XPathSequence.single({key: value.toAtomicValue()});
