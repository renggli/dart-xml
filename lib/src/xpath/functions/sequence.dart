import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/cdata.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/declaration.dart';
import '../../xml/nodes/doctype.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/duration.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
final fnEmpty = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:empty'),
  (context, arg) => XPathSequence.single(XPathBoolean.fromBool(arg.isEmpty)),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
final fnExists = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:exists'),
  (context, arg) => XPathSequence.single(XPathBoolean.fromBool(arg.isNotEmpty)),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-head
final fnHead = XPathFunctionItem.fn1(const XmlName.qualified('fn:head'), (
  context,
  arg,
) {
  if (arg.isEmpty) return XPathSequence.empty;
  return XPathSequence.single(arg.first);
});

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
final fnTail = XPathFunctionItem.fn1(const XmlName.qualified('fn:tail'), (
  context,
  arg,
) {
  if (arg.isEmpty) return XPathSequence.empty;
  return XPathSequence(arg.skip(1));
});

/// https://www.w3.org/TR/xpath-functions-31/#func-insert-before
final fnInsertBefore = XPathFunctionItem.fn3(
  const XmlName.qualified('fn:insert-before'),
  (context, target, position, inserts) {
    final posItem = position.atomize().firstOrNull as XPathInteger?;
    final pos = posItem?.asInt ?? 1;
    return XPathSequence(_fnInsertBeforeSync(target, pos, inserts));
  },
);

Iterable<XPathItem> _fnInsertBeforeSync(
  XPathSequence target,
  int position,
  XPathSequence inserts,
) sync* {
  var index = 1;
  if (position <= 0) {
    yield* inserts;
    yield* target;
    return;
  }
  var inserted = false;
  for (final item in target) {
    if (index == position) {
      yield* inserts;
      inserted = true;
    }
    yield item;
    index++;
  }
  if (!inserted) {
    yield* inserts;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-remove
final fnRemove = XPathFunctionItem.fn2(const XmlName.qualified('fn:remove'), (
  context,
  target,
  position,
) {
  final posItem = position.atomize().firstOrNull as XPathInteger?;
  final pos = posItem?.asInt ?? 1;
  return XPathSequence(_fnRemoveSync(target, pos));
});

Iterable<XPathItem> _fnRemoveSync(XPathSequence target, int position) sync* {
  var index = 1;
  for (final item in target) {
    if (index != position) {
      yield item;
    }
    index++;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-reverse
final fnReverse = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:reverse'),
  (context, arg) => XPathSequence(arg.toList().reversed),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-format-integer
final fnFormatInteger = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-integer'),
  {
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:format-integer'), (
      context,
      value,
      picture,
    ) {
      final val = value.atomize().firstOrNull as XPathInteger?;
      if (val == null) return XPathSequence.empty;
      return XPathSequence.single(XPathString(val.stringValue));
    }),
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:format-integer'), (
      context,
      value,
      picture,
      language,
    ) {
      final val = value.atomize().firstOrNull as XPathInteger?;
      if (val == null) return XPathSequence.empty;
      return XPathSequence.single(XPathString(val.stringValue));
    }),
  },
);

XPathNumeric? _coerceNumeric(XPathSequence seq) {
  final item = seq.atomize().firstOrNull;
  if (item == null) return null;
  if (item is XPathNumeric) return item;
  if (item is XPathUntypedAtomic) {
    final d = XPathDouble.tryParse(item.stringValue);
    if (d != null) return d;
    throw XPathEvaluationException(
      XPathErrorCode.FORG0001,
      'Cannot convert untypedAtomic "${item.stringValue}" to xs:double',
    );
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Expected numeric value, got ${item.type}',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-format-number
final fnFormatNumber = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:format-number'),
  {
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:format-number'), (
      context,
      value,
      picture,
    ) {
      final val = _coerceNumeric(value);
      if (val == null) return XPathSequence.empty;
      return XPathSequence.single(XPathString(val.stringValue));
    }),
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:format-number'), (
      context,
      value,
      picture,
      decimalFormatName,
    ) {
      final val = _coerceNumeric(value);
      if (val == null) return XPathSequence.empty;
      return XPathSequence.single(XPathString(val.stringValue));
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-subsequence
final fnSubsequence = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:subsequence'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:subsequence'),
      (context, sourceSeq, startingLoc) =>
          _evalSubsequence(sourceSeq, _coerceNumeric(startingLoc), null),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:subsequence'),
      (context, sourceSeq, startingLoc, length) => _evalSubsequence(
        sourceSeq,
        _coerceNumeric(startingLoc),
        _coerceNumeric(length),
      ),
    ),
  },
);

