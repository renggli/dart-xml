import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:collation-key', () {
    test('returns collation key', () {
      expect(
        fnCollationKey(context, [const XPathSequence.single('abc')]),
        isXPathSequence(['abc']),
      );
    });
  });

  group('fn:concat', () {
    test('concatenates strings', () {
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence(['ab']),
      );
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
          const XPathSequence.single('c'),
        ]),
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
          const XPathSequence(['a', 'b']),
          const XPathSequence.single(','),
        ]),
        isXPathSequence(['a,b']),
      );
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
          const XPathSequence.single('-'),
        ]),
        isXPathSequence(['a-b-c']),
      );
    });

    test('joins strings without separator', () {
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
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
        fnStringJoin(context, [
          XPathSequence.empty,
          const XPathSequence.single(','),
        ]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:substring', () {
    test('returns substring with start position', () {
      expect(
        fnSubstring(context, [
          const XPathSequence.single('motor car'),
          const XPathSequence.single(6),
        ]),
        isXPathSequence([' car']),
      );
    });

    test('returns substring with start and length', () {
      expect(
        fnSubstring(context, [
          const XPathSequence.single('metadata'),
          const XPathSequence.single(4),
          const XPathSequence.single(3),
        ]),
        isXPathSequence(['ada']),
      );
    });

    test('handles floating point positions', () {
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(1.5),
          const XPathSequence.single(2.6),
        ]),
        isXPathSequence(['234']),
      );
    });

    test('handles zero index', () {
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(0),
          const XPathSequence.single(3),
        ]),
        isXPathSequence(['12']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnSubstring(context, [
          XPathSequence.empty,
          const XPathSequence.single(1),
        ]),
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
        'substring("12345", 0 div 0, 3)',
        isXPathSequence(['']),
      );
      expectEvaluate(
        xml,
        'substring("12345", 1, 0 div 0)',
        isXPathSequence(['']),
      );
      expectEvaluate(
        xml,
        'substring("12345", -42, 1 div 0)',
        isXPathSequence(['12345']),
      );
      expectEvaluate(
        xml,
        'substring("12345", -1 div 0, 1 div 0)',
        isXPathSequence(['']),
      );
    });
  });

  group('fn:string-length', () {
    test('returns string length', () {
      expect(
        fnStringLength(context, [const XPathSequence.single('abc')]),
        isXPathSequence([3]),
      );
    });

    test('returns zero for empty sequence', () {
      expect(
        fnStringLength(context, [XPathSequence.empty]),
        isXPathSequence([0]),
      );
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('hello');
      final contextWithNode = XPathContext.empty(textNode);
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
        fnNormalizeSpace(context, [const XPathSequence.single('  a  b   c  ')]),
        isXPathSequence(['a b c']),
      );
    });

    test('uses context item if no arguments', () {
      final textNode = XmlText('  hello   ');
      final contextWithNode = XPathContext.empty(textNode);
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
      expect(
        fnUpperCase(context, [const XPathSequence.single('abc')]),
        isXPathSequence(['ABC']),
      );
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
      expect(
        fnLowerCase(context, [const XPathSequence.single('ABC')]),
        isXPathSequence(['abc']),
      );
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
        fnContains(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnContains(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([false]),
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('a'),
          XPathSequence.empty,
        ]),
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
        fnStartsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnStartsWith(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
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
        fnEndsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnEndsWith(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:substring-before', () {
    test('returns substring before match', () {
      expect(
        fnSubstringBefore(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        isXPathSequence(['tat']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnSubstringBefore(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
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
        fnSubstringAfter(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        isXPathSequence(['too']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnSubstringAfter(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
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
        fnTranslate(context, [
          const XPathSequence.single('bar'),
          const XPathSequence.single('abc'),
          const XPathSequence.single('ABC'),
        ]),
        isXPathSequence(['BAr']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnTranslate(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence(['']),
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
        fnMatches(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles flags', () {
      expect(
        fnMatches(context, [
          const XPathSequence.single('a\nb'),
          const XPathSequence.single('^b'),
          const XPathSequence.single('m'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles escapes', () {
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(r'^\i$'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles class subtraction', () {
      expect(
        fnMatches(context, [
          const XPathSequence.single('b'),
          const XPathSequence.single(r'^[a-z-[aeiou]]$'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnMatches(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:replace', () {
    test('replaces matches', () {
      expect(
        fnReplace(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
          const XPathSequence.single('*'),
        ]),
        isXPathSequence(['a*cada*']),
      );
    });

    test('handles flags', () {
      expect(
        fnReplace(context, [
          const XPathSequence.single('a.b'),
          const XPathSequence.single('.'),
          const XPathSequence.single('-'),
          const XPathSequence.single('q'),
        ]),
        isXPathSequence(['a-b']),
      );
    });

    test('throws for invalid flags', () {
      expect(
        () => fnReplace(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
          const XPathSequence.single('Z'),
        ]),
        throwsA(isXPathEvaluationException(message: 'Invalid regex flag: Z')),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnReplace(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence(['']),
      );
    });

    test('throws for invalid regex pattern', () {
      expect(
        () => fnReplace(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('['),
          const XPathSequence.single('b'),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:codepoints-to-string', () {
    test('converts codepoints to string', () {
      expect(
        fnCodepointsToString(context, [
          const XPathSequence([97, 98, 99]),
        ]),
        isXPathSequence(['abc']),
      );
    });

    test('throws for invalid codepoint', () {
      expect(
        () => fnCodepointsToString(context, [const XPathSequence.single(-1)]),
        throwsA(
          isXPathEvaluationException(message: 'Invalid character code: -1'),
        ),
      );
    });
  });

  group('fn:string-to-codepoints', () {
    test('converts string to codepoints', () {
      expect(
        fnStringToCodepoints(context, [const XPathSequence.single('abc')]),
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
      expect(
        fnCompare(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([-1]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnCompare(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:codepoint-equal', () {
    test('returns true if codepoints equal', () {
      expect(
        fnCodepointEqual(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnCodepointEqual(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:contains-token', () {
    test('returns true if contains token', () {
      expect(
        fnContainsToken(context, [
          const XPathSequence.single('a b c'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnContainsToken(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:normalize-unicode', () {
    test('normalizes unicode', () {
      expect(
        fnNormalizeUnicode(context, [const XPathSequence.single('a')]),
        isXPathSequence(['a']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnNormalizeUnicode(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:tokenize', () {
    test('tokenizes string', () {
      expect(
        fnTokenize(context, [const XPathSequence.single('a b c')]),
        isXPathSequence(['a', 'b', 'c']),
      );
    });

    test('handles flags', () {
      expect(
        fnTokenize(context, [
          const XPathSequence.single('a.b.c'),
          const XPathSequence.single('.'),
          const XPathSequence.single('q'),
        ]),
        isXPathSequence(['a', 'b', 'c']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnTokenize(context, [
          XPathSequence.empty,
          const XPathSequence.single('a'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:analyze-string', () {
    test('throws not implemented', () {
      expect(
        () => fnAnalyzeString(context, [
          const XPathSequence.single(''),
          const XPathSequence.single(''),
        ]),
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
