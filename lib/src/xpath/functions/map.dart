import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-map-size
const fnMapSize = XPathFunctionItem.fn1(
  XmlName.qualified('map:size'),
  _fnMapSize,
);

XPathSequence _fnMapSize(XPathContext context, XPathSequence mapSeq) {
  final map = mapSeq.first as XPathMap;
  return XPathSequence.single(XPathInteger.fromInt(map.length));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-get
const fnMapGet = XPathFunctionItem.fn2(XmlName.qualified('map:get'), _fnMapGet);

XPathSequence _fnMapGet(
  XPathContext context,
  XPathSequence mapSeq,
  XPathSequence keySeq,
) {
  final map = mapSeq.first as XPathMap;
  final key = keySeq.atomize().first;
  return map.get(_normalizeKey(key)) ?? XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-put
const fnMapPut = XPathFunctionItem.fn3(XmlName.qualified('map:put'), _fnMapPut);

XPathSequence _fnMapPut(
  XPathContext context,
  XPathSequence mapSeq,
  XPathSequence keySeq,
  XPathSequence value,
) {
  final map = mapSeq.first as XPathMap;
  final key = keySeq.atomize().first;
  final entries = XPathMap.createEntries(map.entries);
  entries[_normalizeKey(key)] = value;
  return XPathSequence.single(XPathMap(entries));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-contains
const fnMapContains = XPathFunctionItem.fn2(
  XmlName.qualified('map:contains'),
  _fnMapContains,
);

XPathSequence _fnMapContains(
  XPathContext context,
  XPathSequence mapSeq,
  XPathSequence keySeq,
) {
  final map = mapSeq.first as XPathMap;
  final key = keySeq.atomize().first;
  final found = map.get(_normalizeKey(key)) != null;
  return XPathSequence.single(XPathBoolean.fromBool(found));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-remove
const fnMapRemove = XPathFunctionItem.fn2(
  XmlName.qualified('map:remove'),
  _fnMapRemove,
);

XPathSequence _fnMapRemove(
  XPathContext context,
  XPathSequence mapSeq,
  XPathSequence keys,
) {
  final map = mapSeq.first as XPathMap;
  final entries = XPathMap.createEntries(map.entries);
  for (final key in keys.atomize()) {
    entries.remove(_normalizeKey(key));
  }
  return XPathSequence.single(XPathMap(entries));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-keys
const fnMapKeys = XPathFunctionItem.fn1(
  XmlName.qualified('map:keys'),
  _fnMapKeys,
);

XPathSequence _fnMapKeys(XPathContext context, XPathSequence mapSeq) {
  final map = mapSeq.first as XPathMap;
  return XPathSequence(map.keys);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-merge
const fnMapMerge = XPathFunctionItem.overloaded(
  XmlName.qualified('map:merge'),
  {
    1: XPathFunctionItem.fn1(XmlName.qualified('map:merge'), _fnMapMerge1),
    2: XPathFunctionItem.fn2(XmlName.qualified('map:merge'), _fnMapMerge2),
  },
);

XPathSequence _fnMapMerge1(XPathContext context, XPathSequence maps) =>
    _evalMapMerge(maps, null);

XPathSequence _fnMapMerge2(
  XPathContext context,
  XPathSequence maps,
  XPathSequence optionsSeq,
) {
  final optionsItem = optionsSeq.firstOrNull;
  if (optionsSeq.length != 1 || optionsItem is! XPathMap) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'The second argument to map:merge must be a single map(*)',
    );
  }
  return _evalMapMerge(maps, optionsItem);
}

XPathSequence _evalMapMerge(XPathSequence maps, XPathMap? options) {
  var duplicates = 'use-first';
  if (options != null) {
    for (final entry in options.entries.entries) {
      final key = entry.key.stringValue;
      if (key == 'duplicates') {
        final valSeq = entry.value.atomize();
        final val = valSeq.firstOrNull?.stringValue;
        if (valSeq.length != 1 ||
            val == null ||
            (val != 'use-first' &&
                val != 'use-last' &&
                val != 'combine' &&
                val != 'reject' &&
                val != 'use-any')) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0005,
            'Invalid duplicates option: $val',
          );
        }
        duplicates = val;
      } else {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0005,
          'Unrecognized map:merge option: $key',
        );
      }
    }
  }

  final result = XPathMap.createEntries();
  for (final item in maps) {
    if (item is! XPathMap) {
      final val = item is XPathAtomic ? item.value : item;
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Unsupported cast from $val to map(*)',
      );
    }
    for (final entry in item.entries.entries) {
      final key = entry.key;
      final value = entry.value;
      if (result.containsKey(key)) {
        switch (duplicates) {
          case 'reject':
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0003,
              'Duplicate key: ${key.stringValue}',
            );
          case 'use-first':
          case 'use-any':
            break;
          case 'use-last':
            result[key] = value;
          case 'combine':
            final existing = result[key]!;
            result[key] = XPathSequence([...existing, ...value]);
        }
      } else {
        result[key] = value;
      }
    }
  }
  return XPathSequence.single(XPathMap(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-for-each
const fnMapForEach = XPathFunctionItem.fn2(
  XmlName.qualified('map:for-each'),
  _fnMapForEach,
);

XPathSequence _fnMapForEach(
  XPathContext context,
  XPathSequence mapSeq,
  XPathSequence actionSeq,
) {
  final map = mapSeq.first as XPathMap;
  final action = actionSeq.first as XPathFunctionItem;
  return XPathSequence(_fnMapForEachSync(context, map, action));
}

Iterable<XPathItem> _fnMapForEachSync(
  XPathContext context,
  XPathMap map,
  XPathFunctionItem action,
) sync* {
  for (final entry in map.entries.entries) {
    final res = action.call(context, [
      XPathSequence.single(entry.key),
      entry.value,
    ]);
    yield* res;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-find
const fnMapFind = XPathFunctionItem.fn2(
  XmlName.qualified('map:find'),
  _fnMapFind,
);

XPathSequence _fnMapFind(
  XPathContext context,
  XPathSequence input,
  XPathSequence keySeq,
) {
  final key = keySeq.atomize().first;
  final result = <XPathSequence>[];
  _fnMapFindRecurse(input, _normalizeKey(key), result);
  return XPathSequence.single(XPathArray(result));
}

void _fnMapFindRecurse(
  XPathSequence sequence,
  XPathAtomic key,
  List<XPathSequence> result,
) {
  for (final item in sequence) {
    if (item is XPathMap) {
      final val = item.get(key);
      if (val != null) {
        result.add(val);
      }
      for (final v in item.entries.values) {
        _fnMapFindRecurse(v, key, result);
      }
    } else if (item is XPathArray) {
      for (final member in item.members) {
        _fnMapFindRecurse(member, key, result);
      }
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-map-entry
const fnMapEntry = XPathFunctionItem.fn2(
  XmlName.qualified('map:entry'),
  _fnMapEntry,
);

XPathSequence _fnMapEntry(
  XPathContext context,
  XPathSequence keySeq,
  XPathSequence value,
) {
  final key = keySeq.atomize().first;
  return XPathSequence.single(XPathMap({_normalizeKey(key): value}));
}

XPathAtomic _normalizeKey(XPathAtomic key) =>
    key is XPathUntypedAtomic ? XPathString(key.value) : key;