XPathSequence _evalSubsequence(
  XPathSequence sourceSeq,
  XPathNumeric? startingLoc,
  XPathNumeric? length,
) {
  if (startingLoc == null) return XPathSequence.empty;
  final sVal = startingLoc.toDouble();
  final lVal = length?.toDouble();
  if (sVal.isNaN || (lVal != null && lVal.isNaN)) {
    return XPathSequence.empty;
  }

  final startRound = sVal.isInfinite ? sVal : sVal.roundToDouble();
  final lengthRound = lVal == null
      ? null
      : (lVal.isInfinite ? lVal : lVal.roundToDouble());
  final endRound = lengthRound != null
      ? startRound + lengthRound
      : double.infinity;

  if (endRound.isNaN ||
      endRound <= 1.0 ||
      (startRound.isInfinite && startRound > 0)) {
    return XPathSequence.empty;
  }

  var skipCount = 0;
  if (startRound > 1.0) {
    if (startRound > 9007199254740992.0) {
      return XPathSequence.empty;
    }
    skipCount = (startRound - 1.0).toInt();
  }

  int? takeCount;
  if (endRound != double.infinity) {
    if (endRound > 9007199254740992.0) {
      takeCount = null;
    } else {
      final take = (endRound - 1.0).toInt() - skipCount;
      if (take <= 0) return XPathSequence.empty;
      takeCount = take;
    }
  }

  Iterable<XPathItem> iter = sourceSeq;
  if (skipCount > 0) {
    iter = iter.skip(skipCount);
  }
  if (takeCount != null) {
    iter = iter.take(takeCount);
  }

  return XPathSequence(iter);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unordered
final fnUnordered = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:unordered'),
  (context, sourceSeq) => sourceSeq,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
final fnDistinctValues = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:distinct-values'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:distinct-values'),
      (context, arg) => _evalDistinctValues(arg),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:distinct-values'),
      (context, arg, collation) => _evalDistinctValues(arg),
    ),
  },
);

XPathSequence _evalDistinctValues(XPathSequence arg) {
  final set = <XPathAtomic>{};
  final result = <XPathAtomic>[];
  for (final atom in arg.atomize()) {
    if (set.add(atom)) {
      result.add(atom);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-index-of
final fnIndexOf = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:index-of'),
  {
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:index-of'), (
      context,
      seq,
      searchSeq,
    ) {
      final search = searchSeq.atomize().firstOrNull;
      if (search == null) return XPathSequence.empty;
      return _evalIndexOf(seq, search);
    }),
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:index-of'), (
      context,
      seq,
      searchSeq,
      collation,
    ) {
      final search = searchSeq.atomize().firstOrNull;
      if (search == null) return XPathSequence.empty;
      return _evalIndexOf(seq, search);
    }),
  },
);

XPathSequence _evalIndexOf(XPathSequence seq, XPathAtomic search) =>
    XPathSequence(_evalIndexOfSync(seq, search));

Iterable<XPathInteger> _evalIndexOfSync(
  XPathSequence seq,
  XPathAtomic search,
) sync* {
  var index = 1;
  for (final item in seq.atomize()) {
    if (item == search) {
      yield XPathInteger.fromInt(index);
    }
    index++;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-deep-equal
final fnDeepEqual = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:deep-equal'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:deep-equal'),
      (context, p1, p2) => _evalDeepEqual(p1, p2),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:deep-equal'),
      (context, p1, p2, collation) => _evalDeepEqual(p1, p2),
    ),
  },
);

