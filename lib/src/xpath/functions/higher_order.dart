import '../../xml/utils/name.dart';
import '../evaluation/cardinality.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/qname.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
const fnForEach = XPathFunctionItem.fn2(
  XmlName.qualified('fn:for-each'),
  _fnForEach,
);

XPathSequence _fnForEach(
  XPathContext context,
  XPathSequence seq,
  XPathSequence actionSeq,
) {
  final action = actionSeq.first as XPathFunctionItem;
  return XPathSequence(_fnForEachSync(context, seq, action));
}

Iterable<XPathItem> _fnForEachSync(
  XPathContext context,
  XPathSequence seq,
  XPathFunctionItem action,
) sync* {
  for (final item in seq) {
    yield* action.call(context, [XPathSequence.single(item)]);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
///
/// Signature: `fn:filter($seq as item()*, $f as function(item()) as xs:boolean)
/// as item()*`
const fnFilter = XPathFunctionItem.fn2(
  XmlName.qualified('fn:filter'),
  _fnFilter,
  parameterTypes: [
    XPathSequenceType(
      itemType: xsItem,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathFunctionType(
      parameterTypes: [
        XPathSequenceType(
          itemType: xsItem,
          cardinality: XPathCardinality.exactlyOne,
        ),
      ],
      returnType: XPathSequenceType(
        itemType: xsBoolean,
        cardinality: XPathCardinality.exactlyOne,
      ),
    ),
  ],
  returnType: XPathSequenceType(
    itemType: xsItem,
    cardinality: XPathCardinality.zeroOrMore,
  ),
);

XPathSequence _fnFilter(
  XPathContext context,
  XPathSequence seq,
  XPathSequence predicateSeq,
) {
  final predicate = predicateSeq.first as XPathFunctionItem;
  return XPathSequence(_fnFilterSync(context, seq, predicate));
}

Iterable<XPathItem> _fnFilterSync(
  XPathContext context,
  XPathSequence seq,
  XPathFunctionItem predicate,
) sync* {
  for (final item in seq) {
    final result = predicate.call(context, [XPathSequence.single(item)]);
    if (result.effectiveBooleanValue) yield item;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
const fnFoldLeft = XPathFunctionItem.fn3(
  XmlName.qualified('fn:fold-left'),
  _fnFoldLeft,
);

XPathSequence _fnFoldLeft(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathSequence actionSeq,
) {
  final action = actionSeq.first as XPathFunctionItem;
  var result = zero;
  for (final item in seq) {
    result = action.call(context, [result, XPathSequence.single(item)]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-right
const fnFoldRight = XPathFunctionItem.fn3(
  XmlName.qualified('fn:fold-right'),
  _fnFoldRight,
);

XPathSequence _fnFoldRight(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathSequence actionSeq,
) {
  final action = actionSeq.first as XPathFunctionItem;
  var result = zero;
  final list = seq.toList();
  for (var i = list.length - 1; i >= 0; i--) {
    result = action.call(context, [XPathSequence.single(list[i]), result]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each-pair
const fnForEachPair = XPathFunctionItem.fn3(
  XmlName.qualified('fn:for-each-pair'),
  _fnForEachPair,
);

XPathSequence _fnForEachPair(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  XPathSequence actionSeq,
) {
  final action = actionSeq.first as XPathFunctionItem;
  return XPathSequence(_fnForEachPairSync(context, seq1, seq2, action));
}

Iterable<XPathItem> _fnForEachPairSync(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  XPathFunctionItem action,
) sync* {
  final it1 = seq1.iterator;
  final it2 = seq2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    yield* action.call(context, [
      XPathSequence.single(it1.current),
      XPathSequence.single(it2.current),
    ]);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-apply
const fnApply = XPathFunctionItem.fn2(XmlName.qualified('fn:apply'), _fnApply);

XPathSequence _fnApply(
  XPathContext context,
  XPathSequence functionSeq,
  XPathSequence arraySeq,
) {
  final function = functionSeq.first as XPathFunctionItem;
  final array = arraySeq.first as XPathArray;
  return function.call(context, array.members);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
const fnFunctionName = XPathFunctionItem.fn1(
  XmlName.qualified('fn:function-name'),
  _fnFunctionName,
);

XPathSequence _fnFunctionName(XPathContext context, XPathSequence funcSeq) {
  final func = funcSeq.first as XPathFunctionItem;
  final name = func.name;
  return name != null && name.local.isNotEmpty
      ? XPathSequence.single(XPathQName(name))
      : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
const fnFunctionArity = XPathFunctionItem.fn1(
  XmlName.qualified('fn:function-arity'),
  _fnFunctionArity,
);

XPathSequence _fnFunctionArity(XPathContext context, XPathSequence funcSeq) {
  final func = funcSeq.first as XPathFunctionItem;
  return XPathSequence.single(XPathInteger.fromInt(func.arity));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sort
const fnSort = XPathFunctionItem.overloaded(XmlName.qualified('fn:sort'), {
  1: XPathFunctionItem.fn1(XmlName.qualified('fn:sort'), _fnSort1),
  2: XPathFunctionItem.fn2(XmlName.qualified('fn:sort'), _fnSort2),
  3: XPathFunctionItem.fn3(XmlName.qualified('fn:sort'), _fnSort3),
});

XPathSequence _fnSort1(XPathContext context, XPathSequence seq) =>
    _evalSort(context, seq, null, null);

XPathSequence _fnSort2(
  XPathContext context,
  XPathSequence seq,
  XPathSequence collationSeq,
) => _evalSort(context, seq, collationSeq.firstOrNull as XPathString?, null);

XPathSequence _fnSort3(
  XPathContext context,
  XPathSequence seq,
  XPathSequence collationSeq,
  XPathSequence keySeq,
) => _evalSort(
  context,
  seq,
  collationSeq.firstOrNull as XPathString?,
  keySeq.firstOrNull as XPathFunctionItem?,
);

XPathSequence _evalSort(
  XPathContext context,
  XPathSequence seq,
  XPathString? collation,
  XPathFunctionItem? key,
) {
  final list = seq.toList();
  list.sort((a, b) {
    final ka = key != null
        ? _evalSortKey(context, key, a)
        : XPathSequence.single(a);
    final kb = key != null
        ? _evalSortKey(context, key, b)
        : XPathSequence.single(b);
    final atomA = ka.atomize().firstOrNull;
    final atomB = kb.atomize().firstOrNull;
    if (atomA == null && atomB == null) return 0;
    if (atomA == null) return -1;
    if (atomB == null) return 1;
    return atomA.compareTo(atomB);
  });
  return XPathSequence(list);
}

XPathSequence _evalSortKey(
  XPathContext context,
  XPathFunctionItem key,
  XPathItem item,
) => key.call(context, [XPathSequence.single(item)]);

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
const fnFunctionLookup = XPathFunctionItem.fn2(
  XmlName.qualified('fn:function-lookup'),
  _fnFunctionLookup,
);

XPathSequence _fnFunctionLookup(
  XPathContext context,
  XPathSequence qnameSeq,
  XPathSequence aritySeq,
) {
  final qname = qnameSeq.first as XPathQName;
  final arity = aritySeq.first as XPathInteger;
  try {
    final function = context.configuration.getFunctionByString(
      qname.value.extendedQualified,
      arity.asInt,
    );
    return XPathSequence.single(function);
  } on XPathEvaluationException {
    return XPathSequence.empty;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
const fnLoadXqueryModule = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:load-xquery-module'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:load-xquery-module'),
      _fnLoadXqueryModule1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:load-xquery-module'),
      _fnLoadXqueryModule2,
    ),
  },
);

XPathSequence _fnLoadXqueryModule1(XPathContext context, XPathSequence uri) {
  throw UnimplementedError('fn:load-xquery-module');
}

XPathSequence _fnLoadXqueryModule2(
  XPathContext context,
  XPathSequence uri,
  XPathSequence options,
) {
  throw UnimplementedError('fn:load-xquery-module');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
const fnTransform = XPathFunctionItem.fn1(
  XmlName.qualified('fn:transform'),
  _fnTransform,
);

XPathSequence _fnTransform(XPathContext context, XPathSequence options) {
  throw UnimplementedError('fn:transform');
}
