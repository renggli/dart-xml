import 'dart:math';

import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../values31/sequence.dart';

// 14. Functions and operators on sequences

// 14.1 General functions and operators on sequences

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
XPathSequence fnEmpty(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:empty', arguments, 1);
  return arguments[0].isEmpty
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
XPathSequence fnExists(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:exists', arguments, 1);
  return arguments[0].isNotEmpty
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-head
XPathSequence fnHead(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:head', arguments, 1);
  final sequence = arguments[0];
  return sequence.isEmpty
      ? XPathSequence.empty
      : XPathSequence.single(sequence.first);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
XPathSequence fnTail(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:tail', arguments, 1);
  final sequence = arguments[0];
  return sequence.isEmpty
      ? XPathSequence.empty
      : XPathSequence(sequence.skip(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-insert-before
XPathSequence fnInsertBefore(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:insert-before', arguments, 3);
  final target = arguments[0];
  var position = arguments[1].isEmpty ? 1 : arguments[1].first as int;
  final inserts = arguments[2];
  if (position < 1) {
    position = 1;
  } else if (position > target.length) {
    position = target.length + 1;
  }
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in target) {
      if (i == position) yield* inserts;
      yield item;
      i++;
    }
    if (i == position) yield* inserts;
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-remove
XPathSequence fnRemove(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:remove', arguments, 2);
  final target = arguments[0];
  final position = arguments[1].isEmpty ? 0 : arguments[1].first as int;
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in target) {
      if (i != position) yield item;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-reverse
XPathSequence fnReverse(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:reverse', arguments, 1);
  final sequence = arguments[0];
  return XPathSequence(sequence.toList().reversed);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-subsequence
XPathSequence fnSubsequence(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:subsequence',
    arguments,
    2,
    3,
  );
  final source = arguments[0];
  final startingLoc = arguments[1].isEmpty
      ? 1.0
      : (arguments[1].first as num).toDouble();
  final startingIdx = startingLoc.round();
  if (arguments.length == 2) {
    return XPathSequence(source.skip(max(0, startingIdx - 1)));
  }
  final length = (arguments[2].first as num).toDouble();
  final endingIdx = (startingLoc + length).round();
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in source) {
      if (i >= startingIdx && i < endingIdx) {
        yield item;
      }
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unordered
XPathSequence fnUnordered(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:unordered', arguments, 1);
  return arguments[0];
}

// 14.2 Functions that compare values in sequences

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
XPathSequence fnDistinctValues(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'distinct-values',
    arguments,
    1,
    2,
  );
  final sequence = arguments[0];
  return XPathSequence(sequence.toSet());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-index-of
XPathSequence fnIndexOf(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:index-of', arguments, 2, 3);
  final sequence = arguments[0];
  final search = arguments[1].firstOrNull;
  if (search == null) return XPathSequence.empty;
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in sequence) {
      if (item == search) yield i;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-deep-equal
XPathSequence fnDeepEqual(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:deep-equal', arguments, 2, 3);
  final seq1 = arguments[0];
  final seq2 = arguments[1];
  if (seq1.length != seq2.length) return XPathSequence.falseSequence;
  final it1 = seq1.iterator;
  final it2 = seq2.iterator;
  while (it1.moveNext() && it2.moveNext()) {
    if (it1.current != it2.current) return XPathSequence.falseSequence;
  }
  return XPathSequence.trueSequence;
}

// 14.3 Functions that test the cardinality of sequences

/// https://www.w3.org/TR/xpath-functions-31/#func-zero-or-one
XPathSequence fnZeroOrOne(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:zero-or-one', arguments, 1);
  final sequence = arguments[0];
  if (sequence.length > 1) {
    throw XPathEvaluationException(
      'fn:zero-or-one called with a sequence of more than one item',
    );
  }
  return sequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-one-or-more
XPathSequence fnOneOrMore(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:one-or-more', arguments, 1);
  final sequence = arguments[0];
  if (sequence.isEmpty) {
    throw XPathEvaluationException(
      'fn:one-or-more called with an empty sequence',
    );
  }
  return sequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exactly-one
XPathSequence fnExactlyOne(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:exactly-one', arguments, 1);
  final sequence = arguments[0];
  if (sequence.length != 1) {
    throw XPathEvaluationException(
      'fn:exactly-one called with a sequence that does not contain exactly one item',
    );
  }
  return sequence;
}

// 14.4 Aggregate functions

/// https://www.w3.org/TR/xpath-functions-31/#func-count
XPathSequence fnCount(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:count', arguments, 1);
  return XPathSequence.single(arguments[0].length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
XPathSequence fnAvg(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:avg', arguments, 1);
  final sequence = arguments[0];
  if (sequence.isEmpty) return XPathSequence.empty;
  var sum = 0.0;
  var count = 0;
  for (final item in sequence) {
    sum += (item as num).toDouble();
    count++;
  }
  return XPathSequence.single(sum / count);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-max
XPathSequence fnMax(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:max', arguments, 1, 2);
  final sequence = arguments[0];
  if (sequence.isEmpty) return XPathSequence.empty;
  num? maxVal;
  for (final item in sequence) {
    final value = item as num;
    if (maxVal == null || value > maxVal) maxVal = value;
  }
  return XPathSequence.single(maxVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
XPathSequence fnMin(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:min', arguments, 1, 2);
  final sequence = arguments[0];
  if (sequence.isEmpty) return XPathSequence.empty;
  num? minVal;
  for (final item in sequence) {
    final value = item as num;
    if (minVal == null || value < minVal) minVal = value;
  }
  return XPathSequence.single(minVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
XPathSequence fnSum(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:sum', arguments, 1, 2);
  final sequence = arguments[0];
  if (sequence.isEmpty) {
    return arguments.length == 2 ? arguments[1] : XPathSequence.single(0);
  }
  var sum = 0.0;
  for (final item in sequence) {
    sum += (item as num).toDouble();
  }
  return XPathSequence.single(sum);
}

// 14.5 Functions on node identifiers

/// https://www.w3.org/TR/xpath-functions-31/#func-id
XPathSequence fnId(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
XPathSequence fnElementWithId(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:element-with-id is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
XPathSequence fnIdref(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:idref is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
XPathSequence fnGenerateId(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:generate-id is not yet implemented');
}

// 14.6 Functions giving access to external information

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
XPathSequence fnDoc(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:doc is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
XPathSequence fnDocAvailable(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:doc-available is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
XPathSequence fnCollection(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:collection is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
XPathSequence fnUriCollection(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:uri-collection is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
XPathSequence fnUnparsedText(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:unparsed-text is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines
XPathSequence fnUnparsedTextLines(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:unparsed-text-lines is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
XPathSequence fnUnparsedTextAvailable(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:unparsed-text-available is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
XPathSequence fnEnvironmentVariable(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:environment-variable is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
XPathSequence fnAvailableEnvironmentVariables(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError(
    'fn:available-environment-variables is not yet implemented',
  );
}

// 14.7 Parsing and serializing

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml
XPathSequence fnParseXml(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:parse-xml is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml-fragment
XPathSequence fnParseXmlFragment(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  throw UnimplementedError('fn:parse-xml-fragment is not yet implemented');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
XPathSequence fnSerialize(XPathContext context, List<XPathSequence> arguments) {
  throw UnimplementedError('fn:serialize is not yet implemented');
}
