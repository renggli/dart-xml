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
import 'package:xml/src/xpath/types31/map.dart';
import 'package:xml/src/xpath/types31/sequence.dart';
import 'package:xml/src/xpath/types31/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('accessor', () {
    test('fn:node-name', () {
      final a = document.findAllElements('a').first;
      expect(fnNodeName(XPathContext(a), []), XPathSequence.single(a.name));
      expect(
        fnNodeName(context, [XPathSequence.single(a)]),
        XPathSequence.single(a.name),
      );
      expect(fnNodeName(context, [XPathSequence.empty]), XPathSequence.empty);
    });
    test('fn:nilled', () {
      expect(
        fnNilled(context, [XPathSequence.single(document)]),
        XPathSequence.empty,
      );
      expect(
        fnNilled(context, [XPathSequence.single(document.rootElement)]),
        XPathSequence.falseSequence,
      );
      expect(fnNilled(context, [XPathSequence.empty]), XPathSequence.empty);
    });
    test('fn:string', () {
      expect(
        fnString(context, [XPathSequence.single('foo')]),
        XPathSequence.single(const v31.XPathString('foo')),
      );
      expect(
        fnString(context, [XPathSequence.empty]),
        XPathSequence.single(v31.XPathString.empty),
      );
      expect(
        fnString(XPathContext(document.findAllElements('a').first), []),
        XPathSequence.single(const v31.XPathString('1')),
      );
    });
    test('fn:data', () {
      expect(fnData(context, [XPathSequence.empty]), XPathSequence.empty);
      expect(
        fnData(context, [XPathSequence.single(123)]),
        XPathSequence.single(123),
      );
      expect(
        fnData(context, [
          XPathSequence.single([1, 2, 3]),
        ]),
        const XPathSequence([1, 2, 3]),
      );
    });
    test('fn:base-uri', () {
      expect(
        fnBaseUri(context, [XPathSequence.single(document)]),
        XPathSequence.empty,
      );
    });
    test('fn:document-uri', () {
      expect(
        fnDocumentUri(context, [XPathSequence.single(document)]),
        XPathSequence.empty,
      );
    });
    test('fn:node-name processing-instruction', () {
      final pi = XmlProcessing('target', 'value');
      expect(
        fnNodeName(context, [XPathSequence.single(pi)]).first.toString(),
        equals('target'),
      );
    });
    test('fn:base-uri', () {
      expect(fnBaseUri(context, []), isEmpty);
    });
    test('fn:document-uri', () {
      expect(fnDocumentUri(context, []), isEmpty);
    });
    test('fn:nilled', () {
      // Element -> false
      final el = XmlElement(XmlName.fromString('e'));
      expect(
        fnNilled(context, [XPathSequence.single(el)]),
        orderedEquals([false]),
      );
      // Other -> empty
      expect(
        fnNilled(context, [XPathSequence.single(const v31.XPathString('s'))]),
        isEmpty,
      );
    });
  });
  group('error', () {
    test('fn:error', () {
      expect(
        () => fnError(context, []),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => fnError(context, [XPathSequence.single('err:code')]),
        throwsA(
          isA<XPathEvaluationException>().having(
            (e) => e.message,
            'message',
            contains('err:code'),
          ),
        ),
      );
    });
    test('fn:trace', () {
      final seq = XPathSequence.single(1);
      final traceLog = <(XPathSequence, String?)>[];
      final traceContext = context.copy(
        onTraceCallback: (value, label) {
          traceLog.add((value, label));
        },
      );
      expect(fnTrace(traceContext, [seq]), seq);
      expect(traceLog, hasLength(1));
      expect(traceLog.first.$1, seq);
      expect(traceLog.first.$2, null);
      expect(fnTrace(traceContext, [seq, XPathSequence.single('label')]), seq);
      expect(traceLog, hasLength(2));
      expect(traceLog.last.$1, seq);
      expect(traceLog.last.$2, 'label');
    });
    test('fn:error', () {
      expect(
        () => fnError(context, []),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => fnError(context, [XPathSequence.single('code')]),
        throwsA(isA<XPathEvaluationException>()),
      );
      try {
        fnError(context, [
          XPathSequence.single('code'),
          XPathSequence.single('desc'),
          XPathSequence.single('obj'),
        ]);
      } catch (e) {
        expect(e.toString(), contains('code: desc ([obj])'));
      }
    });
    test('fn:trace', () {
      expect(
        fnTrace(context, [
          XPathSequence.single('value'),
          XPathSequence.single('label'),
        ]),
        orderedEquals(['value']),
      );
    });
  });
  group('number', () {
    test('fn:abs', () {
      expect(
        fnAbs(context, [XPathSequence.single(-5)]),
        XPathSequence.single(5),
      );
      expect(fnAbs(context, [XPathSequence.empty]), XPathSequence.empty);
    });
    test('fn:ceiling', () {
      expect(
        fnCeiling(context, [XPathSequence.single(1.1)]),
        XPathSequence.single(2),
      );
    });
    test('fn:floor', () {
      expect(
        fnFloor(context, [XPathSequence.single(1.9)]),
        XPathSequence.single(1),
      );
    });
    test('fn:round', () {
      expect(
        fnRound(context, [XPathSequence.single(1.1)]),
        XPathSequence.single(1),
      );
      expect(
        fnRound(context, [XPathSequence.single(1.5)]),
        XPathSequence.single(2),
      );
    });
    test('fn:round-half-to-even', () {
      expect(
        fnRoundHalfToEven(context, [XPathSequence.single(0.5)]),
        XPathSequence.single(0),
      );
      expect(
        fnRoundHalfToEven(context, [XPathSequence.single(1.5)]),
        XPathSequence.single(2),
      );
      expect(
        fnRoundHalfToEven(context, [XPathSequence.single(2.5)]),
        XPathSequence.single(2),
      );
    });
    test('fn:number', () {
      expect(
        fnNumber(context, [XPathSequence.single('123')]),
        XPathSequence.single(123),
      );
      expect(
        (fnNumber(context, [XPathSequence.empty]).first as num).isNaN,
        isTrue,
      );
    });
    test('math:pi', () {
      expect(mathPi(context, []), XPathSequence.single(math.pi));
    });
    test('math:sqrt', () {
      expect(
        mathSqrt(context, [XPathSequence.single(4)]),
        XPathSequence.single(2),
      );
    });
    test('fn:random-number-generator', () {
      final result = fnRandomNumberGenerator(context, []).toXPathMap();
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
      expect(next, equals(result['number']));
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
          XPathSequence.single(1),
          XPathSequence.single(2),
        ]),
        orderedEquals([3]),
      );
    });
    test('op:numeric-subtract', () {
      expect(
        opNumericSubtract(context, [
          XPathSequence.single(3),
          XPathSequence.single(2),
        ]),
        orderedEquals([1]),
      );
    });
    test('op:numeric-multiply', () {
      expect(
        opNumericMultiply(context, [
          XPathSequence.single(2),
          XPathSequence.single(3),
        ]),
        orderedEquals([6]),
      );
    });
    test('op:numeric-divide', () {
      expect(
        opNumericDivide(context, [
          XPathSequence.single(6),
          XPathSequence.single(2),
        ]),
        orderedEquals([3.0]),
      );
    });
    test('op:numeric-integer-divide', () {
      expect(
        opNumericIntegerDivide(context, [
          XPathSequence.single(10),
          XPathSequence.single(3),
        ]),
        orderedEquals([3]),
      );
    });
    test('op:numeric-mod', () {
      expect(
        opNumericMod(context, [
          XPathSequence.single(10),
          XPathSequence.single(3),
        ]),
        orderedEquals([1]),
      );
    });
    test('op:numeric-unary-plus', () {
      expect(
        opNumericUnaryPlus(context, [XPathSequence.single(1)]),
        orderedEquals([1]),
      );
    });
    test('op:numeric-unary-minus', () {
      expect(
        opNumericUnaryMinus(context, [XPathSequence.single(1)]),
        orderedEquals([-1]),
      );
    });
    test('op:numeric-equal', () {
      expect(
        opNumericEqual(context, [
          XPathSequence.single(1),
          XPathSequence.single(1),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:numeric-less-than', () {
      expect(
        opNumericLessThan(context, [
          XPathSequence.single(1),
          XPathSequence.single(2),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:numeric-greater-than', () {
      expect(
        opNumericGreaterThan(context, [
          XPathSequence.single(2),
          XPathSequence.single(1),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:abs', () {
      expect(fnAbs(context, [XPathSequence.single(-1)]), orderedEquals([1]));
      expect(fnAbs(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:ceiling', () {
      expect(
        fnCeiling(context, [XPathSequence.single(1.5)]),
        orderedEquals([2]),
      );
    });
    test('fn:floor', () {
      expect(fnFloor(context, [XPathSequence.single(1.5)]), orderedEquals([1]));
    });
    test('fn:round', () {
      expect(fnRound(context, [XPathSequence.single(1.5)]), orderedEquals([2]));
      expect(fnRound(context, [XPathSequence.empty]), isEmpty);
      expect(
        fnRound(context, [XPathSequence.single(double.nan)]),
        orderedEquals([isNaN]),
      );
      expect(
        fnRound(context, [XPathSequence.single(1.5), XPathSequence.single(1)]),
        orderedEquals([1.5]),
      );
    });
    test('fn:round-half-to-even', () {
      expect(
        fnRoundHalfToEven(context, [XPathSequence.single(1.5)]),
        orderedEquals([2]),
      );
      expect(
        fnRoundHalfToEven(context, [XPathSequence.single(2.5)]),
        orderedEquals([2]),
      );
      expect(fnRoundHalfToEven(context, [XPathSequence.empty]), isEmpty);
    });
    test('fn:format-integer', () {
      expect(
        fnFormatInteger(context, [
          XPathSequence.single(123),
          XPathSequence.single('000'),
        ]),
        orderedEquals(['123']),
      );
      expect(
        fnFormatInteger(context, [
          XPathSequence.empty,
          XPathSequence.single('000'),
        ]),
        isEmpty,
      );
    });
    test('fn:number', () {
      expect(
        fnNumber(context, [XPathSequence.single('123')]),
        orderedEquals([123]),
      );
      expect(fnNumber(context, [XPathSequence.empty]), orderedEquals([isNaN]));
    });
    test('math functions', () {
      expect(
        mathPi(context, []),
        orderedEquals([predicate((x) => (x as double) > 3.14)]),
      );
      expect(mathExp(context, [XPathSequence.single(0)]), orderedEquals([1.0]));
      expect(
        mathExp10(context, [XPathSequence.single(0)]),
        orderedEquals([1.0]),
      );
      expect(
        mathLog(context, [XPathSequence.single(math.e)]),
        orderedEquals([1.0]),
      );
      expect(
        mathLog10(context, [XPathSequence.single(10)]),
        orderedEquals([1.0]),
      );
      expect(
        mathPow(context, [XPathSequence.single(2), XPathSequence.single(3)]),
        orderedEquals([8.0]),
      );
      expect(
        mathSqrt(context, [XPathSequence.single(4)]),
        orderedEquals([2.0]),
      );
      expect(mathSin(context, [XPathSequence.single(0)]), orderedEquals([0.0]));
      expect(mathCos(context, [XPathSequence.single(0)]), orderedEquals([1.0]));
      expect(mathTan(context, [XPathSequence.single(0)]), orderedEquals([0.0]));
      expect(
        mathAsin(context, [XPathSequence.single(0)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAcos(context, [XPathSequence.single(1)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAtan(context, [XPathSequence.single(0)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAtan2(context, [XPathSequence.single(0), XPathSequence.single(1)]),
        orderedEquals([0.0]),
      );
    });
    test('fn:random-number-generator', () {
      expect(
        fnRandomNumberGenerator(context, [XPathSequence.single(1)]),
        hasLength(1),
      );
    });
  });
  group('string', () {
    test('fn:concat', () {
      expect(
        fnConcat(context, [
          XPathSequence.single('a'),
          XPathSequence.single('b'),
        ]),
        XPathSequence.single(const v31.XPathString('ab')),
      );
      expect(
        fnConcat(context, [
          XPathSequence.single('a'),
          XPathSequence.single('b'),
          XPathSequence.single('c'),
        ]),
        orderedEquals(['abc']),
      );
    });
    test('fn:string-join', () {
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b']),
          XPathSequence.single(','),
        ]),
        XPathSequence.single(const v31.XPathString('a,b')),
      );
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
          XPathSequence.single('-'),
        ]),
        orderedEquals(['a-b-c']),
      );
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
        ]),
        orderedEquals(['abc']),
      );
    });
    test('fn:substring', () {
      expect(
        fnSubstring(context, [
          XPathSequence.single('motor car'),
          XPathSequence.single(6),
        ]),
        orderedEquals([' car']),
      );
      expect(
        fnSubstring(context, [
          XPathSequence.single('metadata'),
          XPathSequence.single(4),
          XPathSequence.single(3),
        ]),
        orderedEquals(['ada']),
      );
      expect(
        fnSubstring(context, [
          XPathSequence.single('12345'),
          XPathSequence.single(1.5),
          XPathSequence.single(2.6),
        ]),
        orderedEquals(['234']),
      );
      expect(
        fnSubstring(context, [
          XPathSequence.single('12345'),
          XPathSequence.single(0),
          XPathSequence.single(3),
        ]),
        orderedEquals(['12']),
      );
    });
    test('fn:string-length', () {
      expect(
        fnStringLength(context, [XPathSequence.single('abc')]),
        orderedEquals([3]),
      );
      expect(
        fnStringLength(context, [XPathSequence.empty]),
        orderedEquals([0]),
      );
    });
    test('fn:normalize-space', () {
      expect(
        fnNormalizeSpace(context, [XPathSequence.single('  a  b   c  ')]),
        orderedEquals(['a b c']),
      );
    });
    test('fn:upper-case', () {
      expect(
        fnUpperCase(context, [XPathSequence.single('abc')]),
        orderedEquals(['ABC']),
      );
    });
    test('fn:lower-case', () {
      expect(
        fnLowerCase(context, [XPathSequence.single('ABC')]),
        orderedEquals(['abc']),
      );
    });
    test('fn:contains', () {
      expect(
        fnContains(context, [
          XPathSequence.single('abc'),
          XPathSequence.single('b'),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        fnContains(context, [
          XPathSequence.single('tattoo'),
          XPathSequence.single('t'),
        ]),
        orderedEquals([true]),
      );
      expect(
        fnContains(context, [
          XPathSequence.single('tattoo'),
          XPathSequence.single('z'),
        ]),
        orderedEquals([false]),
      );
    });
    test('fn:starts-with', () {
      expect(
        fnStartsWith(context, [
          XPathSequence.single('tattoo'),
          XPathSequence.single('tat'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:ends-with', () {
      expect(
        fnEndsWith(context, [
          XPathSequence.single('tattoo'),
          XPathSequence.single('too'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:substring-before', () {
      expect(
        fnSubstringBefore(context, [
          XPathSequence.single('tattoo'),
          XPathSequence.single('too'),
        ]),
        orderedEquals(['tat']),
      );
    });
    test('fn:substring-after', () {
      expect(
        fnSubstringAfter(context, [
          XPathSequence.single('tattoo'),
          XPathSequence.single('tat'),
        ]),
        orderedEquals(['too']),
      );
    });
    test('fn:translate', () {
      expect(
        fnTranslate(context, [
          XPathSequence.single('bar'),
          XPathSequence.single('abc'),
          XPathSequence.single('ABC'),
        ]),
        orderedEquals(['BAr']),
      );
    });
    test('fn:matches', () {
      expect(
        fnMatches(context, [
          XPathSequence.single('abc'),
          XPathSequence.single('b'),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        fnMatches(context, [
          XPathSequence.single('abracadabra'),
          XPathSequence.single('bra'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:replace', () {
      expect(
        fnReplace(context, [
          XPathSequence.single('abracadabra'),
          XPathSequence.single('bra'),
          XPathSequence.single('*'),
        ]),
        orderedEquals(['a*cada*']),
      );
    });
    test('fn:codepoints-to-string', () {
      expect(
        fnCodepointsToString(context, [
          const XPathSequence([97, 98, 99]),
        ]),
        orderedEquals(['abc']),
      );
      expect(
        () => fnCodepointsToString(context, [XPathSequence.single(-1)]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('fn:string-to-codepoints', () {
      expect(
        fnStringToCodepoints(context, [XPathSequence.single('abc')]),
        orderedEquals([97, 98, 99]),
      );
    });
    test('fn:compare', () {
      expect(
        fnCompare(context, [
          XPathSequence.single('a'),
          XPathSequence.single('b'),
        ]),
        orderedEquals([-1]),
      );
    });
    test('fn:codepoint-equal', () {
      expect(
        fnCodepointEqual(context, [
          XPathSequence.single('a'),
          XPathSequence.single('a'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:collation-key', () {
      expect(
        fnCollationKey(context, [XPathSequence.single('abc')]),
        orderedEquals(['abc']),
      );
    });
    test('fn:contains-token', () {
      expect(
        fnContainsToken(context, [
          XPathSequence.single('a b c'),
          XPathSequence.single('b'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:normalize-unicode', () {
      expect(
        fnNormalizeUnicode(context, [XPathSequence.single('a')]),
        orderedEquals(['a']),
      );
    });
    test('fn:tokenize', () {
      expect(
        fnTokenize(context, [XPathSequence.single('a b c')]).toList(),
        orderedEquals(['a', 'b', 'c']),
      );
      expect(
        fnTokenize(context, [
          XPathSequence.single('abracadabra'),
          XPathSequence.single('(ab)|(a)'),
        ]).toList(),
        orderedEquals(['', 'r', 'c', 'd', 'r', '']),
      );
    });
    test('fn:analyze-string', () {
      expect(
        () => fnAnalyzeString(context, []),
        throwsA(isA<UnimplementedError>()),
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
        equals(XPathSequence.trueSequence),
      );
      expect(
        opBooleanEqual(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        equals(XPathSequence.falseSequence),
      );
    });
    test('op:boolean-less-than', () {
      expect(
        opBooleanLessThan(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        equals(XPathSequence.trueSequence),
      );
      expect(
        opBooleanLessThan(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        equals(XPathSequence.falseSequence),
      );
    });
    test('op:boolean-greater-than', () {
      expect(
        opBooleanGreaterThan(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        equals(XPathSequence.trueSequence),
      );
      expect(
        opBooleanGreaterThan(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        equals(XPathSequence.falseSequence),
      );
    });
    test('fn:boolean', () {
      expect(
        fnBoolean(context, [XPathSequence.single(true)]),
        XPathSequence.trueSequence,
      );
      expect(
        fnBoolean(context, [XPathSequence.empty]),
        XPathSequence.falseSequence,
      );
      expect(
        fnBoolean(context, [XPathSequence.single(1)]),
        orderedEquals([true]),
      );
    });
    test('fn:not', () {
      expect(
        fnNot(context, [XPathSequence.single(true)]),
        XPathSequence.falseSequence,
      );
    });
    test('fn:true', () {
      expect(fnTrue(context, []), XPathSequence.trueSequence);
    });
    test('fn:false', () {
      expect(fnFalse(context, []), XPathSequence.falseSequence);
    });
    test('fn:lang', () {
      final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
      final c = doc.rootElement.children.whereType<XmlElement>().first;
      final newContext = XPathContext(c);
      expect(
        fnLang(newContext, [XPathSequence.single('en')]),
        orderedEquals([true]),
      );
      expect(
        fnLang(newContext, [XPathSequence.single('fr')]),
        orderedEquals([false]),
      );
      expect(
        fnLang(newContext, [XPathSequence.single('EN-US')]),
        orderedEquals([false]),
      );
    });
  });
  group('node', () {
    test('fn:name', () {
      final a = document.findAllElements('a').first;
      expect(
        fnName(context, [XPathSequence.single(a)]),
        XPathSequence.single(const v31.XPathString('a')),
      );
    });
    test('fn:local-name', () {
      final a = document.findAllElements('a').first;
      expect(
        fnLocalName(context, [XPathSequence.single(a)]),
        XPathSequence.single(const v31.XPathString('a')),
      );
    });
    test('fn:root', () {
      final a = document.findAllElements('a').first;
      expect(
        fnRoot(context, [XPathSequence.single(a)]),
        XPathSequence.single(document),
      );
    });
    test('fn:has-children', () {
      expect(
        fnHasChildren(context, [XPathSequence.single(document)]),
        XPathSequence.trueSequence,
      );
    });
    test('fn:innermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnInnermost(context, [
          XPathSequence([document, a]),
        ]),
        XPathSequence.single(a),
      );
    });
    test('fn:outermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnOutermost(context, [
          XPathSequence([document, a]),
        ]),
        XPathSequence.single(document),
      );
    });
    test('fn:path', () {
      final a = document.findAllElements('a').first;
      expect(
        fnPath(context, [XPathSequence.single(a)]),
        XPathSequence.single(const v31.XPathString('/r/a')),
      );
    });
    group('node hierarchy', () {
      final document = XmlDocument.parse('''
        <root>
          <child1>
            <grandchild1/>
            <grandchild2/>
          </child1>
          <child2/>
          <child3/>
        </root>''');
      final root = document.rootElement;
      final child1 = root.children.whereType<XmlElement>().first;
      final grandchild2 = child1.children.whereType<XmlElement>().last;
      final child3 = root.children.whereType<XmlElement>().last;
      test('fn:name', () {
        expect(
          fnName(context, [XPathSequence.single(root)]),
          orderedEquals(['root']),
        );
        expect(
          fnName(context, [XPathSequence.single(document)]),
          orderedEquals(['']),
        );
      });
      test('fn:local-name', () {
        expect(
          fnLocalName(context, [XPathSequence.single(root)]),
          orderedEquals(['root']),
        );
      });
      test('fn:namespace-uri', () {
        expect(
          fnNamespaceUri(context, [XPathSequence.single(root)]),
          orderedEquals(['']),
        );
      });
      test('fn:root', () {
        expect(
          fnRoot(context, [XPathSequence.single(grandchild2)]).first,
          equals(document),
        );
      });
      test('fn:has-children', () {
        expect(
          fnHasChildren(context, [XPathSequence.single(root)]),
          orderedEquals([true]),
        );
        expect(
          fnHasChildren(context, [XPathSequence.single(grandchild2)]),
          orderedEquals([false]),
        );
      });
      test('fn:innermost', () {
        expect(
          fnInnermost(context, [
            XPathSequence([root, child1, grandchild2, child3]),
          ]).toList(),
          containsAll([grandchild2, child3]),
        );
      });
      test('fn:outermost', () {
        expect(
          fnOutermost(context, [
            XPathSequence([root, child1, grandchild2, child3]),
          ]).toList(),
          orderedEquals([root]),
        );
      });
      test('fn:path', () {
        // Basic path test, implementation might be simple
        final path = fnPath(context, [
          XPathSequence.single(grandchild2),
        ]).firstOrNull?.toString();
        // Implementation uses names and indexes.
        // root -> child[1] -> grandchild[1]
        // path string format: /root/child[1]/grandchild
        expect(path, isNotNull);
        expect(path, matches(RegExp(r'/root.*child.*grandchild')));
      });
    });
  });
  group('context', () {
    test('fn:position', () {
      expect(fnPosition(context, []), XPathSequence.single(1));
    });
    test('fn:last', () {
      expect(fnLast(context, []), XPathSequence.single(1));
    });
    test('fn:current-dateTime', () {
      expect(fnCurrentDateTime(context, []).first, isA<DateTime>());
    });
    test('fn:current-date', () {
      expect(fnCurrentDate(context, []).first, isA<DateTime>());
    });
    test('fn:current-time', () {
      expect(fnCurrentTime(context, []).first, isA<DateTime>());
    });
    test('fn:implicit-timezone', () {
      expect(fnImplicitTimezone(context, []), orderedEquals([Duration.zero]));
    });
    test('fn:default-collation', () {
      expect(
        fnDefaultCollation(context, []),
        orderedEquals([
          'http://www.w3.org/2005/xpath-functions/collation/codepoint',
        ]),
      );
    });
    test('fn:default-language', () {
      expect(fnDefaultLanguage(context, []), orderedEquals(['en']));
    });
    test('fn:static-base-uri', () {
      expect(fnStaticBaseUri(context, []), isEmpty);
    });
  });
  group('sequence', () {
    group('general functions and operators on sequences', () {
      test('fn:empty', () {
        expect(
          fnEmpty(context, [XPathSequence.empty]),
          XPathSequence.trueSequence,
        );
        expect(
          fnEmpty(context, [XPathSequence.single(1)]),
          XPathSequence.falseSequence,
        );
      });
      test('fn:exists', () {
        expect(
          fnExists(context, [XPathSequence.empty]),
          XPathSequence.falseSequence,
        );
        expect(
          fnExists(context, [XPathSequence.single(1)]),
          XPathSequence.trueSequence,
        );
      });
      test('fn:head', () {
        expect(fnHead(context, [XPathSequence.empty]), XPathSequence.empty);
        expect(
          fnHead(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(1),
        );
      });
      test('fn:tail', () {
        expect(fnTail(context, [XPathSequence.empty]), XPathSequence.empty);
        expect(
          fnTail(context, [
            const XPathSequence([1]),
          ]),
          XPathSequence.empty,
        );
        expect(
          fnTail(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence([2, 3]),
        );
      });
      test('fn:insert-before', () {
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(1),
            XPathSequence.single(0),
          ]),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(2),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 0, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(3),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 0]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(0),
            XPathSequence.single(0),
          ]),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(10),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 0]),
        );
      });
      test('fn:remove', () {
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(2),
          ]),
          const XPathSequence([1, 3]),
        );
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 3]),
        );
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(4),
          ]),
          const XPathSequence([1, 2, 3]),
        );
      });
      test('fn:reverse', () {
        expect(
          fnReverse(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence([3, 2, 1]),
        );
        expect(fnReverse(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:subsequence', () {
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(2),
          ]),
          const XPathSequence([2, 3, 4, 5]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(2),
            XPathSequence.single(2),
          ]),
          const XPathSequence([2, 3]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(0),
            XPathSequence.single(2),
          ]),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(-1),
            XPathSequence.single(3),
          ]),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(0.5),
            XPathSequence.single(1),
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
            XPathSequence.single(1),
          ]),
          const XPathSequence([1, 3]),
        );
        expect(
          fnIndexOf(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(4),
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
          XPathSequence.falseSequence,
        );
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.falseSequence,
        );
      });
    });
    group('functions that test the cardinality of sequences', () {
      test('fn:zero-or-one', () {
        expect(
          fnZeroOrOne(context, [XPathSequence.empty]),
          XPathSequence.empty,
        );
        expect(
          fnZeroOrOne(context, [XPathSequence.single(1)]),
          XPathSequence.single(1),
        );
        expect(
          () => fnZeroOrOne(context, [
            const XPathSequence([1, 2]),
          ]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('fn:one-or-more', () {
        expect(
          fnOneOrMore(context, [XPathSequence.single(1)]),
          XPathSequence.single(1),
        );
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
        expect(
          fnExactlyOne(context, [XPathSequence.single(1)]),
          XPathSequence.single(1),
        );
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
        expect(
          fnCount(context, [XPathSequence.empty]),
          XPathSequence.single(0),
        );
        expect(
          fnCount(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(3),
        );
      });
      test('fn:avg', () {
        expect(
          fnAvg(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(2.0),
        );
        expect(fnAvg(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:max', () {
        expect(
          fnMax(context, [
            const XPathSequence([1, 3, 2]),
          ]),
          XPathSequence.single(3),
        );
        expect(fnMax(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:min', () {
        expect(
          fnMin(context, [
            const XPathSequence([3, 1, 2]),
          ]),
          XPathSequence.single(1),
        );
        expect(fnMin(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:sum', () {
        expect(fnSum(context, [XPathSequence.empty]), XPathSequence.single(0));
        expect(
          fnSum(context, [XPathSequence.empty, XPathSequence.single(42)]),
          XPathSequence.single(42),
        );
        expect(
          fnSum(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(6.0),
        );
      });
    });
    group('functions on node identifiers', () {
      test('fn:id', () {
        expect(
          () => fnId(context, [XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:element-with-id', () {
        expect(
          () => fnElementWithId(context, [XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:idref', () {
        expect(
          () => fnIdref(context, [XPathSequence.single('id')]),
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
          () => fnDoc(context, [XPathSequence.single('uri')]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('fn:doc-available', () {
        expect(
          fnDocAvailable(context, [XPathSequence.single('uri')]),
          equals(XPathSequence.falseSequence),
        );
      });
      test('fn:collection', () {
        expect(fnCollection(context, []), equals(XPathSequence.empty));
      });
      test('fn:uri-collection', () {
        expect(fnUriCollection(context, []), equals(XPathSequence.empty));
      });
      test('fn:unparsed-text', () {
        expect(
          () => fnUnparsedText(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-lines', () {
        expect(
          () => fnUnparsedTextLines(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-available', () {
        expect(
          () => fnUnparsedTextAvailable(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:environment-variable', () {
        expect(
          () => fnEnvironmentVariable(context, [XPathSequence.single('name')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:available-environment-variables', () {
        expect(
          () => fnAvailableEnvironmentVariables(context, []),
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
          () => fnParseXml(context, [XPathSequence.single('<r/>')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml-fragment', () {
        expect(
          () => fnParseXmlFragment(context, [XPathSequence.single('<r/>')]),
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
        orderedEquals([1, 2, 3]),
      );
      expect(
        fnSort(context, [
          const XPathSequence(['b', 'a', 'c']),
        ]).toList(),
        orderedEquals(['a', 'b', 'c']),
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
        orderedEquals(['be', 'cat', 'apple']),
      );
    });
    test('fn:apply', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        fnApply(context, [
          XPathSequence.single(add),
          XPathSequence.single([1, 2]),
        ]),
        orderedEquals([3]),
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
        orderedEquals([2, 4, 6]),
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
        orderedEquals([2, 4]),
      );
    });
    test('fn:fold-left', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        fnFoldLeft(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          XPathSequence.single(0),
          XPathSequence.single(add),
        ]).first,
        equals(15),
      );
    });
    test('fn:fold-right', () {
      XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) - (args[1].first as num));
      // (1 - (2 - (3 - (4 - (5 - 0))))) = 1 - (2 - (3 - (4 - 5))) = 1 - (2 - (3 - (-1))) = 1 - (2 - 4) = 1 - (-2) = 3
      expect(
        fnFoldRight(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          XPathSequence.single(0),
          XPathSequence.single(sub),
        ]).first,
        equals(3),
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
        orderedEquals(['a1', 'b2', 'c3']),
      );
    });
    test('fn:function-lookup', () {
      expect(
        () => fnFunctionLookup(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-name', () {
      expect(
        () => fnFunctionName(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-arity', () {
      expect(
        () => fnFunctionArity(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:load-xquery-module', () {
      expect(
        () => fnLoadXqueryModule(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:transform', () {
      expect(
        () => fnTransform(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
  group('map', () {
    test('map:merge', () {
      final map1 = {'a': 1, 'b': 2};
      final map2 = {'b': 3, 'c': 4};
      expect(
        mapMerge(context, [
          XPathSequence([map1, map2]),
        ]).first,
        // duplicate keys: last wins by default? logic says result.addAll which overwrites.
        equals({'a': 1, 'b': 3, 'c': 4}),
      );
      expect(
        () => mapMerge(context, [XPathSequence.single(123)]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('map:size', () {
      final map = {'a': 1, 'b': 2};
      expect(mapSize(context, [XPathSequence.single(map)]), orderedEquals([2]));
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
          XPathSequence.single('a'),
        ]),
        orderedEquals([true]),
      );
      expect(
        mapContains(context, [
          XPathSequence.single(map),
          XPathSequence.single('b'),
        ]),
        orderedEquals([false]),
      );
    });
    test('map:get', () {
      final map = {'a': 1};
      expect(
        mapGet(context, [XPathSequence.single(map), XPathSequence.single('a')]),
        orderedEquals([1]),
      );
      expect(
        mapGet(context, [XPathSequence.single(map), XPathSequence.single('b')]),
        isEmpty,
      );
    });
    test('map:find', () {
      // Stub implementation alias to map:get
      final map = {'a': 1};
      expect(
        mapFind(context, [
          XPathSequence.single(map),
          XPathSequence.single('a'),
        ]),
        orderedEquals([1]),
      );
    });
    test('map:put', () {
      final map = {'a': 1};
      expect(
        mapPut(context, [
          XPathSequence.single(map),
          XPathSequence.single('b'),
          XPathSequence.single(2),
        ]).first,
        equals({'a': 1, 'b': 2}),
      );
    });
    test('map:entry', () {
      expect(
        mapEntry(context, [
          XPathSequence.single('a'),
          XPathSequence.single(1),
        ]).first,
        equals({'a': 1}),
      );
    });
    test('map:remove', () {
      final map = {'a': 1, 'b': 2};
      expect(
        mapRemove(context, [
          XPathSequence.single(map),
          XPathSequence.single('a'),
        ]).first,
        equals({'b': 2}),
      );
      expect(
        mapRemove(context, [
          XPathSequence.single(map),
          const XPathSequence(['a', 'b']),
        ]).first,
        equals({}),
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
      expect(
        arraySize(context, [XPathSequence.single(array)]),
        orderedEquals([3]),
      );
    });
    test('array:get', () {
      final array = ['a', 'b'];
      expect(
        arrayGet(context, [
          XPathSequence.single(array),
          XPathSequence.single(1),
        ]),
        orderedEquals(['a']),
      );
      expect(
        () => arrayGet(context, [
          XPathSequence.single(array),
          XPathSequence.single(3),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => arrayGet(context, [
          XPathSequence.single(array),
          XPathSequence.single(0),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:put', () {
      final array = ['a', 'b'];
      expect(
        arrayPut(context, [
          XPathSequence.single(array),
          XPathSequence.single(1),
          XPathSequence.single('c'),
        ]).first,
        equals(['c', 'b']),
      );
      expect(
        () => arrayPut(context, [
          XPathSequence.single(array),
          XPathSequence.single(3),
          XPathSequence.single('c'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:append', () {
      final array = ['a'];
      expect(
        arrayAppend(context, [
          XPathSequence.single(array),
          XPathSequence.single('b'),
        ]).first,
        equals(['a', 'b']),
      );
    });
    test('array:subarray', () {
      final array = ['a', 'b', 'c', 'd'];
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          XPathSequence.single(2),
        ]).first,
        equals(['b', 'c', 'd']),
      );
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          XPathSequence.single(2),
          XPathSequence.single(2),
        ]).first,
        equals(['b', 'c']),
      );
      expect(
        () => arraySubarray(context, [
          XPathSequence.single(array),
          XPathSequence.single(0),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          XPathSequence.single(5),
        ]).first,
        equals([]),
      );
      expect(
        () => arraySubarray(context, [
          XPathSequence.single(array),
          XPathSequence.single(4),
          XPathSequence.single(2),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:remove', () {
      final array = ['a', 'b', 'c'];
      expect(
        arrayRemove(context, [
          XPathSequence.single(array),
          XPathSequence.single(2),
        ]).first,
        equals(['a', 'c']),
      );
      expect(
        arrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence([1, 3]),
        ]).first,
        equals(['b']),
      );
      expect(
        () => arrayRemove(context, [
          XPathSequence.single(array),
          XPathSequence.single(4),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:insert-before', () {
      final array = ['a', 'c'];
      expect(
        arrayInsertBefore(context, [
          XPathSequence.single(array),
          XPathSequence.single(2),
          XPathSequence.single('b'),
        ]).first,
        equals(['a', 'b', 'c']),
      );
      expect(
        () => arrayInsertBefore(context, [
          XPathSequence.single(array),
          XPathSequence.single(4),
          XPathSequence.single('d'),
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
        orderedEquals(['a']),
      );
      expect(
        () => arrayHead(context, [XPathSequence.single([])]),
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
        equals(['b', 'c']),
      );
      expect(
        () => arrayTail(context, [XPathSequence.single([])]),
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
        equals(['c', 'b', 'a']),
      );
    });
    test('array:join', () {
      expect(
        arrayJoin(context, [
          XPathSequence.single([1, 2]),
        ]).first,
        orderedEquals([1, 2]),
      );
      expect(
        arrayJoin(context, [
          const XPathSequence([
            [1, 2],
            [3, 4, 5],
          ]),
        ]).first,
        orderedEquals([1, 2, 3, 4, 5]),
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
      expect(
        arrayFlatten(context, [XPathSequence(input)]).toList(),
        orderedEquals([1, 2, 3, 4, 5]),
      );
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
        orderedEquals([2, 4, 6]),
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
        orderedEquals([2, 4]),
      );
    });
    test('array:fold-left', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        arrayFoldLeft(context, [
          XPathSequence.single(array),
          XPathSequence.single(0),
          XPathSequence.single(add),
        ]).first,
        equals(15),
      );
    });
    test('array:fold-right', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) - (args[1].first as num));
      expect(
        arrayFoldRight(context, [
          XPathSequence.single(array),
          XPathSequence.single(0),
          XPathSequence.single(sub),
        ]).first,
        equals(3),
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
        orderedEquals(['a1', 'b2', 'c3']),
      );
    });
    test('array:sort', () {
      final array = [3, 1, 2];
      final result =
          arraySort(context, [XPathSequence.single(array)]).first as List;
      expect(
        result.map((e) => (e as Object).toXPathSequence().first).toList(),
        orderedEquals([1, 2, 3]),
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
        orderedEquals(['be', 'cat', 'apple']),
      );
    });
  });
  group('binary', () {
    test('op:hexBinary-equal', () {
      expect(
        opHexBinaryEqual(context, [
          XPathSequence.single('AB'),
          XPathSequence.single('AB'),
        ]),
        orderedEquals([true]),
      );
      expect(
        opHexBinaryEqual(context, [
          XPathSequence.single('AB'),
          XPathSequence.single('AC'),
        ]),
        orderedEquals([false]),
      );
    });
    test('op:hexBinary-less-than', () {
      expect(
        opHexBinaryLessThan(context, [
          XPathSequence.single('AA'),
          XPathSequence.single('BB'),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:hexBinary-greater-than', () {
      expect(
        opHexBinaryGreaterThan(context, [
          XPathSequence.single('BB'),
          XPathSequence.single('AA'),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-equal', () {
      expect(
        opBase64BinaryEqual(context, [
          XPathSequence.single('AA=='),
          XPathSequence.single('AA=='),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-less-than', () {
      expect(
        opBase64BinaryLessThan(context, [
          XPathSequence.single('AA=='),
          XPathSequence.single('BB=='),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-greater-than', () {
      expect(
        opBase64BinaryGreaterThan(context, [
          XPathSequence.single('BB=='),
          XPathSequence.single('AA=='),
        ]),
        orderedEquals([true]),
      );
    });
  });
  group('notation', () {
    test('op:NOTATION-equal', () {
      expect(
        opNotationEqual(context, [
          XPathSequence.single('foo:bar'),
          XPathSequence.single('foo:bar'),
        ]),
        orderedEquals([true]),
      );
    });
  });
  group('qname', () {
    test('op:QName-equal', () {
      expect(
        opQNameEqual(context, [XPathSequence.empty, XPathSequence.empty]),
        equals(XPathSequence.empty),
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
          XPathSequence.single('p:local'),
          XPathSequence.single(const v31.XPathString('element')),
        ]).first,
        isA<XmlName>(),
      );
    });
    test('fn:QName', () {
      expect(
        fnQName(context, [
          XPathSequence.single('uri'),
          XPathSequence.single('p:local'),
        ]).first,
        isA<XmlName>(),
      );
    });
    test('fn:prefix-from-QName', () {
      final qname = XmlName.fromString('p:local');
      expect(
        fnPrefixFromQName(context, [XPathSequence.single(qname)]),
        orderedEquals(['p']),
      );
    });
    test('fn:local-name-from-QName', () {
      final qname = XmlName.fromString('p:local');
      expect(
        fnLocalNameFromQName(context, [XPathSequence.single(qname)]),
        orderedEquals(['local']),
      );
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
    test('fn:year-from-date', () {
      expect(
        fnYearFromDate(context, [XPathSequence.single(DateTime(2023, 10, 26))]),
        orderedEquals([2023]),
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
        orderedEquals([true]),
      );
      expect(
        opDateTimeEqual(context, [
          XPathSequence.single(dt1),
          XPathSequence.single(dt3),
        ]),
        orderedEquals([false]),
      );
    });
    test('fn:dateTime', () {
      expect(
        fnDateTime(context, [
          XPathSequence.single(DateTime.utc(2023, 10, 26)),
          XPathSequence.single(DateTime.utc(0, 1, 1, 12, 30, 45)),
        ]).first,
        equals(DateTime(2023, 10, 26, 12, 30, 45)),
      );
    });
    test('fn:year-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnYearFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([2023]),
      );
    });
    test('fn:month-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnMonthFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([10]),
      );
    });
    test('fn:day-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnDayFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([26]),
      );
    });
    test('fn:hours-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnHoursFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([12]),
      );
    });
    test('fn:minutes-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnMinutesFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnSecondsFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([45.0]),
      );
    });
    test('op:dateTime-less-than', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      expect(
        opDateTimeLessThan(context, [
          XPathSequence.single(dt1),
          XPathSequence.single(dt2),
        ]),
        orderedEquals([true]),
      );
      expect(
        opDateTimeLessThan(context, [
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ]),
        orderedEquals([false]),
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
        orderedEquals([true]),
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
        equals(const Duration(days: 1)),
      );
    });
    test('op:add-duration-to-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      const dur = Duration(days: 1);
      expect(
        opAddDurationToDateTime(context, [
          XPathSequence.single(dt1),
          XPathSequence.single(dur),
        ]).first,
        equals(dt2),
      );
    });
    test('op:subtract-duration-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
      const dur = Duration(days: 1);
      expect(
        opSubtractDurationFromDateTime(context, [
          XPathSequence.single(dt2),
          XPathSequence.single(dur),
        ]).first,
        equals(dt1),
      );
    });
    test('fn:timezone-from-dateTime', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnTimezoneFromDateTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([Duration.zero]),
      );
    });
    test('fn:year-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnYearFromDate(context, [XPathSequence.single(dt1)]),
        orderedEquals([2023]),
      );
    });
    test('fn:month-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnMonthFromDate(context, [XPathSequence.single(dt1)]),
        orderedEquals([10]),
      );
    });
    test('fn:day-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnDayFromDate(context, [XPathSequence.single(dt1)]),
        orderedEquals([26]),
      );
    });
    test('fn:timezone-from-date', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnTimezoneFromDate(context, [XPathSequence.single(dt1)]),
        orderedEquals([Duration.zero]),
      );
    });
    test('fn:hours-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnHoursFromTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([12]),
      );
    });
    test('fn:minutes-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnMinutesFromTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnSecondsFromTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([45.0]),
      );
    });
    test('fn:timezone-from-time', () {
      final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
      expect(
        fnTimezoneFromTime(context, [XPathSequence.single(dt1)]),
        orderedEquals([Duration.zero]),
      );
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
    test('missing functions stubs', () {
      expect(
        () => fnAdjustDateTimeToTimezone(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => fnAdjustDateToTimezone(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => fnAdjustTimeToTimezone(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => fnFormatDateTime(context, [
          XPathSequence.empty,
          XPathSequence.empty,
        ]),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => fnFormatDate(context, [XPathSequence.empty, XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => fnFormatTime(context, [XPathSequence.empty, XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => fnParseIetfDate(context, [XPathSequence.empty]),
        throwsA(isA<UnimplementedError>()),
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
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ]),
        orderedEquals([true]),
      );
      expect(
        opDurationEqual(context, [
          XPathSequence.single(d1),
          XPathSequence.single(d3),
        ]),
        orderedEquals([false]),
      );
    });
    test('op:yearMonthDuration-less-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationLessThan(context, [
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:yearMonthDuration-greater-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opYearMonthDurationGreaterThan(context, [
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:dayTimeDuration-less-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationLessThan(context, [
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:dayTimeDuration-greater-than', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDayTimeDurationGreaterThan(context, [
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:add-yearMonthDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddYearMonthDurations(context, [
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ]).first,
        equals(d1 + d2),
      );
    });
    test('op:subtract-yearMonthDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractYearMonthDurations(context, [
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ]).first,
        equals(d1),
      );
    });
    test('op:multiply-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyYearMonthDuration(context, [
          XPathSequence.single(d1),
          XPathSequence.single(2),
        ]).first,
        equals(d2),
      );
    });
    test('op:divide-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDuration(context, [
          XPathSequence.single(d2),
          XPathSequence.single(2),
        ]).first,
        equals(d1),
      );
    });
    test('op:divide-yearMonthDuration-by-yearMonthDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideYearMonthDurationByYearMonthDuration(context, [
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ]),
        orderedEquals([2.0]),
      );
    });
    test('op:add-dayTimeDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opAddDayTimeDurations(context, [
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ]).first,
        equals(d1 + d2),
      );
    });
    test('op:subtract-dayTimeDurations', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opSubtractDayTimeDurations(context, [
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ]).first,
        equals(d1),
      );
    });
    test('op:multiply-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opMultiplyDayTimeDuration(context, [
          XPathSequence.single(d1),
          XPathSequence.single(2),
        ]).first,
        equals(d2),
      );
    });
    test('op:divide-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDuration(context, [
          XPathSequence.single(d2),
          XPathSequence.single(2),
        ]).first,
        equals(d1),
      );
    });
    test('op:divide-dayTimeDuration-by-dayTimeDuration', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 2);
      expect(
        opDivideDayTimeDurationByDayTimeDuration(context, [
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ]),
        orderedEquals([2.0]),
      );
    });
    test('fn:years-from-duration', () {
      const d1 = Duration(days: 1);
      expect(
        fnYearsFromDuration(context, [XPathSequence.single(d1)]),
        orderedEquals([0]),
      );
    });
    test('fn:months-from-duration', () {
      const d1 = Duration(days: 1);
      expect(
        fnMonthsFromDuration(context, [XPathSequence.single(d1)]),
        orderedEquals([0]),
      );
    });
    test('fn:days-from-duration', () {
      const d1 = Duration(days: 1);
      expect(
        fnDaysFromDuration(context, [XPathSequence.single(d1)]),
        orderedEquals([1]),
      );
    });
    test('fn:hours-from-duration', () {
      const d3 = Duration(hours: 1);
      expect(
        fnHoursFromDuration(context, [XPathSequence.single(d3)]),
        orderedEquals([1]),
      );
    });
    test('fn:minutes-from-duration', () {
      const d = Duration(minutes: 90);
      expect(
        fnMinutesFromDuration(context, [XPathSequence.single(d)]),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-duration', () {
      const d = Duration(seconds: 90); // 1 min 30 sec
      expect(
        fnSecondsFromDuration(context, [XPathSequence.single(d)]),
        orderedEquals([30.0]),
      );
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
        () => fnJsonDoc(context, [XPathSequence.single('url')]),
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
        fnResolveUri(context, [XPathSequence.single('foo')]),
        XPathSequence.single(const v31.XPathString('foo')),
      );
    });
    test('fn:encode-for-uri', () {
      expect(
        fnEncodeForUri(context, [XPathSequence.single(' ')]),
        XPathSequence.single(const v31.XPathString('%20')),
      );
    });
    test('fn:iri-to-uri', () {
      expect(
        fnIriToUri(context, [XPathSequence.single(' ')]),
        XPathSequence.single(const v31.XPathString('%20')),
      );
    });
    test('fn:escape-html-uri', () {
      expect(
        fnEscapeHtmlUri(context, [XPathSequence.single(' ')]),
        XPathSequence.single(const v31.XPathString('%20')),
      );
    });
  });
}