bool _deepEqual(Object? a, Object? b) {
  if (a is XPathFunctionItem || b is XPathFunctionItem) {
    if (a is XPathMap && b is XPathMap) {
      if (a.length != b.length) return false;
      for (final keyA in a.keys) {
        final valA = a.get(keyA);
        final valB = b.get(keyA);
        if (valB == null || !_deepEqual(valA, valB)) return false;
      }
      return true;
    }
    if (a is XPathArray && b is XPathArray) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_deepEqual(a[i], b[i])) return false;
      }
      return true;
    }
    throw XPathEvaluationException(
      XPathErrorCode.FOTY0015,
      'Cannot compare function items with deep-equal',
    );
  }
  if (identical(a, b)) return true;
  if (a == null || b == null) return false;

  // Handle sequences
  if (a is XPathSequence && b is XPathSequence) {
    if (a.length != b.length) return false;
    final it1 = a.iterator;
    final it2 = b.iterator;
    while (it1.moveNext() && it2.moveNext()) {
      if (!_deepEqual(it1.current, it2.current)) return false;
    }
    return true;
  }

  // Handle XPathNode
  if (a is XPathNode && b is XPathNode) {
    final na = a.node;
    final nb = b.node;
    if (na.nodeType != nb.nodeType) return false;
    if (na is XmlDocument && nb is XmlDocument) {
      final childrenA = _deepEqualChildren(na);
      final childrenB = _deepEqualChildren(nb);
      if (childrenA.length != childrenB.length) return false;
      for (var i = 0; i < childrenA.length; i++) {
        if (!_deepEqual(XPathNode(childrenA[i]), XPathNode(childrenB[i]))) {
          return false;
        }
      }
      return true;
    }
    if (na is XmlElement && nb is XmlElement) {
      final uriA = na.name.namespaceUri ?? '';
      final uriB = nb.name.namespaceUri ?? '';
      if (na.name.local != nb.name.local || uriA != uriB) return false;
      final attrsA = na.attributes
          .where((a) => !a.isNamespaceDeclaration)
          .toList();
      final attrsB = nb.attributes
          .where((a) => !a.isNamespaceDeclaration)
          .toList();
      if (attrsA.length != attrsB.length) return false;
      for (final attrA in attrsA) {
        final aUri = attrA.name.namespaceUri ?? '';
        XmlAttribute? attrB;
        for (final cand in attrsB) {
          final candUri = cand.name.namespaceUri ?? '';
          if (cand.name.local == attrA.name.local && candUri == aUri) {
            attrB = cand;
            break;
          }
        }
        if (attrB == null || attrB.value != attrA.value) return false;
      }
      final childrenA = _deepEqualChildren(na);
      final childrenB = _deepEqualChildren(nb);
      if (childrenA.length != childrenB.length) return false;
      for (var i = 0; i < childrenA.length; i++) {
        if (!_deepEqual(XPathNode(childrenA[i]), XPathNode(childrenB[i]))) {
          return false;
        }
      }
      return true;
    }
    if (na is XmlAttribute && nb is XmlAttribute) {
      final uriA = na.name.namespaceUri ?? '';
      final uriB = nb.name.namespaceUri ?? '';
      if (na.name.local != nb.name.local || uriA != uriB) return false;
      return na.value == nb.value;
    }
    if (na is XmlProcessing && nb is XmlProcessing) {
      return na.target == nb.target && na.value == nb.value;
    }
    return na.value == nb.value;
  }

  if (a is XPathAtomic && b is XPathAtomic) {
    if (a is XPathDouble && b is XPathDouble) {
      if (a.value.isNaN && b.value.isNaN) return true;
    }
    return a == b;
  }

  return false;
}

XPathSequence _evalDeepEqual(
  XPathSequence parameter1,
  XPathSequence parameter2,
) {
  try {
    return _deepEqual(parameter1, parameter2)
        ? XPathSequence.trueSequence
        : XPathSequence.falseSequence;
  } on XPathEvaluationException {
    rethrow;
  } catch (_) {
    return XPathSequence.falseSequence;
  }
}

