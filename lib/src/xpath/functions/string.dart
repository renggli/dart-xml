import '../../xml/utils/cache.dart';
import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoints-to-string
final fnCodepointsToString = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:codepoints-to-string'),
  (context, arg) {
    final string = String.fromCharCodes(
      arg.atomize().map((item) {
        final codepoint = (item as XPathInteger).asInt;
        return _isValidXmlChar(codepoint)
            ? codepoint
            : throw XPathEvaluationException(
                XPathErrorCode.FOCH0001,
                'Invalid character code: $codepoint',
              );
      }),
    );
    return XPathSequence.single(XPathString(string));
  },
);

bool _isValidXmlChar(int codepoint) =>
    codepoint == 0x9 ||
    codepoint == 0xA ||
    codepoint == 0xD ||
    (codepoint >= 0x20 && codepoint <= 0xD7FF) ||
    (codepoint >= 0xE000 && codepoint <= 0xFFFD) ||
    (codepoint >= 0x10000 && codepoint <= 0x10FFFF);

String? _asString(XPathItem? item) => item?.stringValue;

/// https://www.w3.org/TR/xpath-functions-31/#func-string-to-codepoints
final fnStringToCodepoints = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:string-to-codepoints'),
  (context, arg) {
    final str = _asString(arg.atomize().firstOrNull);
    if (str == null) return XPathSequence.empty;
    return XPathSequence(str.runes.map(XPathInteger.fromInt));
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-compare
final fnCompare = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:compare'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:compare'),
      (context, c1, c2) => _evalCompare(
        _asString(c1.atomize().firstOrNull),
        _asString(c2.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:compare'),
      (context, c1, c2, col) => _evalCompare(
        _asString(c1.atomize().firstOrNull),
        _asString(c2.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalCompare(String? comparand1, String? comparand2) {
  if (comparand1 == null || comparand2 == null) return XPathSequence.empty;
  return XPathSequence.single(
    XPathInteger.fromInt(comparand1.compareTo(comparand2)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoint-equal
final fnCodepointEqual = XPathFunctionItem.fn2(
  const XmlName.qualified('fn:codepoint-equal'),
  (context, c1, c2) {
    final comparand1 = _asString(c1.atomize().firstOrNull);
    final comparand2 = _asString(c2.atomize().firstOrNull);
    if (comparand1 == null || comparand2 == null) return XPathSequence.empty;
    return XPathSequence.single(
      XPathBoolean.fromBool(comparand1 == comparand2),
    );
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-concat
final fnConcat = XPathFunctionItem.variadic(
  const XmlName.qualified('fn:concat'),
  2,
  (context, args) {
    final result = StringBuffer();
    for (final arg in args) {
      final item = arg.atomize().firstOrNull;
      if (item != null) result.write(item.stringValue);
    }
    return XPathSequence.single(XPathString(result.toString()));
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-string-join
final fnStringJoin = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:string-join'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:string-join'),
      (context, arg) => XPathSequence.single(
        XPathString(arg.atomize().map((i) => i.stringValue).join('')),
      ),
    ),
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:string-join'), (
      context,
      arg,
      sep,
    ) {
      final separator = sep.atomize().firstOrNull?.stringValue ?? '';
      return XPathSequence.single(
        XPathString(arg.atomize().map((i) => i.stringValue).join(separator)),
      );
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-substring
final fnSubstring = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:substring'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:substring'),
      (context, str, start) => _evalSubstring(
        _asString(str.atomize().firstOrNull),
        start.atomize().firstOrNull as XPathNumeric?,
        null,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:substring'),
      (context, str, start, len) => _evalSubstring(
        _asString(str.atomize().firstOrNull),
        start.atomize().firstOrNull as XPathNumeric?,
        len.atomize().firstOrNull as XPathNumeric?,
      ),
    ),
  },
);

XPathSequence _evalSubstring(
  String? sourceString,
  XPathNumeric? startingLoc,
  XPathNumeric? length,
) {
  if (sourceString == null || startingLoc == null) {
    return const XPathSequence.single(XPathString.empty);
  }
  final startVal = startingLoc.toDouble();
  final lenVal = length?.toDouble();
  if (startVal.isNaN) return const XPathSequence.single(XPathString.empty);
  if (lenVal != null && lenVal.isNaN) {
    return const XPathSequence.single(XPathString.empty);
  }

  if (startVal.isInfinite) return const XPathSequence.single(XPathString.empty);
  final start = startVal.round();
  final end = (lenVal != null && lenVal.isFinite)
      ? start + lenVal.round()
      : double.infinity;

  var s = start - 1;
  final str = sourceString;
  var e = (lenVal != null && lenVal.isFinite) ? end.round() - 1 : str.length;

  if (s < 0) s = 0;
  if (e > str.length) e = str.length;
  if (s >= e) return const XPathSequence.single(XPathString.empty);

  return XPathSequence.single(XPathString(str.substring(s, e)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-length
final fnStringLength = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:string-length'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:string-length'),
      (context) => XPathSequence.single(
        XPathInteger.fromInt(
          (context.item as XPathItem).stringValue.runes.length,
        ),
      ),
    ),
    1: XPathFunctionItem.fn1(const XmlName.qualified('fn:string-length'), (
      context,
      arg,
    ) {
      final str = _asString(arg.atomize().firstOrNull);
      if (str == null) return XPathSequence.single(XPathInteger.fromInt(0));
      return XPathSequence.single(XPathInteger.fromInt(str.runes.length));
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-space
final fnNormalizeSpace = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:normalize-space'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:normalize-space'),
      (context) => _evalNormalizeSpace((context.item as XPathItem).stringValue),
    ),
    1: XPathFunctionItem.fn1(const XmlName.qualified('fn:normalize-space'), (
      context,
      arg,
    ) {
      final item = arg.atomize().firstOrNull;
      return _evalNormalizeSpace(item?.stringValue ?? '');
    }),
  },
);

XPathSequence _evalNormalizeSpace(String str) => XPathSequence.single(
  XPathString(str.trim().replaceAll(_whitespaceRegExp, ' ')),
);

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-unicode
final fnNormalizeUnicode = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:normalize-unicode'),
  {
    1: XPathFunctionItem.fn1(const XmlName.qualified('fn:normalize-unicode'), (
      context,
      arg,
    ) {
      final item = arg.atomize().firstOrNull;
      if (item == null) return const XPathSequence.single(XPathString.empty);
      return XPathSequence.single(item);
    }),
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:normalize-unicode'), (
      context,
      arg,
      form,
    ) {
      final item = arg.atomize().firstOrNull;
      if (item == null) return const XPathSequence.single(XPathString.empty);
      return XPathSequence.single(item);
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-upper-case
final fnUpperCase = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:upper-case'),
  (context, arg) {
    final str = _asString(arg.atomize().firstOrNull);
    if (str == null) return const XPathSequence.single(XPathString.empty);
    return XPathSequence.single(XPathString(str.toUpperCase()));
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-lower-case
final fnLowerCase = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:lower-case'),
  (context, arg) {
    final str = _asString(arg.atomize().firstOrNull);
    if (str == null) return const XPathSequence.single(XPathString.empty);
    return XPathSequence.single(XPathString(str.toLowerCase()));
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-translate
final fnTranslate = XPathFunctionItem.fn3(
  const XmlName.qualified('fn:translate'),
  (context, argSeq, mapSeq, transSeq) {
    final arg = _asString(argSeq.atomize().firstOrNull);
    final mapString = _asString(mapSeq.atomize().firstOrNull);
    final transString = _asString(transSeq.atomize().firstOrNull);
    if (arg == null) return const XPathSequence.single(XPathString.empty);
    if (mapString == null || transString == null) {
      return XPathSequence.single(XPathString(arg));
    }
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
    return XPathSequence.single(XPathString(String.fromCharCodes(result)));
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-contains
final fnContains = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:contains'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:contains'),
      (context, a1, a2) => _evalContains(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:contains'),
      (context, a1, a2, col) => _evalContains(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalContains(String? arg1, String? arg2) {
  if (arg1 == null) return XPathSequence.falseSequence;
  if (arg2 == null) return XPathSequence.trueSequence;
  return arg1.contains(arg2)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-starts-with
final fnStartsWith = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:starts-with'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:starts-with'),
      (context, a1, a2) => _evalStartsWith(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:starts-with'),
      (context, a1, a2, col) => _evalStartsWith(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalStartsWith(String? arg1, String? arg2) {
  if (arg1 == null) return XPathSequence.falseSequence;
  if (arg2 == null) return XPathSequence.trueSequence;
  return arg1.startsWith(arg2)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ends-with
final fnEndsWith = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:ends-with'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:ends-with'),
      (context, a1, a2) => _evalEndsWith(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:ends-with'),
      (context, a1, a2, col) => _evalEndsWith(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalEndsWith(String? arg1, String? arg2) {
  if (arg1 == null) return XPathSequence.falseSequence;
  if (arg2 == null) return XPathSequence.trueSequence;
  return arg1.endsWith(arg2)
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-before
final fnSubstringBefore = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:substring-before'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:substring-before'),
      (context, a1, a2) => _evalSubstringBefore(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:substring-before'),
      (context, a1, a2, col) => _evalSubstringBefore(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalSubstringBefore(String? arg1, String? arg2) {
  if (arg1 == null || arg2 == null) {
    return const XPathSequence.single(XPathString.empty);
  }
  final index = arg1.indexOf(arg2);
  if (index == -1) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(arg1.substring(0, index)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-after
final fnSubstringAfter = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:substring-after'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:substring-after'),
      (context, a1, a2) => _evalSubstringAfter(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:substring-after'),
      (context, a1, a2, col) => _evalSubstringAfter(
        _asString(a1.atomize().firstOrNull),
        _asString(a2.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalSubstringAfter(String? arg1, String? arg2) {
  if (arg1 == null || arg2 == null) {
    return const XPathSequence.single(XPathString.empty);
  }
  final index = arg1.indexOf(arg2);
  if (index == -1) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(arg1.substring(index + arg2.length)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-matches
final fnMatches = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:matches'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:matches'),
      (context, input, pattern) => _evalMatches(
        _asString(input.atomize().firstOrNull),
        _asString(pattern.atomize().firstOrNull),
        null,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:matches'),
      (context, input, pattern, flags) => _evalMatches(
        _asString(input.atomize().firstOrNull),
        _asString(pattern.atomize().firstOrNull),
        _asString(flags.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalMatches(String? input, String? pattern, String? flags) {
  if (input == null || pattern == null) return XPathSequence.falseSequence;
  final regex = _regexpCache[(pattern: pattern, flags: flags)];
  return XPathSequence.single(XPathBoolean.fromBool(regex.hasMatch(input)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
final fnReplace = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:replace'),
  {
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:replace'),
      (context, input, pattern, replacement) => _evalReplace(
        _asString(input.atomize().firstOrNull),
        _asString(pattern.atomize().firstOrNull),
        _asString(replacement.atomize().firstOrNull),
        null,
      ),
    ),
    4: XPathFunctionItem.fnN(
      const XmlName.qualified('fn:replace'),
      4,
      (context, args) => _evalReplace(
        _asString(args[0].atomize().firstOrNull),
        _asString(args[1].atomize().firstOrNull),
        _asString(args[2].atomize().firstOrNull),
        _asString(args[3].atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalReplace(
  String? input,
  String? pattern,
  String? replacement,
  String? flags,
) {
  if (input == null) return const XPathSequence.single(XPathString.empty);
  if (pattern == null || replacement == null) return XPathSequence.empty;
  final regex = _regexpCache[(pattern: pattern, flags: flags)];
  return XPathSequence.single(
    XPathString(input.replaceAll(regex, replacement)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tokenize
final fnTokenize = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:tokenize'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:tokenize'),
      (context, input) =>
          _evalTokenize(_asString(input.atomize().firstOrNull), null, null),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:tokenize'),
      (context, input, pattern) => _evalTokenize(
        _asString(input.atomize().firstOrNull),
        _asString(pattern.atomize().firstOrNull),
        null,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:tokenize'),
      (context, input, pattern, flags) => _evalTokenize(
        _asString(input.atomize().firstOrNull),
        _asString(pattern.atomize().firstOrNull),
        _asString(flags.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalTokenize(String? input, String? pattern, String? flags) {
  if (input == null) return XPathSequence.empty;
  if (pattern == null) {
    return XPathSequence(
      input
          .trim()
          .split(_whitespaceRegExp)
          .where((s) => s.isNotEmpty)
          .map(XPathString.new),
    );
  }
  final regex = _regexpCache[(pattern: pattern, flags: flags)];
  return XPathSequence(input.split(regex).map(XPathString.new));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-analyze-string
final fnAnalyzeString = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:analyze-string'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:analyze-string'),
      (context, input, pattern) => throw XPathEvaluationException(
        XPathErrorCode.FOER0000,
        'Not implemented: fn:analyze-string',
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:analyze-string'),
      (context, input, pattern, flags) => throw XPathEvaluationException(
        XPathErrorCode.FOER0000,
        'Not implemented: fn:analyze-string',
      ),
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-collation-key
final fnCollationKey = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:collation-key'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:collation-key'),
      (context, rel) => rel,
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:collation-key'),
      (context, rel, col) => rel,
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-contains-token
final fnContainsToken = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:contains-token'),
  {
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:contains-token'),
      (context, input, token) => _evalContainsToken(
        _asString(input.atomize().firstOrNull),
        _asString(token.atomize().firstOrNull),
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:contains-token'),
      (context, input, token, col) => _evalContainsToken(
        _asString(input.atomize().firstOrNull),
        _asString(token.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalContainsToken(String? input, String? token) {
  if (input == null || token == null) {
    return XPathSequence.falseSequence;
  }
  final tokens = input.trim().split(_whitespaceRegExp);
  return XPathSequence.single(
    XPathBoolean.fromBool(tokens.contains(token.trim())),
  );
}

final _whitespaceRegExp = RegExp(r'\s+');

final _regexpCache = XmlCache<({String pattern, String? flags}), RegExp>(
  (args) => _compileRegex(args.pattern, args.flags),
  25,
);

RegExp _compileRegex(String pattern, String? flags) {
  var isMultiLine = false;
  var isCaseSensitive = true;
  var isDotAll = false;
  var isLiteral = false;
  if (flags != null) {
    for (var i = 0; i < flags.length; i++) {
      final flag = flags[i];
      if (flag == 'm') {
        isMultiLine = true;
      } else if (flag == 'i') {
        isCaseSensitive = false;
      } else if (flag == 's') {
        isDotAll = true;
      } else if (flag == 'q') {
        isLiteral = true;
      } else if (flag != 'x') {
        throw XPathEvaluationException(
          XPathErrorCode.FORX0001,
          'Invalid regex flag: $flag',
        );
      }
    }
  }
  try {
    return RegExp(
      isLiteral ? RegExp.escape(pattern) : _translateXPathRegex(pattern),
      multiLine: isMultiLine,
      caseSensitive: isCaseSensitive,
      dotAll: isDotAll,
      unicode: true,
    );
  } on FormatException catch (error) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0002,
      'Invalid regex: ${error.message}',
    );
  }
}

// Regex matching character class subtraction: `[X-[Y]]`.
final _charClassSubtraction = RegExp(
  r'\[(\^?)' // opening `[` with optional negation
  r'((?:[^\]\\]|\\.)*)' // base class content
  r'-\[(\^?)' // subtraction `-[` with optional negation
  r'((?:[^\]\\]|\\.)*)' // subtracted class content
  r'\]\]', // closing `]]`
);

String _translateXPathRegex(String pattern) {
  // Character class subtraction: [X-[Y]] → (?:(?![Y])[X])
  pattern = pattern.replaceAllMapped(
    _charClassSubtraction,
    (m) => '(?:(?![${m[3]}${m[4]}])[${m[1]}${m[2]}])',
  );
  // XML character class escapes.
  return pattern
      .replaceAll(r'\i', r'[\p{L}_:]')
      .replaceAll(r'\I', r'[^\p{L}_:]')
      .replaceAll(r'\c', r'[\p{L}\p{N}.\-_:\p{M}]')
      .replaceAll(r'\C', r'[^\p{L}\p{N}.\-_:\p{M}]');
}
