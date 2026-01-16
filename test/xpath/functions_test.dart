import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions31/accessor.dart';
import 'package:xml/src/xpath/functions31/array.dart';
import 'package:xml/src/xpath/functions31/binary.dart';
import 'package:xml/src/xpath/functions31/boolean.dart';
import 'package:xml/src/xpath/functions31/context.dart';
import 'package:xml/src/xpath/functions31/date_time.dart';
import 'package:xml/src/xpath/functions31/duration.dart';
import 'package:xml/src/xpath/functions31/error.dart';
import 'package:xml/src/xpath/functions31/general.dart';
import 'package:xml/src/xpath/functions31/higher_order.dart';
import 'package:xml/src/xpath/functions31/json.dart';
import 'package:xml/src/xpath/functions31/map.dart';
import 'package:xml/src/xpath/functions31/node.dart';
import 'package:xml/src/xpath/functions31/notation.dart';
import 'package:xml/src/xpath/functions31/number.dart';
import 'package:xml/src/xpath/functions31/qname.dart';
import 'package:xml/src/xpath/functions31/sequence.dart';
import 'package:xml/src/xpath/functions31/string.dart';
import 'package:xml/src/xpath/functions31/uri.dart';
import 'package:xml/src/xpath/types31/date_time.dart';

import 'package:xml/src/xpath/types31/string.dart' as v31;

