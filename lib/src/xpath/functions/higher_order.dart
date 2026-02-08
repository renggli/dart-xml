import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../operators/comparison.dart';
import '../types/any.dart';
import '../types/array.dart';
import '../types/boolean.dart';
import '../types/function.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
const fnForEach = XPathFunctionDefinition(
  name: 'fn:for-each',
  aliases: ['for-each'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnForEach,
);

XPathSequence _fnForEach(
  XPathContext context,
  XPathSequence seq,
  XPathFunction action,
) => XPathSequence(_fnForEachSync(context, seq, action));

Iterable<Object> _fnForEachSync(
  XPathContext context,
  XPathSequence seq,
  XPathFunction action,
) sync* {
  for (final item in seq) {
    yield* action(context, [XPathSequence.single(item)]);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
const fnFilter = XPathFunctionDefinition(
  name: 'fn:filter',
  aliases: ['filter'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'predicate', type: xsFunction),
  ],
  function: _fnFilter,
);

XPathSequence _fnFilter(
  XPathContext context,
  XPathSequence seq,
  XPathFunction predicate,
) => XPathSequence(_fnFilterSync(context, seq, predicate));

Iterable<Object> _fnFilterSync(
  XPathContext context,
  XPathSequence seq,
  XPathFunction predicate,
) sync* {
  for (final item in seq) {
    final result = xsBoolean.cast(
      predicate(context, [XPathSequence.single(item)]),
    );
    if (result) {
      yield item;
    }
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
const fnFoldLeft = XPathFunctionDefinition(
  name: 'fn:fold-left',
  aliases: ['fold-left'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'zero',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnFoldLeft,
);

XPathSequence _fnFoldLeft(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathFunction action,
) {
  var result = zero;
  for (final item in seq) {
    result = action(context, [result, XPathSequence.single(item)]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-right
const fnFoldRight = XPathFunctionDefinition(
  name: 'fn:fold-right',
  aliases: ['fold-right'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'zero',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnFoldRight,
);

XPathSequence _fnFoldRight(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathFunction action,
) {
  var result = zero;
  final list = seq.toList();
  for (var i = list.length - 1; i >= 0; i--) {
    result = action(context, [XPathSequence.single(list[i]), result]);
  }
  return result;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each-pair
const fnForEachPair = XPathFunctionDefinition(
  name: 'fn:for-each-pair',
  aliases: ['for-each-pair'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq1',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'seq2',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'action', type: xsFunction),
  ],
  function: _fnForEachPair,
);

XPathSequence _fnForEachPair(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  XPathFunction action,
) => XPathSequence(_fnForEachPairSync(context, seq1, seq2, action));

Iterable<Object> _fnForEachPairSync(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  XPathFunction action,
) sync* {
  final it1 = seq1.iterator;
  final it2 = seq2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    yield* action(context, [
      XPathSequence.single(it1.current),
      XPathSequence.single(it2.current),
    ]);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-apply
const fnApply = XPathFunctionDefinition(
  name: 'fn:apply',
  aliases: ['apply'],
  requiredArguments: [
    XPathArgumentDefinition(name: 'function', type: xsFunction),
    XPathArgumentDefinition(name: 'array', type: xsArray),
  ],
  function: _fnApply,
);

XPathSequence _fnApply(
  XPathContext context,
  XPathFunction function,
  XPathArray array,
) => function(context, array.map(xsSequence.cast).toList());

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
const fnFunctionName = XPathFunctionDefinition(
  name: 'fn:function-name',
  aliases: ['function-name'],
  requiredArguments: [XPathArgumentDefinition(name: 'func', type: xsFunction)],
  function: _fnFunctionName,
);

XPathSequence _fnFunctionName(XPathContext context, Function func) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
const fnFunctionArity = XPathFunctionDefinition(
  name: 'fn:function-arity',
  aliases: ['function-arity'],
  requiredArguments: [XPathArgumentDefinition(name: 'func', type: xsFunction)],
  function: _fnFunctionArity,
);

XPathSequence _fnFunctionArity(XPathContext context, Function func) =>
    const XPathSequence.single(0);

/// https://www.w3.org/TR/xpath-functions-31/#func-sort
const fnSort = XPathFunctionDefinition(
  name: 'fn:sort',
  aliases: ['sort'],
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'key', type: xsFunction),
  ],
  function: _fnSort,
);

XPathSequence _fnSort(
  XPathContext context,
  XPathSequence seq, [
  String? collation,
  XPathFunction? key,
]) {
  final list = seq.toList();
  list.sort((a, b) {
    final ka = key != null
        ? key(context, [XPathSequence.single(a)]).toAtomicValue()
        : a;
    final kb = key != null
        ? key(context, [XPathSequence.single(b)]).toAtomicValue()
        : b;
    return compare(ka, kb);
  });
  return XPathSequence(list);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
const fnFunctionLookup = XPathFunctionDefinition(
  name: 'fn:function-lookup',
  aliases: ['function-lookup'],
  requiredArguments: [
    XPathArgumentDefinition(name: 'name', type: xsString), // Technically QName
    XPathArgumentDefinition(name: 'arity', type: xsInteger),
  ],
  function: _fnFunctionLookup,
);

XPathSequence _fnFunctionLookup(XPathContext context, String name, num arity) {
  throw UnimplementedError('fn:function-lookup');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
const fnLoadXqueryModule = XPathFunctionDefinition(
  name: 'fn:load-xquery-module',
  aliases: ['load-xquery-module'],
  requiredArguments: [XPathArgumentDefinition(name: 'uri', type: xsString)],
  function: _fnLoadXqueryModule,
);

XPathSequence _fnLoadXqueryModule(XPathContext context, String uri) {
  throw UnimplementedError('fn:load-xquery-module');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
const fnTransform = XPathFunctionDefinition(
  name: 'fn:transform',
  aliases: ['transform'],
  requiredArguments: [XPathArgumentDefinition(name: 'options', type: xsAny)],
  function: _fnTransform,
);

XPathSequence _fnTransform(XPathContext context, Object options) {
  throw UnimplementedError('fn:transform');
}
