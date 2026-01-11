import 'dart:math';

import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
XPathSequence fnEmpty(XPathContext context, XPathSequence arg) =>
    arg.isEmpty ? XPathSequence.trueSequence : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
XPathSequence fnExists(XPathContext context, XPathSequence arg) =>
    arg.isNotEmpty ? XPathSequence.trueSequence : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-head
XPathSequence fnHead(XPathContext context, XPathSequence arg) =>
    arg.isEmpty ? XPathSequence.empty : XPathSequence.single(arg.first);

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
XPathSequence fnTail(XPathContext context, XPathSequence arg) =>
    arg.isEmpty ? XPathSequence.empty : XPathSequence(arg.skip(1));

/// https://www.w3.org/TR/xpath-functions-31/#func-insert-before
XPathSequence fnInsertBefore(
  XPathContext context,
  XPathSequence target,
  XPathSequence position,
  XPathSequence inserts,
) {
  var pos = XPathEvaluationException.checkExactlyOne(
    position,
  ).toXPathNumber().toInt();
  if (pos < 1) {
    pos = 1;
  } else if (pos > target.length) {
    pos = target.length + 1;
  }
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in target) {
      if (i == pos) yield* inserts;
      yield item;
      i++;
    }
    if (i == pos) yield* inserts;
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-remove
XPathSequence fnRemove(
  XPathContext context,
  XPathSequence target,
  XPathSequence position,
) {
  final pos = XPathEvaluationException.checkExactlyOne(
    position,
  ).toXPathNumber().toInt();
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in target) {
      if (i != pos) yield item;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-reverse
XPathSequence fnReverse(XPathContext context, XPathSequence arg) =>
    XPathSequence(arg.toList().reversed);

/// https://www.w3.org/TR/xpath-functions-31/#func-subsequence
XPathSequence fnSubsequence(
  XPathContext context,
  XPathSequence sourceSeq,
  XPathSequence startingLoc, [
  XPathSequence? length,
]) {
  final startingLocVal = XPathEvaluationException.checkExactlyOne(
    startingLoc,
  ).toXPathNumber().toDouble();
  final startingIdx = startingLocVal.round();
  if (length == null) {
    return XPathSequence(sourceSeq.skip(max(0, startingIdx - 1)));
  }
  final lengthVal = XPathEvaluationException.checkExactlyOne(
    length,
  ).toXPathNumber().toDouble();
  final endingIdx = (startingLocVal + lengthVal).round();
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in sourceSeq) {
      if (i >= startingIdx && i < endingIdx) {
        yield item;
      }
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unordered
XPathSequence fnUnordered(XPathContext context, XPathSequence arg) => arg;

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
XPathSequence fnDistinctValues(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? collation,
]) => XPathSequence(arg.toSet());

/// https://www.w3.org/TR/xpath-functions-31/#func-index-of
XPathSequence fnIndexOf(
  XPathContext context,
  XPathSequence seq,
  XPathSequence search, [
  XPathSequence? collation,
]) {
  final searchVal = XPathEvaluationException.checkExactlyOne(search);
  // TODO: Handle collation parameter
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in seq) {
      if (item == searchVal) yield i;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-deep-equal
XPathSequence fnDeepEqual(
  XPathContext context,
  XPathSequence parameter1,
  XPathSequence parameter2, [
  XPathSequence? collation,
]) {
  if (parameter1.length != parameter2.length) {
    return XPathSequence.falseSequence;
  }
  // TODO: Handle collation parameter
  final it1 = parameter1.iterator;
  final it2 = parameter2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    if (it1.current != it2.current) return XPathSequence.falseSequence;
  }
  return XPathSequence.trueSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-zero-or-one
XPathSequence fnZeroOrOne(XPathContext context, XPathSequence arg) {
  if (arg.length > 1) {
    throw XPathEvaluationException(
      'fn:zero-or-one called with a sequence of more than one item',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-one-or-more
XPathSequence fnOneOrMore(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) {
    throw XPathEvaluationException(
      'fn:one-or-more called with an empty sequence',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exactly-one
XPathSequence fnExactlyOne(XPathContext context, XPathSequence arg) {
  if (arg.length != 1) {
    throw XPathEvaluationException(
      'fn:exactly-one called with a sequence that does not contain exactly one item',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-count
XPathSequence fnCount(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
XPathSequence fnAvg(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) return XPathSequence.empty;
  var sum = 0.0;
  var count = 0;
  for (final item in arg) {
    sum += (item as num).toDouble();
    count++;
  }
  return XPathSequence.single(sum / count);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-max
XPathSequence fnMax(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? collation,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  // TODO: Handle collation parameter
  num? maxVal;
  for (final item in arg) {
    final value = item as num;
    if (maxVal == null || value > maxVal) maxVal = value;
  }
  return XPathSequence.single(maxVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
XPathSequence fnMin(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? collation,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  // TODO: Handle collation parameter
  num? minVal;
  for (final item in arg) {
    final value = item as num;
    if (minVal == null || value < minVal) minVal = value;
  }
  return XPathSequence.single(minVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
XPathSequence fnSum(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? zero,
]) {
  if (arg.isEmpty) {
    return zero ?? XPathSequence.single(0);
  }
  var sum = 0.0;
  for (final item in arg) {
    sum += (item as num).toDouble();
  }
  return XPathSequence.single(sum);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-id
XPathSequence fnId(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? node,
]) {
  throw UnimplementedError('fn:id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
XPathSequence fnElementWithId(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? node,
]) {
  throw UnimplementedError('fn:element-with-id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
XPathSequence fnIdref(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? node,
]) {
  throw UnimplementedError('fn:idref is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
XPathSequence fnGenerateId(XPathContext context, [XPathSequence? arg]) {
  throw UnimplementedError('fn:generate-id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
XPathSequence fnDoc(XPathContext context, XPathSequence href) {
  final uri = XPathEvaluationException.checkZeroOrOne(href)?.toXPathString();
  if (uri == null) return XPathSequence.empty;
  final doc = context.documents[uri];
  if (doc == null) {
    // If validation is required, we might error, but spec says "or returns empty sequence if not found" is not exactly true, usually it errors if resource is missing?
    // "If $uri is not a valid xs:anyURI, an error is raised [err:FODC0005]."
    // "If the resource cannot be retrieved... [err:FODC0002]."
    throw XPathEvaluationException('Document not found: $uri');
  }
  return XPathSequence.single(doc);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
XPathSequence fnDocAvailable(XPathContext context, XPathSequence href) {
  final uri = XPathEvaluationException.checkZeroOrOne(href)?.toXPathString();
  if (uri == null) return XPathSequence.falseSequence;
  return context.documents.containsKey(uri)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
XPathSequence fnCollection(XPathContext context, [XPathSequence? arg]) {
  final uri = arg == null
      ? null
      : XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString();
  if (uri == null) {
    // Return default collection if defined, else potentially empty
    return XPathSequence(
      context.documents.values,
    ); // Return all known docs as default collection?
  }
  // Basic support: treat uri as matching a document key
  final doc = context.documents[uri];
  return doc != null ? XPathSequence.single(doc) : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
XPathSequence fnUriCollection(XPathContext context, [XPathSequence? arg]) {
  final uri = arg == null
      ? null
      : XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString();
  if (uri == null) {
    return XPathSequence(context.documents.keys.map(XPathString.new));
  }
  // If specific collection URI provided, return URIs in that collection
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
XPathSequence fnUnparsedText(
  XPathContext context,
  XPathSequence href, [
  XPathSequence? encoding,
]) {
  throw UnimplementedError('fn:unparsed-text is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines
XPathSequence fnUnparsedTextLines(
  XPathContext context,
  XPathSequence href, [
  XPathSequence? encoding,
]) {
  throw UnimplementedError('fn:unparsed-text-lines is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
XPathSequence fnUnparsedTextAvailable(
  XPathContext context,
  XPathSequence href, [
  XPathSequence? encoding,
]) {
  throw UnimplementedError('fn:unparsed-text-available is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
XPathSequence fnEnvironmentVariable(XPathContext context, XPathSequence name) {
  throw UnimplementedError('fn:environment-variable is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
XPathSequence fnAvailableEnvironmentVariables(XPathContext context) {
  throw UnimplementedError(
    'fn:available-environment-variables is not yet implemented',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml
XPathSequence fnParseXml(XPathContext context, XPathSequence arg) {
  throw UnimplementedError('fn:parse-xml is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml-fragment
XPathSequence fnParseXmlFragment(XPathContext context, XPathSequence arg) {
  throw UnimplementedError('fn:parse-xml-fragment is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
XPathSequence fnSerialize(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? params,
]) {
  throw UnimplementedError('fn:serialize is not yet implemented');
}
