import '../evaluation/context.dart';
import '../evaluation/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
const fnMapSize = XPathFunctionDefinition(
  namespace: 'map',
  name: 'size',
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: xsMap)],
  function: _fnMapSize,
);

XPathSequence _fnMapSize(XPathContext context, Map<Object, Object> map) =>
    XPathSequence.single(map.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
const fnMapGet = XPathFunctionDefinition(
  namespace: 'map',
  name: 'get',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
  ],
  function: _fnMapGet,
);

XPathSequence _fnMapGet(
  XPathContext context,
  Map<Object, Object> map,
  Object key,
) {
  final value = map[key];
  if (value == null) return XPathSequence.empty;
  return value.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
const fnMapPut = XPathFunctionDefinition(
  namespace: 'map',
  name: 'put',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
    XPathArgumentDefinition(
      name: 'value',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnMapPut,
);

XPathSequence _fnMapPut(
  XPathContext context,
  Map<Object, Object> map,
  Object key,
  XPathSequence value,
) => XPathSequence.single({
  ...map,
  key: value.length == 1 ? value.first : value,
});

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
const fnMapContains = XPathFunctionDefinition(
  namespace: 'map',
  name: 'contains',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
  ],
  function: _fnMapContains,
);

XPathSequence _fnMapContains(
  XPathContext context,
  Map<Object, Object> map,
  Object key,
) => XPathSequence.single(map.containsKey(key));

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
const fnMapRemove = XPathFunctionDefinition(
  namespace: 'map',
  name: 'remove',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(
      name: 'keys',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnMapRemove,
);

XPathSequence _fnMapRemove(
  XPathContext context,
  Map<Object, Object> map,
  XPathSequence keys,
) {
  final result = Map<Object, Object>.from(map);
  for (final key in keys) {
    result.remove(key);
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
const fnMapKeys = XPathFunctionDefinition(
  namespace: 'map',
  name: 'keys',
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: xsMap)],
  function: _fnMapKeys,
);

XPathSequence _fnMapKeys(XPathContext context, Map<Object, Object> map) =>
    XPathSequence(map.keys);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
const fnMapMerge = XPathFunctionDefinition(
  namespace: 'map',
  name: 'merge',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'maps',
      type: XPathSequenceType(
        xsMap,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnMapMerge,
);

XPathSequence _fnMapMerge(
  XPathContext context,
  XPathSequence maps, [
  Map<Object, Object>? options,
]) {
  final result = <Object, Object>{};
  for (final item in maps) {
    if (item is Map<Object, Object>) {
      result.addAll(item);
    }
  }
  return XPathSequence.single(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-for-each
const fnMapForEach = XPathFunctionDefinition(
  namespace: 'map',
  name: 'for-each',
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnMapForEach,
);

XPathSequence _fnMapForEach(
  XPathContext context,
  Map<Object, Object> map,
  Function action,
) => XPathSequence(_fnMapForEachSync(context, map, action));

Iterable<Object> _fnMapForEachSync(
  XPathContext context,
  Map<Object, Object> map,
  Function action,
) sync* {
  for (final entry in map.entries) {
    final result =
        action(context, [
              entry.key.toXPathSequence(),
              entry.value.toXPathSequence(),
            ])
            as Object?;
    if (result is XPathSequence) {
      yield* result;
    } else if (result != null) {
      yield result;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-find
const fnMapFind = XPathFunctionDefinition(
  namespace: 'map',
  name: 'find',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
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
    if (item is Map<Object, Object>) {
      if (item.containsKey(key)) {
        yield item[key] as Object;
      }
      yield* _fnMapFindSync(context, XPathSequence(item.values), key);
    } else if (item is List<Object>) {
      yield* _fnMapFindSync(context, XPathSequence(item), key);
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
const fnMapEntry = XPathFunctionDefinition(
  namespace: 'map',
  name: 'entry',
  requiredArguments: [
    XPathArgumentDefinition(name: 'key', type: xsAny),
    XPathArgumentDefinition(
      name: 'value',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnMapEntry,
);

XPathSequence _fnMapEntry(
  XPathContext context,
  Object key,
  XPathSequence value,
) => XPathSequence.single({key: value.length == 1 ? value.first : value});
