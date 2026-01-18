import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-concat
/// Special case: accepts 2+ arguments, requires rest parameter
const fnConcat = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'concat',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  variadicArgument: XPathArgumentDefinition(
    name: 'arg',
    type: XPathSequence,
    cardinality: XPathArgumentCardinality.zeroOrOne,
  ),
  function: _fnConcat,
);

XPathSequence _fnConcat(
  XPathContext context,
  XPathSequence? arg1,
  XPathSequence? arg2,
  List<dynamic> rest,
) {
  final buffer = StringBuffer();
  if (arg1 != null) buffer.write(arg1.toXPathString());
  if (arg2 != null) buffer.write(arg2.toXPathString());
  for (final item in rest) {
    if (item != null) buffer.write((item as XPathSequence).toXPathString());
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-join
const fnStringJoin = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'string-join',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'separator',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnStringJoin,
);

XPathSequence _fnStringJoin(
  XPathContext context,
  XPathSequence input, [
  XPathString? separator,
]) {
  final sep = separator ?? '';
  final result = input.map((item) => item.toXPathString()).join(sep);
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring
const fnSubstring = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'substring',
  requiredArguments: [
    XPathArgumentDefinition(name: 'sourceString', type: XPathString),
    XPathArgumentDefinition(name: 'start', type: XPathNumber),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'length', type: XPathNumber),
  ],
  function: _fnSubstring,
);