import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('accessor', () {
    test('fn:node-name', () {
      final a = document.findAllElements('a').first;
      expect(fnNodeName(XPathContext(a), []), [a.name]);
      expect(fnNodeName(context, [XPathSequence.single(a)]), [a.name]);
      expect(fnNodeName(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:node-name (processing-instruction)', () {
      final pi = XmlProcessing('target', 'value');
      expect(
        fnNodeName(context, [XPathSequence.single(pi)]).first.toString(),
        'target',
      );
    });
    test('fn:nilled', () {
      expect(fnNilled(context, [XPathSequence.single(document)]), isEmpty);
      expect(fnNilled(context, [XPathSequence.single(document.rootElement)]), [
        false,
      ]);
      expect(fnNilled(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:string', () {
      expect(fnString(context, [const XPathSequence.single('foo')]), [
        const v31.XPathString('foo'),
      ]);
      expect(fnString(context, [XPathSequence.empty]), [v31.XPathString.empty]);
      expect(fnString(XPathContext(document.findAllElements('a').first), []), [
        const v31.XPathString('1'),
      ]);
    });
    test('fn:data', () {
      expect(fnData(context, [XPathSequence.empty]), isEmpty);
      expect(fnData(context, [const XPathSequence.single(123)]), [123]);
      expect(
        fnData(context, [
          const XPathSequence.single([1, 2, 3]),
        ]),
        [1, 2, 3],
      );
    });
    test('fn:base-uri', () {
      expect(fnBaseUri(context, const <XPathSequence>[]), isEmpty);
      expect(fnBaseUri(context, [XPathSequence.single(document)]), isEmpty);
    });
    test('fn:document-uri', () {
      expect(fnDocumentUri(context, const <XPathSequence>[]), isEmpty);
      expect(fnDocumentUri(context, [XPathSequence.single(document)]), isEmpty);
    });
  });
  group('error', () {
    test('fn:error', () {
      expect(
        () => fnError(context, const <XPathSequence>[]),
        throwsA(isXPathEvaluationException(message: '')),
      );
      expect(
        () => fnError(context, [const XPathSequence.single('code')]),
        throwsA(isXPathEvaluationException(message: 'code')),
      );
      expect(
        () => fnError(context, [
          const XPathSequence.single('code'),
          const XPathSequence.single('description'),
        ]),
        throwsA(isXPathEvaluationException(message: 'code: description')),
      );
      expect(
        () => fnError(context, [
          const XPathSequence.single('code'),
          const XPathSequence.single('description'),
          const XPathSequence([1, 2, 3]),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'code: description (1, 2, 3)'),
        ),
      );
    });
    test('fn:trace (without handler)', () {
      const value = XPathSequence.single('value');
      const label = XPathSequence.single('label');
      expect(fnTrace(context, [value]), ['value']);
      expect(fnTrace(context, [value, label]), ['value']);
    });
    test('fn:trace (with handler)', () {
      const value = XPathSequence.single('value');
      const label = XPathSequence.single('label');
      final traceLog = <(XPathSequence, v31.XPathString?)>[];
      final traceContext = context.copy(
        onTraceCallback: (value, label) => traceLog.add((value, label)),
      );
      expect(fnTrace(traceContext, [value]), ['value']);
      expect(fnTrace(traceContext, [value, label]), ['value']);
      expect(traceLog, [(value, null), (value, label.single)]);
    });
  });
  group('number', () {
    test('fn:abs', () {
      expect(
        fnAbs(context, [const XPathSequence.single(-5)]),
        const XPathSequence.single(5),
      );
      expect(fnAbs(context, [XPathSequence.empty]), isEmpty);
    });

    test('fn:round-half-to-even', () {
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(0.5)]),
        const XPathSequence.single(0),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(1.5)]),
        const XPathSequence.single(2),
      );
      expect(
        fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]),
        const XPathSequence.single(2),
      );
    });
    test('fn:number', () {
      expect(
        fnNumber(context, [const XPathSequence.single('123')]),
        const XPathSequence.single(123),
      );
      expect(
        (fnNumber(context, [XPathSequence.empty]).first as num).isNaN,
        isTrue,
      );
    });
    test('math:pi', () {
      expect(mathPi(context, const <XPathSequence>[]), [math.pi]);
    });
    test('math:sqrt', () {
      expect(
        mathSqrt(context, [const XPathSequence.single(4)]),
        const XPathSequence.single(2),
      );
    });
    test('fn:random-number-generator', () {
      final result =
          fnRandomNumberGenerator(context, const <XPathSequence>[]).first
              as Map;
      expect(result.keys, containsAll(['number', 'next', 'permute']));
      final current = result['number'];
      expect(current, isA<double>());
      expect(current, isNonNegative);
      expect(current, lessThan(1.0));
      final next = (result['next'] as Function)(
        context,
        const <XPathSequence>[],
      );
      expect(next, isA<double>());
      expect(next, isNonNegative);
      expect(next, lessThan(1.0));
      expect(next, result['number']);
      expect(next, isNot(current));
      final permuted = (result['permute'] as Function)(context, [
        const XPathSequence([1, 2, 3]),
      ]);
      expect(permuted, isA<XPathSequence>());
      expect(permuted, hasLength(3));
      expect(permuted, containsAll([1, 2, 3]));
    });
    test('op:numeric-add', () {
      expect(
        opNumericAdd(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ]),
        [3],
      );
    });
    test('op:numeric-subtract', () {
      expect(
        opNumericSubtract(context, [
          const XPathSequence.single(3),
          const XPathSequence.single(2),
        ]),
        [1],
      );
    });
    test('op:numeric-multiply', () {
      expect(
        opNumericMultiply(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        [6],
      );
    });
    test('op:numeric-divide', () {
      expect(
        opNumericDivide(context, [
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ]),
        [3.0],
      );
    });
    test('op:numeric-integer-divide', () {
      expect(
        opNumericIntegerDivide(context, [
          const XPathSequence.single(10),
          const XPathSequence.single(3),
        ]),
        [3],
      );
    });
    test('op:numeric-mod', () {
      expect(
        opNumericMod(context, [
          const XPathSequence.single(10),
          const XPathSequence.single(3),
        ]),
        [1],
      );
    });
    test('op:numeric-unary-plus', () {
      expect(opNumericUnaryPlus(context, [const XPathSequence.single(1)]), [1]);
    });
    test('op:numeric-unary-minus', () {
      expect(opNumericUnaryMinus(context, [const XPathSequence.single(1)]), [
        -1,
      ]);
    });
    test('op:numeric-equal', () {
      expect(
        opNumericEqual(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ]),
        [true],
      );
    });
    test('op:numeric-less-than', () {
      expect(
        opNumericLessThan(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ]),
        [true],
      );
    });
    test('op:numeric-greater-than', () {
      expect(
        opNumericGreaterThan(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ]),
        [true],
      );
    });
    test('fn:ceiling', () {
      expect(fnCeiling(context, [const XPathSequence.single(1.5)]), [2]);
    });
    test('fn:floor', () {
      expect(fnFloor(context, [const XPathSequence.single(1.5)]), [1]);
    });
    test('fn:round', () {
      expect(fnRound(context, [const XPathSequence.single(1.5)]), [2]);
      expect(fnRound(context, [XPathSequence.empty]), isEmpty);
      expect(fnRound(context, [const XPathSequence.single(double.nan)]), [
        isNaN,
      ]);
      expect(
        fnRound(context, [
          const XPathSequence.single(1.5),
          const XPathSequence.single(1),
        ]),
        [1.5],
      );
    });
    test('fn:format-integer', () {
      expect(
        fnFormatInteger(context, [
          const XPathSequence.single(123),
          const XPathSequence.single('000'),
        ]),
        ['123'],
      );
      expect(
        fnFormatInteger(context, [
          XPathSequence.empty,
          const XPathSequence.single('000'),
        ]),
        isEmpty,
      );
    });
    test('math functions', () {
      expect(mathPi(context, const <XPathSequence>[]), [
        predicate((x) => (x as double) > 3.14),
      ]);
      expect(mathExp(context, [const XPathSequence.single(0)]), [1.0]);
      expect(mathExp10(context, [const XPathSequence.single(0)]), [1.0]);
      expect(mathLog(context, [const XPathSequence.single(math.e)]), [1.0]);
      expect(mathLog10(context, [const XPathSequence.single(10)]), [1.0]);
      expect(
        mathPow(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        [8.0],
      );
      expect(mathSqrt(context, [const XPathSequence.single(4)]), [2.0]);
      expect(mathSin(context, [const XPathSequence.single(0)]), [0.0]);
      expect(mathCos(context, [const XPathSequence.single(0)]), [1.0]);
      expect(mathTan(context, [const XPathSequence.single(0)]), [0.0]);
      expect(mathAsin(context, [const XPathSequence.single(0)]), [0.0]);
      expect(mathAcos(context, [const XPathSequence.single(1)]), [0.0]);
      expect(mathAtan(context, [const XPathSequence.single(0)]), [0.0]);
      expect(
        mathAtan2(context, [
          const XPathSequence.single(0),
          const XPathSequence.single(1),
        ]),
        [0.0],
      );
    });

    test('fn:format-integer (3 args)', () {
      expect(
        fnFormatInteger(context, [
          const XPathSequence.single(123),
          const XPathSequence.single('0000'),
          const XPathSequence.single('en'),
        ]),
        [const v31.XPathString('123')],
      ); // Partial implementation ignoring picture
    });
    test('fn:format-number (basic)', () {
      expect(
        fnFormatNumber(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single('#.00'),
        ]),
        [const v31.XPathString('123.456')],
      ); // Partial implementation ignoring picture
    });
    test('fn:format-number (3 args)', () {
      expect(
        fnFormatNumber(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single('#.00'),
          const XPathSequence.single('foo'), // decimal format name
        ]),
        [const v31.XPathString('123.456')],
      ); // Partial implementation ignoring picture
    });
    test('fn:format-number (empty)', () {
      expect(
        fnFormatNumber(context, [
          XPathSequence.empty,
          const XPathSequence.single('#.00'),
        ]),
        isEmpty,
      ); // Partial implementation returns empty seq
    });

    test('fn:round (precision)', () {
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(2),
        ]),
        [123.46],
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(0),
        ]),
        [123],
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(123.456),
          const XPathSequence.single(-2),
        ]),
        [100],
      ); // Round to hundreds
    });

    test('fn:round-half-to-even (coverage)', () {
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.5)]), [
        2,
      ]);
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(3.5)]), [
        4,
      ]);
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.4)]), [
        2,
      ]);
      expect(fnRoundHalfToEven(context, [const XPathSequence.single(2.6)]), [
        3,
      ]);

      expect(
        fnRoundHalfToEven(context, [
          const XPathSequence.single(2.5),
          const XPathSequence.single(0),
        ]),
        [2],
      );
    });

    test('fn:number (context item)', () {
      final textNode = XmlText('123');
      final contextWithNode = XPathContext(textNode);
      expect(fnNumber(contextWithNode, []), [123]);
    });

    test('fn:random-number-generator (seed)', () {
      final result = fnRandomNumberGenerator(context, [
        const XPathSequence.single(123),
      ]);
      expect(result, isNotEmpty);
      // Check determinism
      final result2 = fnRandomNumberGenerator(context, [
        const XPathSequence.single(123),
      ]);
      final map1 = result.first as Map;
      final map2 = result2.first as Map;
      expect(map1['number'], map2['number']);
    });
  });
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
  group('boolean', () {
    test('op:boolean-equal', () {
      expect(
        opBooleanEqual(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
      expect(
        opBooleanEqual(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [false],
      );
    });
    test('op:boolean-less-than', () {
      expect(
        opBooleanLessThan(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
      expect(
        opBooleanLessThan(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        [false],
      );
    });
    test('op:boolean-greater-than', () {
      expect(
        opBooleanGreaterThan(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [true],
      );
      expect(
        opBooleanGreaterThan(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [false],
      );
    });
    test('fn:boolean', () {
      expect(
        fnBoolean(context, [const XPathSequence.single(true)]),
        XPathSequence.trueSequence,
      );
      expect(
        fnBoolean(context, [XPathSequence.empty]),
        XPathSequence.falseSequence,
      );
      expect(fnBoolean(context, [const XPathSequence.single(1)]), [true]);
    });
    test('fn:not', () {
      expect(
        fnNot(context, [const XPathSequence.single(true)]),
        XPathSequence.falseSequence,
      );
    });
    test('fn:true', () {
      expect(fnTrue(context, const <XPathSequence>[]), [true]);
    });
    test('fn:false', () {
      expect(fnFalse(context, const <XPathSequence>[]), [false]);
    });
    test('fn:lang', () {
      final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
      final c = doc.rootElement.children.whereType<XmlElement>().first;
      final newContext = XPathContext(c);
      expect(fnLang(newContext, [const XPathSequence.single('en')]), [true]);
      expect(fnLang(newContext, [const XPathSequence.single('fr')]), [false]);
      expect(fnLang(newContext, [const XPathSequence.single('EN-US')]), [
        false,
      ]);
    });
  });
  group('node', () {
    test('op:union', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opUnion(context, [XPathSequence.single(a), XPathSequence.single(b)]),
        XPathSequence([a, b]),
      );
      // Test document order preservation/enforcement
      expect(
        opUnion(context, [XPathSequence.single(b), XPathSequence.single(a)]),
        [a, b],
      );
    });
    test('op:intersect', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opIntersect(context, [
          XPathSequence([a, b]),
          XPathSequence.single(a),
        ]),
        [a],
      );
    });
    test('op:except', () {
      final doc = XmlDocument.parse('<r><a/><b/></r>');
      final a = doc.findAllElements('a').single;
      final b = doc.findAllElements('b').single;
      expect(
        opExcept(context, [
          XPathSequence([a, b]),
          XPathSequence.single(a),
        ]),
        [b],
      );
    });
    test('fn:name', () {
      final a = document.findAllElements('a').first;
      expect(fnName(context, [XPathSequence.single(a)]), [
        const v31.XPathString('a'),
      ]);
    });
    test('fn:local-name', () {
      final a = document.findAllElements('a').first;
      expect(fnLocalName(context, [XPathSequence.single(a)]), [
        const v31.XPathString('a'),
      ]);
    });
    test('fn:root', () {
      final a = document.findAllElements('a').first;
      expect(fnRoot(context, [XPathSequence.single(a)]), [document]);
    });
    test('fn:innermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnInnermost(context, [
          XPathSequence([document, a]),
        ]),
        [a],
      );
    });
    test('fn:outermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnOutermost(context, [
          XPathSequence([document, a]),
        ]),
        [document],
      );
    });
    test('fn:path', () {
      final a = document.findAllElements('a').first;
      expect(fnPath(context, [XPathSequence.single(a)]), [
        const v31.XPathString('/r/a'),
      ]);
    });
  });
  group('context', () {
    test('fn:position', () {
      expect(fnPosition(context, const <XPathSequence>[]), [1]);
    });
    test('fn:last', () {
      expect(fnLast(context, const <XPathSequence>[]), [1]);
    });
    test('fn:current-dateTime', () {
      expect(
        fnCurrentDateTime(context, const <XPathSequence>[]).first,
        isA<DateTime>(),
      );
    });
    test('fn:current-date', () {
      expect(
        fnCurrentDate(context, const <XPathSequence>[]).first,
        isA<DateTime>(),
      );
    });
    test('fn:current-time', () {
      expect(
        fnCurrentTime(context, const <XPathSequence>[]).first,
        isA<DateTime>(),
      );
    });
    test('fn:implicit-timezone', () {
      expect(fnImplicitTimezone(context, const <XPathSequence>[]), [
        Duration.zero,
      ]);
    });
    test('fn:default-collation', () {
      expect(fnDefaultCollation(context, const <XPathSequence>[]), [
        'http://www.w3.org/2005/xpath-functions/collation/codepoint',
      ]);
    });
    test('fn:default-language', () {
      expect(fnDefaultLanguage(context, const <XPathSequence>[]), ['en']);
    });
    test('fn:static-base-uri', () {
      expect(fnStaticBaseUri(context, const <XPathSequence>[]), isEmpty);
    });
  });
  group('sequence', () {
    group('general functions and operators on sequences', () {
      test('fn:empty', () {
        expect(fnEmpty(context, [XPathSequence.empty]), [true]);
        expect(fnEmpty(context, [const XPathSequence.single(1)]), [false]);
      });
      test('fn:exists', () {
        expect(fnExists(context, [XPathSequence.empty]), [false]);
        expect(fnExists(context, [const XPathSequence.single(1)]), [true]);
      });
      test('fn:head', () {
        expect(fnHead(context, [XPathSequence.empty]), isEmpty);
        expect(
          fnHead(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          [1],
        );
      });
      test('fn:tail', () {
        expect(fnTail(context, [XPathSequence.empty]), isEmpty);
        expect(
          fnTail(context, [
            const XPathSequence([1]),
          ]),
          isEmpty,
        );
        expect(
          fnTail(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          [2, 3],
        );
      });
      test('fn:insert-before', () {
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            const XPathSequence.single(1),
            const XPathSequence.single(0),
          ]),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            const XPathSequence.single(2),
            const XPathSequence.single(0),
          ]),
          [1, 0, 2],
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            const XPathSequence.single(3),
            const XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 0]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            const XPathSequence.single(0),
            const XPathSequence.single(0),
          ]),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            const XPathSequence.single(10),
            const XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 0]),
        );
      });
      test('fn:remove', () {
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            const XPathSequence.single(2),
          ]),
          const XPathSequence([1, 3]),
        );
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            const XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 3]),
        );
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            const XPathSequence.single(4),
          ]),
          const XPathSequence([1, 2, 3]),
        );
      });
      test('fn:reverse', () {
        expect(
          fnReverse(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          [3, 2, 1],
        );
        expect(fnReverse(context, [XPathSequence.empty]), isEmpty);
      });
      test('fn:subsequence', () {
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(2),
          ]),
          [2, 3, 4, 5],
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(2),
            const XPathSequence.single(2),
          ]),
          [2, 3],
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(0),
            const XPathSequence.single(2),
          ]),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(-1),
            const XPathSequence.single(3),
          ]),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(0.5),
            const XPathSequence.single(1),
          ]),
          const XPathSequence([1]),
        );
      });
      test('fn:unordered', () {
        const seq = XPathSequence([1, 2, 3]);
        expect(fnUnordered(context, [seq]), seq);
      });
    });
    group('functions that compare values in sequences', () {
      test('fn:distinct-values', () {
        expect(
          fnDistinctValues(context, [
            const XPathSequence([1, 2, 1, 3, 2]),
          ]),
          const XPathSequence([1, 2, 3]),
        );
      });
      test('fn:index-of', () {
        expect(
          fnIndexOf(context, [
            const XPathSequence([1, 2, 1, 3]),
            const XPathSequence.single(1),
          ]),
          const XPathSequence([1, 3]),
        );
        expect(
          fnIndexOf(context, [
            const XPathSequence([1, 2, 3]),
            const XPathSequence.single(4),
          ]),
          XPathSequence.empty,
        );
      });
      test('fn:deep-equal', () {
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2]),
          ]),
          XPathSequence.trueSequence,
        );
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 3]),
          ]),
          [false],
        );
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2, 3]),
          ]),
          [false],
        );
      });
    });
    group('functions that test the cardinality of sequences', () {
      test('fn:zero-or-one', () {
        expect(fnZeroOrOne(context, [XPathSequence.empty]), isEmpty);
        expect(fnZeroOrOne(context, [const XPathSequence.single(1)]), [1]);
        expect(
          () => fnZeroOrOne(context, [
            const XPathSequence([1, 2]),
          ]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('fn:one-or-more', () {
        expect(fnOneOrMore(context, [const XPathSequence.single(1)]), [1]);
        expect(
          fnOneOrMore(context, [
            const XPathSequence([1, 2]),
          ]),
          const XPathSequence([1, 2]),
        );
        expect(
          () => fnOneOrMore(context, [XPathSequence.empty]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('fn:exactly-one', () {
        expect(fnExactlyOne(context, [const XPathSequence.single(1)]), [1]);
        expect(
          () => fnExactlyOne(context, [XPathSequence.empty]),
          throwsA(isA<XPathEvaluationException>()),
        );
        expect(
          () => fnExactlyOne(context, [
            const XPathSequence([1, 2]),
          ]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
    group('aggregate functions', () {
      test('fn:count', () {
        expect(fnCount(context, [XPathSequence.empty]), [0]);
        expect(
          fnCount(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          [3],
        );
      });
      test('fn:avg', () {
        expect(
          fnAvg(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          [2.0],
        );
        expect(fnAvg(context, [XPathSequence.empty]), isEmpty);
      });
      test('fn:max', () {
        expect(
          fnMax(context, [
            const XPathSequence([1, 3, 2]),
          ]),
          [3],
        );
        expect(fnMax(context, [XPathSequence.empty]), isEmpty);
      });
      test('fn:min', () {
        expect(
          fnMin(context, [
            const XPathSequence([3, 1, 2]),
          ]),
          [1],
        );
        expect(fnMin(context, [XPathSequence.empty]), isEmpty);
      });
      test('fn:sum', () {
        expect(fnSum(context, [XPathSequence.empty]), [0]);
        expect(
          fnSum(context, [XPathSequence.empty, const XPathSequence.single(42)]),
          [42],
        );
        expect(
          fnSum(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          [6.0],
        );
      });
    });
    group('functions on node identifiers', () {
      test('fn:id', () {
        expect(
          () => fnId(context, [const XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:element-with-id', () {
        expect(
          () => fnElementWithId(context, [const XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:idref', () {
        expect(
          () => fnIdref(context, [const XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:generate-id', () {
        expect(
          () => fnGenerateId(context, [XPathSequence.empty]),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
    group('functions giving access to external information', () {
      test('fn:doc', () {
        expect(
          () => fnDoc(context, [const XPathSequence.single('uri')]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('fn:doc-available', () {
        expect(fnDocAvailable(context, [const XPathSequence.single('uri')]), [
          false,
        ]);
      });
      test('fn:collection', () {
        expect(fnCollection(context, const <XPathSequence>[]), isEmpty);
      });
      test('fn:uri-collection', () {
        expect(fnUriCollection(context, const <XPathSequence>[]), isEmpty);
      });
      test('fn:unparsed-text', () {
        expect(
          () => fnUnparsedText(context, [const XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-lines', () {
        expect(
          () =>
              fnUnparsedTextLines(context, [const XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-available', () {
        expect(
          () => fnUnparsedTextAvailable(context, [
            const XPathSequence.single('uri'),
          ]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:environment-variable', () {
        expect(
          () => fnEnvironmentVariable(context, [
            const XPathSequence.single('name'),
          ]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:available-environment-variables', () {
        expect(
          () =>
              fnAvailableEnvironmentVariables(context, const <XPathSequence>[]),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
    group('parsing and serializing', () {
      test('fn:serialize', () {
        expect(
          () => fnSerialize(context, [XPathSequence.empty]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml', () {
        expect(
          () => fnParseXml(context, [const XPathSequence.single('<r/>')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml-fragment', () {
        expect(
          () =>
              fnParseXmlFragment(context, [const XPathSequence.single('<r/>')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
  group('higher_order', () {
    test('fn:sort', () {
      expect(
        fnSort(context, [
          const XPathSequence([3, 1, 2]),
        ]).toList(),
        [1, 2, 3],
      );
      expect(
        fnSort(context, [
          const XPathSequence(['b', 'a', 'c']),
        ]).toList(),
        ['a', 'b', 'c'],
      );
      // Sort with key
      expect(
        fnSort(context, [
          const XPathSequence(['apple', 'be', 'cat']),
          XPathSequence.empty,
          XPathSequence.single(
            (XPathContext context, List<XPathSequence> args) =>
                XPathSequence.single(args[0].toXPathString().length),
          ),
        ]).toList(),
        ['be', 'cat', 'apple'],
      );
    });
    test('fn:apply', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        fnApply(context, [
          XPathSequence.single(add),
          const XPathSequence.single([1, 2]),
        ]),
        [3],
      );
    });
    test('fn:for-each', () {
      XPathSequence double(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) * 2);
      expect(
        fnForEach(context, [
          const XPathSequence([1, 2, 3]),
          XPathSequence.single(double),
        ]).toList(),
        [2, 4, 6],
      );
    });
    test('fn:filter', () {
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) % 2 == 0);
      expect(
        fnFilter(context, [
          const XPathSequence([1, 2, 3, 4]),
          XPathSequence.single(isEven),
        ]).toList(),
        [2, 4],
      );
    });
    test('fn:fold-left', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        fnFoldLeft(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          XPathSequence.single(add),
        ]).first,
        15,
      );
    });
    test('fn:fold-right', () {
      XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) - (args[1].first as num));
      // (1 - (2 - (3 - (4 - (5 - 0))))) = 1 - (2 - (3 - (4 - 5))) = 1 - (2 - (3 - (-1))) = 1 - (2 - 4) = 1 - (-2) = 3
      expect(
        fnFoldRight(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          XPathSequence.single(sub),
        ]).first,
        3,
      );
    });
    test('fn:for-each-pair', () {
      XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(
            args[0].toXPathString() + args[1].toXPathString(),
          );
      expect(
        fnForEachPair(context, [
          const XPathSequence(['a', 'b', 'c']),
          const XPathSequence(['1', '2', '3']),
          XPathSequence.single(concat),
        ]).toList(),
        ['a1', 'b2', 'c3'],
      );
    });
    test('fn:function-lookup', () {
      expect(
        () => fnFunctionLookup(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-name', () {
      expect(
        () => fnFunctionName(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-arity', () {
      expect(
        () => fnFunctionArity(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:load-xquery-module', () {
      expect(
        () => fnLoadXqueryModule(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:transform', () {
      expect(
        () => fnTransform(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
  group('map', () {
    test('op:same-key', () {
      expect(
        opSameKey(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        opSameKey(context, [
          const XPathSequence.single(double.nan),
          const XPathSequence.single(double.nan),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        opSameKey(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        XPathSequence.falseSequence,
      );
    });
    test('map:merge', () {
      final map1 = {'a': 1, 'b': 2};
      final map2 = {'b': 3, 'c': 4};
      expect(
        mapMerge(context, [
          XPathSequence([map1, map2]),
        ]).first,
        // duplicate keys: last wins by default? logic says result.addAll which overwrites.
        {'a': 1, 'b': 3, 'c': 4},
      );
      expect(
        () => mapMerge(context, [const XPathSequence.single(123)]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('map:size', () {
      final map = {'a': 1, 'b': 2};
      expect(mapSize(context, [XPathSequence.single(map)]), [2]);
    });
    test('map:keys', () {
      final map = {'a': 1, 'b': 2};
      // Keys matching is order-dependent? Map keys order is iteration order.
      expect(
        mapKeys(context, [XPathSequence.single(map)]).toList(),
        containsAll(['a', 'b']),
      );
    });
    test('map:contains', () {
      final map = {'a': 1};
      expect(
        mapContains(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        [true],
      );
      expect(
        mapContains(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
        ]),
        [false],
      );
    });
    test('map:get', () {
      final map = {'a': 1};
      expect(
        mapGet(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        [1],
      );
      expect(
        mapGet(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
        ]),
        isEmpty,
      );
    });
    test('map:find', () {
      // Stub implementation alias to map:get
      final map = {'a': 1};
      expect(
        mapFind(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        [1],
      );
    });
    test('map:put', () {
      final map = {'a': 1};
      expect(
        mapPut(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
          const XPathSequence.single(2),
        ]).first,
        {'a': 1, 'b': 2},
      );
    });
    test('map:entry', () {
      expect(
        mapEntry(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(1),
        ]).first,
        {'a': 1},
      );
    });
    test('map:remove', () {
      final map = {'a': 1, 'b': 2};
      expect(
        mapRemove(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]).first,
        {'b': 2},
      );
      expect(
        mapRemove(context, [
          XPathSequence.single(map),
          const XPathSequence(['a', 'b']),
        ]).first,
        const <dynamic, dynamic>{},
      );
    });
    test('map:for-each', () {
      final map = {'a': 1, 'b': 2};
      XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(
            args[0].toXPathString() + args[1].toXPathString(),
          );
      expect(
        mapForEach(context, [
          XPathSequence.single(map),
          XPathSequence.single(concat),
        ]).toList(),
        containsAll(['a1', 'b2']),
      );
    });
  });
  group('array', () {
    test('array:size', () {
      final array = ['a', 'b', 'c'];
      expect(arraySize(context, [XPathSequence.single(array)]), [3]);
    });
    test('array:get', () {
      final array = ['a', 'b'];
      expect(
        arrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
        ]),
        ['a'],
      );
      expect(
        () => arrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => arrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:put', () {
      final array = ['a', 'b'];
      expect(
        arrayPut(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
          const XPathSequence.single('c'),
        ]).first,
        ['c', 'b'],
      );
      expect(
        () => arrayPut(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
          const XPathSequence.single('c'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:append', () {
      final array = ['a'];
      expect(
        arrayAppend(context, [
          XPathSequence.single(array),
          const XPathSequence.single('b'),
        ]).first,
        ['a', 'b'],
      );
    });
    test('array:subarray', () {
      final array = ['a', 'b', 'c', 'd'];
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]).first,
        ['b', 'c', 'd'],
      );
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]).first,
        ['b', 'c'],
      );
      expect(
        () => arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(5),
        ]).first,
        isEmpty,
      );
      expect(
        () => arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
          const XPathSequence.single(2),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:remove', () {
      final array = ['a', 'b', 'c'];
      expect(
        arrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]).first,
        ['a', 'c'],
      );
      expect(
        arrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence([1, 3]),
        ]).first,
        ['b'],
      );
      expect(
        () => arrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:insert-before', () {
      final array = ['a', 'c'];
      expect(
        arrayInsertBefore(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single('b'),
        ]).first,
        ['a', 'b', 'c'],
      );
      expect(
        () => arrayInsertBefore(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
          const XPathSequence.single('d'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:head', () {
      expect(
        arrayHead(context, [
          const XPathSequence([
            ['a', 'b'],
          ]),
        ]),
        ['a'],
      );
      expect(
        () => arrayHead(context, [const XPathSequence.single([])]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:tail', () {
      expect(
        arrayTail(context, [
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ]).first,
        ['b', 'c'],
      );
      expect(
        () => arrayTail(context, [const XPathSequence.single([])]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:reverse', () {
      expect(
        arrayReverse(context, [
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ]).first,
        ['c', 'b', 'a'],
      );
    });
    test('array:join', () {
      expect(
        arrayJoin(context, [
          const XPathSequence.single([1, 2]),
        ]).first,
        [1, 2],
      );
      expect(
        arrayJoin(context, [
          const XPathSequence([
            [1, 2],
            [3, 4, 5],
          ]),
        ]).first,
        [1, 2, 3, 4, 5],
      );
    });
    test('array:flatten', () {
      final input = [
        1,
        [2, 3],
        [
          [4, 5],
        ],
      ];
      // Note: standard array:flatten is recursive.
      // My implementation might be too? Let's check.
      // Our implementation flattens recursively.
      expect(arrayFlatten(context, [XPathSequence(input)]).toList(), [
        1,
        2,
        3,
        4,
        5,
      ]);
    });
    test('array:for-each', () {
      final array = [1, 2, 3];
      XPathSequence double(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) * 2);
      final result =
          arrayForEach(context, [
                XPathSequence.single(array),
                XPathSequence.single(double),
              ]).first
              as List;
      expect(
        result.map((e) => (e as Object).toXPathSequence().first).toList(),
        [2, 4, 6],
      );
    });
    test('array:filter', () {
      final array = [1, 2, 3, 4];
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) % 2 == 0);
      final result =
          arrayFilter(context, [
                XPathSequence.single(array),
                XPathSequence.single(isEven),
              ]).first
              as List;
      expect(
        result.map((e) => (e as Object).toXPathSequence().first).toList(),
        [2, 4],
      );
    });
    test('array:fold-left', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        arrayFoldLeft(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
          XPathSequence.single(add),
        ]).first,
        15,
      );
    });
    test('array:fold-right', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) - (args[1].first as num));
      expect(
        arrayFoldRight(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
          XPathSequence.single(sub),
        ]).first,
        3,
      );
    });
    test('array:for-each-pair', () {
      final array1 = ['a', 'b', 'c'];
      final array2 = ['1', '2', '3'];
      XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(
            args[0].toXPathString() + args[1].toXPathString(),
          );
      final result =
          arrayForEachPair(context, [
                XPathSequence.single(array1),
                XPathSequence.single(array2),
                XPathSequence.single(concat),
              ]).first
              as List;
      expect(
        result
            .map((e) => (e as Object).toXPathSequence().first.toString())
            .toList(),
        ['a1', 'b2', 'c3'],
      );
    });
    test('array:sort', () {
      final array = [3, 1, 2];
      final result =
          arraySort(context, [XPathSequence.single(array)]).first as List;
      expect(
        result.map((e) => (e as Object).toXPathSequence().first).toList(),
        [1, 2, 3],
      );
      // Sort with key
      final array2 = ['apple', 'be', 'cat'];
      XPathSequence length(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(args[0].toXPathString().length);
      final result2 =
          arraySort(context, [
                XPathSequence.single(array2),
                XPathSequence.empty,
                XPathSequence.single(length),
              ]).first
              as List;
      expect(
        result2.map((e) => (e as Object).toXPathSequence().first).toList(),
        ['be', 'cat', 'apple'],
      );
    });
  });
  group('binary', () {
    test('op:hexBinary-equal', () {
      expect(
        opHexBinaryEqual(context, [
          const XPathSequence.single('AB'),
          const XPathSequence.single('AB'),
        ]),
        [true],
      );
      expect(
        opHexBinaryEqual(context, [
          const XPathSequence.single('AB'),
          const XPathSequence.single('AC'),
        ]),
        [false],
      );
    });
    test('op:hexBinary-less-than', () {
      expect(
        opHexBinaryLessThan(context, [
          const XPathSequence.single('AA'),
          const XPathSequence.single('BB'),
        ]),
        [true],
      );
    });
    test('op:hexBinary-greater-than', () {
      expect(
        opHexBinaryGreaterThan(context, [
          const XPathSequence.single('BB'),
          const XPathSequence.single('AA'),
        ]),
        [true],
      );
    });
    test('op:base64Binary-equal', () {
      expect(
        opBase64BinaryEqual(context, [
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AA=='),
        ]),
        [true],
      );
    });
    test('op:base64Binary-less-than', () {
      expect(
        opBase64BinaryLessThan(context, [
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AQ=='),
        ]),
        [true],
      );
    });
    test('op:base64Binary-greater-than', () {
      expect(
        opBase64BinaryGreaterThan(context, [
          const XPathSequence.single('AQ=='),
          const XPathSequence.single('AA=='),
        ]),
        [true],
      );
    });
  });
  group('notation', () {
    test('op:NOTATION-equal', () {
      expect(
        opNotationEqual(context, [
          const XPathSequence.single('foo:bar'),
          const XPathSequence.single('foo:bar'),
        ]),
        [true],
      );
    });
  });
  group('qname', () {
    test('op:QName-equal', () {
      expect(
        opQNameEqual(context, [XPathSequence.empty, XPathSequence.empty]),
        isEmpty,
      );
    });
    test('fn:namespace-uri-for-prefix', () {
      expect(
        () => fnNamespaceUriForPrefix(context, [
          XPathSequence.empty,
          XPathSequence.empty,
        ]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:resolve-QName', () {
      expect(
        fnResolveQName(context, [
          const XPathSequence.single('p:local'),
          const XPathSequence.single(v31.XPathString('element')),
        ]).first,
        isA<XmlName>(),
      );
    });
    test('fn:QName', () {
      expect(
        fnQName(context, [
          const XPathSequence.single('uri'),
          const XPathSequence.single('p:local'),
        ]).first,
        isA<XmlName>(),
      );
    });
    test('fn:prefix-from-QName', () {
      final qname = XmlName.fromString('p:local');
      expect(fnPrefixFromQName(context, [XPathSequence.single(qname)]), ['p']);
    });
    test('fn:local-name-from-qname', () {
      final qname = XmlName.fromString('p:local');
      expect(fnLocalNameFromQName(context, [XPathSequence.single(qname)]), [
        'local',
      ]);
    });
    test('fn:namespace-uri-from-QName', () {
      final qname = XmlName.fromString('p:local');
      expect(
        fnNamespaceUriFromQName(context, [XPathSequence.single(qname)]),
        isEmpty,
      );
    });
    test('fn:in-scope-prefixes', () {
      expect(
        () => fnInScopePrefixes(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
  group('date_time', () {
    test('fn:adjust-dateTime-to-timezone', () {
      final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
      // Adjust to UTC (same)
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(dt),
          const XPathSequence.single(Duration()),
        ]),
        [dt.toXPathDateTime()],
      );
      // Adjust to Implicit (Local)
      expect(fnAdjustDateTimeToTimezone(context, [XPathSequence.single(dt)]), [
        dt.toLocal().toXPathDateTime(),
      ]);
    });
    test('fn:format-dateTime', () {
      final dt = DateTime.utc(2020, 1, 1, 12, 0, 0);
      expect(
        fnFormatDateTime(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[Y]-[M]-[D]'),
        ]),
        // Basic implementation returns ISO string
        [v31.XPathString(dt.toIso8601String())],
      );
    });
    test('fn:year-from-date', () {
      expect(
        fnYearFromDate(context, [XPathSequence.single(DateTime(2023, 10, 26))]),
        [2023],
      );
    });
    test('op:dateTime-equal', () {
      final dt1 = DateTime(2023, 1, 1);
      final dt2 = DateTime(2023, 1, 1);
      final dt3 = DateTime(2023, 1, 2);
      expect(
        opDateTimeEqual(context, [
          XPathSequence.single(dt1),
          XPathSequence.single(dt2),
        ]),
        [true],
      );
      expect(
        opDateTimeEqual(context, [
          XPathSequence.single(dt1),
          XPathSequence.single(dt3),
        ]),
        [false],
      );
    });
    test('fn:dateTime', () {
      expect(
        fnDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26)),
          XPathSequence.single(DateTime.utc(0, 1, 1, 12, 30, 45)),
        ]).first,
        DateTime(2023, 10, 26, 12, 30, 45),
      );
    });
    test('fn:month-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnMonthFromDateTime(context, [XPathSequence.single(dt1)]), [10]);
    });
    test('fn:day-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnDayFromDateTime(context, [XPathSequence.single(dt1)]), [26]);
    });
    test('fn:hours-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnHoursFromDateTime(context, [XPathSequence.single(dt1)]), [12]);
    });
    test('fn:minutes-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnMinutesFromDateTime(context, [XPathSequence.single(dt1)]), [30]);
    });
    test('fn:seconds-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnSecondsFromDateTime(context, [XPathSequence.single(dt1)]), [
        45.0,
      ]);
    });
    test('op:dateTime-less-than', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opDateTimeLessThan(context, [
          XPathSequence.single(dt1),
          XPathSequence.single(dt2),
        ]),
        [true],
      );
      expect(
        opDateTimeLessThan(context, [
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ]),
        [false],
      );
    });
    test('op:dateTime-greater-than', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opDateTimeGreaterThan(context, [
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ]),
        [true],
      );
    });
    test('op:subtract-dateTimes', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opSubtractDateTimes(context, [
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ]).first,
        const Duration(days: 1),
      );
    });
    test('op:add-duration-to-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      const dur = Duration(days: 1);
      expect(
        opAddDurationToDateTime(context, [
          XPathSequence.single(dt1),
          const XPathSequence.single(dur),
        ]).first,
        dt2,
      );
    });
    test('op:subtract-duration-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      const dur = Duration(days: 1);
      expect(
        opSubtractDurationFromDateTime(context, [
          XPathSequence.single(dt2),
          const XPathSequence.single(dur),
        ]).first,
        dt1,
      );
    });
    test('fn:timezone-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnTimezoneFromDateTime(context, [XPathSequence.single(dt1)]), [
        Duration.zero,
      ]);
    });
    test('fn:year-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnYearFromDate(context, [XPathSequence.single(dt1)]), [2023]);
    });
    test('fn:month-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnMonthFromDate(context, [XPathSequence.single(dt1)]), [10]);
    });
    test('fn:day-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnDayFromDate(context, [XPathSequence.single(dt1)]), [26]);
    });
    test('fn:timezone-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnTimezoneFromDate(context, [XPathSequence.single(dt1)]), [
        Duration.zero,
      ]);
    });
    test('fn:hours-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnHoursFromTime(context, [XPathSequence.single(dt1)]), [12]);
    });
    test('fn:minutes-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnMinutesFromTime(context, [XPathSequence.single(dt1)]), [30]);
    });
    test('fn:seconds-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnSecondsFromTime(context, [XPathSequence.single(dt1)]), [45.0]);
    });
    test('fn:timezone-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(fnTimezoneFromTime(context, [XPathSequence.single(dt1)]), [
        Duration.zero,
      ]);
    });
    test('operators coverage', () {
      // opDateEqual
      expect(
        opDateEqual(context, [
          XPathSequence.single(DateTime(2020)),
          XPathSequence.single(DateTime(2020)),
        ]),
        XPathSequence.trueSequence,
      );
      // opDateLessThan
      expect(
        opDateLessThan(context, [
          XPathSequence.single(DateTime(2020)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
      // opDateGreaterThan
      expect(
        opDateGreaterThan(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ]),
        XPathSequence.trueSequence,
      );
      // opTimeEqual
      expect(
        opTimeEqual(context, [
          XPathSequence.single(DateTime(0, 1, 1, 10, 0, 0)),
          XPathSequence.single(DateTime(0, 1, 1, 10, 0, 0)),
        ]),
        XPathSequence.trueSequence,
      );
      // opTimeLessThan
      expect(
        opTimeLessThan(context, [
          XPathSequence.single(DateTime(2020)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
      // opTimeGreaterThan
      expect(
        opTimeGreaterThan(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ]),
        XPathSequence.trueSequence,
      );
      // opSubtractDates
      expect(
        opSubtractDates(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ]),
        isNotNull,
      );
      // opSubtractTimes
      expect(
        opSubtractTimes(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2020)),
        ]),
        isNotNull,
      );
      // opGYearMonthEqual
      expect(
        opGYearMonthEqual(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
      // opGYearEqual
      expect(
        opGYearEqual(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
      // opGMonthDayEqual
      expect(
        opGMonthDayEqual(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
      // opGMonthEqual
      expect(
        opGMonthEqual(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
      // opGDayEqual
      expect(
        opGDayEqual(context, [
          XPathSequence.single(DateTime(2021)),
          XPathSequence.single(DateTime(2021)),
        ]),
        XPathSequence.trueSequence,
      );
    });
  });
  group('duration', () {
    test('op:duration-equal', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 1);
      const d3 = Duration(days: 2);
      expect(
        opDurationEqual(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]),
        [true],
      );
      expect(
        opDurationEqual(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d3),
        ]),
        [false],
      );
    });
    test('op:yearMonthDuration-less-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationLessThan(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]),
        [true],
      );
    });
    test('op:yearMonthDuration-greater-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationGreaterThan(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [true],
      );
    });
    test('op:dayTimeDuration-less-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationLessThan(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]),
        [true],
      );
    });
    test('op:dayTimeDuration-greater-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationGreaterThan(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [true],
      );
    });
    test('op:add-yearMonthDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddYearMonthDurations(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]).first,
        d1 + d2,
      );
    });
    test('op:subtract-yearMonthDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractYearMonthDurations(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]).first,
        d1,
      );
    });
    test('op:multiply-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyYearMonthDuration(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(2),
        ]).first,
        d2,
      );
    });
    test('op:divide-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(2),
        ]).first,
        d1,
      );
    });
    test('op:divide-yearMonthDuration-by-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDurationByYearMonthDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [2.0],
      );
    });
    test('op:add-dayTimeDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddDayTimeDurations(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d2),
        ]).first,
        d1 + d2,
      );
    });
    test('op:subtract-dayTimeDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractDayTimeDurations(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]).first,
        d1,
      );
    });
    test('op:multiply-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyDayTimeDuration(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(2),
        ]).first,
        d2,
      );
    });
    test('op:divide-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(2),
        ]).first,
        d1,
      );
    });
    test('op:divide-dayTimeDuration-by-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDurationByDayTimeDuration(context, [
          const XPathSequence.single(d2),
          const XPathSequence.single(d1),
        ]),
        [2.0],
      );
    });
    test('fn:years-from-duration', () {
      const d1 = Duration(days: 1);
      expect(fnYearsFromDuration(context, [const XPathSequence.single(d1)]), [
        0,
      ]);
    });
    test('fn:months-from-duration', () {
      const d1 = Duration(days: 1);
      expect(fnMonthsFromDuration(context, [const XPathSequence.single(d1)]), [
        0,
      ]);
    });
    test('fn:days-from-duration', () {
      const d1 = Duration(days: 1);
      expect(fnDaysFromDuration(context, [const XPathSequence.single(d1)]), [
        1,
      ]);
    });
    test('fn:hours-from-duration', () {
      const d3 = Duration(hours: 1);
      expect(fnHoursFromDuration(context, [const XPathSequence.single(d3)]), [
        1,
      ]);
    });
    test('fn:minutes-from-duration', () {
      const d = Duration(minutes: 90);
      expect(fnMinutesFromDuration(context, [const XPathSequence.single(d)]), [
        30,
      ]);
    });
    test('fn:seconds-from-duration', () {
      const d = Duration(seconds: 90); // 1 min 30 sec
      expect(fnSecondsFromDuration(context, [const XPathSequence.single(d)]), [
        30.0,
      ]);
    });
  });
  group('json', () {
    test('fn:parse-json', () {
      expect(
        () => fnParseJson(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:json-doc', () {
      expect(
        () => fnJsonDoc(context, [const XPathSequence.single('url')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:json-to-xml', () {
      expect(
        () => fnJsonToXml(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:xml-to-json', () {
      expect(
        () => fnXmlToJson(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
  group('uri', () {
    test('fn:resolve-uri', () {
      expect(
        fnResolveUri(context, [
          const XPathSequence.single(v31.XPathString('foo')),
          const XPathSequence.single(v31.XPathString('http://example.com/')),
        ]),
        [const v31.XPathString('http://example.com/foo')],
      );
      expect(
        () => fnResolveUri(context, [
          const XPathSequence.single(v31.XPathString('foo')),
          const XPathSequence.single(v31.XPathString('::invalid::')),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('fn:encode-for-uri', () {
      expect(fnEncodeForUri(context, [const XPathSequence.single(' ')]), [
        const v31.XPathString('%20'),
      ]);
    });
    test('fn:iri-to-uri', () {
      expect(fnIriToUri(context, [const XPathSequence.single(' ')]), [
        const v31.XPathString('%20'),
      ]);
    });
    test('fn:escape-html-uri', () {
      expect(fnEscapeHtmlUri(context, [const XPathSequence.single(' ')]), [
        const v31.XPathString('%20'),
      ]);
    });
  });
  group('general', () {
    test('op:and', () {
      expect(opAnd(context, const []), [true]);
      expect(opAnd(context, [XPathSequence.trueSequence]), [true]);
      expect(opAnd(context, [XPathSequence.falseSequence]), [false]);
      expect(
        opAnd(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
      expect(
        opAnd(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [false],
      );
      expect(
        opAnd(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [false],
      );
    });
    test('op:or', () {
      expect(opOr(context, const []), [false]);
      expect(opOr(context, [XPathSequence.trueSequence]), [true]);
      expect(opOr(context, [XPathSequence.falseSequence]), [false]);
      expect(
        opOr(context, [
          XPathSequence.falseSequence,
          XPathSequence.falseSequence,
        ]),
        [false],
      );
      expect(
        opOr(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [true],
      );
      expect(
        opOr(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
    });
    test('op:general-equal', () {
      expect(
        opGeneralEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([2, 3]),
        ]),
        [true],
      );
      expect(
        opGeneralEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([3, 4]),
        ]),
        [false],
      );
      expect(
        opGeneralEqual(context, [
          const XPathSequence([1]),
          const XPathSequence(['1']),
        ]),
        [true],
      );
    });
    test('op:general-not-equal', () {
      expect(
        opGeneralNotEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([2, 3]),
        ]),
        [true],
      );
      expect(
        opGeneralNotEqual(context, [
          const XPathSequence([1]),
          const XPathSequence([1]),
        ]),
        [false],
      );
      expect(
        opGeneralNotEqual(context, [
          const XPathSequence([1]),
          const XPathSequence(['1']),
        ]),
        [
          true,
        ], // TODO: Should be false, but current implementation lacks type promotion
      );
    });

    test('op:general-less-than', () {
      expect(
        opGeneralLessThan(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
    test('op:general-greater-than', () {
      expect(
        opGeneralGreaterThan(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
    test('op:general-less-than-or-equal', () {
      expect(
        opGeneralLessThanOrEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
    test('op:general-greater-than-or-equal', () {
      expect(
        opGeneralGreaterThanOrEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
  });
  group('date_time', () {
    test('fn:dateTime (empty)', () {
      expect(
        fnDateTime(context, [
          XPathSequence.empty,
          XPathSequence.single(DateTime.now()),
        ]),
        isEmpty,
      );
      expect(
        fnDateTime(context, [
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ]),
        isEmpty,
      );
    });
    test('fn:adjust-dateTime-to-timezone (empty timezone)', () {
      final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(dt),
          XPathSequence.empty, // Empty timezone sequence
        ]),
        [dt.toXPathDateTime()],
      );
    });
    test('fn:adjust-date-to-timezone', () {
      final dt = DateTime.utc(2020, 1, 1);
      // Implicit
      expect(fnAdjustDateToTimezone(context, [XPathSequence.single(dt)]), [
        dt.toLocal().toXPathDateTime(),
      ]);
    });
    test('fn:adjust-time-to-timezone', () {
      final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
      // Implicit
      expect(fnAdjustTimeToTimezone(context, [XPathSequence.single(dt)]), [
        dt.toLocal().toXPathDateTime(),
      ]);
    });
    test('fn:format-date', () {
      final dt = DateTime.utc(2020, 1, 1);
      expect(
        fnFormatDate(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[Y]'),
        ]),
        [v31.XPathString(dt.toIso8601String())],
      );
    });
    test('fn:format-time', () {
      final dt = DateTime.utc(1970, 1, 1, 10, 30, 0);
      expect(
        fnFormatTime(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[H]:[m]'),
        ]),
        [v31.XPathString(dt.toIso8601String())],
      );
    });
    test('fn:format-dateTime (empty)', () {
      expect(
        fnFormatDateTime(context, [
          XPathSequence.empty,
          const XPathSequence.single('[Y]'),
        ]),
        isEmpty,
      );
    });
    // Component extraction empty tests
    test('components (empty)', () {
      expect(fnYearFromDateTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnMonthFromDateTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnDayFromDateTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnHoursFromDateTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnMinutesFromDateTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnSecondsFromDateTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnTimezoneFromDateTime(context, [XPathSequence.empty]), isEmpty);

      expect(fnYearFromDate(context, [XPathSequence.empty]), isEmpty);
      expect(fnMonthFromDate(context, [XPathSequence.empty]), isEmpty);
      expect(fnDayFromDate(context, [XPathSequence.empty]), isEmpty);
      expect(fnTimezoneFromDate(context, [XPathSequence.empty]), isEmpty);

      expect(fnHoursFromTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnMinutesFromTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnSecondsFromTime(context, [XPathSequence.empty]), isEmpty);
      expect(fnTimezoneFromTime(context, [XPathSequence.empty]), isEmpty);
    });

    test('subtraction (empty)', () {
      expect(
        opSubtractDateTimes(context, [
          XPathSequence.empty,
          XPathSequence.single(DateTime.now()),
        ]),
        isEmpty,
      );
      expect(
        opSubtractDateTimes(context, [
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ]),
        isEmpty,
      );
    });
    test('add duration (empty)', () {
      expect(
        opAddDurationToDateTime(context, [
          XPathSequence.empty,
          const XPathSequence.single(Duration()),
        ]),
        isEmpty,
      );
      expect(
        opAddDurationToDateTime(context, [
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ]),
        isEmpty,
      );
    });
    test('subtract duration (empty)', () {
      expect(
        opSubtractDurationFromDateTime(context, [
          XPathSequence.empty,
          const XPathSequence.single(Duration()),
        ]),
        isEmpty,
      );
      expect(
        opSubtractDurationFromDateTime(context, [
          XPathSequence.single(DateTime.now()),
          XPathSequence.empty,
        ]),
        isEmpty,
      );
    });
    test('fn:adjust-dateTime-to-timezone (unsupported)', () {
      final now = DateTime.now();
      final localOffset = now.timeZoneOffset;
      // Create a duration that is definitely not matching local or UTC
      // If local is 0, we use 42 mins. If local is 42 mins, we use 43.
      var weirdOffset = const Duration(minutes: 42);
      if (localOffset.inMinutes == 42) {
        weirdOffset = const Duration(minutes: 43);
      }

      expect(
        () => fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(now),
          XPathSequence.single(weirdOffset),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('fn:parse-ietf-date', () {
      expect(
        () => fnParseIetfDate(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
