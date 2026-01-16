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
import 'package:xml/src/xpath/types31/date_time.dart';
import 'package:xml/src/xpath/types31/map.dart';
import 'package:xml/src/xpath/types31/string.dart' as v31;
import 'package:xml/src/xpath/types31/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/matchers.dart';

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
    test('fn:node-name (processing-instruction)', () {
      final pi = XmlProcessing('target', 'value');
      expect(
        fnNodeName(context, [XPathSequence.single(pi)]).first.toString(),
        equals('target'),
      );
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
        fnString(context, [const XPathSequence.single('foo')]),
        const XPathSequence.single(v31.XPathString('foo')),
      );
      expect(
        fnString(context, [XPathSequence.empty]),
        const XPathSequence.single(v31.XPathString.empty),
      );
      expect(
        fnString(XPathContext(document.findAllElements('a').first), []),
        const XPathSequence.single(v31.XPathString('1')),
      );
    });
    test('fn:data', () {
      expect(fnData(context, [XPathSequence.empty]), XPathSequence.empty);
      expect(
        fnData(context, [const XPathSequence.single(123)]),
        const XPathSequence.single(123),
      );
      expect(
        fnData(context, [
          const XPathSequence.single([1, 2, 3]),
        ]),
        const XPathSequence([1, 2, 3]),
      );
    });
    test('fn:base-uri', () {
      expect(fnBaseUri(context, []), isEmpty);
      expect(
        fnBaseUri(context, [XPathSequence.single(document)]),
        XPathSequence.empty,
      );
    });
    test('fn:document-uri', () {
      expect(fnDocumentUri(context, []), isEmpty);
      expect(
        fnDocumentUri(context, [XPathSequence.single(document)]),
        XPathSequence.empty,
      );
    });
  });
  group('error', () {
    test('fn:error', () {
      expect(
        () => fnError(context, []),
        throwsA(isXPathEvaluationException(message: '')),
      );
      expect(
        () => fnError(context, const [XPathSequence.single('code')]),
        throwsA(isXPathEvaluationException(message: 'code')),
      );
      expect(
        () => fnError(context, const [
          XPathSequence.single('code'),
          XPathSequence.single('description'),
        ]),
        throwsA(isXPathEvaluationException(message: 'code: description')),
      );
      expect(
        () => fnError(context, const [
          XPathSequence.single('code'),
          XPathSequence.single('description'),
          XPathSequence([1, 2, 3]),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'code: description (1, 2, 3)'),
        ),
      );
    });
    test('fn:trace (without handler)', () {
      const value = XPathSequence.single('value');
      const label = XPathSequence.single('label');
      expect(fnTrace(context, [value]), value);
      expect(fnTrace(context, [value, label]), value);
    });
    test('fn:trace (with handler)', () {
      const value = XPathSequence.single('value');
      const label = XPathSequence.single('label');
      final traceLog = <(XPathSequence, XPathString?)>[];
      final traceContext = context.copy(
        onTraceCallback: (value, label) => traceLog.add((value, label)),
      );
      expect(fnTrace(traceContext, [value]), value);
      expect(fnTrace(traceContext, [value, label]), value);
      expect(traceLog, [(value, null), (value, label.single)]);
    });
  });
  group('number', () {
    test('fn:abs', () {
      expect(
        fnAbs(context, [const XPathSequence.single(-5)]),
        const XPathSequence.single(5),
      );
      expect(fnAbs(context, [XPathSequence.empty]), XPathSequence.empty);
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
      expect(mathPi(context, []), const XPathSequence.single(math.pi));
    });
    test('math:sqrt', () {
      expect(
        mathSqrt(context, [const XPathSequence.single(4)]),
        const XPathSequence.single(2),
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
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ]),
        orderedEquals([3]),
      );
    });
    test('op:numeric-subtract', () {
      expect(
        opNumericSubtract(context, [
          const XPathSequence.single(3),
          const XPathSequence.single(2),
        ]),
        orderedEquals([1]),
      );
    });
    test('op:numeric-multiply', () {
      expect(
        opNumericMultiply(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        orderedEquals([6]),
      );
    });
    test('op:numeric-divide', () {
      expect(
        opNumericDivide(context, [
          const XPathSequence.single(6),
          const XPathSequence.single(2),
        ]),
        orderedEquals([3.0]),
      );
    });
    test('op:numeric-integer-divide', () {
      expect(
        opNumericIntegerDivide(context, [
          const XPathSequence.single(10),
          const XPathSequence.single(3),
        ]),
        orderedEquals([3]),
      );
    });
    test('op:numeric-mod', () {
      expect(
        opNumericMod(context, [
          const XPathSequence.single(10),
          const XPathSequence.single(3),
        ]),
        orderedEquals([1]),
      );
    });
    test('op:numeric-unary-plus', () {
      expect(
        opNumericUnaryPlus(context, [const XPathSequence.single(1)]),
        orderedEquals([1]),
      );
    });
    test('op:numeric-unary-minus', () {
      expect(
        opNumericUnaryMinus(context, [const XPathSequence.single(1)]),
        orderedEquals([-1]),
      );
    });
    test('op:numeric-equal', () {
      expect(
        opNumericEqual(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(1),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:numeric-less-than', () {
      expect(
        opNumericLessThan(context, [
          const XPathSequence.single(1),
          const XPathSequence.single(2),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:numeric-greater-than', () {
      expect(
        opNumericGreaterThan(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(1),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:ceiling', () {
      expect(
        fnCeiling(context, [const XPathSequence.single(1.5)]),
        orderedEquals([2]),
      );
    });
    test('fn:floor', () {
      expect(
        fnFloor(context, [const XPathSequence.single(1.5)]),
        orderedEquals([1]),
      );
    });
    test('fn:round', () {
      expect(
        fnRound(context, [const XPathSequence.single(1.5)]),
        orderedEquals([2]),
      );
      expect(fnRound(context, [XPathSequence.empty]), isEmpty);
      expect(
        fnRound(context, [const XPathSequence.single(double.nan)]),
        orderedEquals([isNaN]),
      );
      expect(
        fnRound(context, [
          const XPathSequence.single(1.5),
          const XPathSequence.single(1),
        ]),
        orderedEquals([1.5]),
      );
    });
    test('fn:format-integer', () {
      expect(
        fnFormatInteger(context, [
          const XPathSequence.single(123),
          const XPathSequence.single('000'),
        ]),
        orderedEquals(['123']),
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
      expect(
        mathPi(context, []),
        orderedEquals([predicate((x) => (x as double) > 3.14)]),
      );
      expect(
        mathExp(context, [const XPathSequence.single(0)]),
        orderedEquals([1.0]),
      );
      expect(
        mathExp10(context, [const XPathSequence.single(0)]),
        orderedEquals([1.0]),
      );
      expect(
        mathLog(context, [const XPathSequence.single(math.e)]),
        orderedEquals([1.0]),
      );
      expect(
        mathLog10(context, [const XPathSequence.single(10)]),
        orderedEquals([1.0]),
      );
      expect(
        mathPow(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        orderedEquals([8.0]),
      );
      expect(
        mathSqrt(context, [const XPathSequence.single(4)]),
        orderedEquals([2.0]),
      );
      expect(
        mathSin(context, [const XPathSequence.single(0)]),
        orderedEquals([0.0]),
      );
      expect(
        mathCos(context, [const XPathSequence.single(0)]),
        orderedEquals([1.0]),
      );
      expect(
        mathTan(context, [const XPathSequence.single(0)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAsin(context, [const XPathSequence.single(0)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAcos(context, [const XPathSequence.single(1)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAtan(context, [const XPathSequence.single(0)]),
        orderedEquals([0.0]),
      );
      expect(
        mathAtan2(context, [
          const XPathSequence.single(0),
          const XPathSequence.single(1),
        ]),
        orderedEquals([0.0]),
      );
    });
  });
  group('string', () {
    test('fn:collation-key', () {
      expect(
        fnCollationKey(context, [const XPathSequence.single('abc')]),
        const XPathSequence.single(v31.XPathString('abc')),
      );
    });
    test('fn:concat', () {
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        const XPathSequence.single(v31.XPathString('ab')),
      );
      expect(
        fnConcat(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
          const XPathSequence.single('c'),
        ]),
        orderedEquals(['abc']),
      );
    });
    test('fn:string-join', () {
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b']),
          const XPathSequence.single(','),
        ]),
        const XPathSequence.single(v31.XPathString('a,b')),
      );
      expect(
        fnStringJoin(context, [
          const XPathSequence(['a', 'b', 'c']),
          const XPathSequence.single('-'),
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
          const XPathSequence.single('motor car'),
          const XPathSequence.single(6),
        ]),
        orderedEquals([' car']),
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('metadata'),
          const XPathSequence.single(4),
          const XPathSequence.single(3),
        ]),
        orderedEquals(['ada']),
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(1.5),
          const XPathSequence.single(2.6),
        ]),
        orderedEquals(['234']),
      );
      expect(
        fnSubstring(context, [
          const XPathSequence.single('12345'),
          const XPathSequence.single(0),
          const XPathSequence.single(3),
        ]),
        orderedEquals(['12']),
      );
    });
    test('fn:string-length', () {
      expect(
        fnStringLength(context, [const XPathSequence.single('abc')]),
        orderedEquals([3]),
      );
      expect(
        fnStringLength(context, [XPathSequence.empty]),
        orderedEquals([0]),
      );
    });
    test('fn:normalize-space', () {
      expect(
        fnNormalizeSpace(context, [const XPathSequence.single('  a  b   c  ')]),
        orderedEquals(['a b c']),
      );
    });
    test('fn:upper-case', () {
      expect(
        fnUpperCase(context, [const XPathSequence.single('abc')]),
        orderedEquals(['ABC']),
      );
    });
    test('fn:lower-case', () {
      expect(
        fnLowerCase(context, [const XPathSequence.single('ABC')]),
        orderedEquals(['abc']),
      );
    });
    test('fn:contains', () {
      expect(
        fnContains(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('t'),
        ]),
        orderedEquals([true]),
      );
      expect(
        fnContains(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('z'),
        ]),
        orderedEquals([false]),
      );
    });
    test('fn:starts-with', () {
      expect(
        fnStartsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:ends-with', () {
      expect(
        fnEndsWith(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:substring-before', () {
      expect(
        fnSubstringBefore(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('too'),
        ]),
        orderedEquals(['tat']),
      );
    });
    test('fn:substring-after', () {
      expect(
        fnSubstringAfter(context, [
          const XPathSequence.single('tattoo'),
          const XPathSequence.single('tat'),
        ]),
        orderedEquals(['too']),
      );
    });
    test('fn:translate', () {
      expect(
        fnTranslate(context, [
          const XPathSequence.single('bar'),
          const XPathSequence.single('abc'),
          const XPathSequence.single('ABC'),
        ]),
        orderedEquals(['BAr']),
      );
    });
    test('fn:matches', () {
      expect(
        fnMatches(context, [
          const XPathSequence.single('abc'),
          const XPathSequence.single('b'),
        ]),
        XPathSequence.trueSequence,
      );
      expect(
        fnMatches(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:replace', () {
      expect(
        fnReplace(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('bra'),
          const XPathSequence.single('*'),
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
        () => fnCodepointsToString(context, [const XPathSequence.single(-1)]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('fn:string-to-codepoints', () {
      expect(
        fnStringToCodepoints(context, [const XPathSequence.single('abc')]),
        orderedEquals([97, 98, 99]),
      );
    });
    test('fn:compare', () {
      expect(
        fnCompare(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('b'),
        ]),
        orderedEquals([-1]),
      );
    });
    test('fn:codepoint-equal', () {
      expect(
        fnCodepointEqual(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single('a'),
        ]),
        orderedEquals([true]),
      );
    });

    test('fn:contains-token', () {
      expect(
        fnContainsToken(context, [
          const XPathSequence.single('a b c'),
          const XPathSequence.single('b'),
        ]),
        orderedEquals([true]),
      );
    });
    test('fn:normalize-unicode', () {
      expect(
        fnNormalizeUnicode(context, [const XPathSequence.single('a')]),
        orderedEquals(['a']),
      );
    });
    test('fn:tokenize', () {
      expect(
        fnTokenize(context, [const XPathSequence.single('a b c')]).toList(),
        orderedEquals(['a', 'b', 'c']),
      );
      expect(
        fnTokenize(context, [
          const XPathSequence.single('abracadabra'),
          const XPathSequence.single('(ab)|(a)'),
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
        fnBoolean(context, [const XPathSequence.single(true)]),
        XPathSequence.trueSequence,
      );
      expect(
        fnBoolean(context, [XPathSequence.empty]),
        XPathSequence.falseSequence,
      );
      expect(
        fnBoolean(context, [const XPathSequence.single(1)]),
        orderedEquals([true]),
      );
    });
    test('fn:not', () {
      expect(
        fnNot(context, [const XPathSequence.single(true)]),
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
        fnLang(newContext, [const XPathSequence.single('en')]),
        orderedEquals([true]),
      );
      expect(
        fnLang(newContext, [const XPathSequence.single('fr')]),
        orderedEquals([false]),
      );
      expect(
        fnLang(newContext, [const XPathSequence.single('EN-US')]),
        orderedEquals([false]),
      );
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
        XPathSequence([a, b]),
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
        XPathSequence.single(a),
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
        XPathSequence.single(b),
      );
    });
    test('fn:name', () {
      final a = document.findAllElements('a').first;
      expect(
        fnName(context, [XPathSequence.single(a)]),
        const XPathSequence.single(v31.XPathString('a')),
      );
    });
    test('fn:local-name', () {
      final a = document.findAllElements('a').first;
      expect(
        fnLocalName(context, [XPathSequence.single(a)]),
        const XPathSequence.single(v31.XPathString('a')),
      );
    });
    test('fn:root', () {
      final a = document.findAllElements('a').first;
      expect(
        fnRoot(context, [XPathSequence.single(a)]),
        XPathSequence.single(document),
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
        const XPathSequence.single(v31.XPathString('/r/a')),
      );
    });
  });
  group('context', () {
    test('fn:position', () {
      expect(fnPosition(context, []), const XPathSequence.single(1));
    });
    test('fn:last', () {
      expect(fnLast(context, []), const XPathSequence.single(1));
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
          fnEmpty(context, [const XPathSequence.single(1)]),
          XPathSequence.falseSequence,
        );
      });
      test('fn:exists', () {
        expect(
          fnExists(context, [XPathSequence.empty]),
          XPathSequence.falseSequence,
        );
        expect(
          fnExists(context, [const XPathSequence.single(1)]),
          XPathSequence.trueSequence,
        );
      });
      test('fn:head', () {
        expect(fnHead(context, [XPathSequence.empty]), XPathSequence.empty);
        expect(
          fnHead(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence.single(1),
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
          const XPathSequence([1, 0, 2]),
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
          const XPathSequence([3, 2, 1]),
        );
        expect(fnReverse(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:subsequence', () {
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(2),
          ]),
          const XPathSequence([2, 3, 4, 5]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            const XPathSequence.single(2),
            const XPathSequence.single(2),
          ]),
          const XPathSequence([2, 3]),
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
          fnZeroOrOne(context, [const XPathSequence.single(1)]),
          const XPathSequence.single(1),
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
          fnOneOrMore(context, [const XPathSequence.single(1)]),
          const XPathSequence.single(1),
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
          fnExactlyOne(context, [const XPathSequence.single(1)]),
          const XPathSequence.single(1),
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
          const XPathSequence.single(0),
        );
        expect(
          fnCount(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence.single(3),
        );
      });
      test('fn:avg', () {
        expect(
          fnAvg(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence.single(2.0),
        );
        expect(fnAvg(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:max', () {
        expect(
          fnMax(context, [
            const XPathSequence([1, 3, 2]),
          ]),
          const XPathSequence.single(3),
        );
        expect(fnMax(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:min', () {
        expect(
          fnMin(context, [
            const XPathSequence([3, 1, 2]),
          ]),
          const XPathSequence.single(1),
        );
        expect(fnMin(context, [XPathSequence.empty]), XPathSequence.empty);
      });
      test('fn:sum', () {
        expect(
          fnSum(context, [XPathSequence.empty]),
          const XPathSequence.single(0),
        );
        expect(
          fnSum(context, [XPathSequence.empty, const XPathSequence.single(42)]),
          const XPathSequence.single(42),
        );
        expect(
          fnSum(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence.single(6.0),
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
        expect(
          fnDocAvailable(context, [const XPathSequence.single('uri')]),
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
          const XPathSequence.single([1, 2]),
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
          const XPathSequence.single(0),
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
          const XPathSequence.single(0),
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
        equals({'a': 1, 'b': 3, 'c': 4}),
      );
      expect(
        () => mapMerge(context, [const XPathSequence.single(123)]),
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
          const XPathSequence.single('a'),
        ]),
        orderedEquals([true]),
      );
      expect(
        mapContains(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
        ]),
        orderedEquals([false]),
      );
    });
    test('map:get', () {
      final map = {'a': 1};
      expect(
        mapGet(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        orderedEquals([1]),
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
        orderedEquals([1]),
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
        equals({'a': 1, 'b': 2}),
      );
    });
    test('map:entry', () {
      expect(
        mapEntry(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(1),
        ]).first,
        equals({'a': 1}),
      );
    });
    test('map:remove', () {
      final map = {'a': 1, 'b': 2};
      expect(
        mapRemove(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
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
          const XPathSequence.single(1),
        ]),
        orderedEquals(['a']),
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
        equals(['c', 'b']),
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
        equals(['a', 'b']),
      );
    });
    test('array:subarray', () {
      final array = ['a', 'b', 'c', 'd'];
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]).first,
        equals(['b', 'c', 'd']),
      );
      expect(
        arraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]).first,
        equals(['b', 'c']),
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
        equals([]),
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
        equals(['a', 'b', 'c']),
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
        orderedEquals(['a']),
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
        equals(['b', 'c']),
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
        equals(['c', 'b', 'a']),
      );
    });
    test('array:join', () {
      expect(
        arrayJoin(context, [
          const XPathSequence.single([1, 2]),
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
          const XPathSequence.single(0),
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
          const XPathSequence.single(0),
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
          const XPathSequence.single('AB'),
          const XPathSequence.single('AB'),
        ]),
        orderedEquals([true]),
      );
      expect(
        opHexBinaryEqual(context, [
          const XPathSequence.single('AB'),
          const XPathSequence.single('AC'),
        ]),
        orderedEquals([false]),
      );
    });
    test('op:hexBinary-less-than', () {
      expect(
        opHexBinaryLessThan(context, [
          const XPathSequence.single('AA'),
          const XPathSequence.single('BB'),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:hexBinary-greater-than', () {
      expect(
        opHexBinaryGreaterThan(context, [
          const XPathSequence.single('BB'),
          const XPathSequence.single('AA'),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-equal', () {
      expect(
        opBase64BinaryEqual(context, [
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AA=='),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-less-than', () {
      expect(
        opBase64BinaryLessThan(context, [
          const XPathSequence.single('AA=='),
          const XPathSequence.single('AQ=='),
        ]),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-greater-than', () {
      expect(
        opBase64BinaryGreaterThan(context, [
          const XPathSequence.single('AQ=='),
          const XPathSequence.single('AA=='),
        ]),
        orderedEquals([true]),
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
      expect(
        fnPrefixFromQName(context, [XPathSequence.single(qname)]),
        orderedEquals(['p']),
      );
    });
    test('fn:local-name-from-qname', () {
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
    test('fn:adjust-dateTime-to-timezone', () {
      final dt = DateTime.utc(2020, 1, 1, 10, 0, 0);
      // Adjust to UTC (same)
      expect(
        fnAdjustDateTimeToTimezone(context, [
          XPathSequence.single(dt),
          const XPathSequence.single(Duration()),
        ]),
        XPathSequence.single(dt.toXPathDateTime()),
      );
      // Adjust to Implicit (Local)
      expect(
        fnAdjustDateTimeToTimezone(context, [XPathSequence.single(dt)]),
        XPathSequence.single(dt.toLocal().toXPathDateTime()),
      );
    });
    test('fn:format-dateTime', () {
      final dt = DateTime.utc(2020, 1, 1, 12, 0, 0);
      expect(
        fnFormatDateTime(context, [
          XPathSequence.single(dt),
          const XPathSequence.single('[Y]-[M]-[D]'),
        ]),
        // Basic implementation returns ISO string
        XPathSequence.single(v31.XPathString(dt.toIso8601String())),
      );
    });
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
          const XPathSequence.single(dur),
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
          const XPathSequence.single(dur),
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
        orderedEquals([true]),
      );
      expect(
        opDurationEqual(context, [
          const XPathSequence.single(d1),
          const XPathSequence.single(d3),
        ]),
        orderedEquals([false]),
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
        orderedEquals([true]),
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
        orderedEquals([true]),
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
        orderedEquals([true]),
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
        orderedEquals([true]),
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
        equals(d1 + d2),
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
        equals(d1),
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
        equals(d2),
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
        equals(d1),
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
        orderedEquals([2.0]),
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
        equals(d1 + d2),
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
        equals(d1),
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
        equals(d2),
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
        equals(d1),
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
        orderedEquals([2.0]),
      );
    });
    test('fn:years-from-duration', () {
      const d1 = Duration(days: 1);
      expect(
        fnYearsFromDuration(context, [const XPathSequence.single(d1)]),
        orderedEquals([0]),
      );
    });
    test('fn:months-from-duration', () {
      const d1 = Duration(days: 1);
      expect(
        fnMonthsFromDuration(context, [const XPathSequence.single(d1)]),
        orderedEquals([0]),
      );
    });
    test('fn:days-from-duration', () {
      const d1 = Duration(days: 1);
      expect(
        fnDaysFromDuration(context, [const XPathSequence.single(d1)]),
        orderedEquals([1]),
      );
    });
    test('fn:hours-from-duration', () {
      const d3 = Duration(hours: 1);
      expect(
        fnHoursFromDuration(context, [const XPathSequence.single(d3)]),
        orderedEquals([1]),
      );
    });
    test('fn:minutes-from-duration', () {
      const d = Duration(minutes: 90);
      expect(
        fnMinutesFromDuration(context, [const XPathSequence.single(d)]),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-duration', () {
      const d = Duration(seconds: 90); // 1 min 30 sec
      expect(
        fnSecondsFromDuration(context, [const XPathSequence.single(d)]),
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
        const XPathSequence.single(v31.XPathString('http://example.com/foo')),
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
      expect(
        fnEncodeForUri(context, [const XPathSequence.single(' ')]),
        const XPathSequence.single(v31.XPathString('%20')),
      );
    });
    test('fn:iri-to-uri', () {
      expect(
        fnIriToUri(context, [const XPathSequence.single(' ')]),
        const XPathSequence.single(v31.XPathString('%20')),
      );
    });
    test('fn:escape-html-uri', () {
      expect(
        fnEscapeHtmlUri(context, [const XPathSequence.single(' ')]),
        const XPathSequence.single(v31.XPathString('%20')),
      );
    });
  });
}
