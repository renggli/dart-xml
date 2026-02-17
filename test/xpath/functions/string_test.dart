import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('string', () {
    test('fn:collation-key', () {
      expect(
        fnCollationKey(context, [const XPathSequence.single('abc')]),
        isXPathSequence(['abc']),
      );
    });
    test('fn:concat', () {
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
    test('fn:string-join', () {
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
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
        ]),
        isXPathSequence(['abc']),
      );
    });
    test('fn:substring', () {
      expect(
        fnSubstring(context, [
          const XPathSequence.single('motor car'),
          const XPathSequence.single(6),
        ]),
        isXPathSequence([' car']),
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('metadata'),
          const XPathSequence.single(4),
          const XPathSequence.single(3),
        ]),
        isXPathSequence(['ada']),
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(1.5),
          const XPathSequence.single(2.6),
        ]),
        isXPathSequence(['234']),
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(0),
          const XPathSequence.single(3),
        ]),
        isXPathSequence(['12']),
      );
    });
    test('fn:string-length', () {
      expect(
        fnStringLength(context, [const XPathSequence.single('abc')]),
        isXPathSequence([3]),
      );
      expect(
        fnStringLength(context, [XPathSequence.empty]),
        isXPathSequence([0]),
      );
    });
    test('fn:normalize-space', () {
      expect(
        fnNormalizeSpace(context, [const XPathSequence.single('  a  b   c  ')]),
        isXPathSequence(['a b c']),
      );
    });
    test('fn:upper-case', () {
      expect(
        fnUpperCase(context, [const XPathSequence.single('abc')]),
        isXPathSequence(['ABC']),
      );
    });
    test('fn:lower-case', () {
      expect(
        fnLowerCase(context, [const XPathSequence.single('ABC')]),
        isXPathSequence(['abc']),
      );
    });
    test('fn:contains', () {
      expect(
        fnContains(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('t'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('z'),
        ]),
        isXPathSequence([false]),
      );
    });
    test('fn:starts-with', () {
      expect(
        fnStartsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        isXPathSequence([true]),
      );
    });
    test('fn:ends-with', () {
      expect(
        fnEndsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        isXPathSequence([true]),
      );
    });
    test('fn:substring-before', () {
      expect(
        fnSubstringBefore(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        isXPathSequence(['tat']),
      );
    });
    test('fn:substring-after', () {
      expect(
        fnSubstringAfter(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        isXPathSequence(['too']),
      );
    });
    test('fn:translate', () {
      expect(
        fnTranslate(context, [
          const XPathSequence.single('bar'),
          const XPathSequence.single('abc'),
          const XPathSequence.single('ABC'),
        ]),
        isXPathSequence(['BAr']),
      );
    });
    test('fn:matches', () {
      expect(
        fnMatches(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
        ]),
        isXPathSequence([true]),
      );
    });
    test('fn:replace', () {
      expect(
        fnReplace(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
          const XPathSequence.single('*'),
        ]),
        isXPathSequence(['a*cada*']),
      );
    });
    test('fn:codepoints-to-string', () {
      expect(
        fnCodepointsToString(context, [
          const XPathSequence([97, 98, 99]),
        ]),
        isXPathSequence(['abc']),
      );
      expect(
        () => fnCodepointsToString(context, [const XPathSequence.single(-1)]),
        throwsA(
          isXPathEvaluationException(message: 'Invalid character code: -1'),
        ),
      );
    });
    test('fn:string-to-codepoints', () {
      expect(
        fnStringToCodepoints(context, [const XPathSequence.single('abc')]),
        isXPathSequence([97, 98, 99]),
      );
    });
    test('fn:compare', () {
      expect(
        fnCompare(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([-1]),
      );
    });
    test('fn:codepoint-equal', () {
      expect(
        fnCodepointEqual(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('fn:contains-token', () {
      expect(
        fnContainsToken(context, [
          const XPathSequence.single('a b c'),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([true]),
      );
    });
    test('fn:normalize-unicode', () {
      expect(
        fnNormalizeUnicode(context, [const XPathSequence.single('a')]),
        isXPathSequence(['a']),
      );
    });
    test('fn:tokenize', () {
      expect(
        fnTokenize(context, [const XPathSequence.single('a b c')]),
        isXPathSequence(['a', 'b', 'c']),
      );
      expect(
        fnTokenize(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('(ab)|(a)'),
        ]),
        isXPathSequence(['', 'r', 'c', 'd', 'r', '']),
      );
    });
    test('fn:analyze-string', () {
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

    test('fn:string-join (empty)', () {
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
    test('fn:substring (start/length)', () {
      const s = XPathSequence.single('12345');
      expect(
        fnSubstring(context, [s, const XPathSequence.single(1.5)]),
        isXPathSequence(['2345']),
      );
      expect(
        fnSubstring(context, [s, const XPathSequence.single(0)]),
        isXPathSequence(['12345']),
      );
      expect(
        fnSubstring(context, [s, const XPathSequence.single(6)]),
        isXPathSequence(['']),
      );

      expect(
        fnSubstring(context, [
          s,
          const XPathSequence.single(1),
          const XPathSequence.single(0),
        ]),
        isXPathSequence(['']),
      );
    });

    test('fn:string-length (context item)', () {
      final textNode = XmlText('hello');
      final contextWithNode = XPathContext(textNode);
      expect(fnStringLength(contextWithNode, []), isXPathSequence([5]));
    });

    test('fn:normalize-space (context item)', () {
      final textNode = XmlText('  hello  ');
      final contextWithNode = XPathContext(textNode);
      expect(fnNormalizeSpace(contextWithNode, []), isXPathSequence(['hello']));
    });

    test('fn:tokenize (flags)', () {
      expect(
        fnTokenize(context, [
          const XPathSequence.single('a.b.c'),
          const XPathSequence.single('.'),
          const XPathSequence.single('q'), // quote pattern
        ]),
        isXPathSequence(['a', 'b', 'c']),
      );

      expect(
        fnTokenize(context, [
          const XPathSequence.single('A.b.c'),
          const XPathSequence.single('a'),
          const XPathSequence.single('i'), // case insensitive
        ]),
        isXPathSequence(['', '.b.c']),
      );
    });

    test('fn:replace (flags)', () {
      expect(
        fnReplace(context, [
          const XPathSequence.single('a.b'),
          const XPathSequence.single('.'),
          const XPathSequence.single('-'),
          const XPathSequence.single('q'),
        ]),
        isXPathSequence(['a-b']),
      );

      expect(
        fnReplace(context, [
          const XPathSequence.single('A.B'),
          const XPathSequence.single('a'),
          const XPathSequence.single('x'),
          const XPathSequence.single('i'),
        ]),
        isXPathSequence(['x.B']),
      );

      // Invalid flag
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

    test('regex flags coverage', () {
      // 'm' multiline: '^' matches start of line
      expect(
        fnMatches(context, [
          const XPathSequence.single('a\nb'),
          const XPathSequence.single('^b'),
          const XPathSequence.single('m'),
        ]),
        isXPathSequence([true]),
      );

      // 's' dotAll: '.' matches newline
      expect(
        fnMatches(context, [
          const XPathSequence.single('a\nb'),
          const XPathSequence.single('a.b'),
          const XPathSequence.single('s'),
        ]),
        isXPathSequence([true]),
      );

      // 'x' extended (currently no-op but should compile)
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
          const XPathSequence.single('x'),
        ]),
        isXPathSequence([true]),
      );
    });
    test('regex \\i and \\I escapes', () {
      // \i matches XML name start characters (letters, _, :)
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(r'^\i$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('_'),
          const XPathSequence.single(r'^\i$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('1'),
          const XPathSequence.single(r'^\i$'),
        ]),
        isXPathSequence([false]),
      );
      // \I matches non-name-start characters
      expect(
        fnMatches(context, [
          const XPathSequence.single('1'),
          const XPathSequence.single(r'^\I$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(r'^\I$'),
        ]),
        isXPathSequence([false]),
      );
    });
    test('regex \\c and \\C escapes', () {
      // \c matches XML name characters (letters, digits, ., -, _, :)
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(r'^\c$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('1'),
          const XPathSequence.single(r'^\c$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('-'),
          const XPathSequence.single(r'^\c$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single(' '),
          const XPathSequence.single(r'^\c$'),
        ]),
        isXPathSequence([false]),
      );
      // \C matches non-name characters
      expect(
        fnMatches(context, [
          const XPathSequence.single(' '),
          const XPathSequence.single(r'^\C$'),
        ]),
        isXPathSequence([true]),
      );
    });
    test('character class subtraction', () {
      // [a-z-[aeiou]] matches consonants only
      expect(
        fnMatches(context, [
          const XPathSequence.single('b'),
          const XPathSequence.single(r'^[a-z-[aeiou]]$'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(r'^[a-z-[aeiou]]$'),
        ]),
        isXPathSequence([false]),
      );
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('string(nodes)', () {
      expectEvaluate(xml, 'string()', isXPathSequence(['123']));
      expectEvaluate(xml, 'string(/r/b)', isXPathSequence(['23']));
    });
    test('string(string)', () {
      expectEvaluate(xml, 'string("")', isXPathSequence(['']));
      expectEvaluate(xml, 'string("hello")', isXPathSequence(['hello']));
    });
    test('string(number)', () {
      expectEvaluate(xml, 'string(0)', isXPathSequence(['0']));
      expectEvaluate(xml, 'string(0 div 0)', isXPathSequence(['NaN']));
      expectEvaluate(xml, 'string(1 div 0)', isXPathSequence(['INF']));
      expectEvaluate(xml, 'string(-1 div 0)', isXPathSequence(['-INF']));
      expectEvaluate(xml, 'string(42)', isXPathSequence(['42']));
      expectEvaluate(xml, 'string(-42)', isXPathSequence(['-42']));
      expectEvaluate(xml, 'string(3.1415)', isXPathSequence(['3.1415']));
      expectEvaluate(xml, 'string(-3.1415)', isXPathSequence(['-3.1415']));
    });
    test('string(boolean)', () {
      expectEvaluate(xml, 'string(false())', isXPathSequence(['false']));
      expectEvaluate(xml, 'string(true())', isXPathSequence(['true']));
    });
    test('concat', () {
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
    test('starts-with', () {
      expectEvaluate(xml, 'starts-with("abc", "")', isXPathSequence([true]));
      expectEvaluate(xml, 'starts-with("abc", "a")', isXPathSequence([true]));
      expectEvaluate(xml, 'starts-with("abc", "ab")', isXPathSequence([true]));
      expectEvaluate(xml, 'starts-with("abc", "abc")', isXPathSequence([true]));
      expectEvaluate(
        xml,
        'starts-with("abc", "abcd")',
        isXPathSequence([false]),
      );
      expectEvaluate(xml, 'starts-with("abc", "bc")', isXPathSequence([false]));
    });
    test('contains', () {
      expectEvaluate(xml, 'contains("abc", "")', isXPathSequence([true]));
      expectEvaluate(xml, 'contains("abc", "a")', isXPathSequence([true]));
      expectEvaluate(xml, 'contains("abc", "b")', isXPathSequence([true]));
      expectEvaluate(xml, 'contains("abc", "c")', isXPathSequence([true]));
      expectEvaluate(xml, 'contains("abc", "d")', isXPathSequence([false]));
      expectEvaluate(xml, 'contains("abc", "ac")', isXPathSequence([false]));
    });
    test('substring-before', () {
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
    test('substring-after', () {
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
      expect(
        () => expectEvaluate(xml, 'substring-after("abcde")', anything),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('substring', () {
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
      expect(
        () => expectEvaluate(xml, 'substring("abcde")', anything),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('string-length', () {
      expectEvaluate(xml, 'string-length("")', isXPathSequence([0]));
      expectEvaluate(xml, 'string-length("1")', isXPathSequence([1]));
      expectEvaluate(xml, 'string-length("12")', isXPathSequence([2]));
      expectEvaluate(xml, 'string-length("123")', isXPathSequence([3]));
    });
    test('normalize-space', () {
      expectEvaluate(xml, 'normalize-space("")', isXPathSequence(['']));
      expectEvaluate(xml, 'normalize-space(" 1 ")', isXPathSequence(['1']));
      expectEvaluate(
        xml,
        'normalize-space(" 1  2 ")',
        isXPathSequence(['1 2']),
      );
      expectEvaluate(xml, 'normalize-space("1 \n2")', isXPathSequence(['1 2']));
    });
    test('translate', () {
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
}
