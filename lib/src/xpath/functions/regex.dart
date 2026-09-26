import 'package:petitparser/core.dart';
import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

import '../../xml/builder/builder.dart';
import '../../xml/utils/cache.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/item.dart';

/// All Unicode blocks defined in W3C XML Schema Part 2: Datatypes Second Edition.
const xmlSchemaBlocks = <String, (int, int)>{
  'BasicLatin': (0x0000, 0x007F),
  'Latin-1Supplement': (0x0080, 0x00FF),
  'LatinExtended-A': (0x0100, 0x017F),
  'LatinExtended-B': (0x0180, 0x024F),
  'IPAExtensions': (0x0250, 0x02AF),
  'SpacingModifierLetters': (0x02B0, 0x02FF),
  'CombiningDiacriticalMarks': (0x0300, 0x036F),
  'Greek': (0x0370, 0x03FF),
  'GreekandCoptic': (0x0370, 0x03FF),
  'Cyrillic': (0x0400, 0x04FF),
  'Armenian': (0x0530, 0x058F),
  'Hebrew': (0x0590, 0x05FF),
  'Arabic': (0x0600, 0x06FF),
  'Syriac': (0x0700, 0x074F),
  'Thaana': (0x0780, 0x07BF),
  'Devanagari': (0x0900, 0x097F),
  'Bengali': (0x0980, 0x09FF),
  'Gurmukhi': (0x0A00, 0x0A7F),
  'Gujarati': (0x0A80, 0x0AFF),
  'Oriya': (0x0B00, 0x0B7F),
  'Tamil': (0x0B80, 0x0BFF),
  'Telugu': (0x0C00, 0x0C7F),
  'Kannada': (0x0C80, 0x0CFF),
  'Malayalam': (0x0D00, 0x0D7F),
  'Sinhala': (0x0D80, 0x0DFF),
  'Thai': (0x0E00, 0x0E7F),
  'Lao': (0x0E80, 0x0EFF),
  'Tibetan': (0x0F00, 0x0FFF),
  'Myanmar': (0x1000, 0x109F),
  'Georgian': (0x10A0, 0x10FF),
  'HangulJamo': (0x1100, 0x11FF),
  'Ethiopic': (0x1200, 0x137F),
  'Cherokee': (0x13A0, 0x13FF),
  'UnifiedCanadianAboriginalSyllabics': (0x1400, 0x167F),
  'Ogham': (0x1680, 0x169F),
  'Runic': (0x16A0, 0x16FF),
  'Khmer': (0x1780, 0x17FF),
  'Mongolian': (0x1800, 0x18AF),
  'LatinExtendedAdditional': (0x1E00, 0x1EFF),
  'GreekExtended': (0x1F00, 0x1FFF),
  'GeneralPunctuation': (0x2000, 0x206F),
  'SuperscriptsandSubscripts': (0x2070, 0x209F),
  'CurrencySymbols': (0x20A0, 0x20CF),
  'CombiningDiacriticalMarksforSymbols': (0x20D0, 0x20FF),
  'LetterlikeSymbols': (0x2100, 0x214F),
  'NumberForms': (0x2150, 0x218F),
  'Arrows': (0x2190, 0x21FF),
  'MathematicalOperators': (0x2200, 0x22FF),
  'MiscellaneousTechnical': (0x2300, 0x23FF),
  'ControlPictures': (0x2400, 0x243F),
  'OpticalCharacterRecognition': (0x2440, 0x245F),
  'EnclosedAlphanumerics': (0x2460, 0x24FF),
  'BoxDrawing': (0x2500, 0x257F),
  'BlockElements': (0x2580, 0x259F),
  'GeometricShapes': (0x25A0, 0x25FF),
  'MiscellaneousSymbols': (0x2600, 0x26FF),
  'Dingbats': (0x2700, 0x27BF),
  'BraillePatterns': (0x2800, 0x28FF),
  'CJKRadicalsSupplement': (0x2E80, 0x2EFF),
  'KangxiRadicals': (0x2F00, 0x2FDF),
  'IdeographicDescriptionCharacters': (0x2FF0, 0x2FFF),
  'CJKSymbolsandPunctuation': (0x3000, 0x303F),
  'Hiragana': (0x3040, 0x309F),
  'Katakana': (0x30A0, 0x30FF),
  'Bopomofo': (0x3100, 0x312F),
  'HangulCompatibilityJamo': (0x3130, 0x318F),
  'Kanbun': (0x3190, 0x319F),
  'BopomofoExtended': (0x31A0, 0x31BF),
  'EnclosedCJKLettersandMonths': (0x3200, 0x32FF),
  'CJKCompatibility': (0x3300, 0x33FF),
  'CJKUnifiedIdeographsExtensionA': (0x3400, 0x4DB5),
  'CJKUnifiedIdeographs': (0x4E00, 0x9FFF),
  'YiSyllables': (0xA000, 0xA48F),
  'YiRadicals': (0xA490, 0xA4CF),
  'HangulSyllables': (0xAC00, 0xD7A3),
  'HighSurrogates': (0xD800, 0xDB7F),
  'LowSurrogates': (0xDC00, 0xDFFF),
  'PrivateUseArea': (0xE000, 0xF8FF),
  'CJKCompatibilityIdeographs': (0xF900, 0xFAFF),
  'AlphabeticPresentationForms': (0xFB00, 0xFB4F),
  'ArabicPresentationForms-A': (0xFB50, 0xFDFF),
  'CombiningHalfMarks': (0xFE20, 0xFE2F),
  'CJKCompatibilityForms': (0xFE30, 0xFE4F),
  'SmallFormVariants': (0xFE50, 0xFE6F),
  'ArabicPresentationForms-B': (0xFE70, 0xFEFE),
  'HalfwidthandFullwidthForms': (0xFF00, 0xFFEF),
  'Specials': (0xFFF0, 0xFFFD),
  'OldItalic': (0x10300, 0x1032F),
  'Gothic': (0x10330, 0x1034F),
  'Deseret': (0x10400, 0x1044F),
  'ByzantineMusicalSymbols': (0x1D000, 0x1D0FF),
  'MusicalSymbols': (0x1D100, 0x1D1FF),
  'MathematicalAlphanumericSymbols': (0x1D400, 0x1D7FF),
  'CJKUnifiedIdeographsExtensionB': (0x20000, 0x2A6DF),
  'CJKCompatibilityIdeographsSupplement': (0x2F800, 0x2FA1F),
  'Tags': (0xE0000, 0xE007F),
  'SupplementaryPrivateUseArea-A': (0xF0000, 0xFFFFD),
  'SupplementaryPrivateUseArea-B': (0x100000, 0x10FFFD),
  'Emoticons': (0x1F600, 0x1F64F),
};

