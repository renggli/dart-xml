import 'dart:math';

import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
const fnEmpty = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'empty',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnEmpty,
);

XPathSequence _fnEmpty(XPathContext context, XPathSequence arg) =>
    arg.isEmpty ? XPathSequence.trueSequence : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
const fnExists = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'exists',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnExists,
);

XPathSequence _fnExists(XPathContext context, XPathSequence arg) =>
    arg.isNotEmpty ? XPathSequence.trueSequence : XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-head
const fnHead = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'head',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnHead,
);

XPathSequence _fnHead(XPathContext context, XPathSequence arg) =>
    arg.isEmpty ? XPathSequence.empty : XPathSequence.single(arg.first);

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
const fnTail = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'tail',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnTail,
);

XPathSequence _fnTail(XPathContext context, XPathSequence arg) =>
    arg.isEmpty ? XPathSequence.empty : XPathSequence(arg.skip(1));

/// https://www.w3.org/TR/xpath-functions-31/#func-insert-before
const fnInsertBefore = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'insert-before',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'target',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'position', type: XPathNumber),
    XPathArgumentDefinition(
      name: 'inserts',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnInsertBefore,
);

XPathSequence _fnInsertBefore(
  XPathContext context,
  XPathSequence target,
  XPathNumber position,
  XPathSequence inserts,
) {
  var pos = position.toInt();
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
const fnRemove = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'remove',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'target',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'position', type: XPathNumber),
  ],
  function: _fnRemove,
);

XPathSequence _fnRemove(
  XPathContext context,
  XPathSequence target,
  XPathNumber position,
) {
  final pos = position.toInt();
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in target) {
      if (i != pos) yield item;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-reverse
const fnReverse = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'reverse',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnReverse,
);

XPathSequence _fnReverse(XPathContext context, XPathSequence arg) =>
    XPathSequence(arg.toList().reversed);

/// https://www.w3.org/TR/xpath-functions-31/#func-subsequence
const fnSubsequence = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'subsequence',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceSeq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'startingLoc', type: XPathNumber),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'length', type: XPathNumber),
  ],
  function: _fnSubsequence,
);

XPathSequence _fnSubsequence(
  XPathContext context,
  XPathSequence sourceSeq,
  XPathNumber startingLoc, [
  Object? length = _missing,
]) {
  final startingLocVal = startingLoc.toDouble();
  final startingIdx = startingLocVal.round();
  if (identical(length, _missing)) {
    return XPathSequence(sourceSeq.skip(max(0, startingIdx - 1)));
  }
  final lengthVal = (length as XPathNumber).toDouble();
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
const fnUnordered = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unordered',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceSeq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnUnordered,
);

XPathSequence _fnUnordered(XPathContext context, XPathSequence sourceSeq) =>
    sourceSeq;

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
const fnDistinctValues = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'distinct-values',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
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
  ],
  function: _fnDistinctValues,
);

// Argument 2: collation (ignored for now via TODO)
XPathSequence _fnDistinctValues(
  XPathContext context,
  XPathSequence arg, [
  Object? collation = _missing,
]) => XPathSequence(arg.toSet());

/// https://www.w3.org/TR/xpath-functions-31/#func-index-of
const fnIndexOf = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'index-of',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'seq',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(name: 'search', type: XPathSequence),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnIndexOf,
);

XPathSequence _fnIndexOf(
  XPathContext context,
  XPathSequence seq,
  XPathSequence search, [
  Object? collation = _missing,
]) {
  // Argument 3: collation (ignored for now via TODO)
  // Search item is exactly one? 'search' argument definition minValues: 1.
  // But strictly `index-of` takes `$search as xs:anyAtomicType`.
  // If we say `type: XPathValue` (generic single item)?
  // Or `type: XPathSequence` and extract single?
  // Original impl extracted exactly one.
  // We'll assume search is single item sequence or we take first?
  // Spec: `$search as xs:anyAtomicType`. Atomization applies.
  // We'll extract first item if sequence passed.
  final searchItem = search.isNotEmpty
      ? search.first
      : throw XPathEvaluationException('Search item cannot be empty');
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in seq) {
      if (item == searchItem) yield i;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-deep-equal
const fnDeepEqual = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'deep-equal',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'parameter1',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
    XPathArgumentDefinition(
      name: 'parameter2',
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
  ],
  function: _fnDeepEqual,
);

