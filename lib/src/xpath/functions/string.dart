import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'regex.dart';

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
    XPathInteger.fromInt(compareCodepoints(comparand1, comparand2)),
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
  if (lenVal != null && lenVal.isInfinite && lenVal.isNegative) {
    return const XPathSequence.single(XPathString.empty);
  }

  int roundXPath(double val) => (val + 0.5).floor();

  final start = roundXPath(startVal);
  final hasFiniteLen = lenVal != null && lenVal.isFinite;
  final end = hasFiniteLen ? start + roundXPath(lenVal) : null;

  var s = start - 1;
  final runes = sourceString.runes.toList();
  var e = end != null ? end - 1 : runes.length;

  if (s < 0) s = 0;
  if (e > runes.length) e = runes.length;
  if (s >= e) return const XPathSequence.single(XPathString.empty);

  return XPathSequence.single(
    XPathString(String.fromCharCodes(runes.sublist(s, e))),
  );
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
  XPathString(_trimXmlWhitespace(str).replaceAll(_xmlWhitespaceRegExp, ' ')),
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
  final s1 = arg1 ?? '';
  final s2 = arg2 ?? '';
  return s1.contains(s2)
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
  final s1 = arg1 ?? '';
  final s2 = arg2 ?? '';
  return s1.startsWith(s2)
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
  final s1 = arg1 ?? '';
  final s2 = arg2 ?? '';
  return s1.endsWith(s2)
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
  final s1 = arg1 ?? '';
  final s2 = arg2 ?? '';
  if (s2.isEmpty) return const XPathSequence.single(XPathString.empty);
  final index = s1.indexOf(s2);
  if (index == -1) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(s1.substring(0, index)));
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
  final s1 = arg1 ?? '';
  final s2 = arg2 ?? '';
  if (s2.isEmpty) return XPathSequence.single(XPathString(s1));
  final index = s1.indexOf(s2);
  if (index == -1) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(s1.substring(index + s2.length)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-matches
final fnMatches = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:matches'),
  {
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:matches'), (
      context,
      input,
      pattern,
    ) {
      final p = _asString(pattern.atomize().firstOrNull);
      if (p == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Pattern cannot be the empty sequence',
        );
      }
      return _evalMatches(_asString(input.atomize().firstOrNull), p, null);
    }),
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:matches'), (
      context,
      input,
      pattern,
      flags,
    ) {
      final p = _asString(pattern.atomize().firstOrNull);
      if (p == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Pattern cannot be the empty sequence',
        );
      }
      final f = _asString(flags.atomize().firstOrNull);
      if (f == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Flags cannot be the empty sequence',
        );
      }
      return _evalMatches(_asString(input.atomize().firstOrNull), p, f);
    }),
  },
);

XPathSequence _evalMatches(String? input, String pattern, String? flags) {
  if (input == null) return XPathSequence.falseSequence;
  final regex = getCachedXPathRegex(pattern, flags);
  return XPathSequence.single(XPathBoolean.fromBool(regex.hasMatch(input)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
final fnReplace = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:replace'),
  {
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:replace'), (
      context,
      input,
      pattern,
      replacement,
    ) {
      final p = _asString(pattern.atomize().firstOrNull);
      if (p == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Pattern cannot be the empty sequence',
        );
      }
      final r = _asString(replacement.atomize().firstOrNull);
      if (r == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Replacement cannot be the empty sequence',
        );
      }
      return _evalReplace(_asString(input.atomize().firstOrNull), p, r, null);
    }),
    4: XPathFunctionItem.fnN(const XmlName.qualified('fn:replace'), 4, (
      context,
      args,
    ) {
      final p = _asString(args[1].atomize().firstOrNull);
      if (p == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Pattern cannot be the empty sequence',
        );
      }
      final r = _asString(args[2].atomize().firstOrNull);
      if (r == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Replacement cannot be the empty sequence',
        );
      }
      final f = _asString(args[3].atomize().firstOrNull);
      if (f == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Flags cannot be the empty sequence',
        );
      }
      return _evalReplace(_asString(args[0].atomize().firstOrNull), p, r, f);
    }),
  },
);

