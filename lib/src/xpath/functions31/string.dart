import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/number.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-concat
/// Special case: accepts 2+ arguments, requires rest parameter
XPathSequence fnConcat(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? arg3,
  XPathSequence? arg4,
  XPathSequence? arg5,
  XPathSequence? arg6,
  XPathSequence? arg7,
  XPathSequence? arg8,
  XPathSequence? arg9,
]) {
  final buffer = StringBuffer();
  for (final arg in [arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]) {
    if (arg == null) break;
    final item = XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString();
    if (item != null) buffer.write(item);
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-join
XPathSequence fnStringJoin(
  XPathContext context,
  XPathSequence input, [
  XPathSequence? separator,
]) {
  final sepVal =
      XPathEvaluationException.checkZeroOrOne(
        separator ?? XPathSequence.empty,
      )?.toXPathString() ??
      '';
  final result = input.map((item) => item.toXPathString()).join(sepVal);
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring
XPathSequence fnSubstring(
  XPathContext context,
  XPathSequence sourceString,
  XPathSequence start, [
  XPathSequence? length,
]) {
  final string =
      XPathEvaluationException.checkZeroOrOne(sourceString)?.toXPathString() ??
      '';
  final startVal = XPathEvaluationException.checkExactlyOne(
    start,
  ).toXPathNumber().toDouble();
  if (!startVal.isFinite) return XPathSequence.single(XPathString.empty);
  final startIdx = startVal.round() - 1;

  final endVal = length != null
      ? XPathEvaluationException.checkExactlyOne(
          length,
        ).toXPathNumber().toDouble()
      : double.infinity;

  if (endVal.isNaN || endVal <= 0) {
    return XPathSequence.single(XPathString.empty);
  }
  final endIdx = endVal.isFinite ? startIdx + endVal.round() : string.length;

  final i = startIdx.clamp(0, string.length);
  final j = endIdx.clamp(i, string.length);
  return XPathSequence.single(XPathString(string.substring(i, j)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-length
XPathSequence fnStringLength(XPathContext context, [XPathSequence? arg]) {
  final value = arg == null
      ? context.value.toXPathString()
      : (XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '');
  return XPathSequence.single(value.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-space
XPathSequence fnNormalizeSpace(XPathContext context, [XPathSequence? arg]) {
  final value = arg == null
      ? context.value.toXPathString()
      : (XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '');
  final result = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-upper-case
XPathSequence fnUpperCase(XPathContext context, XPathSequence arg) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(valOpt.toUpperCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-lower-case
XPathSequence fnLowerCase(XPathContext context, XPathSequence arg) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(valOpt.toLowerCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains
XPathSequence fnContains(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final val1 =
      XPathEvaluationException.checkZeroOrOne(arg1)?.toXPathString() ?? '';
  final val2 =
      XPathEvaluationException.checkZeroOrOne(arg2)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(val1.contains(val2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-starts-with
XPathSequence fnStartsWith(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final val1 =
      XPathEvaluationException.checkZeroOrOne(arg1)?.toXPathString() ?? '';
  final val2 =
      XPathEvaluationException.checkZeroOrOne(arg2)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(val1.startsWith(val2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ends-with
XPathSequence fnEndsWith(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final val1 =
      XPathEvaluationException.checkZeroOrOne(arg1)?.toXPathString() ?? '';
  final val2 =
      XPathEvaluationException.checkZeroOrOne(arg2)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(val1.endsWith(val2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-before
XPathSequence fnSubstringBefore(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final val1 =
      XPathEvaluationException.checkZeroOrOne(arg1)?.toXPathString() ?? '';
  final val2 =
      XPathEvaluationException.checkZeroOrOne(arg2)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  final index = val1.indexOf(val2);
  return XPathSequence.single(
    XPathString(index >= 0 ? val1.substring(0, index) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-after
XPathSequence fnSubstringAfter(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final val1 =
      XPathEvaluationException.checkZeroOrOne(arg1)?.toXPathString() ?? '';
  final val2 =
      XPathEvaluationException.checkZeroOrOne(arg2)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  if (val2.isEmpty) return XPathSequence.single(XPathString(val1));
  final index = val1.indexOf(val2);
  return XPathSequence.single(
    XPathString(index >= 0 ? val1.substring(index + val2.length) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-translate
XPathSequence fnTranslate(
  XPathContext context,
  XPathSequence arg,
  XPathSequence mapString,
  XPathSequence transString,
) {
  final input =
      XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '';
  final mapStr =
      XPathEvaluationException.checkZeroOrOne(mapString)?.toXPathString() ?? '';
  final transStr =
      XPathEvaluationException.checkZeroOrOne(transString)?.toXPathString() ??
      '';

  final mapping = <String, String>{};
  for (var i = 0; i < mapStr.length; i++) {
    final char = mapStr[i];
    if (!mapping.containsKey(char)) {
      mapping[char] = i < transStr.length ? transStr[i] : '';
    }
  }

  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    buffer.write(mapping[char] ?? char);
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-matches
XPathSequence fnMatches(
  XPathContext context,
  XPathSequence input,
  XPathSequence pattern, [
  XPathSequence? flags,
]) {
  final inputStr =
      XPathEvaluationException.checkZeroOrOne(input)?.toXPathString() ?? '';
  final patternStr =
      XPathEvaluationException.checkZeroOrOne(pattern)?.toXPathString() ?? '';
  final flagsStr =
      XPathEvaluationException.checkZeroOrOne(
        flags ?? XPathSequence.empty,
      )?.toXPathString() ??
      '';
  final regExp = _createRegExp(patternStr, flagsStr);
  return XPathSequence.single(inputStr.contains(regExp));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
XPathSequence fnReplace(
  XPathContext context,
  XPathSequence input,
  XPathSequence pattern,
  XPathSequence replacement, [
  XPathSequence? flags,
]) {
  final inputStr =
      XPathEvaluationException.checkZeroOrOne(input)?.toXPathString() ?? '';
  final patternStr =
      XPathEvaluationException.checkZeroOrOne(pattern)?.toXPathString() ?? '';
  final replaceStr =
      XPathEvaluationException.checkZeroOrOne(replacement)?.toXPathString() ??
      '';
  final flagsStr =
      XPathEvaluationException.checkZeroOrOne(
        flags ?? XPathSequence.empty,
      )?.toXPathString() ??
      '';
  final regExp = _createRegExp(patternStr, flagsStr);
  // Dart's replaceAll is global by default, unlike some regex engines.
  // XPath's replace is also global.
  // We need to handle $ capturing groups if they differ from Dart's.
  // XPath uses $N, Dart uses $N or ${N}.
  // But XPath might not support named groups in the same way or extended chars.
  // For basic support, we assume compatibility.
  return XPathSequence.single(
    XPathString(inputStr.replaceAll(regExp, replaceStr)),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoints-to-string
XPathSequence fnCodepointsToString(XPathContext context, XPathSequence arg) {
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
XPathSequence fnStringToCodepoints(XPathContext context, XPathSequence arg) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '';
  return XPathSequence(valOpt.runes);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-compare
XPathSequence fnCompare(
  XPathContext context,
  XPathSequence comparand1,
  XPathSequence comparand2, [
  XPathSequence? collation,
]) {
  final val1 =
      XPathEvaluationException.checkZeroOrOne(comparand1)?.toXPathString() ??
      '';
  final val2 =
      XPathEvaluationException.checkZeroOrOne(comparand2)?.toXPathString() ??
      '';
  // TODO: Handle collation parameter
  return XPathSequence.single(val1.compareTo(val2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoint-equal
XPathSequence fnCodepointEqual(
  XPathContext context,
  XPathSequence comparand1,
  XPathSequence comparand2,
) {
  final val1 = XPathEvaluationException.checkZeroOrOne(
    comparand1,
  )?.toXPathString();
  final val2 = XPathEvaluationException.checkZeroOrOne(
    comparand2,
  )?.toXPathString();
  if (val1 == null || val2 == null) return XPathSequence.empty;
  return XPathSequence.single(val1 == val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collation-key
XPathSequence fnCollationKey(
  XPathContext context,
  XPathSequence key, [
  XPathSequence? collation,
]) {
  // Basic implementation: return codepoints as key.
  // In a real implementation, this would depend on the collation.
  final keyVal =
      XPathEvaluationException.checkZeroOrOne(key)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(
    XPathString(String.fromCharCodes(keyVal.runes)), // Identity for now
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains-token
XPathSequence fnContainsToken(
  XPathContext context,
  XPathSequence input,
  XPathSequence token, [
  XPathSequence? collation,
]) {
  final inputStr =
      XPathEvaluationException.checkZeroOrOne(input)?.toXPathString() ?? '';
  final tokenStr =
      XPathEvaluationException.checkZeroOrOne(token)?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  final tokens = inputStr.trim().split(RegExp(r'\s+'));
  return XPathSequence.single(tokens.contains(tokenStr.trim()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-unicode
XPathSequence fnNormalizeUnicode(
  XPathContext context,
  XPathSequence arg, [
  XPathSequence? normalizationForm,
]) {
  final valOpt =
      XPathEvaluationException.checkZeroOrOne(arg)?.toXPathString() ?? '';
  // Dart doesn't support normalization directly in core.
  return XPathSequence.single(XPathString(valOpt));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tokenize
XPathSequence fnTokenize(
  XPathContext context,
  XPathSequence input, [
  XPathSequence? pattern,
  XPathSequence? flags,
]) {
  final inputStr =
      XPathEvaluationException.checkZeroOrOne(input)?.toXPathString() ?? '';
  if (pattern == null) {
    return XPathSequence(
      inputStr.trim().split(RegExp(r'\s+')).map(XPathString.new),
    );
  }
  final patternStr =
      XPathEvaluationException.checkZeroOrOne(pattern)?.toXPathString() ?? '';
  final flagsStr =
      XPathEvaluationException.checkZeroOrOne(
        flags ?? XPathSequence.empty,
      )?.toXPathString() ??
      '';
  final regExp = _createRegExp(patternStr, flagsStr);
  // Method split in Dart does not include empty strings if they are at the end?
  // XPath tokenize says: "If the separator pattern matches a zero-length string..."
  // It also says "The result is a sequence of strings...".
  return XPathSequence(inputStr.split(regExp).map(XPathString.new));
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
      case 'u': // Not standard XPath but good for Dart? No, strictly stick to XPath flags.
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

/// https://www.w3.org/TR/xpath-functions-31/#func-analyze-string
XPathSequence fnAnalyzeString(
  XPathContext context,
  XPathSequence input,
  XPathSequence pattern, [
  XPathSequence? flags,
]) {
  throw UnimplementedError('fn:analyze-string');
}
