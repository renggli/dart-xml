import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:collation-key', () {
    test('returns collation key', () {
      check(fnCollationKey(context, [seq('abc')])).isXPathSequence(['abc']);
      check(
        fnCollationKey(context, [seq('abc'), seq('http://example.com/col')]),
      ).isXPathSequence(['abc']);
    });
  });

  group('fn:concat', () {
    test('concatenates strings', () {
      check(fnConcat(context, [seq('a'), seq('b')])).isXPathSequence(['ab']);
      check(fnConcat(context, [seq('a'), seq('b'), seq('c')]))
          .isXPathSequence(['abc']);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      check(() => xml.xpathEvaluate('concat()'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => xml.xpathEvaluate('concat("a")'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      expectEvaluate(xml, 'concat("a", "b")', isXPathSequence(['ab']));
      expectEvaluate(xml, 'concat("a", "b", "c")', isXPathSequence(['abc']));
    });
  });

  group('fn:string-join', () {
    test('joins strings with separator', () {
      check(
        fnStringJoin(context, [
          seq(['a', 'b']),
          seq(','),
        ]),
      ).isXPathSequence(['a,b']);
      check(
        fnStringJoin(context, [
          seq(['a', 'b', 'c']),
          seq('-'),
        ]),
      ).isXPathSequence(['a-b-c']);
    });

    test('joins strings without separator', () {
      check(
        fnStringJoin(context, [
          seq(['a', 'b', 'c']),
        ]),
      ).isXPathSequence(['abc']);
    });

    test('handles empty sequence', () {
      check(fnStringJoin(context, [XPathSequence.empty])).isXPathSequence(['']);
      check(fnStringJoin(context, [XPathSequence.empty, seq(',')]))
          .isXPathSequence(['']);
    });
  });

  group('fn:substring', () {
    test('returns substring with start position', () {
      check(fnSubstring(context, [seq('motor car'), seq(6)]))
          .isXPathSequence([' car']);
    });

    test('returns substring with start and length', () {
      check(fnSubstring(context, [seq('metadata'), seq(4), seq(3)]))
          .isXPathSequence(['ada']);
    });

    test('handles floating point positions', () {
      check(fnSubstring(context, [seq('12345'), seq(1.5), seq(2.6)]))
          .isXPathSequence(['234']);
    });

    test('handles zero index', () {
      check(fnSubstring(context, [seq('12345'), seq(0), seq(3)]))
          .isXPathSequence(['12']);
    });

    test('handles empty sequence', () {
      check(fnSubstring(context, [XPathSequence.empty, seq(1)]))
          .isXPathSequence(['']);
    });

    test('handles Unicode codepoints beyond BMP (surrogate pairs)', () {
      check(fnSubstring(context, [seq('😀hello'), seq(1), seq(1)]))
          .isXPathSequence(['😀']);
      check(fnSubstring(context, [seq('😀hello'), seq(2), seq(2)]))
          .isXPathSequence(['he']);
    });

    test('XPath rounding for negative halves', () {
      check(fnSubstring(context, [seq('12345'), seq(-1.5), seq(3.5)]))
          .isXPathSequence(['12']);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'substring("12345", 3)', isXPathSequence(['345']));
      expectEvaluate(xml, 'substring("12345", 2, 3)', isXPathSequence(['234']));
      expectEvaluate(xml, 'substring("12345", 0, 3)', isXPathSequence(['12']));
      expectEvaluate(xml, 'substring("12345", 4, 9)', isXPathSequence(['45']));
      expectEvaluate(
        xml,
        'substring("12345", 1.5, 2.6)',
        isXPathSequence(['234']),
      );
      expectEvaluate(
        xml,
        'substring("12345", xs:double(0) div xs:double(0), 3)',
        isXPathSequence(['']),
      );
      expectEvaluate(
        xml,
        'substring("12345", 1, xs:double(0) div xs:double(0))',
        isXPathSequence(['']),
      );
      expectEvaluate(
        xml,
        'substring("12345", -42, xs:double(1) div xs:double(0))',
        isXPathSequence(['12345']),
      );
      expectEvaluate(
        xml,
        'substring("12345", -xs:double(1) div xs:double(0), xs:double(1) div xs:double(0))',
        isXPathSequence(['']),
      );
      check(() => xml.xpathEvaluate('substring("12345", 0 div 0, 3)'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('fn:string-length', () {
    test('returns string length', () {
      check(fnStringLength(context, [seq('abc')])).isXPathSequence([3]);
    });

    test('returns zero for empty sequence', () {
      check(fnStringLength(context, [XPathSequence.empty]))
          .isXPathSequence([0]);
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('hello');
      final contextWithNode = const XPathConfiguration.raw().context(textNode);
      check(fnStringLength(contextWithNode, [])).isXPathSequence([5]);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'string-length("")', isXPathSequence([0]));
      expectEvaluate(xml, 'string-length("1")', isXPathSequence([1]));
      expectEvaluate(xml, 'string-length("12")', isXPathSequence([2]));
    });
  });

  group('fn:normalize-space', () {
    test('normalizes spaces', () {
      check(fnNormalizeSpace(context, [seq('  a  b   c  ')]))
          .isXPathSequence(['a b c']);
    });

    test('does not strip non-XML Unicode whitespace such as NBSP (U+00A0)', () {
      check(fnNormalizeSpace(context, [seq('\u00A0hello\u00A0')]))
          .isXPathSequence(['\u00A0hello\u00A0']);
      check(fnTokenize(context, [seq('\u00A0hello\u00A0')]))
          .isXPathSequence(['\u00A0hello\u00A0']);
      check(
        fnContainsToken(context, [
          seq('\u00A0hello\u00A0'),
          seq('\u00A0hello\u00A0'),
        ]),
      ).isXPathSequence([true]);
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('  hello   ');
      final contextWithNode = const XPathConfiguration.raw().context(textNode);
      check(fnNormalizeSpace(contextWithNode, [])).isXPathSequence(['hello']);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'normalize-space("")', isXPathSequence(['']));
      expectEvaluate(xml, 'normalize-space(" 1 ")', isXPathSequence(['1']));
      expectEvaluate(
        xml,
        'normalize-space(" 1  2 ")',
        isXPathSequence(['1 2']),
      );
    });
  });

  group('fn:upper-case', () {
    test('converts to upper case', () {
      check(fnUpperCase(context, [seq('abc')])).isXPathSequence(['ABC']);
    });

    test('returns empty for empty sequence', () {
      check(fnUpperCase(context, [XPathSequence.empty])).isXPathSequence(['']);
    });
  });

  group('fn:lower-case', () {
    test('converts to lower case', () {
      check(fnLowerCase(context, [seq('ABC')])).isXPathSequence(['abc']);
    });

    test('returns empty for empty sequence', () {
      check(fnLowerCase(context, [XPathSequence.empty])).isXPathSequence(['']);
    });
  });

  group('fn:contains', () {
    test('returns true if contains substring', () {
      check(fnContains(context, [seq('abc'), seq('b')]))
          .isXPathSequence([true]);
    });

    test('handles empty sequence', () {
      check(fnContains(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence([false]);
      check(fnContains(context, [seq('a'), XPathSequence.empty]))
          .isXPathSequence([true]);
      check(fnContains(context, [XPathSequence.empty, seq('')]))
          .isXPathSequence([true]);
      check(fnContains(context, [XPathSequence.empty, XPathSequence.empty]))
          .isXPathSequence([true]);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'contains("abc", "")', isXPathSequence([true]));
      expectEvaluate(xml, 'contains("abc", "a")', isXPathSequence([true]));
      expectEvaluate(xml, 'contains("abc", "d")', isXPathSequence([false]));
    });
  });

  group('fn:starts-with', () {
    test('returns true if starts with', () {
      check(fnStartsWith(context, [seq('tattoo'), seq('tat')]))
          .isXPathSequence([true]);
    });

    test('handles empty sequence', () {
      check(fnStartsWith(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence([false]);
      check(fnStartsWith(context, [XPathSequence.empty, seq('')]))
          .isXPathSequence([true]);
      check(fnStartsWith(context, [XPathSequence.empty, XPathSequence.empty]))
          .isXPathSequence([true]);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(xml, 'starts-with("abc", "")', isXPathSequence([true]));
      expectEvaluate(xml, 'starts-with("abc", "a")', isXPathSequence([true]));
      expectEvaluate(xml, 'starts-with("abc", "bc")', isXPathSequence([false]));
    });
  });

  group('fn:ends-with', () {
    test('returns true if ends with', () {
      check(fnEndsWith(context, [seq('tattoo'), seq('too')]))
          .isXPathSequence([true]);
    });

    test('handles empty sequence', () {
      check(fnEndsWith(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence([false]);
      check(fnEndsWith(context, [XPathSequence.empty, seq('')]))
          .isXPathSequence([true]);
      check(fnEndsWith(context, [XPathSequence.empty, XPathSequence.empty]))
          .isXPathSequence([true]);
    });
  });

  group('fn:substring-before', () {
    test('returns substring before match', () {
      check(fnSubstringBefore(context, [seq('tattoo'), seq('too')]))
          .isXPathSequence(['tat']);
    });

    test('handles empty sequence', () {
      check(fnSubstringBefore(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence(['']);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(
        xml,
        'substring-before("abcde", "c")',
        isXPathSequence(['ab']),
      );
      expectEvaluate(
        xml,
        'substring-before("abcde", "x")',
        isXPathSequence(['']),
      );
    });
  });

  group('fn:substring-after', () {
    test('returns substring after match', () {
      check(fnSubstringAfter(context, [seq('tattoo'), seq('tat')]))
          .isXPathSequence(['too']);
    });

    test('handles empty sequence', () {
      check(fnSubstringAfter(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence(['']);
      check(fnSubstringAfter(context, [seq('abc'), XPathSequence.empty]))
          .isXPathSequence(['abc']);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(
        xml,
        'substring-after("abcde", "c")',
        isXPathSequence(['de']),
      );
      expectEvaluate(
        xml,
        'substring-after("abcde", "x")',
        isXPathSequence(['']),
      );
    });
  });

  group('fn:translate', () {
    test('translates characters', () {
      check(fnTranslate(context, [seq('bar'), seq('abc'), seq('ABC')]))
          .isXPathSequence(['BAr']);
    });

    test('handles empty sequence', () {
      check(fnTranslate(context, [XPathSequence.empty, seq('a'), seq('b')]))
          .isXPathSequence(['']);
      check(fnTranslate(context, [seq('bar'), XPathSequence.empty, seq('ABC')]))
          .isXPathSequence(['bar']);
      check(fnTranslate(context, [seq('bar'), seq('abc'), XPathSequence.empty]))
          .isXPathSequence(['bar']);
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expectEvaluate(
        xml,
        'translate("bar", "abc", "ABC")',
        isXPathSequence(['BAr']),
      );
      expectEvaluate(
        xml,
        'translate("-aaa-", "a-", "A")',
        isXPathSequence(['AAA']),
      );
    });
  });

  group('fn:matches', () {
    test('returns true if matches regex', () {
      check(fnMatches(context, [seq('abc'), seq('b')])).isXPathSequence([true]);
    });

    test('handles flags', () {
      check(fnMatches(context, [seq('a\nb'), seq('^b'), seq('m')]))
          .isXPathSequence([true]);
    });

    test('handles escapes', () {
      check(fnMatches(context, [seq('a'), seq(r'^\i$')]))
          .isXPathSequence([true]);
    });

    test('handles class subtraction', () {
      check(fnMatches(context, [seq('b'), seq(r'^[a-z-[aeiou]]$')]))
          .isXPathSequence([true]);
    });

    test('handles empty sequence', () {
      check(fnMatches(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence([false]);
    });

    test('throws for empty sequence pattern or flags', () {
      check(() => fnMatches(context, [seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => fnMatches(context, [seq('a'), seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });
  });

  group('fn:replace', () {
    test('replaces matches', () {
      check(fnReplace(context, [seq('abracadabra'), seq('bra'), seq('*')]))
          .isXPathSequence(['a*cada*']);
    });

    test('handles flags', () {
      check(fnReplace(context, [seq('a.b'), seq('.'), seq('-'), seq('q')]))
          .isXPathSequence(['a-b']);
    });

    test('throws for invalid flags', () {
      check(() => fnReplace(context, [seq('a'), seq('a'), seq('b'), seq('Z')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Invalid regex flag: Z'));
    });

    test('handles empty sequence', () {
      check(fnReplace(context, [XPathSequence.empty, seq('a'), seq('b')]))
          .isXPathSequence(['']);
    });

    test('throws for empty sequence pattern, replacement, or flags', () {
      check(() => fnReplace(context, [seq('a'), XPathSequence.empty, seq('b')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => fnReplace(context, [seq('a'), seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(
        () => fnReplace(context, [
          seq('a'),
          XPathSequence.empty,
          seq('b'),
          seq('q'),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
      check(
        () => fnReplace(context, [
          seq('a'),
          seq('a'),
          XPathSequence.empty,
          seq('q'),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
      check(
        () => fnReplace(context, [
          seq('a'),
          seq('a'),
          seq('b'),
          XPathSequence.empty,
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });

    test('throws for invalid regex pattern', () {
      check(() => fnReplace(context, [seq('a'), seq('['), seq('b')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('fn:codepoints-to-string', () {
    test('converts codepoints to string', () {
      check(
        fnCodepointsToString(context, [
          seq([97, 98, 99]),
        ]),
      ).isXPathSequence(['abc']);
    });

    test('throws for invalid codepoint', () {
      check(() => fnCodepointsToString(context, [seq(-1)]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Invalid character code: -1'),
          );
    });

    test('converts valid boundary codepoints to string', () {
      check(
        fnCodepointsToString(context, [
          seq([0x9, 0xA, 0xD, 0x20, 0xD7FF, 0xE000, 0xFFFD, 0x10000, 0x10FFFF]),
        ]),
      ).isXPathSequence([
        String.fromCharCodes([
          0x9,
          0xA,
          0xD,
          0x20,
          0xD7FF,
          0xE000,
          0xFFFD,
          0x10000,
          0x10FFFF,
        ]),
      ]);
    });

    test('throws for invalid XML codepoints', () {
      final invalidCodepoints = [
        0,
        8,
        0xB,
        0xC,
        0xE,
        0x1F,
        0xD800,
        0xDFFF,
        0xFFFE,
        0xFFFF,
        0x110000,
      ];
      for (final codepoint in invalidCodepoints) {
        check(() => fnCodepointsToString(context, [seq(codepoint)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(
                message: 'Invalid character code: $codepoint',
              ),
            );
      }
    });
  });

  group('fn:string-to-codepoints', () {
    test('converts string to codepoints', () {
      check(fnStringToCodepoints(context, [seq('abc')]))
          .isXPathSequence([97, 98, 99]);
    });

    test('handles empty sequence', () {
      check(fnStringToCodepoints(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:compare', () {
    test('compares strings', () {
      check(fnCompare(context, [seq('a'), seq('b')])).isXPathSequence([-1]);
    });

    test('3-argument collation compares strings', () {
      check(
        fnCompare(context, [
          seq('a'),
          seq('b'),
          seq('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
        ]),
      ).isXPathSequence([-1]);
    });

    test('handles empty sequence', () {
      check(fnCompare(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence(isEmpty);
    });

    test('Unicode codepoint ordering for supplementary characters', () {
      check(fnCompare(context, [seq('\u{10000}'), seq('\uE000')]))
          .isXPathSequence([1]);
      check(fnCompare(context, [seq('\uE000'), seq('\u{10000}')]))
          .isXPathSequence([-1]);
    });
  });

  group('collation overloads for string matching functions', () {
    const collation =
        'http://www.w3.org/2005/xpath-functions/collation/codepoint';

    test('fn:contains with 3 arguments', () {
      check(
        fnContains(context, [seq('hello world'), seq('world'), seq(collation)]),
      ).isXPathSequence([true]);
    });

    test('fn:starts-with with 3 arguments', () {
      check(
        fnStartsWith(context, [
          seq('hello world'),
          seq('hello'),
          seq(collation),
        ]),
      ).isXPathSequence([true]);
    });

    test('fn:ends-with with 3 arguments', () {
      check(
        fnEndsWith(context, [seq('hello world'), seq('world'), seq(collation)]),
      ).isXPathSequence([true]);
    });

    test('fn:substring-before with 3 arguments', () {
      check(
        fnSubstringBefore(context, [
          seq('hello world'),
          seq(' '),
          seq(collation),
        ]),
      ).isXPathSequence(['hello']);
    });

    test('fn:substring-after with 3 arguments', () {
      check(
        fnSubstringAfter(context, [
          seq('hello world'),
          seq(' '),
          seq(collation),
        ]),
      ).isXPathSequence(['world']);
    });
  });

  group('fn:codepoint-equal', () {
    test('returns true if codepoints equal', () {
      check(fnCodepointEqual(context, [seq('a'), seq('a')]))
          .isXPathSequence([true]);
    });

    test('handles empty sequence', () {
      check(fnCodepointEqual(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:contains-token', () {
    test('returns true if contains token', () {
      check(fnContainsToken(context, [seq('a b c'), seq('b')]))
          .isXPathSequence([true]);
    });

    test('handles empty sequence', () {
      check(fnContainsToken(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence([false]);
    });

    test('supports collation argument', () {
      check(
        fnContainsToken(context, [
          seq('a b c'),
          seq('b'),
          seq('http://example.com/col'),
        ]),
      ).isXPathSequence([true]);
    });

    test('returns false for empty token or whitespace-only token', () {
      check(fnContainsToken(context, [seq(''), seq('')]))
          .isXPathSequence([false]);
      check(fnContainsToken(context, [seq('   '), seq('   ')]))
          .isXPathSequence([false]);
    });

    test('does not treat non-XML Unicode whitespace as separator', () {
      check(fnContainsToken(context, [seq('a\u00A0b'), seq('a')]))
          .isXPathSequence([false]);
      check(fnContainsToken(context, [seq('a\u00A0b'), seq('a\u00A0b')]))
          .isXPathSequence([true]);
    });

    test('handles input sequence of multiple strings', () {
      check(
        fnContainsToken(context, [
          XPathSequence([
            const XPathString('abc def'),
            const XPathString('ghi'),
          ]),
          seq('def'),
        ]),
      ).isXPathSequence([true]);
    });
  });

  group('fn:normalize-unicode', () {
    test('normalizes unicode', () {
      check(fnNormalizeUnicode(context, [seq('a')])).isXPathSequence(['a']);
      check(fnNormalizeUnicode(context, [seq('a'), seq('NFC')]))
          .isXPathSequence(['a']);
      check(fnNormalizeUnicode(context, [seq('a'), seq('NFD')]))
          .isXPathSequence(['a']);
      check(fnNormalizeUnicode(context, [seq('a'), seq('NFKC')]))
          .isXPathSequence(['a']);
      check(fnNormalizeUnicode(context, [seq('a'), seq('NFKD')]))
          .isXPathSequence(['a']);
      check(fnNormalizeUnicode(context, [seq('a'), seq('FULLY-NORMALIZED')]))
          .isXPathSequence(['a']);
      check(fnNormalizeUnicode(context, [seq('a'), seq('')]))
          .isXPathSequence(['a']);
    });

    test('throws FOCH0003 for unsupported normalization form', () {
      check(() => fnNormalizeUnicode(context, [seq('a'), seq('invalid-form')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOCH0003),
          );
    });

    test('throws XPTY0004 for non-string normalization form or empty', () {
      check(() => fnNormalizeUnicode(context, [seq('a'), seq(123)]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => fnNormalizeUnicode(context, [seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });

    test('handles empty sequence', () {
      check(fnNormalizeUnicode(context, [XPathSequence.empty]))
          .isXPathSequence(['']);
      check(fnNormalizeUnicode(context, [XPathSequence.empty, seq('NFC')]))
          .isXPathSequence(['']);
    });
  });

  group('fn:tokenize', () {
    test('tokenizes string', () {
      check(fnTokenize(context, [seq('a b c')]))
          .isXPathSequence(['a', 'b', 'c']);
    });

    test('does not tokenize on non-XML Unicode whitespace', () {
      check(fnTokenize(context, [seq('a\u00A0b c')]))
          .isXPathSequence(['a\u00A0b', 'c']);
    });

    test('handles flags', () {
      check(fnTokenize(context, [seq('a.b.c'), seq('.'), seq('q')]))
          .isXPathSequence(['a', 'b', 'c']);
    });

    test('handles empty sequence', () {
      check(fnTokenize(context, [XPathSequence.empty, seq('a')]))
          .isXPathSequence(isEmpty);
    });

    test('throws for empty sequence pattern or flags', () {
      check(() => fnTokenize(context, [seq('a'), XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(
        () => fnTokenize(context, [seq('a'), XPathSequence.empty, seq('q')]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
      check(
        () => fnTokenize(context, [seq('a'), seq('a'), XPathSequence.empty]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });
  });

  group('fn:analyze-string', () {
    test('analyzes string with matching and non-matching parts', () {
      final res = fnAnalyzeString(context, [seq('banana'), seq('a')]);
      check(res).length.equals(1);
      check((res.first as XPathNode).node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:non-match>b</fn:non-match>'
        '<fn:match>a</fn:match>'
        '<fn:non-match>n</fn:non-match>'
        '<fn:match>a</fn:match>'
        '<fn:non-match>n</fn:non-match>'
        '<fn:match>a</fn:match>'
        '</fn:analyze-string-result>',
      );
    });

    test('analyzes string with groups', () {
      final res = fnAnalyzeString(context, [seq('banana'), seq('a(n)')]);
      check(res).length.equals(1);
      check((res.first as XPathNode).node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
        '<fn:non-match>b</fn:non-match>'
        '<fn:match>a<fn:group nr="1">n</fn:group></fn:match>'
        '<fn:match>a<fn:group nr="1">n</fn:group></fn:match>'
        '<fn:non-match>a</fn:non-match>'
        '</fn:analyze-string-result>',
      );
    });

    test(
      'analyzes string with empty capture group between non-empty groups',
      () {
        final res = fnAnalyzeString(context, [seq('ab'), seq('(a)()(b)')]);
        check(res).length.equals(1);
        check((res.first as XPathNode).node.toXmlString()).equals(
          '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
          '<fn:match>'
          '<fn:group nr="1">a</fn:group>'
          '<fn:group nr="2"/>'
          '<fn:group nr="3">b</fn:group>'
          '</fn:match>'
          '</fn:analyze-string-result>',
        );
      },
    );

    test(
      'analyzes string with repeated sibling groups matching identical text',
      () {
        final res = fnAnalyzeString(context, [seq('aaa'), seq('(a)(a)(a)')]);
        check(res).length.equals(1);
        check((res.first as XPathNode).node.toXmlString()).equals(
          '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions">'
          '<fn:match>'
          '<fn:group nr="1">a</fn:group>'
          '<fn:group nr="2">a</fn:group>'
          '<fn:group nr="3">a</fn:group>'
          '</fn:match>'
          '</fn:analyze-string-result>',
        );
      },
    );

    test('handles empty input', () {
      final res = fnAnalyzeString(context, [seq(''), seq('abc')]);
      check((res.first as XPathNode).node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions"/>',
      );
    });

    test('handles empty sequence as input', () {
      final res = fnAnalyzeString(context, [XPathSequence.empty, seq('abc')]);
      check((res.first as XPathNode).node.toXmlString()).equals(
        '<fn:analyze-string-result xmlns:fn="http://www.w3.org/2005/xpath-functions"/>',
      );
    });

    test('throws for empty sequence pattern', () {
      check(
        () => fnAnalyzeString(context, [seq('banana'), XPathSequence.empty]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });

    test('throws for invalid flags', () {
      check(() => fnAnalyzeString(context, [seq('abc'), seq('abc'), seq('w')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0001),
          );
    });

    test('throws for invalid regex pattern', () {
      check(() => fnAnalyzeString(context, [seq('abc'), seq(')-(')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0002),
          );
    });

    test('throws for pattern matching zero-length string', () {
      check(() => fnAnalyzeString(context, [seq('abc'), seq('a|b|c?')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORX0003),
          );
    });
  });

  group('fn:string', () {
    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
      expectEvaluate(xml, 'string()', isXPathSequence(['123']));
      expectEvaluate(xml, 'string(/r/b)', isXPathSequence(['23']));
      expectEvaluate(xml, 'string("")', isXPathSequence(['']));
      expectEvaluate(xml, 'string("hello")', isXPathSequence(['hello']));
      expectEvaluate(xml, 'string(0)', isXPathSequence(['0']));
      expectEvaluate(xml, 'string(42)', isXPathSequence(['42']));
      expectEvaluate(xml, 'string(false())', isXPathSequence(['false']));
      expectEvaluate(xml, 'string(true())', isXPathSequence(['true']));
    });
  });
}
