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
  List<XPathSequence> rest = const [],
]) {
  final buffer = StringBuffer();
  for (final arg in [arg1, arg2, ...rest]) {
    if (arg.isNotEmpty) {
      buffer.write(arg.first.toXPathString());
    }
  }
  return XPathSequence.single(XPathString(buffer.toString()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-join
XPathSequence fnStringJoin(
  XPathContext context,
  XPathSequence sequence, [
  XPathSequence? separator,
]) {
  final sep = separator?.firstOrNull?.toXPathString() ?? '';
  final result = sequence.map((item) => item.toXPathString()).join(sep);
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring
XPathSequence fnSubstring(
  XPathContext context,
  XPathSequence sourceString,
  XPathSequence startingLoc, [
  XPathSequence? length,
]) {
  final string = sourceString.firstOrNull?.toXPathString() ?? '';
  final start_ = startingLoc.firstOrNull?.toXPathNumber() as num? ?? double.nan;
  if (!start_.isFinite) return XPathSequence.single(XPathString.empty);
  final start = start_.round() - 1;
  final end_ = length != null
      ? (length.firstOrNull?.toXPathNumber() as num? ?? double.nan)
      : double.infinity;
  if (end_.isNaN || end_ <= 0) return XPathSequence.single(XPathString.empty);
  final end = end_.isFinite ? start + end_.round() : string.length;

  final i = start.clamp(0, string.length);
  final j = end.clamp(i, string.length);
  return XPathSequence.single(XPathString(string.substring(i, j)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string-length
XPathSequence fnStringLength(XPathContext context, [XPathSequence? arg]) {
  final value = arg == null
      ? context.value.toXPathString()
      : (arg.firstOrNull?.toXPathString() ?? '');
  return XPathSequence.single(value.length);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-normalize-space
XPathSequence fnNormalizeSpace(XPathContext context, [XPathSequence? arg]) {
  final value = arg == null
      ? context.value.toXPathString()
      : (arg.firstOrNull?.toXPathString() ?? '');
  final result = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  return XPathSequence.single(XPathString(result));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-upper-case
XPathSequence fnUpperCase(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(value.toUpperCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-lower-case
XPathSequence fnLowerCase(XPathContext context, XPathSequence arg) {
  final value = arg.firstOrNull?.toXPathString() ?? '';
  return XPathSequence.single(XPathString(value.toLowerCase()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains
XPathSequence fnContains(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final string = arg1.firstOrNull?.toXPathString() ?? '';
  final pattern = arg2.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(string.contains(pattern));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-starts-with
XPathSequence fnStartsWith(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final string = arg1.firstOrNull?.toXPathString() ?? '';
  final pattern = arg2.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(string.startsWith(pattern));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-ends-with
XPathSequence fnEndsWith(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final string = arg1.firstOrNull?.toXPathString() ?? '';
  final pattern = arg2.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(string.endsWith(pattern));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-before
XPathSequence fnSubstringBefore(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final string = arg1.firstOrNull?.toXPathString() ?? '';
  final pattern = arg2.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  final index = string.indexOf(pattern);
  return XPathSequence.single(
    XPathString(index >= 0 ? string.substring(0, index) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-substring-after
XPathSequence fnSubstringAfter(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2, [
  XPathSequence? collation,
]) {
  final string = arg1.firstOrNull?.toXPathString() ?? '';
  final pattern = arg2.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  if (pattern.isEmpty) return XPathSequence.single(XPathString(string));
  final index = string.indexOf(pattern);
  return XPathSequence.single(
    XPathString(index >= 0 ? string.substring(index + pattern.length) : ''),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-translate
XPathSequence fnTranslate(
  XPathContext context,
  XPathSequence arg,
  XPathSequence mapString,
  XPathSequence transString,
) {
  final input = arg.firstOrNull?.toXPathString() ?? '';
  final sourceChars = mapString.firstOrNull?.toXPathString() ?? '';
  final targetChars = transString.firstOrNull?.toXPathString() ?? '';

  final mapping = <String, String>{};
  for (var i = 0; i < sourceChars.length; i++) {
    final char = sourceChars[i];
    if (!mapping.containsKey(char)) {
      mapping[char] = i < targetChars.length ? targetChars[i] : '';
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
  final string = input.firstOrNull?.toXPathString() ?? '';
  final patternStr = pattern.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle flags parameter
  final regExp = RegExp(patternStr);
  return XPathSequence.single(string.contains(regExp));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-replace
XPathSequence fnReplace(
  XPathContext context,
  XPathSequence input,
  XPathSequence pattern,
  XPathSequence replacement, [
  XPathSequence? flags,
]) {
  final string = input.firstOrNull?.toXPathString() ?? '';
  final patternStr = pattern.firstOrNull?.toXPathString() ?? '';
  final replacementStr = replacement.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle flags parameter
  final regExp = RegExp(patternStr);
  return XPathSequence.single(
    XPathString(string.replaceAll(regExp, replacementStr)),
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
  final string = arg.firstOrNull?.toXPathString() ?? '';
  return XPathSequence(string.runes);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-compare
XPathSequence fnCompare(
  XPathContext context,
  XPathSequence comparand1,
  XPathSequence comparand2, [
  XPathSequence? collation,
]) {
  final string1 = comparand1.firstOrNull?.toXPathString() ?? '';
  final string2 = comparand2.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(string1.compareTo(string2));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-codepoint-equal
XPathSequence fnCodepointEqual(
  XPathContext context,
  XPathSequence comparand1,
  XPathSequence comparand2,
) {
  final string1 = comparand1.firstOrNull?.toXPathString();
  final string2 = comparand2.firstOrNull?.toXPathString();
  if (string1 == null || string2 == null) return XPathSequence.empty;
  return XPathSequence.single(string1 == string2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collation-key
XPathSequence fnCollationKey(
  XPathContext context,
  XPathSequence key, [
  XPathSequence? collation,
]) {
  // Basic implementation: return codepoints as key.
  // In a real implementation, this would depend on the collation.
  final string = key.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle collation parameter
  return XPathSequence.single(
    XPathString(String.fromCharCodes(string.runes)), // Identity for now
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-contains-token
XPathSequence fnContainsToken(
  XPathContext context,
  XPathSequence input,
  XPathSequence token, [
  XPathSequence? collation,
]) {
  final inputStr = input.firstOrNull?.toXPathString() ?? '';
  final tokenStr = token.firstOrNull?.toXPathString() ?? '';
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
  final value = arg.firstOrNull?.toXPathString() ?? '';
  // Dart doesn't support normalization directly in core.
  return XPathSequence.single(XPathString(value));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-tokenize
XPathSequence fnTokenize(
  XPathContext context,
  XPathSequence input, [
  XPathSequence? pattern,
  XPathSequence? flags,
]) {
  final string = input.firstOrNull?.toXPathString() ?? '';
  if (pattern == null) {
    return XPathSequence(
      string.trim().split(RegExp(r'\s+')).map(XPathString.new),
    );
  }
  final patternStr = pattern.firstOrNull?.toXPathString() ?? '';
  // TODO: Handle flags parameter
  final regExp = RegExp(patternStr);
  return XPathSequence(string.split(regExp).map(XPathString.new));
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
