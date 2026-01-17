import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/array.dart';
import '../types/boolean.dart';
import '../types/function.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
XPathSequence fnForEach(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:for-each', arguments, 2);
  final seq = arguments[0];
  final action = XPathEvaluationException.extractExactlyOne(
    'fn:for-each',
    'action',
    arguments[1],
  ).toXPathFunction();
  final result = <Object>[];
  for (final item in seq) {
    result.addAll(action(context, [XPathSequence.single(item)]));
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
XPathSequence fnFilter(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:filter', arguments, 2);
  final seq = arguments[0];
  final function = XPathEvaluationException.extractExactlyOne(
    'fn:filter',
    'function',
    arguments[1],
  ).toXPathFunction();
  final result = <Object>[];
  for (final item in seq) {
    if (function(context, [XPathSequence.single(item)]).toXPathBoolean()) {
      result.add(item);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
XPathSequence fnFoldLeft(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:fold-left', arguments, 3);
  final seq = arguments[0];
  var zero = arguments[1];
  final function = XPathEvaluationException.extractExactlyOne(
    'fn:fold-left',
    'function',
    arguments[2],
  ).toXPathFunction();
  for (final item in seq) {
    zero = function(context, [zero, XPathSequence.single(item)]);
  }
  return zero;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-right
XPathSequence fnFoldRight(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:fold-right', arguments, 3);
  final seq = arguments[0];
  var zero = arguments[1];
  final function = XPathEvaluationException.extractExactlyOne(
    'fn:fold-right',
    'function',
    arguments[2],
  ).toXPathFunction();
  final items = seq.toList().reversed;
  for (final item in items) {
    zero = function(context, [XPathSequence.single(item), zero]);
  }
  return zero;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each-pair
XPathSequence fnForEachPair(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:for-each-pair', arguments, 3);
  final seq1 = arguments[0];
  final seq2 = arguments[1];
  final action = XPathEvaluationException.extractExactlyOne(
    'fn:for-each-pair',
    'action',
    arguments[2],
  ).toXPathFunction();
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
XPathSequence fnSort(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:sort', arguments, 1, 3);
  final input = arguments[0];
  // ignore: unused_local_variable
  final collation = arguments.length > 1
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:sort',
          'collation',
          arguments[1],
        )?.toXPathString()
      : null;
  final key = arguments.length > 2
      ? XPathEvaluationException.extractExactlyOne(
          'fn:sort',
          'key',
          arguments[2],
        ).toXPathFunction()
      : null;
  final list = input.toList();
  list.sort((a, b) {
    if (key != null) {
      final keyA = key(context, [XPathSequence.single(a)]).toAtomicValue();
      final keyB = key(context, [XPathSequence.single(b)]).toAtomicValue();
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
XPathSequence fnApply(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:apply', arguments, 2);
  final function = XPathEvaluationException.extractExactlyOne(
    'fn:apply',
    'function',
    arguments[0],
  ).toXPathFunction();
  final array = XPathEvaluationException.extractExactlyOne(
    'fn:apply',
    'array',
    arguments[1],
  ).toXPathArray();
  return function(context, array.map((e) => e.toXPathSequence()).toList());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
XPathSequence fnFunctionLookup(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:function-lookup');

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
XPathSequence fnFunctionName(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:function-name');

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
XPathSequence fnFunctionArity(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:function-arity');

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
XPathSequence fnLoadXqueryModule(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:load-xquery-module');

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
XPathSequence fnTransform(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:transform');
