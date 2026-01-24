import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/array.dart';
import '../types/boolean.dart';
import '../types/function.dart';
import '../types/item.dart';
import '../types/map.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
const fnForEach = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'for-each',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'action', type: XPathFunction),
  ],
  function: _fnForEach,
);

XPathSequence _fnForEach(
  XPathContext context,
  XPathSequence seq,
  XPathFunction action,
) {
  final result = <Object>[];
  for (final item in seq) {
    result.addAll(action(context, [XPathSequence.single(item)]));
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
const fnFilter = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'filter',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _fnFilter,
);

XPathSequence _fnFilter(
  XPathContext context,
  XPathSequence seq,
  XPathFunction function,
) {
  final result = <Object>[];
  for (final item in seq) {
    if (function(context, [XPathSequence.single(item)]).toXPathBoolean()) {
      result.add(item);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
const fnFoldLeft = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'fold-left',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'zero',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _fnFoldLeft,
);

XPathSequence _fnFoldLeft(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathFunction function,
) {
  var result = zero;
  for (final item in seq) {
    result = function(context, [result, XPathSequence.single(item)]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-right
const fnFoldRight = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'fold-right',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'zero',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _fnFoldRight,
);

XPathSequence _fnFoldRight(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathFunction function,
) {
  var result = zero;
  final items = seq.toList().reversed;
  for (final item in items) {
    result = function(context, [XPathSequence.single(item), result]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each-pair
const fnForEachPair = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'for-each-pair',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq1',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'seq2',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'action', type: XPathFunction),
  ],
  function: _fnForEachPair,
);

XPathSequence _fnForEachPair(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  XPathFunction action,
) {
  final iter1 = seq1.iterator;
  final iter2 = seq2.iterator;
  final result = <Object>[];
  while (iter1.moveNext() && iter2.moveNext()) {
    result.addAll(
      action(context, [
        XPathSequence.single(iter1.current),
        XPathSequence.single(iter2.current),
      ]),
    );
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sort
const fnSort = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'sort',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'key',
      type: XPathFunction,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSort,
);

XPathSequence _fnSort(
  XPathContext context,
  XPathSequence input, [
  XPathString? collation,
  XPathFunction? key,
]) {
  // ignore: unused_local_variable
  final coll = collation; // ignored for now
  final keyFunc = key;

  final list = input.toList();
  list.sort((a, b) {
    if (keyFunc != null) {
      final keyA = keyFunc(context, [XPathSequence.single(a)]).toAtomicValue();
      final keyB = keyFunc(context, [XPathSequence.single(b)]).toAtomicValue();
      if (keyA is Comparable && keyB is Comparable) {
        try {
          return keyA.compareTo(keyB);
        } catch (_) {}
      }
      return keyA.toString().compareTo(keyB.toString());
    }
    if (a is Comparable && b is Comparable) {
      try {
        return a.compareTo(b);
      } catch (_) {}
    }
    return a.toString().compareTo(b.toString());
  });
  return XPathSequence(list);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-apply
const fnApply = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'apply',
  requiredArguments: [
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
    XPathArgumentDefinition(name: 'array', type: XPathArray),
  ],
  function: _fnApply,
);

XPathSequence _fnApply(
  XPathContext context,
  XPathFunction function,
  XPathArray array,
) => function(context, array.map((e) => e.toXPathSequence()).toList());

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
const fnFunctionLookup = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'function-lookup',
  requiredArguments: [
    XPathArgumentDefinition(name: 'name', type: XPathSequence), // xs:QName
    XPathArgumentDefinition(name: 'arity', type: XPathSequence), // xs:integer
  ],
  function: _fnFunctionLookup,
);

XPathSequence _fnFunctionLookup(
  XPathContext context, [
  XPathSequence? name,
  XPathSequence? arity,
]) {
  throw UnimplementedError('fn:function-lookup');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
const fnFunctionName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'function-name',
  requiredArguments: [
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _fnFunctionName,
);

XPathSequence _fnFunctionName(XPathContext context, [XPathFunction? function]) {
  throw UnimplementedError('fn:function-name');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
const fnFunctionArity = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'function-arity',
  requiredArguments: [
    XPathArgumentDefinition(name: 'function', type: XPathFunction),
  ],
  function: _fnFunctionArity,
);

XPathSequence _fnFunctionArity(
  XPathContext context, [
  XPathFunction? function,
]) {
  throw UnimplementedError('fn:function-arity');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
const fnLoadXqueryModule = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'load-xquery-module',
  requiredArguments: [
    XPathArgumentDefinition(name: 'module-uri', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'options',
      type: XPathMap,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnLoadXqueryModule,
);

XPathSequence _fnLoadXqueryModule(
  XPathContext context, [
  XPathString? moduleUri,
  XPathMap? options,
]) {
  throw UnimplementedError('fn:load-xquery-module');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
const fnTransform = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'transform',
  requiredArguments: [XPathArgumentDefinition(name: 'options', type: XPathMap)],
  function: _fnTransform,
);

XPathSequence _fnTransform(XPathContext context, [XPathMap? options]) {
  throw UnimplementedError('fn:transform');
}
