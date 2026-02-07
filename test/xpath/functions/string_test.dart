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
      expect(fnCollationKey(context, [const XPathSequence.single('abc')]), [
        'abc',
      ]);
    });
    test('fn:concat', () {
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        ['ab'],
      );
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
          const XPathSequence.single('c'),
        ]),
        ['abc'],
      );
    });
    test('fn:string-join', () {
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b']),
          const XPathSequence.single(','),
        ]),
        ['a,b'],
      );
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
          const XPathSequence.single('-'),
        ]),
        ['a-b-c'],
      );
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
        ]),
        ['abc'],
      );
    });
    test('fn:substring', () {
      expect(
        fnSubstring(context, [
          const XPathSequence.single('motor car'),
          const XPathSequence.single(6),
        ]),
        [' car'],
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('metadata'),
          const XPathSequence.single(4),
          const XPathSequence.single(3),
        ]),
        ['ada'],
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(1.5),
          const XPathSequence.single(2.6),
        ]),
        ['234'],
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(0),
          const XPathSequence.single(3),
        ]),
        ['12'],
      );
    });
    test('fn:string-length', () {
      expect(fnStringLength(context, [const XPathSequence.single('abc')]), [3]);
      expect(fnStringLength(context, [XPathSequence.empty]), [0]);
    });
    test('fn:normalize-space', () {
      expect(
        fnNormalizeSpace(context, [const XPathSequence.single('  a  b   c  ')]),
        ['a b c'],
      );
    });
    test('fn:upper-case', () {
      expect(fnUpperCase(context, [const XPathSequence.single('abc')]), [
        'ABC',
      ]);
    });
    test('fn:lower-case', () {
      expect(fnLowerCase(context, [const XPathSequence.single('ABC')]), [
        'abc',
      ]);
    });
    test('fn:contains', () {
      expect(
        fnContains(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        [true],
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('t'),
        ]),
        [true],
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('z'),
        ]),
        [false],
      );
    });
    test('fn:starts-with', () {
      expect(
        fnStartsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        [true],
      );
    });
    test('fn:ends-with', () {
      expect(
        fnEndsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        [true],
      );
    });
    test('fn:substring-before', () {
      expect(
        fnSubstringBefore(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        ['tat'],
      );
    });
    test('fn:substring-after', () {
      expect(
        fnSubstringAfter(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        ['too'],
      );
    });
    test('fn:translate', () {
      expect(
        fnTranslate(context, [
          const XPathSequence.single('bar'),
          const XPathSequence.single('abc'),
          const XPathSequence.single('ABC'),
        ]),
        ['BAr'],
      );
    });
    test('fn:matches', () {
      expect(
        fnMatches(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        [true],
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
        ]),
        [true],
      );
    });
    test('fn:replace', () {
      expect(
        fnReplace(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
          const XPathSequence.single('*'),
        ]),
        ['a*cada*'],
      );
    });
    test('fn:codepoints-to-string', () {
      expect(
        fnCodepointsToString(context, [
          const XPathSequence([97, 98, 99]),
        ]),
        ['abc'],
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
        [97, 98, 99],
      );
    });
    test('fn:compare', () {
      expect(
        fnCompare(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        [-1],
      );
    });
    test('fn:codepoint-equal', () {
      expect(
        fnCodepointEqual(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ]),
        [true],
      );
    });

    test('fn:contains-token', () {
      expect(
        fnContainsToken(context, [
          const XPathSequence.single('a b c'),
          const XPathSequence.single('b'),
        ]),
        [true],
      );
    });
    test('fn:normalize-unicode', () {
      expect(fnNormalizeUnicode(context, [const XPathSequence.single('a')]), [
        'a',
      ]);
    });
    test('fn:tokenize', () {
      expect(
        fnTokenize(context, [const XPathSequence.single('a b c')]).toList(),
        ['a', 'b', 'c'],
      );
      expect(
        fnTokenize(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('(ab)|(a)'),
        ]).toList(),
        ['', 'r', 'c', 'd', 'r', ''],
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
      expect(fnStringJoin(context, [XPathSequence.empty]), ['']);
      expect(
        fnStringJoin(context, [
          XPathSequence.empty,
          const XPathSequence.single(','),
        ]),
        [''],
      );
    });
    test('fn:substring (start/length)', () {
      const s = XPathSequence.single('12345');
      expect(fnSubstring(context, [s, const XPathSequence.single(1.5)]), [
        '2345',
      ]);
      expect(fnSubstring(context, [s, const XPathSequence.single(0)]), [
        '12345',
      ]);
      expect(fnSubstring(context, [s, const XPathSequence.single(6)]), ['']);

      expect(
        fnSubstring(context, [
          s,
          const XPathSequence.single(1),
          const XPathSequence.single(0),
        ]),
        [''],
      );
    });

    test('fn:string-length (context item)', () {
      final textNode = XmlText('hello');
      final contextWithNode = XPathContext(textNode);
      expect(fnStringLength(contextWithNode, []), [5]);
    });

    test('fn:normalize-space (context item)', () {
      final textNode = XmlText('  hello  ');
      final contextWithNode = XPathContext(textNode);
      expect(fnNormalizeSpace(contextWithNode, []), ['hello']);
    });

    test('fn:tokenize (flags)', () {
      expect(
        fnTokenize(context, [
          const XPathSequence.single('a.b.c'),
          const XPathSequence.single('.'),
          const XPathSequence.single('q'), // quote pattern
        ]),
        ['a', 'b', 'c'],
      );

      expect(
        fnTokenize(context, [
          const XPathSequence.single('A.b.c'),
          const XPathSequence.single('a'),
          const XPathSequence.single('i'), // case insensitive
        ]),
        ['', '.b.c'],
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
        ['a-b'],
      );

      expect(
        fnReplace(context, [
          const XPathSequence.single('A.B'),
          const XPathSequence.single('a'),
          const XPathSequence.single('x'),
          const XPathSequence.single('i'),
        ]),
        ['x.B'],
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
        [true],
      );

      // 's' dotAll: '.' matches newline
      expect(
        fnMatches(context, [
          const XPathSequence.single('a\nb'),
          const XPathSequence.single('a.b'),
          const XPathSequence.single('s'),
        ]),
        [true],
      );

      // 'x' extended (currently no-op but should compile)
      expect(
        fnMatches(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
          const XPathSequence.single('x'),
        ]),
        [true],
      );
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');
    test('string(nodes)', () {
      expectEvaluate(xml, 'string()', ['123']);
      expectEvaluate(xml, 'string(/r/b)', ['23']);
    });
    test('string(string)', () {
      expectEvaluate(xml, 'string("")', ['']);
      expectEvaluate(xml, 'string("hello")', ['hello']);
    });
    test('string(number)', () {
      expectEvaluate(xml, 'string(0)', ['0']);
      expectEvaluate(xml, 'string(0 div 0)', ['NaN']);
      expectEvaluate(xml, 'string(1 div 0)', ['INF']);
      expectEvaluate(xml, 'string(-1 div 0)', ['-INF']);
      expectEvaluate(xml, 'string(42)', ['42']);
      expectEvaluate(xml, 'string(-42)', ['-42']);
      expectEvaluate(xml, 'string(3.1415)', ['3.1415']);
      expectEvaluate(xml, 'string(-3.1415)', ['-3.1415']);
    });
    test('string(boolean)', () {
      expectEvaluate(xml, 'string(false())', ['false']);
      expectEvaluate(xml, 'string(true())', ['true']);
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
      expectEvaluate(xml, 'concat("a", "b")', ['ab']);
      expectEvaluate(xml, 'concat("a", "b", "c")', ['abc']);
    });
    test('starts-with', () {
      expectEvaluate(xml, 'starts-with("abc", "")', [true]);
      expectEvaluate(xml, 'starts-with("abc", "a")', [true]);
      expectEvaluate(xml, 'starts-with("abc", "ab")', [true]);
      expectEvaluate(xml, 'starts-with("abc", "abc")', [true]);
      expectEvaluate(xml, 'starts-with("abc", "abcd")', [false]);
      expectEvaluate(xml, 'starts-with("abc", "bc")', [false]);
    });
    test('contains', () {
      expectEvaluate(xml, 'contains("abc", "")', [true]);
      expectEvaluate(xml, 'contains("abc", "a")', [true]);
      expectEvaluate(xml, 'contains("abc", "b")', [true]);
      expectEvaluate(xml, 'contains("abc", "c")', [true]);
      expectEvaluate(xml, 'contains("abc", "d")', [false]);
      expectEvaluate(xml, 'contains("abc", "ac")', [false]);
    });
    test('substring-before', () {
      expectEvaluate(xml, 'substring-before("abcde", "c")', ['ab']);
      expectEvaluate(xml, 'substring-before("abcde", "x")', ['']);
    });
    test('substring-after', () {
      expectEvaluate(xml, 'substring-after("abcde", "c")', ['de']);
      expectEvaluate(xml, 'substring-after("abcde", "x")', ['']);
      expect(
        () => expectEvaluate(xml, 'substring-after("abcde")', anything),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('substring', () {
      expectEvaluate(xml, 'substring("12345", 3)', ['345']);
      expectEvaluate(xml, 'substring("12345", 2, 3)', ['234']);
      expectEvaluate(xml, 'substring("12345", 0, 3)', ['12']);
      expectEvaluate(xml, 'substring("12345", 4, 9)', ['45']);
      expectEvaluate(xml, 'substring("12345", 1.5, 2.6)', ['234']);
      expectEvaluate(xml, 'substring("12345", 0 div 0, 3)', ['']);
      expectEvaluate(xml, 'substring("12345", 1, 0 div 0)', ['']);
      expectEvaluate(xml, 'substring("12345", -42, 1 div 0)', ['12345']);
      expectEvaluate(xml, 'substring("12345", -1 div 0, 1 div 0)', ['']);
      expect(
        () => expectEvaluate(xml, 'substring("abcde")', anything),
        throwsA(isXPathEvaluationException()),
      );
    });
    test('string-length', () {
      expectEvaluate(xml, 'string-length("")', [0]);
      expectEvaluate(xml, 'string-length("1")', [1]);
      expectEvaluate(xml, 'string-length("12")', [2]);
      expectEvaluate(xml, 'string-length("123")', [3]);
    });
    test('normalize-space', () {
      expectEvaluate(xml, 'normalize-space("")', ['']);
      expectEvaluate(xml, 'normalize-space(" 1 ")', ['1']);
      expectEvaluate(xml, 'normalize-space(" 1  2 ")', ['1 2']);
      expectEvaluate(xml, 'normalize-space("1 \n2")', ['1 2']);
    });
    test('translate', () {
      expectEvaluate(xml, 'translate("bar", "abc", "ABC")', ['BAr']);
      expectEvaluate(xml, 'translate("-aaa-", "a-", "A")', ['AAA']);
    });
  });
}