XPathSequence _fnDeepEqual(
  XPathContext context,
  XPathSequence parameter1,
  XPathSequence parameter2, [
  Object? collation = _missing,
]) {
  // Argument 3: collation (ignored for now via TODO)
  if (parameter1.length != parameter2.length) {
    return XPathSequence.falseSequence;
  }
  final it1 = parameter1.iterator;
  final it2 = parameter2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    if (it1.current != it2.current) return XPathSequence.falseSequence;
  }
  return XPathSequence.trueSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-zero-or-one
const fnZeroOrOne = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'zero-or-one',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnZeroOrOne,
);

XPathSequence _fnZeroOrOne(XPathContext context, XPathSequence arg) {
  if (arg.length > 1) {
    throw XPathEvaluationException(
      'fn:zero-or-one called with a sequence of more than one item',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-one-or-more
const fnOneOrMore = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'one-or-more',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnOneOrMore,
);

XPathSequence _fnOneOrMore(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) {
    throw XPathEvaluationException(
      'fn:one-or-more called with an empty sequence',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exactly-one
const fnExactlyOne = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'exactly-one',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnExactlyOne,
);

XPathSequence _fnExactlyOne(XPathContext context, XPathSequence arg) {
  if (arg.length != 1) {
    throw XPathEvaluationException(
      'fn:exactly-one called with a sequence that does not contain exactly one item',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-count
const fnCount = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'count',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnCount,
);

XPathSequence _fnCount(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.length);

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
const fnAvg = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'avg',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnAvg,
);

XPathSequence _fnAvg(XPathContext context, XPathSequence arg) {
  if (arg.isEmpty) return XPathSequence.empty;
  var sum = 0.0;
  var count = 0;
  for (final item in arg) {
    sum += item.toXPathNumber().toDouble();
    count++;
  }
  return XPathSequence.single(sum / count);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-max
const fnMax = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'max',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
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
  ],
  function: _fnMax,
);

XPathSequence _fnMax(
  XPathContext context,
  XPathSequence arg, [
  Object? collation = _missing,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  num? maxVal;
  for (final item in arg) {
    // Basic support for numeric comparisons for now, as in original
    // If items are not numbers, this cast might fail unless we convert.
    // Original code: `item as num`. Implicitly assumes numbers for now or compatible.
    final value = item as num;
    if (maxVal == null || value > maxVal) maxVal = value;
  }
  return XPathSequence.single(maxVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
const fnMin = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'min',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
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
  ],
  function: _fnMin,
);

XPathSequence _fnMin(
  XPathContext context,
  XPathSequence arg, [
  Object? collation = _missing,
]) {
  if (arg.isEmpty) return XPathSequence.empty;
  num? minVal;
  for (final item in arg) {
    final value = item as num;
    if (minVal == null || value < minVal) minVal = value;
  }
  return XPathSequence.single(minVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
const fnSum = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'sum',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'zero',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne, // optional
    ),
  ],
  function: _fnSum,
);

XPathSequence _fnSum(
  XPathContext context,
  XPathSequence arg, [
  Object? zero = _missing,
]) {
  if (arg.isEmpty) {
    if (!identical(zero, _missing)) {
      // zero is passed as XPathSequence (single item or empty or more?)
      // spec: $zero as xs:anyAtomicType?
      // We return it.
      return zero as XPathSequence;
    }
    return const XPathSequence.single(0);
  }
  var sum = 0.0;
  for (final item in arg) {
    sum += item.toXPathNumber().toDouble();
  }
  return XPathSequence.single(sum);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-id
const fnId = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'id',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnId,
);

XPathSequence _fnId(
  XPathContext context, [
  Object? arg = _missing,
  Object? node = _missing,
]) {
  throw UnimplementedError('fn:id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
const fnElementWithId = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'element-with-id',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnElementWithId,
);

XPathSequence _fnElementWithId(
  XPathContext context, [
  Object? arg = _missing,
  Object? node = _missing,
]) {
  throw UnimplementedError('fn:element-with-id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
const fnIdref = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'idref',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnIdref,
);

XPathSequence _fnIdref(
  XPathContext context, [
  Object? arg = _missing,
  Object? node = _missing,
]) {
  throw UnimplementedError('fn:idref is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
const fnGenerateId = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'generate-id',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnGenerateId,
);

XPathSequence _fnGenerateId(XPathContext context, [Object? node = _missing]) {
  throw UnimplementedError('fn:generate-id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
const fnDoc = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'doc',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDoc,
);

XPathSequence _fnDoc(XPathContext context, XPathString? href) {
  if (href == null) return XPathSequence.empty;
  final doc = context.documents[href];
  if (doc == null) {
    throw XPathEvaluationException('Document not found: $href');
  }
  return XPathSequence.single(doc);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
const fnDocAvailable = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'doc-available',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnDocAvailable,
);

XPathSequence _fnDocAvailable(XPathContext context, XPathString? href) {
  if (href == null) return XPathSequence.falseSequence;
  return context.documents.containsKey(href)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
const fnCollection = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'collection',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnCollection,
);

XPathSequence _fnCollection(XPathContext context, [Object? arg = _missing]) {
  final argVal = identical(arg, _missing) ? null : arg as XPathString?;
  // Argument logic: if no arg provided (0 args), arg is _missing.
  // If arg provided but empty sequence -> argVal is null?
  // Previous: extractZeroOrOne... check arguments.isEmpty.
  // If called without args -> default used.
  // If called with empty sequence -> returns null.
  // Wait, _missing is for omitted argument.
  // If arg omitted, return sequence(documents.values).
  // If arg is empty (null), logic is:
  // "evaluating fn:collection with no argument is... equivalent to ... fn:collection(fn:default-collection())".
  // Existing logic: `if (arg == null) ...`.
  // If I use `arg = _missing`: same logic?
  if (identical(arg, _missing) || arg == null) {
    return XPathSequence(context.documents.values);
  }
  final doc = context.documents[argVal];
  return doc != null ? XPathSequence.single(doc) : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
const fnUriCollection = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'uri-collection',
  requiredArguments: [],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnUriCollection,
);

XPathSequence _fnUriCollection(XPathContext context, [Object? arg = _missing]) {
  final argVal = identical(arg, _missing) ? null : arg as XPathString?;
  if (identical(arg, _missing) || argVal == null) {
    return XPathSequence(context.documents.keys.map(XPathString.new));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
const fnUnparsedText = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unparsed-text',
  requiredArguments: [XPathArgumentDefinition(name: 'href', type: XPathString)],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'encoding',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnUnparsedText,
);

XPathSequence _fnUnparsedText(
  XPathContext context, [
  Object? href = _missing,
  Object? encoding = _missing,
]) {
  throw UnimplementedError('fn:unparsed-text is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines
const fnUnparsedTextLines = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unparsed-text-lines',
  requiredArguments: [XPathArgumentDefinition(name: 'href', type: XPathString)],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'encoding',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnUnparsedTextLines,
);

XPathSequence _fnUnparsedTextLines(
  XPathContext context, [
  Object? href = _missing,
  Object? encoding = _missing,
]) {
  throw UnimplementedError('fn:unparsed-text-lines is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
const fnUnparsedTextAvailable = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'unparsed-text-available',
  requiredArguments: [XPathArgumentDefinition(name: 'href', type: XPathString)],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'encoding',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnUnparsedTextAvailable,
);

XPathSequence _fnUnparsedTextAvailable(
  XPathContext context, [
  Object? href = _missing,
  Object? encoding = _missing,
]) {
  throw UnimplementedError('fn:unparsed-text-available is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
const fnEnvironmentVariable = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'environment-variable',
  requiredArguments: [XPathArgumentDefinition(name: 'name', type: XPathString)],
  function: _fnEnvironmentVariable,
);

XPathSequence _fnEnvironmentVariable(
  XPathContext context, [
  Object? name = _missing,
]) {
  throw UnimplementedError('fn:environment-variable is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
const fnAvailableEnvironmentVariables = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'available-environment-variables',
  function: _fnAvailableEnvironmentVariables,
);

XPathSequence _fnAvailableEnvironmentVariables(XPathContext context) {
  throw UnimplementedError(
    'fn:available-environment-variables is not yet implemented',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml
const fnParseXml = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-xml',
  requiredArguments: [XPathArgumentDefinition(name: 'arg', type: XPathString)],
  function: _fnParseXml,
);

XPathSequence _fnParseXml(XPathContext context, [Object? arg = _missing]) {
  throw UnimplementedError('fn:parse-xml is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml-fragment
const fnParseXmlFragment = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'parse-xml-fragment',
  requiredArguments: [XPathArgumentDefinition(name: 'arg', type: XPathString)],
  function: _fnParseXmlFragment,
);

XPathSequence _fnParseXmlFragment(XPathContext context, XPathString arg) {
  throw UnimplementedError('fn:parse-xml-fragment is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
const fnSerialize = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'serialize',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'params',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSerialize,
);

XPathSequence _fnSerialize(
  XPathContext context,
  XPathSequence arg, [
  Object? params = _missing,
]) {
  throw UnimplementedError('fn:serialize is not yet implemented');
}

const _missing = Object();
