import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/string.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('string', () {
    test('fn:collation-key', () {
      expect(fnCollationKey(context, [const XPathSequence.single('abc')]), [
        const v31.XPathString('abc'),
      ]);
    });
    test('fn:concat', () {
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        [const v31.XPathString('ab')],
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
        [const v31.XPathString('a,b')],
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
        throwsA(isA<XPathEvaluationException>()),
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
        () => fnAnalyzeString(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('fn:string-join (empty)', () {
      expect(fnStringJoin(context, [XPathSequence.empty]), [
        const v31.XPathString(''),
      ]);
      expect(
        fnStringJoin(context, [
          XPathSequence.empty,
          const XPathSequence.single(','),
        ]),
        [const v31.XPathString('')],
      );
    });
    test('fn:substring (start/length)', () {
      const s = XPathSequence.single('12345');
      expect(fnSubstring(context, [s, const XPathSequence.single(1.5)]), [
        const v31.XPathString('2345'),
      ]);
      expect(fnSubstring(context, [s, const XPathSequence.single(0)]), [
        const v31.XPathString('12345'),
      ]);
      expect(fnSubstring(context, [s, const XPathSequence.single(6)]), [
        const v31.XPathString(''),
      ]);

      expect(
        fnSubstring(context, [
          s,
          const XPathSequence.single(1),
          const XPathSequence.single(0),
        ]),
        [const v31.XPathString('')],
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
      expect(fnNormalizeSpace(contextWithNode, []), [
        const v31.XPathString('hello'),
      ]);
    });

    test('fn:tokenize (flags)', () {
      expect(
        fnTokenize(context, [
          const XPathSequence.single('a.b.c'),
          const XPathSequence.single('.'),
          const XPathSequence.single('q'), // quote pattern
        ]),
        [
          const v31.XPathString('a'),
          const v31.XPathString('b'),
          const v31.XPathString('c'),
        ],
      );

      expect(
        fnTokenize(context, [
          const XPathSequence.single('A.b.c'),
          const XPathSequence.single('a'),
          const XPathSequence.single('i'), // case insensitive
        ]),
        [const v31.XPathString(''), const v31.XPathString('.b.c')],
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
        [const v31.XPathString('a-b')],
      );

      expect(
        fnReplace(context, [
          const XPathSequence.single('A.B'),
          const XPathSequence.single('a'),
          const XPathSequence.single('x'),
          const XPathSequence.single('i'),
        ]),
        [const v31.XPathString('x.B')],
      );

      // Invalid flag
      expect(
        () => fnReplace(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
          const XPathSequence.single('Z'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
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
}
