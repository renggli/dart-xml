import 'dart:math';

import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-empty
XPathSequence fnEmpty(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:empty', arguments, 1);
  final arg = arguments[0];
  return arg.isEmpty ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exists
XPathSequence fnExists(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:exists', arguments, 1);
  final arg = arguments[0];
  return arg.isNotEmpty
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-head
XPathSequence fnHead(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:head', arguments, 1);
  final arg = arguments[0];
  return arg.isEmpty ? XPathSequence.empty : XPathSequence.single(arg.first);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tail
XPathSequence fnTail(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:tail', arguments, 1);
  final arg = arguments[0];
  return arg.isEmpty ? XPathSequence.empty : XPathSequence(arg.skip(1));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-insert-before
XPathSequence fnInsertBefore(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:insert-before', arguments, 3);
  final target = arguments[0];
  var pos = XPathEvaluationException.extractExactlyOne(
    'fn:insert-before',
    'position',
    arguments[1],
  ).toXPathNumber().toInt();
  final inserts = arguments[2];

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
XPathSequence fnRemove(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:remove', arguments, 2);
  final target = arguments[0];
  final pos = XPathEvaluationException.extractExactlyOne(
    'fn:remove',
    'position',
    arguments[1],
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
XPathSequence fnReverse(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:reverse', arguments, 1);
  final arg = arguments[0];
  return XPathSequence(arg.toList().reversed);
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
  final sourceSeq = arguments[0];
  final startingLoc = XPathEvaluationException.extractExactlyOne(
    'fn:subsequence',
    'startingLoc',
    arguments[1],
  ).toXPathNumber().toDouble();
  final startingIdx = startingLoc.round();

  if (arguments.length == 2) {
    return XPathSequence(sourceSeq.skip(max(0, startingIdx - 1)));
  }

  final length = XPathEvaluationException.extractExactlyOne(
    'fn:subsequence',
    'length',
    arguments[2],
  ).toXPathNumber().toDouble();
  final endingIdx = (startingLoc + length).round();

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
XPathSequence fnUnordered(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:unordered', arguments, 1);
  return arguments[0];
}

/// https://www.w3.org/TR/xpath-functions-31/#func-distinct-values
XPathSequence fnDistinctValues(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:distinct-values',
    arguments,
    1,
    2,
  );
  final arg = arguments[0];
  // Argument 2: collation (ignored for now via TODO)
  return XPathSequence(arg.toSet());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-index-of
XPathSequence fnIndexOf(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:index-of', arguments, 2, 3);
  final seq = arguments[0];
  final search = XPathEvaluationException.extractExactlyOne(
    'fn:index-of',
    'search',
    arguments[1],
  );
  // Argument 3: collation (ignored for now via TODO)
  return XPathSequence(() sync* {
    var i = 1;
    for (final item in seq) {
      if (item == search) yield i;
      i++;
    }
  }());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-deep-equal
XPathSequence fnDeepEqual(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:deep-equal', arguments, 2, 3);
  final parameter1 = arguments[0];
  final parameter2 = arguments[1];
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
XPathSequence fnZeroOrOne(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:zero-or-one', arguments, 1);
  final arg = arguments[0];
  if (arg.length > 1) {
    throw XPathEvaluationException(
      'fn:zero-or-one called with a sequence of more than one item',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-one-or-more
XPathSequence fnOneOrMore(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:one-or-more', arguments, 1);
  final arg = arguments[0];
  if (arg.isEmpty) {
    throw XPathEvaluationException(
      'fn:one-or-more called with an empty sequence',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-exactly-one
XPathSequence fnExactlyOne(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:exactly-one', arguments, 1);
  final arg = arguments[0];
  if (arg.length != 1) {
    throw XPathEvaluationException(
      'fn:exactly-one called with a sequence that does not contain exactly one item',
    );
  }
  return arg;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-count
XPathSequence fnCount(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:count', arguments, 1);
  return XPathSequence.single(arguments[0].length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-avg
XPathSequence fnAvg(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:avg', arguments, 1);
  final arg = arguments[0];
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
XPathSequence fnMax(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:max', arguments, 1, 2);
  final arg = arguments[0];
  // Argument 2: collation (ignored for now via TODO)

  if (arg.isEmpty) return XPathSequence.empty;
  num? maxVal;
  for (final item in arg) {
    final value = item as num;
    if (maxVal == null || value > maxVal) maxVal = value;
  }
  return XPathSequence.single(maxVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-min
XPathSequence fnMin(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:min', arguments, 1, 2);
  final arg = arguments[0];
  // Argument 2: collation (ignored for now via TODO)

  if (arg.isEmpty) return XPathSequence.empty;
  num? minVal;
  for (final item in arg) {
    final value = item as num;
    if (minVal == null || value < minVal) minVal = value;
  }
  return XPathSequence.single(minVal!);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-sum
XPathSequence fnSum(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:sum', arguments, 1, 2);
  final arg = arguments[0];
  if (arg.isEmpty) {
    if (arguments.length > 1) {
      return XPathSequence.single(
        XPathEvaluationException.extractExactlyOne(
          'fn:sum',
          'zero',
          arguments[1],
        ),
      );
    }
    return XPathSequence.single(0);
  }
  var sum = 0.0;
  for (final item in arg) {
    sum += (item as num).toDouble();
  }
  return XPathSequence.single(sum);
}

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

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
XPathSequence fnDoc(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:doc', arguments, 1);
  final href = XPathEvaluationException.extractZeroOrOne(
    'fn:doc',
    'href',
    arguments[0],
  )?.toXPathString();
  if (href == null) return XPathSequence.empty;
  final doc = context.documents[href];
  if (doc == null) {
    throw XPathEvaluationException('Document not found: $href');
  }
  return XPathSequence.single(doc);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
XPathSequence fnDocAvailable(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:doc-available', arguments, 1);
  final href = XPathEvaluationException.extractZeroOrOne(
    'fn:doc-available',
    'href',
    arguments[0],
  )?.toXPathString();
  if (href == null) return XPathSequence.falseSequence;
  return context.documents.containsKey(href)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
XPathSequence fnCollection(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount('fn:collection', arguments, 0, 1);
  final arg = arguments.isEmpty
      ? null
      : XPathEvaluationException.extractZeroOrOne(
          'fn:collection',
          'arg',
          arguments[0],
        )?.toXPathString();
  if (arg == null) {
    return XPathSequence(context.documents.values);
  }
  final doc = context.documents[arg];
  return doc != null ? XPathSequence.single(doc) : XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
XPathSequence fnUriCollection(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:uri-collection',
    arguments,
    0,
    1,
  );
  final arg = arguments.isEmpty
      ? null
      : XPathEvaluationException.extractZeroOrOne(
          'fn:uri-collection',
          'arg',
          arguments[0],
        )?.toXPathString();
  if (arg == null) {
    return XPathSequence(context.documents.keys.map(XPathString.new));
  }
  return XPathSequence.empty;
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
