import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
XPathSequence fnForEach(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:for-each');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
XPathSequence fnFilter(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:filter');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
XPathSequence fnFoldLeft(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:fold-left');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-right
XPathSequence fnFoldRight(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:fold-right');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each-pair
XPathSequence fnForEachPair(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:for-each-pair');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sort
XPathSequence fnSort(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:sort', arguments, 1, 3);
  final input = arguments[0];
  // Argument 1: collation (ignored for now)
  // Argument 2: key (unsupported)

  if (arguments.length > 2) {
    throw UnimplementedError('fn:sort with key is not supported');
  }
  if (arguments.length > 1) {
    // Check cardinality of collation
    XPathEvaluationException.extractExactlyOne(
      'fn:sort',
      'collation',
      arguments[1],
    );
    // TODO: Support collation
  }

  final list = input.toList();
  list.sort((a, b) {
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
  throw UnimplementedError('fn:apply');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
XPathSequence fnFunctionLookup(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:function-lookup');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
XPathSequence fnFunctionName(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:function-name');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
XPathSequence fnFunctionArity(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:function-arity');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
XPathSequence fnLoadXqueryModule(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:load-xquery-module');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
XPathSequence fnTransform(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:transform');
}
