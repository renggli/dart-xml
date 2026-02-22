import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/any.dart';
import '../types/function.dart';
import '../types/map.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
const fnMapSize = XPathFunctionDefinition(
  name: XmlName.qualified('map:size'),
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: xsMap)],
  function: _fnMapSize,
);

XPathSequence _fnMapSize(XPathContext context, XPathMap map) =>
    XPathSequence.single(map.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
const fnMapGet = XPathFunctionDefinition(
  name: XmlName.qualified('map:get'),
  requiredArguments: [
    XPathArgumentDefinition(name: 'map', type: xsMap),
    XPathArgumentDefinition(name: 'key', type: xsAny),
  ],
  function: _fnMapGet,
);

XPathSequence _fnMapGet(XPathContext context, XPathMap map, Object key) {
  final value = map[key] ?? XPathSequence.empty;
  return value.toXPathSequence();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
const fnMapPut = XPathFunctionDefinition(
  name: XmlName.qualified('map:put'),
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
  name: XmlName.qualified('map:contains'),
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
  name: XmlName.qualified('map:remove'),
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
  name: XmlName.qualified('map:keys'),
  requiredArguments: [XPathArgumentDefinition(name: 'map', type: xsMap)],
  function: _fnMapKeys,
);

XPathSequence _fnMapKeys(XPathContext context, XPathMap map) =>
    XPathSequence(map.keys);

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
const fnMapMerge = XPathFunctionDefinition(
  name: XmlName.qualified('map:merge'),
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
  name: XmlName.qualified('map:for-each'),
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
  name: XmlName.qualified('map:find'),
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
) {
  final result = <Object>[];
  _fnMapFindRecurse(input, key, result);
  return XPathSequence.single(result);
}

void _fnMapFindRecurse(
  XPathSequence sequence,
  Object key,
  List<Object> result,
) {
  for (final item in sequence) {
    if (item is Map) {
      if (item.containsKey(key)) {
        result.add(item[key] as Object);
      }
      _fnMapFindRecurse(XPathSequence(item.values.cast<Object>()), key, result);
    } else if (item is List<Object>) {
      _fnMapFindRecurse(XPathSequence(item), key, result);
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
const fnMapEntry = XPathFunctionDefinition(
  name: XmlName.qualified('map:entry'),
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
