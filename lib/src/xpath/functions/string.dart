import '../definitions/cardinality.dart';
import '../definitions/functions.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/any.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoints-to-string
const fnCodepointsToString = XPathFunctionDefinition(
  name: 'fn:codepoints-to-string',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsInteger,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnCodepointsToString,
);

XPathSequence _fnCodepointsToString(XPathContext context, XPathSequence arg) {
  try {
    final string = String.fromCharCodes(arg.cast<int>());
    return XPathSequence.single(string);
  } catch (e) {
    throw XPathEvaluationException('Invalid character code: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-to-codepoints
const fnStringToCodepoints = XPathFunctionDefinition(
  name: 'fn:string-to-codepoints',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnStringToCodepoints,
);

XPathSequence _fnStringToCodepoints(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.empty;
  return XPathSequence(arg.runes.toList());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-compare
const fnCompare = XPathFunctionDefinition(
  name: 'fn:compare',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'comparand1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'comparand2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnCompare,
);

XPathSequence _fnCompare(
  XPathContext context,
  String? comparand1,
  String? comparand2, [
  String? collation,
]) {
  if (comparand1 == null || comparand2 == null) return XPathSequence.empty;
  return XPathSequence.single(comparand1.compareTo(comparand2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoint-equal
const fnCodepointEqual = XPathFunctionDefinition(
  name: 'fn:codepoint-equal',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'comparand1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'comparand2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnCodepointEqual,
);

XPathSequence _fnCodepointEqual(
  XPathContext context,
  String? comparand1,
  String? comparand2,
) {
  if (comparand1 == null || comparand2 == null) return XPathSequence.empty;
  return XPathSequence.single(comparand1 == comparand2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-concat
const fnConcat = XPathFunctionDefinition(
  name: 'fn:concat',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: xsAny),
    XPathArgumentDefinition(name: 'arg2', type: xsAny),
  ],
  variadicArgument: XPathArgumentDefinition(name: 'args', type: xsAny),
  function: _fnConcat,
);

XPathSequence _fnConcat(
  XPathContext context,
  Object arg1,
  Object arg2, [
  List<Object> args = const [],
]) {
  final result = StringBuffer();
  result.write(xsString.cast(arg1));
  result.write(xsString.cast(arg2));
  for (final arg in args) {
    result.write(xsString.cast(arg));
  }
  return XPathSequence.single(result.toString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-join
const fnStringJoin = XPathFunctionDefinition(
  name: 'fn:string-join',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'separator', type: xsString),
  ],
  function: _fnStringJoin,
);

XPathSequence _fnStringJoin(
  XPathContext context,
  XPathSequence arg, [
  String separator = '',
]) => XPathSequence.single(arg.map(xsString.cast).join(separator));

/// https://www.w3.org/TR/xpath-functions-31/#func-substring
const fnSubstring = XPathFunctionDefinition(
  name: 'fn:substring',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'sourceString',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'startingLoc', type: xsInteger),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'length', type: xsInteger)],
  function: _fnSubstring,
);

XPathSequence _fnSubstring(
  XPathContext context,
  String? sourceString,
  int startingLoc, [
  int? length,
]) {
  if (sourceString == null) return XPathSequence.emptyString;
  final start = startingLoc - 1;
  if (length != null) {
    final end = start + length;
    final s = start < 0 ? 0 : start;
    final e = end > sourceString.length ? sourceString.length : end;
    if (s >= e) return XPathSequence.emptyString;
    return XPathSequence.single(sourceString.substring(s, e));
  }
  final s = start < 0 ? 0 : start;
  if (s >= sourceString.length) return XPathSequence.emptyString;
  return XPathSequence.single(sourceString.substring(s));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-length
const fnStringLength = XPathFunctionDefinition(
  name: 'fn:string-length',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsSequence,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnStringLength,
);

XPathSequence _fnStringLength(XPathContext context, [XPathSequence? arg]) {
  final string = arg != null ? xsString.cast(arg) : xsString.cast(context.item);
  return XPathSequence.single(string.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-space
const fnNormalizeSpace = XPathFunctionDefinition(
  name: 'fn:normalize-space',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnNormalizeSpace,
);

XPathSequence _fnNormalizeSpace(XPathContext context, [Object? arg]) {
  final string = arg != null ? xsString.cast(arg) : xsString.cast(context.item);
  return XPathSequence.single(string.trim().replaceAll(RegExp(r'\s+'), ' '));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-unicode
const fnNormalizeUnicode = XPathFunctionDefinition(
  name: 'fn:normalize-unicode',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'normalizationForm', type: xsString),
  ],
  function: _fnNormalizeUnicode,
);

XPathSequence _fnNormalizeUnicode(
  XPathContext context,
  String? arg, [
  String? normalizationForm,
]) {
  if (arg == null) return XPathSequence.emptyString;
  // TODO: Proper Unicode normalization
  return XPathSequence.single(arg);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-upper-case
const fnUpperCase = XPathFunctionDefinition(
  name: 'fn:upper-case',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnUpperCase,
);

XPathSequence _fnUpperCase(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.emptyString;
  return XPathSequence.single(arg.toUpperCase());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-lower-case
const fnLowerCase = XPathFunctionDefinition(
  name: 'fn:lower-case',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnLowerCase,
);

XPathSequence _fnLowerCase(XPathContext context, String? arg) {
  if (arg == null) return XPathSequence.emptyString;
  return XPathSequence.single(arg.toLowerCase());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-translate
const fnTranslate = XPathFunctionDefinition(
  name: 'fn:translate',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'mapString', type: xsString),
    XPathArgumentDefinition(name: 'transString', type: xsString),
  ],
  function: _fnTranslate,
);

XPathSequence _fnTranslate(
  XPathContext context,
  String? arg,
  String mapString,
  String transString,
) {
  if (arg == null) return XPathSequence.emptyString;
  final map = <int, int?>{};
  final mapRunes = mapString.runes.toList();
  final transRunes = transString.runes.toList();
  for (var i = 0; i < mapRunes.length; i++) {
    if (!map.containsKey(mapRunes[i])) {
      map[mapRunes[i]] = i < transRunes.length ? transRunes[i] : null;
    }
  }
  final result = <int>[];
  for (final rune in arg.runes) {
    if (map.containsKey(rune)) {
      final trans = map[rune];
      if (trans != null) {
        result.add(trans);
      }
    } else {
      result.add(rune);
    }
  }
  return XPathSequence.single(String.fromCharCodes(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains
const fnContains = XPathFunctionDefinition(
  name: 'fn:contains',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnContains,
);

XPathSequence _fnContains(
  XPathContext context,
  String? arg1,
  String? arg2, [
  String? collation,
]) {
  if (arg1 == null) return XPathSequence.falseSequence;
  if (arg2 == null) return XPathSequence.trueSequence;
  return XPathSequence.single(arg1.contains(arg2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-starts-with
const fnStartsWith = XPathFunctionDefinition(
  name: 'fn:starts-with',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnStartsWith,
);

XPathSequence _fnStartsWith(
  XPathContext context,
  String? arg1,
  String? arg2, [
  String? collation,
]) {
  if (arg1 == null) return XPathSequence.falseSequence;
  if (arg2 == null) return XPathSequence.trueSequence;
  return XPathSequence.single(arg1.startsWith(arg2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ends-with
const fnEndsWith = XPathFunctionDefinition(
  name: 'fn:ends-with',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnEndsWith,
);

XPathSequence _fnEndsWith(
  XPathContext context,
  String? arg1,
  String? arg2, [
  String? collation,
]) {
  if (arg1 == null) return XPathSequence.falseSequence;
  if (arg2 == null) return XPathSequence.trueSequence;
  return XPathSequence.single(arg1.endsWith(arg2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-before
const fnSubstringBefore = XPathFunctionDefinition(
  name: 'fn:substring-before',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnSubstringBefore,
);

XPathSequence _fnSubstringBefore(
  XPathContext context,
  String? arg1,
  String? arg2, [
  String? collation,
]) {
  if (arg1 == null || arg2 == null) return XPathSequence.emptyString;
  final index = arg1.indexOf(arg2);
  if (index == -1) return XPathSequence.emptyString;
  return XPathSequence.single(arg1.substring(0, index));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-after
const fnSubstringAfter = XPathFunctionDefinition(
  name: 'fn:substring-after',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnSubstringAfter,
);

XPathSequence _fnSubstringAfter(
  XPathContext context,
  String? arg1,
  String? arg2, [
  String? collation,
]) {
  if (arg1 == null || arg2 == null) return XPathSequence.emptyString;
  final index = arg1.indexOf(arg2);
  if (index == -1) return XPathSequence.emptyString;
  return XPathSequence.single(arg1.substring(index + arg2.length));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-matches
const fnMatches = XPathFunctionDefinition(
  name: 'fn:matches',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'pattern', type: xsString),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'flags', type: xsString)],
  function: _fnMatches,
);

XPathSequence _fnMatches(
  XPathContext context,
  String? input,
  String pattern, [
  String? flags,
]) {
  if (input == null) return XPathSequence.falseSequence;
  // TODO: Proper XPath regex flags
  final regex = RegExp(pattern);
  return XPathSequence.single(regex.hasMatch(input));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
const fnReplace = XPathFunctionDefinition(
  name: 'fn:replace',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'pattern', type: xsString),
    XPathArgumentDefinition(name: 'replacement', type: xsString),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'flags', type: xsString)],
  function: _fnReplace,
);

XPathSequence _fnReplace(
  XPathContext context,
  String? input,
  String pattern,
  String replacement, [
  String? flags,
]) {
  if (input == null) return XPathSequence.emptyString;
  // TODO: Proper XPath regex flags and replacement references ($1, etc.)
  final regex = RegExp(pattern);
  return XPathSequence.single(input.replaceAll(regex, replacement));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tokenize
const fnTokenize = XPathFunctionDefinition(
  name: 'fn:tokenize',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'pattern', type: xsString),
    XPathArgumentDefinition(name: 'flags', type: xsString),
  ],
  function: _fnTokenize,
);

XPathSequence _fnTokenize(
  XPathContext context,
  String? input, [
  String? pattern,
  String? flags,
]) {
  if (input == null) return XPathSequence.empty;
  if (pattern == null) {
    return XPathSequence(input.trim().split(RegExp(r'\s+')));
  }
  // TODO: Proper XPath regex flags
  final regex = RegExp(pattern);
  return XPathSequence(input.split(regex));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-analyze-string
const fnAnalyzeString = XPathFunctionDefinition(
  name: 'fn:analyze-string',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'pattern', type: xsString),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'flags', type: xsString)],
  function: _fnAnalyzeString,
);

// TODO: Implement analyze-string according to spec
XPathSequence _fnAnalyzeString(
  XPathContext context,
  String? input,
  String pattern, [
  String? flags,
]) {
  if (input == null) return XPathSequence.empty;
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collation-key
const fnCollationKey = XPathFunctionDefinition(
  name: 'fn:collation-key',
  requiredArguments: [
    XPathArgumentDefinition(name: 'relative', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnCollationKey,
);

// TODO: Proper collation key generation
XPathSequence _fnCollationKey(
  XPathContext context,
  String relative, [
  String? collation,
]) => XPathSequence.single(relative);

/// https://www.w3.org/TR/xpath-functions-31/#func-contains-token
const fnContainsToken = XPathFunctionDefinition(
  name: 'fn:contains-token',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'token', type: xsString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'collation', type: xsString),
  ],
  function: _fnContainsToken,
);

XPathSequence _fnContainsToken(
  XPathContext context,
  String? input,
  String token, [
  String? collation,
]) {
  if (input == null) return XPathSequence.falseSequence;
  final tokens = input.trim().split(RegExp(r'\s+'));
  return XPathSequence.single(tokens.contains(token.trim()));
}