const _validCategories = <String>{
  'L',
  'Lu',
  'Ll',
  'Lt',
  'Lm',
  'Lo',
  'M',
  'Mn',
  'Mc',
  'Me',
  'N',
  'Nd',
  'Nl',
  'No',
  'P',
  'Pc',
  'Pd',
  'Ps',
  'Pe',
  'Pi',
  'Pf',
  'Po',
  'S',
  'Sm',
  'Sc',
  'Sk',
  'So',
  'Z',
  'Zs',
  'Zl',
  'Zp',
  'C',
  'Cc',
  'Cf',
  'Cs',
  'Co',
  'Cn',
};

final _xpathRegexpCache = XmlCache<({String pattern, String? flags}), RegExp>(
  (args) => compileXPathRegex(args.pattern, args.flags),
  50,
);

/// Returns a cached compiled [RegExp] for [pattern] and [flags].
RegExp getCachedXPathRegex(String pattern, String? flags) =>
    _xpathRegexpCache[(pattern: pattern, flags: flags)];

/// Validates regular expression flags according to XPath 3.1 specifications.
void validateXPathRegexFlags(String? flags) {
  if (flags == null) return;
  final seen = <String>{};
  for (var i = 0; i < flags.length; i++) {
    final flag = flags[i];
    if (flag != 's' &&
        flag != 'm' &&
        flag != 'i' &&
        flag != 'x' &&
        flag != 'q') {
      throw XPathEvaluationException(
        XPathErrorCode.FORX0001,
        'Invalid regex flag: $flag',
      );
    }
    if (!seen.add(flag)) {
      throw XPathEvaluationException(
        XPathErrorCode.FORX0001,
        'Duplicate regular expression flag: $flag',
      );
    }
  }
}

