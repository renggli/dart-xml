import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:collation-key', () {
    test('returns collation key', () {
      expect(fnCollationKey(context, [seq('abc')]), isXPathSequence(['abc']));
      expect(
        fnCollationKey(context, [seq('abc'), seq('http://example.com/col')]),
        isXPathSequence(['abc']),
      );
    });
  });

  group('fn:concat', () {
    test('concatenates strings', () {
      expect(fnConcat(context, [seq('a'), seq('b')]), isXPathSequence(['ab']));
      expect(
        fnConcat(context, [seq('a'), seq('b'), seq('c')]),
        isXPathSequence(['abc']),
      );
    });

    test('integration via xpathEvaluate', () {
      final xml = XmlDocument.parse('<r/>');
      expect(
        () => expectEvaluate(xml, 'concat()', anything),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => expectEvaluate(xml, 'concat("a")', anything),
        throwsA(isXPathEvaluationException()),
      );
      expectEvaluate(xml, 'concat("a", "b")', isXPathSequence(['ab']));
      expectEvaluate(xml, 'concat("a", "b", "c")', isXPathSequence(['abc']));
    });
  });

  group('fn:string-join', () {
    test('joins strings with separator', () {
      expect(
        fnStringJoin(context, [
          seq(['a', 'b']),
          seq(','),
        ]),
        isXPathSequence(['a,b']),
      );
      expect(
        fnStringJoin(context, [
          seq(['a', 'b', 'c']),
          seq('-'),
        ]),
        isXPathSequence(['a-b-c']),
      );
    });

    test('joins strings without separator', () {
      expect(
        fnStringJoin(context, [
          seq(['a', 'b', 'c']),
        ]),
        isXPathSequence(['abc']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnStringJoin(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
      expect(
        fnStringJoin(context, [XPathSequence.empty, seq(',')]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:substring', () {
    test('returns substring with start position', () {
      expect(
        fnSubstring(context, [seq('motor car'), seq(6)]),
        isXPathSequence([' car']),
      );
    });

    test('returns substring with start and length', () {
      expect(
        fnSubstring(context, [seq('metadata'), seq(4), seq(3)]),
        isXPathSequence(['ada']),
      );
    });

    test('handles floating point positions', () {
      expect(
        fnSubstring(context, [seq('12345'), seq(1.5), seq(2.6)]),
        isXPathSequence(['234']),
      );
    });

    test('handles zero index', () {
      expect(
        fnSubstring(context, [seq('12345'), seq(0), seq(3)]),
        isXPathSequence(['12']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnSubstring(context, [XPathSequence.empty, seq(1)]),
        isXPathSequence(['']),
      );
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
      expect(
        () => xml.xpathEvaluate('substring("12345", 0 div 0, 3)'),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:string-length', () {
    test('returns string length', () {
      expect(fnStringLength(context, [seq('abc')]), isXPathSequence([3]));
    });

    test('returns zero for empty sequence', () {
      expect(
        fnStringLength(context, [XPathSequence.empty]),
        isXPathSequence([0]),
      );
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('hello');
      final contextWithNode = const XPathConfiguration.raw().context(textNode);
      expect(fnStringLength(contextWithNode, []), isXPathSequence([5]));
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
      expect(
        fnNormalizeSpace(context, [seq('  a  b   c  ')]),
        isXPathSequence(['a b c']),
      );
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('  hello   ');
      final contextWithNode = const XPathConfiguration.raw().context(textNode);
      expect(fnNormalizeSpace(contextWithNode, []), isXPathSequence(['hello']));
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
      expect(fnUpperCase(context, [seq('abc')]), isXPathSequence(['ABC']));
    });

    test('returns empty for empty sequence', () {
      expect(
        fnUpperCase(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:lower-case', () {
    test('converts to lower case', () {
      expect(fnLowerCase(context, [seq('ABC')]), isXPathSequence(['abc']));
    });

    test('returns empty for empty sequence', () {
      expect(
        fnLowerCase(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:contains', () {
    test('returns true if contains substring', () {
      expect(
        fnContains(context, [seq('abc'), seq('b')]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnContains(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence([false]),
      );
      expect(
        fnContains(context, [seq('a'), XPathSequence.empty]),
        isXPathSequence([true]),
      );
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
      expect(
        fnStartsWith(context, [seq('tattoo'), seq('tat')]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnStartsWith(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence([false]),
      );
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
      expect(
        fnEndsWith(context, [seq('tattoo'), seq('too')]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnEndsWith(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:substring-before', () {
    test('returns substring before match', () {
      expect(
        fnSubstringBefore(context, [seq('tattoo'), seq('too')]),
        isXPathSequence(['tat']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnSubstringBefore(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence(['']),
      );
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
      expect(
        fnSubstringAfter(context, [seq('tattoo'), seq('tat')]),
        isXPathSequence(['too']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnSubstringAfter(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence(['']),
      );
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
      expect(
        fnTranslate(context, [seq('bar'), seq('abc'), seq('ABC')]),
        isXPathSequence(['BAr']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnTranslate(context, [XPathSequence.empty, seq('a'), seq('b')]),
        isXPathSequence(['']),
      );
      expect(
        fnTranslate(context, [seq('bar'), XPathSequence.empty, seq('ABC')]),
        isXPathSequence(['bar']),
      );
      expect(
        fnTranslate(context, [seq('bar'), seq('abc'), XPathSequence.empty]),
        isXPathSequence(['bar']),
      );
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
      expect(
        fnMatches(context, [seq('abc'), seq('b')]),
        isXPathSequence([true]),
      );
    });

    test('handles flags', () {
      expect(
        fnMatches(context, [seq('a\nb'), seq('^b'), seq('m')]),
        isXPathSequence([true]),
      );
    });

    test('handles escapes', () {
      expect(
        fnMatches(context, [seq('a'), seq(r'^\i$')]),
        isXPathSequence([true]),
      );
    });

    test('handles class subtraction', () {
      expect(
        fnMatches(context, [seq('b'), seq(r'^[a-z-[aeiou]]$')]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnMatches(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:replace', () {
    test('replaces matches', () {
      expect(
        fnReplace(context, [seq('abracadabra'), seq('bra'), seq('*')]),
        isXPathSequence(['a*cada*']),
      );
    });

    test('handles flags', () {
      expect(
        fnReplace(context, [seq('a.b'), seq('.'), seq('-'), seq('q')]),
        isXPathSequence(['a-b']),
      );
    });

    test('throws for invalid flags', () {
      expect(
        () => fnReplace(context, [seq('a'), seq('a'), seq('b'), seq('Z')]),
        throwsA(isXPathEvaluationException(message: 'Invalid regex flag: Z')),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnReplace(context, [XPathSequence.empty, seq('a'), seq('b')]),
        isXPathSequence(['']),
      );
    });

    test('throws for invalid regex pattern', () {
      expect(
        () => fnReplace(context, [seq('a'), seq('['), seq('b')]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:codepoints-to-string', () {
    test('converts codepoints to string', () {
      expect(
        fnCodepointsToString(context, [
          seq([97, 98, 99]),
        ]),
        isXPathSequence(['abc']),
      );
    });

    test('throws for invalid codepoint', () {
      expect(
        () => fnCodepointsToString(context, [seq(-1)]),
        throwsA(
          isXPathEvaluationException(message: 'Invalid character code: -1'),
        ),
      );
    });

    test('converts valid boundary codepoints to string', () {
      expect(
        fnCodepointsToString(context, [
          seq([0x9, 0xA, 0xD, 0x20, 0xD7FF, 0xE000, 0xFFFD, 0x10000, 0x10FFFF]),
        ]),
        isXPathSequence([
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
        ]),
      );
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
        expect(
          () => fnCodepointsToString(context, [seq(codepoint)]),
          throwsA(
            isXPathEvaluationException(
              message: 'Invalid character code: $codepoint',
            ),
          ),
        );
      }
    });
  });

  group('fn:string-to-codepoints', () {
    test('converts string to codepoints', () {
      expect(
        fnStringToCodepoints(context, [seq('abc')]),
        isXPathSequence([97, 98, 99]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnStringToCodepoints(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:compare', () {
    test('compares strings', () {
      expect(fnCompare(context, [seq('a'), seq('b')]), isXPathSequence([-1]));
    });

    test('3-argument collation compares strings', () {
      expect(
        fnCompare(context, [
          seq('a'),
          seq('b'),
          seq('http://www.w3.org/2005/xpath-functions/collation/codepoint'),
        ]),
        isXPathSequence([-1]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnCompare(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('collation overloads for string matching functions', () {
    const collation =
        'http://www.w3.org/2005/xpath-functions/collation/codepoint';

    test('fn:contains with 3 arguments', () {
      expect(
        fnContains(context, [seq('hello world'), seq('world'), seq(collation)]),
        isXPathSequence([true]),
      );
    });

    test('fn:starts-with with 3 arguments', () {
      expect(
        fnStartsWith(context, [
          seq('hello world'),
          seq('hello'),
          seq(collation),
        ]),
        isXPathSequence([true]),
      );
    });

    test('fn:ends-with with 3 arguments', () {
      expect(
        fnEndsWith(context, [seq('hello world'), seq('world'), seq(collation)]),
        isXPathSequence([true]),
      );
    });

    test('fn:substring-before with 3 arguments', () {
      expect(
        fnSubstringBefore(context, [
          seq('hello world'),
          seq(' '),
          seq(collation),
        ]),
        isXPathSequence(['hello']),
      );
    });

    test('fn:substring-after with 3 arguments', () {
      expect(
        fnSubstringAfter(context, [
          seq('hello world'),
          seq(' '),
          seq(collation),
        ]),
        isXPathSequence(['world']),
      );
    });
  });

  group('fn:codepoint-equal', () {
    test('returns true if codepoints equal', () {
      expect(
        fnCodepointEqual(context, [seq('a'), seq('a')]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnCodepointEqual(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:contains-token', () {
    test('returns true if contains token', () {
      expect(
        fnContainsToken(context, [seq('a b c'), seq('b')]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnContainsToken(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence([false]),
      );
    });

    test('supports collation argument', () {
      expect(
        fnContainsToken(context, [
          seq('a b c'),
          seq('b'),
          seq('http://example.com/col'),
        ]),
        isXPathSequence([true]),
      );
    });
  });

  group('fn:normalize-unicode', () {
    test('normalizes unicode', () {
      expect(fnNormalizeUnicode(context, [seq('a')]), isXPathSequence(['a']));
      expect(
        fnNormalizeUnicode(context, [seq('a'), seq('NFC')]),
        isXPathSequence(['a']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnNormalizeUnicode(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
      expect(
        fnNormalizeUnicode(context, [XPathSequence.empty, seq('NFC')]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:tokenize', () {
    test('tokenizes string', () {
      expect(
        fnTokenize(context, [seq('a b c')]),
        isXPathSequence(['a', 'b', 'c']),
      );
    });

    test('handles flags', () {
      expect(
        fnTokenize(context, [seq('a.b.c'), seq('.'), seq('q')]),
        isXPathSequence(['a', 'b', 'c']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnTokenize(context, [XPathSequence.empty, seq('a')]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:analyze-string', () {
    test('throws not implemented', () {
      expect(
        () => fnAnalyzeString(context, [seq(''), seq('')]),
        throwsA(
          isXPathEvaluationException(
            message: 'Not implemented: fn:analyze-string',
          ),
        ),
      );
      expect(
        () => fnAnalyzeString(context, [seq(''), seq(''), seq('i')]),
        throwsA(
          isXPathEvaluationException(
            message: 'Not implemented: fn:analyze-string',
          ),
        ),
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