XPathSequence _evalReplace(
  String? input,
  String pattern,
  String replacement,
  String? flags,
) {
  final target = input ?? '';
  final regex = getCachedXPathRegex(pattern, flags);
  final isLiteral = flags != null && flags.contains('q');
  final result = applyXPathReplace(
    target,
    regex,
    replacement,
    isLiteral: isLiteral,
  );
  return XPathSequence.single(XPathString(result));
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
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:tokenize'), (
      context,
      input,
      pattern,
    ) {
      final p = _asString(pattern.atomize().firstOrNull);
      if (p == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Pattern cannot be the empty sequence',
        );
      }
      return _evalTokenize(_asString(input.atomize().firstOrNull), p, null);
    }),
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:tokenize'), (
      context,
      input,
      pattern,
      flags,
    ) {
      final p = _asString(pattern.atomize().firstOrNull);
      if (p == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Pattern cannot be the empty sequence',
        );
      }
      final f = _asString(flags.atomize().firstOrNull);
      if (f == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Flags cannot be the empty sequence',
        );
      }
      return _evalTokenize(_asString(input.atomize().firstOrNull), p, f);
    }),
  },
);

XPathSequence _evalTokenize(String? input, String? pattern, String? flags) {
  if (input == null || input.isEmpty) return XPathSequence.empty;
  if (pattern == null) {
    final trimmed = _trimXmlWhitespace(input);
    if (trimmed.isEmpty) return XPathSequence.empty;
    return XPathSequence(
      trimmed
          .split(_xmlWhitespaceRegExp)
          .where((s) => s.isNotEmpty)
          .map(XPathString.new),
    );
  }
  final regex = getCachedXPathRegex(pattern, flags);
  if (regex.hasMatch('')) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0003,
      'Regular expression matches zero-length string',
    );
  }
  return XPathSequence(input.split(regex).map(XPathString.new));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-analyze-string
final fnAnalyzeString = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:analyze-string'),
  {
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:analyze-string'), (
      context,
      input,
      pattern,
    ) {
      final patternStr = _asString(pattern.atomize().firstOrNull);
      if (patternStr == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'fn:analyze-string pattern must be a string',
        );
      }
      final inputStr = _asString(input.atomize().firstOrNull) ?? '';
      return XPathSequence.single(analyzeXPathString(inputStr, patternStr));
    }),
    3: XPathFunctionItem.fn3(const XmlName.qualified('fn:analyze-string'), (
      context,
      input,
      pattern,
      flags,
    ) {
      final patternStr = _asString(pattern.atomize().firstOrNull);
      if (patternStr == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'fn:analyze-string pattern must be a string',
        );
      }
      final inputStr = _asString(input.atomize().firstOrNull) ?? '';
      final flagsStr = _asString(flags.atomize().firstOrNull);
      return XPathSequence.single(
        analyzeXPathString(inputStr, patternStr, flags: flagsStr),
      );
    }),
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
        input.atomize().map((i) => i.stringValue),
        _asString(token.atomize().firstOrNull),
        null,
      ),
    ),
    3: XPathFunctionItem.fn3(
      const XmlName.qualified('fn:contains-token'),
      (context, input, token, col) => _evalContainsToken(
        input.atomize().map((i) => i.stringValue),
        _asString(token.atomize().firstOrNull),
        _asString(col.atomize().firstOrNull),
      ),
    ),
  },
);

XPathSequence _evalContainsToken(
  Iterable<String> input,
  String? token,
  String? collation,
) {
  if (token == null) {
    return XPathSequence.falseSequence;
  }
  final trimmedToken = _trimXmlWhitespace(token);
  if (trimmedToken.isEmpty || _xmlWhitespaceRegExp.hasMatch(trimmedToken)) {
    return XPathSequence.falseSequence;
  }
  final caseInsensitive =
      collation ==
      'http://www.w3.org/2005/xpath-functions/collation/html-ascii-case-insensitive';
  final targetToken = caseInsensitive
      ? trimmedToken.toLowerCase()
      : trimmedToken;

  for (final str in input) {
    final trimmedStr = _trimXmlWhitespace(str);
    if (trimmedStr.isEmpty) continue;
    final tokens = trimmedStr.split(_xmlWhitespaceRegExp);
    for (final t in tokens) {
      final comp = caseInsensitive ? t.toLowerCase() : t;
      if (comp == targetToken) {
        return XPathSequence.trueSequence;
      }
    }
  }
  return XPathSequence.falseSequence;
}

bool _isXmlWhitespace(int codeUnit) =>
    codeUnit == 0x20 ||
    codeUnit == 0x09 ||
    codeUnit == 0x0A ||
    codeUnit == 0x0D;

String _trimXmlWhitespace(String str) {
  var start = 0;
  while (start < str.length && _isXmlWhitespace(str.codeUnitAt(start))) {
    start++;
  }
  var end = str.length;
  while (end > start && _isXmlWhitespace(str.codeUnitAt(end - 1))) {
    end--;
  }
  return start == 0 && end == str.length ? str : str.substring(start, end);
}

final _xmlWhitespaceRegExp = RegExp(r'[ \t\r\n]+');
