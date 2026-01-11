import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each
XPathSequence fnForEach(
  XPathContext context,
  XPathSequence seq,
  XPathSequence action,
) {
  throw UnimplementedError('fn:for-each');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-filter
XPathSequence fnFilter(
  XPathContext context,
  XPathSequence seq,
  XPathSequence f,
) {
  throw UnimplementedError('fn:filter');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-left
XPathSequence fnFoldLeft(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathSequence f,
) {
  throw UnimplementedError('fn:fold-left');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-fold-right
XPathSequence fnFoldRight(
  XPathContext context,
  XPathSequence seq,
  XPathSequence zero,
  XPathSequence f,
) {
  throw UnimplementedError('fn:fold-right');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-for-each-pair
XPathSequence fnForEachPair(
  XPathContext context,
  XPathSequence seq1,
  XPathSequence seq2,
  XPathSequence f,
) {
  throw UnimplementedError('fn:for-each-pair');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sort
XPathSequence fnSort(
  XPathContext context,
  XPathSequence seq, [
  XPathSequence? collation,
  XPathSequence? key,
]) {
  if (key != null) {
    throw UnimplementedError('fn:sort with key is not supported');
  }
  if (collation != null) {
    // Check cardinality even if ignored
    XPathEvaluationException.checkExactlyOne(collation);
    // TODO: Support collation
  }
  // Basic sort using string/number comparison logic
  final list = seq.toList();
  list.sort((a, b) {
    if (a is Comparable && b is Comparable) {
      try {
        return a.compareTo(b);
      } catch (_) {
        // Fallback to string comparison if types incompatible?
      }
    }
    return a.toString().compareTo(b.toString());
  });
  return XPathSequence(list);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-apply
XPathSequence fnApply(
  XPathContext context,
  XPathSequence function,
  XPathSequence array,
) {
  throw UnimplementedError('fn:apply');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-lookup
XPathSequence fnFunctionLookup(
  XPathContext context,
  XPathSequence name,
  XPathSequence arity,
) {
  throw UnimplementedError('fn:function-lookup');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-name
XPathSequence fnFunctionName(XPathContext context, XPathSequence function) {
  throw UnimplementedError('fn:function-name');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-function-arity
XPathSequence fnFunctionArity(XPathContext context, XPathSequence function) {
  throw UnimplementedError('fn:function-arity');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-load-xquery-module
XPathSequence fnLoadXqueryModule(
  XPathContext context,
  XPathSequence moduleUri, [
  XPathSequence? options,
]) {
  throw UnimplementedError('fn:load-xquery-module');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-transform
XPathSequence fnTransform(XPathContext context, XPathSequence options) {
  throw UnimplementedError('fn:transform');
}
