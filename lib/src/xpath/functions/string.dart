import 'package:petitparser/petitparser.dart' show unbounded;
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/number.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-concat
/// Special case: accepts 2+ arguments, requires rest parameter
XPathSequence fnConcat(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(
    'fn:concat',
    arguments,
    2,
    unbounded,
  );
  final buffer = StringBuffer();
  for (var i = 0; i < arguments.length; i++) {
    final item = XPathEvaluationException.extractZeroOrOne(
      'fn:concat',
      'arg${i + 1}',
      arguments[i],
    )?.toXPathString();
    if (item != null) buffer.write(item);
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-join
XPathSequence fnStringJoin(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:string-join',
    arguments,
    1,
    2,
  );
  final input = arguments[0];
  final separator = arguments.length > 1
      ? XPathEvaluationException.extractExactlyOne(
          'fn:string-join',
          'separator',
          arguments[1],
        ).toXPathString()
      : '';
  final result = input.map((item) => item.toXPathString()).join(separator);
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring
XPathSequence fnSubstring(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:substring', arguments, 2, 3);
  final sourceString =
      XPathEvaluationException.extractZeroOrOne(
        'fn:substring',
        'sourceString',
        arguments[0],
      )?.toXPathString() ??
      '';
  final start = XPathEvaluationException.extractExactlyOne(
    'fn:substring',
    'start',
    arguments[1],
  ).toXPathNumber().toDouble();
  if (!start.isFinite) return const XPathSequence.single(XPathString.empty);
  final startIdx = start.round() - 1;
  final length = arguments.length > 2
      ? XPathEvaluationException.extractExactlyOne(
          'fn:substring',
          'length',
          arguments[2],
        ).toXPathNumber().toDouble()
      : double.infinity;
  if (length.isNaN || length <= 0) {
    return const XPathSequence.single(XPathString.empty);
  }
  final endIdx = length.isFinite
      ? startIdx + length.round()
      : sourceString.length;
  final i = startIdx.clamp(0, sourceString.length);
  final j = endIdx.clamp(i, sourceString.length);
  return XPathSequence.single(XPathString(sourceString.substring(i, j)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-length
XPathSequence fnStringLength(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:string-length',
    arguments,
    0,
    1,
  );
  final value = arguments.isEmpty
      ? context.value.toXPathString()
      : (XPathEvaluationException.extractZeroOrOne(
              'fn:string-length',
              'arg',
              arguments[0],
            )?.toXPathString() ??
            '');
  return XPathSequence.single(value.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-space
XPathSequence fnNormalizeSpace(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:normalize-space',
    arguments,
    0,
    1,
  );
  final value = arguments.isEmpty
      ? context.value.toXPathString()
      : (XPathEvaluationException.extractZeroOrOne(
              'fn:normalize-space',
              'arg',
              arguments[0],
            )?.toXPathString() ??
            '');
  final result = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-upper-case
XPathSequence fnUpperCase(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:upper-case', arguments, 1);
  final arg =
      XPathEvaluationException.extractZeroOrOne(
        'fn:upper-case',
        'arg',
        arguments[0],
      )?.toXPathString() ??
      '';
  return XPathSequence.single(XPathString(arg.toUpperCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-lower-case
XPathSequence fnLowerCase(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:lower-case', arguments, 1);
  final arg =
      XPathEvaluationException.extractZeroOrOne(
        'fn:lower-case',
        'arg',
        arguments[0],
      )?.toXPathString() ??
      '';
  return XPathSequence.single(XPathString(arg.toLowerCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains
XPathSequence fnContains(XPathContext context, List<XPathSequence> arguments) =>
    _stringPredicate(
      'fn:contains',
      arguments,
      (arg1, arg2) => arg1.contains(arg2),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-starts-with
XPathSequence fnStartsWith(
  XPathContext context,
  List<XPathSequence> arguments,
) => _stringPredicate(
  'fn:starts-with',
  arguments,
  (arg1, arg2) => arg1.startsWith(arg2),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-ends-with
XPathSequence fnEndsWith(XPathContext context, List<XPathSequence> arguments) =>
    _stringPredicate(
      'fn:ends-with',
      arguments,
      (arg1, arg2) => arg1.endsWith(arg2),
    );

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-before
XPathSequence fnSubstringBefore(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:substring-before',
    arguments,
    2,
    3,
  );
  final arg1 =
      XPathEvaluationException.extractZeroOrOne(
        'fn:substring-before',
        'arg1',
        arguments[0],
      )?.toXPathString() ??
      '';
  final arg2 =
      XPathEvaluationException.extractZeroOrOne(
        'fn:substring-before',
        'arg2',
        arguments[1],
      )?.toXPathString() ??
      '';
  // TODO: Handle collation parameter
  final index = arg1.indexOf(arg2);
  return XPathSequence.single(
    XPathString(index >= 0 ? arg1.substring(0, index) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-after
XPathSequence fnSubstringAfter(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:substring-after',
    arguments,
    2,
    3,
  );
  final arg1 =
      XPathEvaluationException.extractZeroOrOne(
        'fn:substring-after',
        'arg1',
        arguments[0],
      )?.toXPathString() ??
      '';
  final arg2 =
      XPathEvaluationException.extractZeroOrOne(
        'fn:substring-after',
        'arg2',
        arguments[1],
      )?.toXPathString() ??
      '';
  // TODO: Handle collation parameter
  if (arg2.isEmpty) return XPathSequence.single(XPathString(arg1));
  final index = arg1.indexOf(arg2);
  return XPathSequence.single(
    XPathString(index >= 0 ? arg1.substring(index + arg2.length) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-translate
XPathSequence fnTranslate(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:translate', arguments, 3);
  final arg =
      XPathEvaluationException.extractZeroOrOne(
        'fn:translate',
        'arg',
        arguments[0],
      )?.toXPathString() ??
      '';
  final mapStr = XPathEvaluationException.extractExactlyOne(
    'fn:translate',
    'mapString',
    arguments[1],
  ).toXPathString();
  final transStr = XPathEvaluationException.extractExactlyOne(
    'fn:translate',
    'transString',
    arguments[2],
  ).toXPathString();
  final mapping = <String, String>{};
  for (var i = 0; i < mapStr.length; i++) {
    final char = mapStr[i];
    if (!mapping.containsKey(char)) {
      mapping[char] = i < transStr.length ? transStr[i] : '';
    }
  }
  final buffer = StringBuffer();
  for (var i = 0; i < arg.length; i++) {
    final char = arg[i];
    buffer.write(mapping[char] ?? char);
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-matches
XPathSequence fnMatches(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:matches', arguments, 2, 3);
  final input =
      XPathEvaluationException.extractZeroOrOne(
        'fn:matches',
        'input',
        arguments[0],
      )?.toXPathString() ??
      '';
  final pattern = XPathEvaluationException.extractExactlyOne(
    'fn:matches',
    'pattern',
    arguments[1],
  ).toXPathString();
  final flags = arguments.length > 2
      ? XPathEvaluationException.extractExactlyOne(
          'fn:matches',
          'flags',
          arguments[2],
        ).toXPathString()
      : '';
  final regExp = _createRegExp(pattern, flags);
  return XPathSequence.single(input.contains(regExp));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
XPathSequence fnReplace(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:replace', arguments, 3, 4);
  final input =
      XPathEvaluationException.extractZeroOrOne(
        'fn:replace',
        'input',
        arguments[0],
      )?.toXPathString() ??
      '';
  final pattern = XPathEvaluationException.extractExactlyOne(
    'fn:replace',
    'pattern',
    arguments[1],
  ).toXPathString();
  final replacement = XPathEvaluationException.extractExactlyOne(
    'fn:replace',
    'replacement',
    arguments[2],
  ).toXPathString();
  final flags = arguments.length > 3
      ? XPathEvaluationException.extractExactlyOne(
          'fn:replace',
          'flags',
          arguments[3],
        ).toXPathString()
      : '';
  final regExp = _createRegExp(pattern, flags);
  return XPathSequence.single(
    XPathString(input.replaceAll(regExp, replacement)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoints-to-string
XPathSequence fnCodepointsToString(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:codepoints-to-string',
    arguments,
    1,
  );
  final arg = arguments[0];
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
XPathSequence fnStringToCodepoints(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:string-to-codepoints',
    arguments,
    1,
  );
  final arg =
      XPathEvaluationException.extractZeroOrOne(
        'fn:string-to-codepoints',
        'arg',
        arguments[0],
      )?.toXPathString() ??
      '';
  return XPathSequence(arg.runes);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-compare
XPathSequence fnCompare(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:compare', arguments, 2, 3);
  final comparand1 =
      XPathEvaluationException.extractZeroOrOne(
        'fn:compare',
        'comparand1',
        arguments[0],
      )?.toXPathString() ??
      '';
  final comparand2 =
      XPathEvaluationException.extractZeroOrOne(
        'fn:compare',
        'comparand2',
        arguments[1],
      )?.toXPathString() ??
      '';
  // TODO: Handle collation parameter
  return XPathSequence.single(comparand1.compareTo(comparand2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoint-equal
XPathSequence fnCodepointEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:codepoint-equal',
    arguments,
    2,
  );
  final comparand1 = XPathEvaluationException.extractZeroOrOne(
    'fn:codepoint-equal',
    'comparand1',
    arguments[0],
  )?.toXPathString();
  final comparand2 = XPathEvaluationException.extractZeroOrOne(
    'fn:codepoint-equal',
    'comparand2',
    arguments[1],
  )?.toXPathString();
  if (comparand1 == null || comparand2 == null) return XPathSequence.empty;
  return XPathSequence.single(comparand1 == comparand2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collation-key
XPathSequence fnCollationKey(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:collation-key',
    arguments,
    1,
    2,
  );
  // Basic implementation: return codepoints as key.
  // In a real implementation, this would depend on the collation.
  final key =
      XPathEvaluationException.extractZeroOrOne(
        'fn:collation-key',
        'key',
        arguments[0],
      )?.toXPathString() ??
      '';
  // TODO: Handle collation parameter
  return XPathSequence.single(
    XPathString(String.fromCharCodes(key.runes)), // Identity for now
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains-token
XPathSequence fnContainsToken(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:contains-token',
    arguments,
    2,
    3,
  );
  final input =
      XPathEvaluationException.extractZeroOrOne(
        'fn:contains-token',
        'input',
        arguments[0],
      )?.toXPathString() ??
      '';
  final token = XPathEvaluationException.extractExactlyOne(
    'fn:contains-token',
    'token',
    arguments[1],
  ).toXPathString();
  // TODO: Handle collation parameter
  final tokens = input.trim().split(RegExp(r'\s+'));
  return XPathSequence.single(tokens.contains(token.trim()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-unicode
XPathSequence fnNormalizeUnicode(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:normalize-unicode',
    arguments,
    1,
    2,
  );
  final arg =
      XPathEvaluationException.extractZeroOrOne(
        'fn:normalize-unicode',
        'arg',
        arguments[0],
      )?.toXPathString() ??
      '';
  // Dart doesn't support normalization directly in core.
  return XPathSequence.single(XPathString(arg));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tokenize
XPathSequence fnTokenize(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:tokenize', arguments, 1, 3);
  final input =
      XPathEvaluationException.extractZeroOrOne(
        'fn:tokenize',
        'input',
        arguments[0],
      )?.toXPathString() ??
      '';
  if (arguments.length < 2) {
    return XPathSequence(
      input.trim().split(RegExp(r'\s+')).map(XPathString.new),
    );
  }
  final pattern = XPathEvaluationException.extractExactlyOne(
    'fn:tokenize',
    'pattern',
    arguments[1],
  ).toXPathString();
  final flags = arguments.length > 2
      ? XPathEvaluationException.extractExactlyOne(
          'fn:tokenize',
          'flags',
          arguments[2],
        ).toXPathString()
      : '';
  final regExp = _createRegExp(pattern, flags);
  return XPathSequence(input.split(regExp).map(XPathString.new));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-analyze-string
XPathSequence fnAnalyzeString(
  XPathContext context,
  List<XPathSequence> arguments,
) => throw UnimplementedError('fn:analyze-string');
XPathSequence _stringPredicate(
  String name,
  List<XPathSequence> arguments,
  bool Function(String, String) predicate,
) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2, 3);
  final arg1 =
      XPathEvaluationException.extractZeroOrOne(
        name,
        'arg1',
        arguments[0],
      )?.toXPathString() ??
      '';
  final arg2 =
      XPathEvaluationException.extractZeroOrOne(
        name,
        'arg2',
        arguments[1],
      )?.toXPathString() ??
      '';
  // TODO: Handle collation parameter
  return XPathSequence.single(predicate(arg1, arg2));
}

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