XPathSequence _fnSubstring(
  XPathContext context,
  XPathString sourceString,
  XPathNumber start, [
  XPathNumber? length,
]) {
  final str = sourceString;
  final s = start.toDouble();
  if (!s.isFinite) return const XPathSequence.single(XPathString.empty);
  final startIdx = s.round() - 1;
  final len = length?.toDouble() ?? double.infinity;
  if (len.isNaN || len <= 0) {
    return const XPathSequence.single(XPathString.empty);
  }
  final endIdx = len.isFinite ? startIdx + len.round() : str.length;
  final i = startIdx.clamp(0, str.length);
  final j = endIdx.clamp(i, str.length);
  return XPathSequence.single(XPathString(str.substring(i, j)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-length
const fnStringLength = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'string-length',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnStringLength,
);

XPathSequence _fnStringLength(XPathContext context, [Object? arg = _missing]) {
  if (identical(arg, _missing)) {
    return XPathSequence.single(context.value.toXPathString().length);
  }
  final value = arg == null ? XPathString.empty : arg as XPathString;
  return XPathSequence.single(value.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-space
const fnNormalizeSpace = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'normalize-space',
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnNormalizeSpace,
);

XPathSequence _fnNormalizeSpace(
  XPathContext context, [
  Object? arg = _missing,
]) {
  if (identical(arg, _missing)) {
    final value = context.value.toXPathString();
    final result = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    return XPathSequence.single(XPathString(result));
  }
  final value = arg == null ? XPathString.empty : arg as XPathString;
  final result = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-upper-case
const fnUpperCase = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'upper-case',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnUpperCase,
);

XPathSequence _fnUpperCase(XPathContext context, XPathString? arg) {
  final value = arg ?? XPathString.empty;
  return XPathSequence.single(XPathString(value.toUpperCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-lower-case
const fnLowerCase = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'lower-case',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnLowerCase,
);

XPathSequence _fnLowerCase(XPathContext context, XPathString? arg) {
  final value = arg ?? XPathString.empty;
  return XPathSequence.single(XPathString(value.toLowerCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains
const fnContains = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'contains',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnContains,
);

XPathSequence _fnContains(
  XPathContext context,
  XPathString? arg1,
  XPathString? arg2, [
  XPathString? collation,
]) {
  // TODO: Handle collation
  final s1 = arg1 ?? XPathString.empty;
  final s2 = arg2 ?? XPathString.empty;
  return XPathSequence.single(s1.contains(s2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-starts-with
const fnStartsWith = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'starts-with',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnStartsWith,
);

XPathSequence _fnStartsWith(
  XPathContext context,
  XPathString? arg1,
  XPathString? arg2, [
  XPathString? collation,
]) {
  // TODO: Handle collation
  final s1 = arg1 ?? XPathString.empty;
  final s2 = arg2 ?? XPathString.empty;
  return XPathSequence.single(s1.startsWith(s2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ends-with
const fnEndsWith = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'ends-with',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnEndsWith,
);

XPathSequence _fnEndsWith(
  XPathContext context,
  XPathString? arg1,
  XPathString? arg2, [
  XPathString? collation,
]) {
  // TODO: Handle collation
  final s1 = arg1 ?? XPathString.empty;
  final s2 = arg2 ?? XPathString.empty;
  return XPathSequence.single(s1.endsWith(s2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-before
const fnSubstringBefore = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'substring-before',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSubstringBefore,
);

XPathSequence _fnSubstringBefore(
  XPathContext context,
  XPathString? arg1,
  XPathString? arg2, [
  XPathString? collation,
]) {
  final s1 = arg1 ?? XPathString.empty;
  final s2 = arg2 ?? XPathString.empty;
  // TODO: Handle collation parameter
  final index = s1.indexOf(s2);
  return XPathSequence.single(
    XPathString(index >= 0 ? s1.substring(0, index) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-after
const fnSubstringAfter = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'substring-after',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'arg2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnSubstringAfter,
);

XPathSequence _fnSubstringAfter(
  XPathContext context,
  XPathString? arg1,
  XPathString? arg2, [
  XPathString? collation,
]) {
  final s1 = arg1 ?? XPathString.empty;
  final s2 = arg2 ?? XPathString.empty;
  // TODO: Handle collation parameter
  if (s2.isEmpty) return XPathSequence.single(XPathString(s1));
  final index = s1.indexOf(s2);
  return XPathSequence.single(
    XPathString(index >= 0 ? s1.substring(index + s2.length) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-translate
const fnTranslate = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'translate',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'mapString', type: XPathString),
    XPathArgumentDefinition(name: 'transString', type: XPathString),
  ],
  function: _fnTranslate,
);

XPathSequence _fnTranslate(
  XPathContext context,
  XPathString? arg,
  XPathString mapString,
  XPathString transString,
) {
  final s = arg ?? XPathString.empty;
  final mapStr = mapString;
  final transStr = transString;
  final mapping = <String, String>{};
  for (var i = 0; i < mapStr.length; i++) {
    final char = mapStr[i];
    if (!mapping.containsKey(char)) {
      mapping[char] = i < transStr.length ? transStr[i] : '';
    }
  }
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final char = s[i];
    buffer.write(mapping[char] ?? char);
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-matches
const fnMatches = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'matches',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'pattern', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'flags',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnMatches,
);

XPathSequence _fnMatches(
  XPathContext context,
  XPathString? input,
  XPathString pattern, [
  XPathString? flags,
]) {
  final i = input ?? XPathString.empty;
  final regExp = _createRegExp(pattern.toString(), flags?.toString() ?? '');
  return XPathSequence.single(i.contains(regExp));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
const fnReplace = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'replace',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'pattern', type: XPathString),
    XPathArgumentDefinition(name: 'replacement', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'flags',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnReplace,
);

XPathSequence _fnReplace(
  XPathContext context,
  XPathString? input,
  XPathString pattern,
  XPathString replacement, [
  XPathString? flags,
]) {
  final i = input ?? XPathString.empty;
  final regExp = _createRegExp(pattern.toString(), flags?.toString() ?? '');
  return XPathSequence.single(
    XPathString(i.replaceAll(regExp, replacement.toString())),
  );
}

const _missing = Object();

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoints-to-string
const fnCodepointsToString = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'codepoints-to-string',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
    ),
  ],
  function: _fnCodepointsToString,
);

XPathSequence _fnCodepointsToString(XPathContext context, XPathSequence arg) {
  try {
    return XPathSequence.single(
      XPathString(
        String.fromCharCodes(arg.map((item) => item.toXPathNumber().toInt())),
      ),
    );
  } catch (e) {
    throw XPathEvaluationException('Invalid codepoint: $e');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-to-codepoints
const fnStringToCodepoints = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'string-to-codepoints',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnStringToCodepoints,
);

XPathSequence _fnStringToCodepoints(XPathContext context, XPathString? arg) {
  final value = arg ?? XPathString.empty;
  return XPathSequence(value.runes);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-compare
const fnCompare = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'compare',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'comparand1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'comparand2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnCompare,
);

XPathSequence _fnCompare(
  XPathContext context,
  XPathString? comparand1,
  XPathString? comparand2, [
  XPathString? collation,
]) {
  final c1 = comparand1 ?? XPathString.empty;
  final c2 = comparand2 ?? XPathString.empty;
  // TODO: Handle collation parameter
  return XPathSequence.single(c1.compareTo(c2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoint-equal
const fnCodepointEqual = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'codepoint-equal',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'comparand1',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(
      name: 'comparand2',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnCodepointEqual,
);

XPathSequence _fnCodepointEqual(
  XPathContext context,
  XPathString? comparand1,
  XPathString? comparand2,
) {
  if (comparand1 == null || comparand2 == null) return XPathSequence.empty;
  return XPathSequence.single(comparand1 == comparand2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collation-key
const fnCollationKey = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'collation-key',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'key',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnCollationKey,
);

XPathSequence _fnCollationKey(
  XPathContext context,
  XPathString? key, [
  XPathString? collation,
]) {
  final k = key ?? XPathString.empty;
  // TODO: Handle collation parameter
  return XPathSequence.single(
    XPathString(String.fromCharCodes(k.runes)), // Identity for now
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains-token
const fnContainsToken = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'contains-token',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
    XPathArgumentDefinition(name: 'token', type: XPathString),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'collation',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnContainsToken,
);

XPathSequence _fnContainsToken(
  XPathContext context,
  XPathString? input,
  XPathString token, [
  XPathString? collation,
]) {
  final i = input ?? XPathString.empty;
  // TODO: Handle collation parameter
  final tokens = i.trim().split(RegExp(r'\s+'));
  return XPathSequence.single(tokens.contains(token.trim()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-unicode
const fnNormalizeUnicode = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'normalize-unicode',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'normalizationForm',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnNormalizeUnicode,
);

XPathSequence _fnNormalizeUnicode(
  XPathContext context,
  XPathString? arg, [
  XPathString? normalizationForm,
]) {
  final a = arg ?? XPathString.empty;
  // Dart doesn't support normalization directly in core.
  return XPathSequence.single(XPathString(a));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tokenize
const fnTokenize = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'tokenize',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'pattern', type: XPathString),
    XPathArgumentDefinition(
      name: 'flags',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  function: _fnTokenize,
);

XPathSequence _fnTokenize(
  XPathContext context,
  XPathString? input, [
  XPathString? pattern,
  XPathString? flags,
]) {
  final i = input ?? XPathString.empty;
  if (pattern == null) {
    return XPathSequence(i.trim().split(RegExp(r'\s+')).map(XPathString.new));
  }
  final regExp = _createRegExp(pattern.toString(), flags?.toString() ?? '');
  return XPathSequence(i.split(regExp).map(XPathString.new));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-analyze-string
const fnAnalyzeString = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'analyze-string',
  function: _fnAnalyzeString,
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'pattern', type: XPathString),
    XPathArgumentDefinition(
      name: 'flags',
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
);

XPathSequence _fnAnalyzeString(
  XPathContext context,
  String input, [
  String? pattern,
  String? flags,
]) => throw UnimplementedError('fn:analyze-string');

RegExp _createRegExp(String pattern, String flags) {
  var isMultiLine = false;
  var isCaseInsensitive = false;
  var isDotAll = false;
  var isUnicode = false;
  for (var i = 0; i < flags.length; i++) {
    switch (flags[i]) {
      case 'm':
        isMultiLine = true;
      case 'i':
        isCaseInsensitive = true;
      case 's':
        isDotAll = true;
      case 'x':
        // TODO: Implement extended whitespace ignoring if possible
        break;
      case 'q':
        return RegExp(RegExp.escape(pattern));
      case 'u':
        // XPath 3.1 doesn't have 'u', but assumes Unicode.
        isUnicode = true;
      default:
        throw XPathEvaluationException(
          'Invalid regular expression flag: ${flags[i]}',
        );
    }
  }
  return RegExp(
    pattern,
    multiLine: isMultiLine,
    caseSensitive: !isCaseInsensitive,
    dotAll: isDotAll,
    unicode: isUnicode,
  );
}