List<XmlNode> _deepEqualChildren(XmlNode parent) {
  final result = <XmlNode>[];
  var currentText = '';
  for (final child in parent.children) {
    if (child is XmlComment ||
        child is XmlProcessing ||
        child is XmlDeclaration ||
        child is XmlDoctype) {
      continue;
    } else if (child is XmlText || child is XmlCDATA) {
      currentText += child.value ?? '';
    } else {
      if (currentText.isNotEmpty) {
        result.add(XmlText(currentText));
        currentText = '';
      }
      result.add(child);
    }
  }
  if (currentText.isNotEmpty) {
    result.add(XmlText(currentText));
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-zero-or-one
final fnZeroOrOne = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:zero-or-one'),
  (context, arg) {
    if (arg.length > 1) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0003,
        'Sequence has more than one item',
      );
    }
    return arg;
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-one-or-more
final fnOneOrMore = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:one-or-more'),
  (context, arg) {
    if (arg.isEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0004,
        'Sequence is empty',
      );
    }
    return arg;
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-exactly-one
final fnExactlyOne = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:exactly-one'),
  (context, arg) {
    if (arg.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0005,
        'Sequence does not have exactly one item',
      );
    }
    return arg;
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-count
final fnCount = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:count'),
  (context, arg) => XPathSequence.single(XPathInteger.fromInt(arg.length)),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
final fnAvg = XPathFunctionItem.fn1(const XmlName.qualified('fn:avg'), (
  context,
  arg,
) {
  final items = arg.atomize().map((a) {
    if (a is XPathUntypedAtomic) {
      final d = double.tryParse(a.value);
      if (d != null) return XPathDouble(d);
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Cannot cast untypedAtomic "${a.value}" to double',
      );
    }
    return a;
  }).toList();
  if (items.isEmpty) return XPathSequence.empty;

  final allNumeric = items.every((e) => e is XPathNumeric);
  final allDuration = items.every((e) => e is XPathDuration);

  if (!allNumeric && !allDuration) {
    throw XPathEvaluationException(
      XPathErrorCode.FORG0006,
      'fn:avg: mixed or unsupported argument types',
    );
  }

  final count = items.length;
  if (allNumeric) {
    var sum = items.first as XPathNumeric;
    for (var i = 1; i < items.length; i++) {
      sum = sum + (items[i] as XPathNumeric);
    }
    return XPathSequence.single(sum / XPathInteger.fromInt(count));
  } else {
    final allYearMonth = items.every(
      (e) => e is XPathDuration && e.isYearMonth,
    );
    final allDayTime = items.every((e) => e is XPathDuration && e.isDayTime);

    if (!allYearMonth && !allDayTime) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0006,
        'fn:avg: mixed or unsupported duration types',
      );
    }

    int roundHalfToEven(double val) {
      final floor = val.floor();
      final diff = val - floor;
      if (diff == 0.5) return floor.isEven ? floor : floor + 1;
      return val.round();
    }

    if (allYearMonth) {
      var sumMonths = 0;
      for (final item in items) {
        sumMonths += (item as XPathDuration).totalMonths;
      }
      final avgMonths = roundHalfToEven(sumMonths / count);
      return XPathSequence.single(XPathDuration.yearMonth(avgMonths));
    } else {
      var sumMicroseconds = 0;
      for (final item in items) {
        sumMicroseconds += (item as XPathDuration).inMicroseconds;
      }
      final avgMicroseconds = roundHalfToEven(sumMicroseconds / count);
      return XPathSequence.single(XPathDuration.dayTime(avgMicroseconds));
    }
  }
});

/// https://www.w3.org/TR/xpath-functions-31/#func-max
final fnMax = XPathFunctionItem.overloaded(const XmlName.qualified('fn:max'), {
  1: XPathFunctionItem.fn1(
    const XmlName.qualified('fn:max'),
    (context, arg) => _evalMax(arg),
  ),
  2: XPathFunctionItem.fn2(
    const XmlName.qualified('fn:max'),
    (context, arg, collation) => _evalMax(arg),
  ),
});

List<XPathAtomic> _prepareMinMax(XPathSequence arg) {
  final rawItems = arg.atomize().toList();
  if (rawItems.isEmpty) return const [];
  var hasNumeric = false;
  var hasString = false;
  final items = <XPathAtomic>[];
  for (final raw in rawItems) {
    var val = raw;
    if (val is XPathUntypedAtomic) {
      final d = double.tryParse(val.value);
      if (d != null) {
        val = XPathDouble(d);
      } else {
        throw XPathEvaluationException(
          XPathErrorCode.FORG0001,
          'Cannot cast untypedAtomic to double in min/max',
        );
      }
    }
    if (val is XPathNumeric) {
      hasNumeric = true;
    } else if (val is XPathString) {
      hasString = true;
    }
    items.add(val);
  }
  if (hasNumeric && hasString) {
    throw XPathEvaluationException(
      XPathErrorCode.FORG0006,
      'fn:min/fn:max cannot compare numeric and string values',
    );
  }
  return items;
}