/// Represents a capturing group node in the hierarchy of regular expression groups.
class XPathRegexGroup {
  new({required this.nr, required this.parentNr, required this.children});

  /// The 1-based capturing group number (0 for the root match).
  final int nr;

  /// The 1-based capturing group number of the parent group (or -1 for the root).
  final int parentNr;

  /// Direct children of this capturing group.
  final List<XPathRegexGroup> children;
}

class _RawGroup {
  const new(this.children);
  final List<_RawGroup> children;
}

XPathRegexGroup _assignGroupNumbers(_RawGroup root) {
  var counter = 0;
  XPathRegexGroup assign(_RawGroup node, int parentNr) {
    final currentNr = counter++;
    final children = <XPathRegexGroup>[];
    final result = XPathRegexGroup(
      nr: currentNr,
      parentNr: parentNr,
      children: children,
    );
    for (final child in node.children) {
      children.add(assign(child, currentNr));
    }
    return result;
  }

  return assign(root, -1);
}

/// Compiles an XPath/XML Schema regular expression to Dart [RegExp].
RegExp compileXPathRegex(String pattern, String? flags) {
  validateXPathRegexFlags(flags);
  final isMultiLine = flags != null && flags.contains('m');
  final isCaseSensitive = flags == null || !flags.contains('i');
  final isDotAll = flags != null && flags.contains('s');
  final isLiteral = flags != null && flags.contains('q');
  final isFlagX = flags != null && flags.contains('x');

  final String ecmaPattern;
  if (isLiteral) {
    ecmaPattern = RegExp.escape(pattern);
  } else {
    ecmaPattern = translateXPathRegex(pattern, isFlagX: isFlagX);
  }

  try {
    return RegExp(
      ecmaPattern,
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

final _defaultRegexParser = const XPathRegexTransformGrammar(isFlagX: false)
    .build();
final _flagXRegexParser = const XPathRegexTransformGrammar(isFlagX: true)
    .build();

final _defaultGroupParser = const _XPathRegexGroupGrammar(isFlagX: false)
    .build();
final _flagXGroupParser = const _XPathRegexGroupGrammar(isFlagX: true).build();

/// Translates W3C XML Schema regular expressions to ECMAScript/Dart compatible patterns using PetitParser.
String translateXPathRegex(String pattern, {bool isFlagX = false}) {
  final parser = isFlagX ? _flagXRegexParser : _defaultRegexParser;
  final result = parser.parse(pattern);
  if (result is Failure) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0002,
      'Invalid regular expression: ${result.message}',
    );
  }
  return result.value;
}

/// Parses the capturing group structure from an XPath/XML Schema regular expression.
XPathRegexGroup parseRegexGroups(String pattern, {bool isFlagX = false}) {
  final parser = isFlagX ? _flagXGroupParser : _defaultGroupParser;
  final result = parser.parse(pattern);
  if (result is Success<_RawGroup>) {
    return _assignGroupNumbers(result.value);
  }
  return XPathRegexGroup(nr: 0, parentNr: -1, children: []);
}

/// PetitParser grammar that extracts capturing group structure.
class _XPathRegexGroupGrammar extends GrammarDefinition<_RawGroup> {
  const new({this.isFlagX = false});

  final bool isFlagX;

  Parser<void> ws() => isFlagX ? anyOf(' \t\r\n').plus() : failure();

  @override
  Parser<_RawGroup> start() {
    var p = ref0(patternBody);
    if (isFlagX) {
      p = p.trim(ref0(ws));
    }
    return p.end();
  }

  Parser<_RawGroup> patternBody() => ref0(item).star().map((items) {
    final groups = <_RawGroup>[];
    for (final it in items) {
      if (it is _RawGroup) {
        groups.add(it);
      } else if (it is List<_RawGroup>) {
        groups.addAll(it);
      }
    }
    return _RawGroup(groups);
  });

  Parser<Object?> item() {
    Parser<Object?> p = [
      ref0(nonCapturingGroup),
      ref0(capturingGroup),
      ref0(charClass),
      ref0(escaped),
      ref0(other),
    ].toChoiceParser();
    if (isFlagX) {
      p = p.trim(ref0(ws));
    }
    return p;
  }

  Parser<_RawGroup> capturingGroup() => seq3(
    char('('),
    ref0(patternBody),
    char(')'),
  ).map3((_, body, _) => _RawGroup(body.children));

  Parser<Object?> nonCapturingGroup() => seq3(
    string('(?:'),
    ref0(patternBody),
    char(')'),
  ).map3((_, body, _) => body.children);

  Parser<String> charClass() =>
      char('[').seq(pattern('^]').star()).seq(char(']')).flatten();

  Parser<String> escaped() => seq2(char(r'\'), any()).flatten();

  Parser<String> other() => pattern('^)');
}

/// PetitParser grammar that directly transforms XML Schema regular expressions to ECMAScript regular expressions.
class XPathRegexTransformGrammar extends GrammarDefinition<String> {
  const new({this.isFlagX = false});

  final bool isFlagX;

  Parser<void> ws() => isFlagX ? anyOf(' \t\r\n').plus() : failure();

  @override
  Parser<String> start() {
    var p = ref0(regExp);
    if (isFlagX) {
      p = p.trim(ref0(ws));
    }
    return p.end();
  }

  Parser<String> regExp() =>
      ref0(branch)
          .plusSeparated(isFlagX ? char('|').trim(ref0(ws)) : char('|'))
          .map((sep) => sep.elements.join('|'));

  Parser<String> branch() => ref0(piece).star().map((pieces) => pieces.join());

  Parser<String> piece() {
    var p = seq2(ref0(atom), ref0(quantifier).optional()).map2((atom, quant) {
      if (quant == null) return atom;
      if (atom == '^' || atom == r'$') return '(?:$atom)$quant';
      return '$atom$quant';
    });
    if (isFlagX) {
      p = p.trim(ref0(ws));
    }
    return p;
  }

  Parser<String> quantifier() => [
    string('*?'),
    string('+?'),
    string('??'),
    char('*'),
    char('+'),
    char('?'),
    ref0(rangeQuantifier),
  ].toChoiceParser();

  Parser<String> rangeQuantifier() => seq4(
    char('{'),
    digit().plusString(),
    seq2(
      char(','),
      digit().starString(),
    ).map2((comma, d) => '$comma$d').optional(),
    char('}'),
  ).seq(char('?').optional()).flatten();

  Parser<String> atom() => [
    ref0(nonCapturingGroup),
    ref0(capturingGroup),
    ref0(charClass),
    ref0(escapes),
    ref0(wildcard),
    ref0(anchor),
    ref0(literal),
  ].toChoiceParser();

  Parser<String> capturingGroup() =>
      seq3(char('('), ref0(regExp), char(')')).map3((_, body, _) => '($body)');

  Parser<String> nonCapturingGroup() => seq3(
    string('(?:'),
    ref0(regExp),
    char(')'),
  ).map3((_, body, _) => '(?:$body)');

  Parser<String> wildcard() => char('.').map((_) => '.');

  Parser<String> anchor() => [char('^'), char(r'$')].toChoiceParser();

  Parser<String> literal() {
    final forbidden = isFlagX
        ? r'\()[]{}^$|.?*+ '
              '\t\r\n'
        : r'\()[]{}^$|.?*+';
    return anyOf(forbidden).neg().plusString();
  }

  Parser<String> escapes() => [
    string(r'\ ').map((_) => r'\x20'),
    string(r'\-').map((_) => r'\x2D'),
    string(r'\:').map((_) => ':'),
    string(r'\#').map((_) => '#'),
    string(r'\n').map((_) => r'\n'),
    string(r'\r').map((_) => r'\r'),
    string(r'\t').map((_) => r'\t'),
    string(r'\i').map((_) => r'[\p{L}_:]'),
    string(r'\I').map((_) => r'[^\p{L}_:]'),
    string(r'\c').map((_) => r'[\p{L}\p{N}.\-_:\p{M}]'),
    string(r'\C').map((_) => r'[^\p{L}\p{N}.\-_:\p{M}]'),
    seq2(char(r'\'), pattern('dDsSwW')).flatten(),
    ref0(backreference),
    ref0(unicodeProperty),
    seq2(char(r'\'), anyOf(r'()[]{}^$|.?*+\')).flatten(),
  ].toChoiceParser();

  Parser<String> backreference() => seq2(char(r'\'), pattern('1-9'))
      .map2((slash, digit) => '$slash$digit')
      .then(digit().and().optional())
      .map2((ref, nextDigit) {
        if (nextDigit != null) return '$ref(?:)';
        return ref;
      });

  Parser<String> unicodeProperty() =>
      seq3(
        string(r'\p{').or(string(r'\P{')),
        pattern('^}').plusString(),
        char('}'),
      ).map3((prefix, prop, _) {
        var p = prop;
        if (isFlagX) p = p.replaceAll(RegExp(r'\s+'), '');
        if (p.startsWith('Is')) {
          final blockName = p.substring(2);
          final range = xmlSchemaBlocks[blockName];
          if (range == null) {
            throw XPathEvaluationException(
              XPathErrorCode.FORX0002,
              'Invalid property name: $p',
            );
          }
          final startHex = range.$1.toRadixString(16);
          final endHex = range.$2.toRadixString(16);
          final r = r'\u{' + startHex + r'}-\u{' + endHex + r'}';
          return prefix == r'\p{' ? '[$r]' : '[^$r]';
        }
        if (p.isEmpty || !_validCategories.contains(p)) {
          throw XPathEvaluationException(
            XPathErrorCode.FORX0002,
            'Invalid property name: $p',
          );
        }
        return '$prefix$p}';
      });

  Parser<String> charClass() =>
      seq4(
        char('['),
        char('^').optional(),
        ref0(charClassBody),
        char(']'),
      ).map4((_, neg, body, _) {
        // Double negation: [^\P{IsBlock}] -> [\p{IsBlock}]
        if (neg != null && body.startsWith('^')) {
          return '[${body.substring(1)}]';
        }
        // Subtraction: [base-[sub]]
        final subIdx = body.indexOf(r'-[');
        if (subIdx != -1 && body.endsWith(r']')) {
          final base = body.substring(0, subIdx);
          final sub = body.substring(subIdx + 1);
          final baseClass = neg != null ? '[^$base]' : '[$base]';
          return '(?:(?!$sub)$baseClass)';
        }
        // \C or \I in class
        if (body.contains(r'\C') || body.contains(r'\I')) {
          if (body == r'\C') return r'[^\p{L}\p{N}.\-_:\p{M}]';
          if (body == r'\I') return r'[^\p{L}_:]';
          final rest = body.replaceAll(r'\C', '').replaceAll(r'\I', '');
          final parts = <String>[];
          if (body.contains(r'\C')) parts.add(r'[^\p{L}\p{N}.\-_:\p{M}]');
          if (body.contains(r'\I')) parts.add(r'[^\p{L}_:]');
          if (rest.isNotEmpty) parts.add(rest);
          return '(?:${parts.join('|')})';
        }
        return neg != null ? '[^$body]' : '[$body]';
      });

  Parser<String> charClassBody() =>
      ref0(charClassItem).star().map((items) => items.join());

  Parser<String> charClassItem() => [
    ref0(charClassSub),
    string(r'\i').map((_) => r'\p{L}_:'),
    string(r'\I').map((_) => r'\I'),
    string(r'\c').map((_) => r'\p{L}\p{N}.\-_:\p{M}'),
    string(r'\C').map((_) => r'\C'),
    seq2(char(r'\'), pattern('dDsSwW')).flatten(),
    ref0(unicodePropertyInClass),
    seq2(char(r'\'), anyOf(r'-[]\nrt')).flatten(),
    seq2(char(r'\'), anyOf(r'()[]{}^$|.?*+')).flatten(),
    pattern(r'^\]\\'),
  ].toChoiceParser();

  Parser<String> charClassSub() =>
      seq2(char('-'), ref0(charClass)).map2((dash, sub) => '$dash$sub');

  Parser<String> unicodePropertyInClass() =>
      seq3(
        string(r'\p{').or(string(r'\P{')),
        pattern('^}').plusString(),
        char('}'),
      ).map3((prefix, prop, _) {
        var p = prop;
        if (isFlagX) p = p.replaceAll(RegExp(r'\s+'), '');
        if (p.startsWith('Is')) {
          final blockName = p.substring(2);
          final range = xmlSchemaBlocks[blockName];
          if (range == null) {
            throw XPathEvaluationException(
              XPathErrorCode.FORX0002,
              'Invalid property name: $p',
            );
          }
          final startHex = range.$1.toRadixString(16);
          final endHex = range.$2.toRadixString(16);
          final r = r'\u{' + startHex + r'}-\u{' + endHex + r'}';
          return prefix == r'\p{' ? r : '^$r';
        }
        if (p.isEmpty || !_validCategories.contains(p)) {
          throw XPathEvaluationException(
            XPathErrorCode.FORX0002,
            'Invalid property name: $p',
          );
        }
        return '$prefix$p}';
      });
}

sealed class _ReplacePart {
  const new();
  String evaluate(RegExpMatch match);
}

class _LiteralPart extends _ReplacePart {
  const new(this.value);
  final String value;
  @override
  String evaluate(RegExpMatch match) => value;
}

class _GroupPart extends _ReplacePart {
  const new(this.digits);
  final String digits;

  @override
  String evaluate(RegExpMatch match) {
    var len = digits.length;
    while (len > 0) {
      final sub = digits.substring(0, len);
      final nr = int.parse(sub);
      if (nr <= match.groupCount) {
        final replacement = match.group(nr) ?? '';
        final rest = digits.substring(len);
        return '$replacement$rest';
      }
      len--;
    }
    throw XPathEvaluationException(
      XPathErrorCode.FORX0004,
      'Group index \$$digits exceeds capturing group count ${match.groupCount}',
    );
  }
}

final _replaceTemplateParser = [
  seq2(char(r'\'), anyOf(r'\$')).map2((_, c) => _LiteralPart(c)),
  seq2(
    char(r'$'),
    digit().plusString(),
  ).map2((_, digits) => _GroupPart(digits)),
  anyOf(r'\$').neg().plusString().map(_LiteralPart.new),
].toChoiceParser().star().end();

/// Applies XPath 3.1 fn:replace semantics including replacement template validation and group substitution.
String applyXPathReplace(
  String input,
  RegExp regex,
  String replacement, {
  bool isLiteral = false,
}) {
  if (regex.hasMatch('')) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0003,
      'Regular expression matches zero-length string',
    );
  }

  if (isLiteral) {
    return input.replaceAll(regex, replacement);
  }

  final parsed = _replaceTemplateParser.parse(replacement);
  if (parsed is Failure) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0004,
      'Invalid replacement string: ${parsed.message}',
    );
  }
  final parts = parsed.value;

  return input.replaceAllMapped(regex, (match) {
    final regMatch = match as RegExpMatch;
    final buffer = StringBuffer();
    for (final part in parts) {
      buffer.write(part.evaluate(regMatch));
    }
    return buffer.toString();
  });
}

/// Evaluates XPath 3.1 `fn:analyze-string` returning an [XPathNode] wrapping the `<fn:analyze-string-result>` element.
XPathNode analyzeXPathString(String text, String pattern, {String? flags}) {
  validateXPathRegexFlags(flags);
  final hasFlags = flags != null;
  final isLiteral = hasFlags && flags.contains('q');
  final isFlagX = hasFlags && flags.contains('x');
  final XPathRegexGroup rootGroup;
  final String ecmaPattern;
  if (isLiteral) {
    rootGroup = XPathRegexGroup(nr: 0, parentNr: -1, children: []);
    ecmaPattern = RegExp.escape(pattern);
  } else {
    rootGroup = parseRegexGroups(pattern, isFlagX: isFlagX);
    ecmaPattern = translateXPathRegex(pattern, isFlagX: isFlagX);
  }
  final regex = RegExp(
    ecmaPattern,
    multiLine: hasFlags && flags.contains('m'),
    caseSensitive: !hasFlags || !flags.contains('i'),
    dotAll: hasFlags && flags.contains('s'),
    unicode: true,
  );
  if (regex.hasMatch('')) {
    throw XPathEvaluationException(
      XPathErrorCode.FORX0003,
      'Regular expression matches zero-length string',
    );
  }

  final builder = XmlBuilder();
  builder.element(
    'analyze-string-result',
    namespace: 'http://www.w3.org/2005/xpath-functions',
    namespaces: {'http://www.w3.org/2005/xpath-functions': 'fn'},
    nest: () {
      if (text.isEmpty) return;
      var lastIndex = 0;
      for (final match in regex.allMatches(text)) {
        if (match.start > lastIndex) {
          builder.element(
            'non-match',
            namespace: 'http://www.w3.org/2005/xpath-functions',
            nest: () {
              builder.text(text.substring(lastIndex, match.start));
            },
          );
        }
        builder.element(
          'match',
          namespace: 'http://www.w3.org/2005/xpath-functions',
          nest: () {
            _buildMatchChildren(builder, match, rootGroup, match[0]!);
          },
        );
        lastIndex = match.end;
      }
      if (lastIndex < text.length) {
        builder.element(
          'non-match',
          namespace: 'http://www.w3.org/2005/xpath-functions',
          nest: () {
            builder.text(text.substring(lastIndex));
          },
        );
      }
    },
  );
  return XPathNode(builder.buildDocument().rootElement);
}

void _buildMatchChildren(
  XmlBuilder builder,
  RegExpMatch match,
  XPathRegexGroup parentGroup,
  String parentText,
) {
  final activeChildren = parentGroup.children
      .where((child) => match.group(child.nr) != null)
      .toList();
  if (activeChildren.isEmpty) {
    if (parentText.isNotEmpty) {
      builder.text(parentText);
    }
    return;
  }
  var cursor = 0;
  for (var i = 0; i < activeChildren.length; i++) {
    final child = activeChildren[i];
    final childText = match.group(child.nr)!;
    if (childText.isNotEmpty) {
      var maxEnd = parentText.length;
      for (var j = i + 1; j < activeChildren.length; j++) {
        final nextText = match.group(activeChildren[j].nr)!;
        if (nextText.isNotEmpty) {
          final nextIdx = parentText.lastIndexOf(nextText);
          if (nextIdx != -1 && nextIdx < maxEnd) {
            maxEnd = nextIdx;
          }
          break;
        }
      }
      final searchLimit = maxEnd >= childText.length
          ? maxEnd - childText.length
          : cursor;
      var idx = parentText.lastIndexOf(childText, searchLimit);
      if (idx < cursor) {
        idx = parentText.indexOf(childText, cursor);
      }
      if (idx > cursor) {
        builder.text(parentText.substring(cursor, idx));
      }
      builder.element(
        'group',
        namespace: 'http://www.w3.org/2005/xpath-functions',
        attributes: {'nr': child.nr.toString()},
        nest: () {
          _buildMatchChildren(builder, match, child, childText);
        },
      );
      cursor = idx + childText.length;
    } else {
      if (cursor < parentText.length) {
        builder.text(parentText.substring(cursor));
        cursor = parentText.length;
      }
      builder.element(
        'group',
        namespace: 'http://www.w3.org/2005/xpath-functions',
        attributes: {'nr': child.nr.toString()},
      );
    }
  }
  if (cursor < parentText.length) {
    builder.text(parentText.substring(cursor));
  }
}
