import '../evaluation/context.dart';
import '../evaluation/types.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
const fnForEach = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'for-each',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnForEach,
);

XPathSequence _fnForEach(
  XPathContext context,
  XPathSequence seq,
  Function action,
) => XPathSequence(_fnForEachSync(context, seq, action));

Iterable<Object> _fnForEachSync(
  XPathContext context,
  XPathSequence seq,
  Function action,
) sync* {
  for (final item in seq) {
    final value = action(context, [XPathSequence.single(item)]) as Object?;
    if (value is XPathSequence) {
      yield* value;
    } else if (value != null) {
      yield value;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
const fnFilter = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'filter',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'predicate', type: xsFunction),
  ],
  function: _fnFilter,
);

XPathSequence _fnFilter(
  XPathContext context,
  XPathSequence seq,
  Function predicate,
) => XPathSequence(_fnFilterSync(context, seq, predicate));

Iterable<Object> _fnFilterSync(
  XPathContext context,
  XPathSequence seq,
  Function predicate,
) sync* {
  for (final item in seq) {
    final result =
        (predicate(context, [XPathSequence.single(item)]) as XPathSequence)
            .toXPathBoolean();
    if (result) {
      yield item;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
const fnFoldLeft = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'fold-left',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'zero', type: xsAny),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnFoldLeft,
);

XPathSequence _fnFoldLeft(
  XPathContext context,
  XPathSequence seq,
  Object zero,
  Function action,
) {
  var result = zero.toXPathSequence();
  for (final item in seq) {
    result =
        action(context, [result, XPathSequence.single(item)]) as XPathSequence;
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
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'zero', type: xsAny),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnFoldRight,
);

XPathSequence _fnFoldRight(
  XPathContext context,
  XPathSequence seq,
  Object zero,
  Function action,
) {
  final list = seq.toList();
  var result = zero.toXPathSequence();
  for (var i = list.length - 1; i >= 0; i--) {
    result =
        (action(context, [XPathSequence.single(list[i]), result])
            as XPathSequence);
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
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(
      name: 'seq2',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnForEachPair,
);

XPathSequence _fnForEachPair(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  Function action,
) => XPathSequence(_fnForEachPairSync(context, seq1, seq2, action));

Iterable<Object> _fnForEachPairSync(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  Function action,
) sync* {
  final it1 = seq1.iterator;
  final it2 = seq2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    final result =
        action(context, [
              XPathSequence.single(it1.current),
              XPathSequence.single(it2.current),
            ])
            as Object?;
    if (result is XPathSequence) {
      yield* result;
    } else if (result != null) {
      yield result;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-apply
const fnApply = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'apply',
  requiredArguments: [
    XPathArgumentDefinition(name: 'function', type: xsFunction),
    XPathArgumentDefinition(
      name: 'array',
      type: XPathSequenceType(
        xsAny, // item() technically, but we use it as an array
        cardinality: XPathArgumentCardinality.exactlyOne,
      ),
    ),
  ],
  function: _fnApply,
);

XPathSequence _fnApply(XPathContext context, Function function, Object array) {
  final args = array.toXPathArray();
  return Function.apply(function, [
        context,
        ...args.map((e) => e.toXPathSequence()),
      ])
      as XPathSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
const fnFunctionName = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'function-name',
  requiredArguments: [XPathArgumentDefinition(name: 'func', type: xsFunction)],
  function: _fnFunctionName,
);

XPathSequence _fnFunctionName(XPathContext context, Function func) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
const fnFunctionArity = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'function-arity',
  requiredArguments: [XPathArgumentDefinition(name: 'func', type: xsFunction)],
  function: _fnFunctionArity,
);

XPathSequence _fnFunctionArity(XPathContext context, Function func) =>
    const XPathSequence.single(0);

/// https://www.w3.org/TR/xpath-functions-31/#func-sort
const fnSort = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'sort',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
    XPathArgumentDefinition(name: 'key', type: xsFunction),
  ],
  function: _fnSort,
);

XPathSequence _fnSort(
  XPathContext context,
  XPathSequence seq, [
  String? collation,
  Function? key,
]) {
  final list = seq.toList();
  list.sort((a, b) {
    final ka = key != null
        ? (key(context, [XPathSequence.single(a)]) as Object)
        : a;
    final kb = key != null
        ? (key(context, [XPathSequence.single(b)]) as Object)
        : b;
    return ka.toString().compareTo(kb.toString());
  });
  return XPathSequence(list);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
const fnFunctionLookup = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'function-lookup',
  requiredArguments: [
    XPathArgumentDefinition(name: 'name', type: xsString), // Technically QName
    XPathArgumentDefinition(name: 'arity', type: xsNumeric),
  ],
  function: _fnFunctionLookup,
);

XPathSequence _fnFunctionLookup(XPathContext context, String name, num arity) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
const fnLoadXqueryModule = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'load-xquery-module',
  requiredArguments: [XPathArgumentDefinition(name: 'uri', type: xsString)],
  function: _fnLoadXqueryModule,
);

XPathSequence _fnLoadXqueryModule(XPathContext context, String uri) {
  throw UnimplementedError('fn:load-xquery-module');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
const fnTransform = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'transform',
  requiredArguments: [XPathArgumentDefinition(name: 'options', type: xsAny)],
  function: _fnTransform,
);

XPathSequence _fnTransform(XPathContext context, Object options) {
  throw UnimplementedError('fn:transform');
}