XPathSequence _evalMax(XPathSequence arg) {
  final items = _prepareMinMax(arg);
  if (items.isEmpty) return XPathSequence.empty;
  for (final item in items) {
    if (item is XPathDouble && item.value.isNaN) {
      return const XPathSequence.single(XPathDouble.nan);
    }
  }
  var max = items.first;
  for (var i = 1; i < items.length; i++) {
    final item = items[i];
    if (item.compareTo(max) > 0) {
      max = item;
    }
  }
  return XPathSequence.single(max);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
final fnMin = XPathFunctionItem.overloaded(const XmlName.qualified('fn:min'), {
  1: XPathFunctionItem.fn1(
    const XmlName.qualified('fn:min'),
    (context, arg) => _evalMin(arg),
  ),
  2: XPathFunctionItem.fn2(
    const XmlName.qualified('fn:min'),
    (context, arg, collation) => _evalMin(arg),
  ),
});

XPathSequence _evalMin(XPathSequence arg) {
  final items = _prepareMinMax(arg);
  if (items.isEmpty) return XPathSequence.empty;
  for (final item in items) {
    if (item is XPathDouble && item.value.isNaN) {
      return const XPathSequence.single(XPathDouble.nan);
    }
  }
  var min = items.first;
  for (var i = 1; i < items.length; i++) {
    final item = items[i];
    if (item.compareTo(min) < 0) {
      min = item;
    }
  }
  return XPathSequence.single(min);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
final fnSum = XPathFunctionItem.overloaded(const XmlName.qualified('fn:sum'), {
  1: XPathFunctionItem.fn1(
    const XmlName.qualified('fn:sum'),
    (context, arg) => _evalSum(arg, null),
  ),
  2: XPathFunctionItem.fn2(
    const XmlName.qualified('fn:sum'),
    (context, arg, zero) => _evalSum(arg, zero),
  ),
});

XPathSequence _evalSum(XPathSequence arg, XPathSequence? zero) {
  final items = arg.atomize().map((a) {
    if (a is XPathUntypedAtomic) {
      final d = double.tryParse(a.value);
      if (d != null) return XPathDouble(d);
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Cannot cast untypedAtomic "${a.value}" to double',
      );
    }
    return a;
  }).toList();

  if (items.isEmpty) {
    return zero ?? XPathSequence.single(XPathInteger.fromInt(0));
  }

  final allNumeric = items.every((e) => e is XPathNumeric);
  final allDuration = items.every((e) => e is XPathDuration);

  if (!allNumeric && !allDuration) {
    throw XPathEvaluationException(
      XPathErrorCode.FORG0006,
      'fn:sum: mixed or unsupported argument types',
    );
  }

  if (allNumeric) {
    var sum = items.first as XPathNumeric;
    for (var i = 1; i < items.length; i++) {
      sum = sum + (items[i] as XPathNumeric);
    }
    return XPathSequence.single(sum);
  } else {
    final allYearMonth = items.every(
      (e) => e is XPathDuration && e.isYearMonth,
    );
    final allDayTime = items.every((e) => e is XPathDuration && e.isDayTime);

    if (!allYearMonth && !allDayTime) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0006,
        'fn:sum: mixed or unsupported duration types',
      );
    }

    if (allYearMonth) {
      var sumMonths = 0;
      for (final item in items) {
        sumMonths += (item as XPathDuration).totalMonths;
      }
      return XPathSequence.single(XPathDuration.yearMonth(sumMonths));
    } else {
      var sumMicroseconds = 0;
      for (final item in items) {
        sumMicroseconds += (item as XPathDuration).inMicroseconds;
      }
      return XPathSequence.single(XPathDuration.dayTime(sumMicroseconds));
    }
  }
}
