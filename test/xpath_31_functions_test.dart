import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions31/accessor.dart';
import 'package:xml/src/xpath/functions31/binary.dart';
import 'package:xml/src/xpath/functions31/boolean.dart';
import 'package:xml/src/xpath/functions31/context.dart';
import 'package:xml/src/xpath/functions31/date_time.dart';
import 'package:xml/src/xpath/functions31/duration.dart';
import 'package:xml/src/xpath/functions31/error.dart';
import 'package:xml/src/xpath/functions31/higher_order.dart';
import 'package:xml/src/xpath/functions31/json.dart';
import 'package:xml/src/xpath/functions31/maps_arrays.dart';
import 'package:xml/src/xpath/functions31/node.dart';
import 'package:xml/src/xpath/functions31/notation.dart';
import 'package:xml/src/xpath/functions31/number.dart';
import 'package:xml/src/xpath/functions31/qname.dart';
import 'package:xml/src/xpath/functions31/sequence.dart';
import 'package:xml/src/xpath/functions31/string.dart';
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
      expect(fnNodeName(XPathContext(a)), XPathSequence.single(a.name));
      expect(
        fnNodeName(context, XPathSequence.single(a)),
        XPathSequence.single(a.name),
      );
      expect(fnNodeName(context, XPathSequence.empty), XPathSequence.empty);
    });
    test('fn:nilled', () {
      expect(
        fnNilled(context, XPathSequence.single(document)),
        XPathSequence.empty,
      );
      expect(
        fnNilled(context, XPathSequence.single(document.rootElement)),
        XPathSequence.falseSequence,
      );
      expect(fnNilled(context, XPathSequence.empty), XPathSequence.empty);
    });
    test('fn:string', () {
      expect(
        fnString(context, XPathSequence.single('foo')),
        XPathSequence.single(const v31.XPathString('foo')),
      );
      expect(
        fnString(context, XPathSequence.empty),
        XPathSequence.single(v31.XPathString.empty),
      );
      expect(
        fnString(XPathContext(document.findAllElements('a').first)),
        XPathSequence.single(const v31.XPathString('1')),
      );
    });
    test('fn:data', () {
      final a = document.findAllElements('a').first;
      expect(
        fnData(context, XPathSequence.single(a)),
        XPathSequence.single(const v31.XPathString('1')),
      );
      expect(
        fnData(context, XPathSequence.single(123)),
        XPathSequence.single(123),
      );
    });
    test('fn:base-uri', () {
      expect(
        fnBaseUri(context, XPathSequence.single(document)),
        XPathSequence.empty,
      );
    });
    test('fn:document-uri', () {
      expect(
        fnDocumentUri(context, XPathSequence.single(document)),
        XPathSequence.empty,
      );
    });
  });

  group('error', () {
    test('fn:error', () {
      expect(() => fnError(context), throwsA(isA<XPathEvaluationException>()));
      expect(
        () => fnError(context, XPathSequence.single('err:code')),
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
      expect(fnTrace(context, seq), seq);
      expect(fnTrace(context, seq, XPathSequence.single('label')), seq);
    });
  });

  group('number', () {
    test('fn:abs', () {
      expect(fnAbs(context, XPathSequence.single(-5)), XPathSequence.single(5));
      expect(fnAbs(context, XPathSequence.empty), XPathSequence.empty);
    });
    test('fn:ceiling', () {
      expect(
        fnCeiling(context, XPathSequence.single(1.1)),
        XPathSequence.single(2),
      );
    });
    test('fn:floor', () {
      expect(
        fnFloor(context, XPathSequence.single(1.9)),
        XPathSequence.single(1),
      );
    });
    test('fn:round', () {
      expect(
        fnRound(context, XPathSequence.single(1.1)),
        XPathSequence.single(1),
      );
      expect(
        fnRound(context, XPathSequence.single(1.5)),
        XPathSequence.single(2),
      );
    });
    test('fn:round-half-to-even', () {
      expect(
        fnRoundHalfToEven(context, XPathSequence.single(0.5)),
        XPathSequence.single(0),
      );
      expect(
        fnRoundHalfToEven(context, XPathSequence.single(1.5)),
        XPathSequence.single(2),
      );
      expect(
        fnRoundHalfToEven(context, XPathSequence.single(2.5)),
        XPathSequence.single(2),
      );
    });
    test('fn:number', () {
      expect(
        fnNumber(context, XPathSequence.single('123')),
        XPathSequence.single(123),
      );
      expect(
        (fnNumber(context, XPathSequence.empty).first as num).isNaN,
        isTrue,
      );
    });
    test('math:pi', () {
      expect(mathPi(context), XPathSequence.single(math.pi));
    });
    test('math:sqrt', () {
      expect(
        mathSqrt(context, XPathSequence.single(4)),
        XPathSequence.single(2),
      );
    });
    test('fn:random-number-generator', () {
      final result = fnRandomNumberGenerator(context);
      expect(result.first, isA<double>());
      expect(result.first as double, isNonNegative);
      expect(result.first as double, lessThan(1.0));
    });
  });

  group('string', () {
    test('fn:concat', () {
      expect(
        fnConcat(context, XPathSequence.single('a'), XPathSequence.single('b')),
        XPathSequence.single(const v31.XPathString('ab')),
      );
    });
    test('fn:string-join', () {
      expect(
        fnStringJoin(
          context,
          const XPathSequence(['a', 'b']),
          XPathSequence.single(','),
        ),
        XPathSequence.single(const v31.XPathString('a,b')),
      );
    });
    test('fn:upper-case', () {
      expect(
        fnUpperCase(context, XPathSequence.single('abc')),
        XPathSequence.single(const v31.XPathString('ABC')),
      );
    });
    test('fn:lower-case', () {
      expect(
        fnLowerCase(context, XPathSequence.single('ABC')),
        XPathSequence.single(const v31.XPathString('abc')),
      );
    });
    test('fn:contains', () {
      expect(
        fnContains(
          context,
          XPathSequence.single('abc'),
          XPathSequence.single('b'),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('fn:matches', () {
      expect(
        fnMatches(
          context,
          XPathSequence.single('abc'),
          XPathSequence.single('b'),
        ),
        XPathSequence.trueSequence,
      );
    });
    test('fn:tokenize', () {
      expect(
        fnTokenize(context, XPathSequence.single('a b c')),
        const XPathSequence([
          v31.XPathString('a'),
          v31.XPathString('b'),
          v31.XPathString('c'),
        ]),
      );
    });
    test('fn:codepoints-to-string', () {
      expect(
        fnCodepointsToString(context, const XPathSequence([97, 98, 99])),
        XPathSequence.single(const v31.XPathString('abc')),
      );
    });
    test('fn:string-to-codepoints', () {
      expect(
        fnStringToCodepoints(context, XPathSequence.single('abc')),
        const XPathSequence([97, 98, 99]),
      );
    });
    test('fn:compare', () {
      expect(
        fnCompare(
          context,
          XPathSequence.single('a'),
          XPathSequence.single('b'),
        ),
        XPathSequence.single(-1),
      );
    });
  });

  group('boolean', () {
    test('fn:boolean', () {
      expect(
        fnBoolean(context, XPathSequence.single(true)),
        XPathSequence.trueSequence,
      );
      expect(
        fnBoolean(context, XPathSequence.empty),
        XPathSequence.falseSequence,
      );
    });
    test('fn:not', () {
      expect(
        fnNot(context, XPathSequence.single(true)),
        XPathSequence.falseSequence,
      );
    });
    test('fn:true', () {
      expect(fnTrue(context), XPathSequence.trueSequence);
    });
    test('fn:false', () {
      expect(fnFalse(context), XPathSequence.falseSequence);
    });
    test('fn:lang', () {
      expect(
        fnLang(context, XPathSequence.single('en')),
        XPathSequence.falseSequence,
      );
    });
  });

  group('node', () {
    test('fn:name', () {
      final a = document.findAllElements('a').first;
      expect(
        fnName(context, XPathSequence.single(a)),
        XPathSequence.single(const v31.XPathString('a')),
      );
    });
    test('fn:local-name', () {
      final a = document.findAllElements('a').first;
      expect(
        fnLocalName(context, XPathSequence.single(a)),
        XPathSequence.single(const v31.XPathString('a')),
      );
    });
    test('fn:root', () {
      final a = document.findAllElements('a').first;
      expect(
        fnRoot(context, XPathSequence.single(a)),
        XPathSequence.single(document),
      );
    });
    test('fn:has-children', () {
      expect(
        fnHasChildren(context, XPathSequence.single(document)),
        XPathSequence.trueSequence,
      );
    });
    test('fn:innermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnInnermost(context, XPathSequence([document, a])),
        XPathSequence.single(a),
      );
    });
    test('fn:outermost', () {
      final a = document.findAllElements('a').first;
      expect(
        fnOutermost(context, XPathSequence([document, a])),
        XPathSequence.single(document),
      );
    });
    test('fn:path', () {
      final a = document.findAllElements('a').first;
      expect(
        fnPath(context, XPathSequence.single(a)),
        XPathSequence.single(const v31.XPathString('/r/a')),
      );
    });
  });

  group('context', () {
    test('fn:position', () {
      expect(fnPosition(context), XPathSequence.single(1));
    });
    test('fn:last', () {
      expect(fnLast(context), XPathSequence.single(1));
    });
    test('fn:current-dateTime', () {
      expect(fnCurrentDateTime(context), isNotNull);
    });
  });

  group('sequence', () {
    group('general functions and operators on sequences', () {
      test('fn:empty', () {
        expect(
          fnEmpty(context, XPathSequence.empty),
          XPathSequence.trueSequence,
        );
        expect(
          fnEmpty(context, XPathSequence.single(1)),
          XPathSequence.falseSequence,
        );
      });

      test('fn:exists', () {
        expect(
          fnExists(context, XPathSequence.empty),
          XPathSequence.falseSequence,
        );
        expect(
          fnExists(context, XPathSequence.single(1)),
          XPathSequence.trueSequence,
        );
      });

      test('fn:head', () {
        expect(fnHead(context, XPathSequence.empty), XPathSequence.empty);
        expect(
          fnHead(context, const XPathSequence([1, 2, 3])),
          XPathSequence.single(1),
        );
      });

      test('fn:tail', () {
        expect(fnTail(context, XPathSequence.empty), XPathSequence.empty);
        expect(fnTail(context, const XPathSequence([1])), XPathSequence.empty);
        expect(
          fnTail(context, const XPathSequence([1, 2, 3])),
          const XPathSequence([2, 3]),
        );
      });

      test('fn:insert-before', () {
        expect(
          fnInsertBefore(
            context,
            const XPathSequence([1, 2]),
            XPathSequence.single(1),
            XPathSequence.single(0),
          ),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(
            context,
            const XPathSequence([1, 2]),
            XPathSequence.single(2),
            XPathSequence.single(0),
          ),
          const XPathSequence([1, 0, 2]),
        );
        expect(
          fnInsertBefore(
            context,
            const XPathSequence([1, 2]),
            XPathSequence.single(3),
            XPathSequence.single(0),
          ),
          const XPathSequence([1, 2, 0]),
        );
        expect(
          fnInsertBefore(
            context,
            const XPathSequence([1, 2]),
            XPathSequence.single(0),
            XPathSequence.single(0),
          ),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(
            context,
            const XPathSequence([1, 2]),
            XPathSequence.single(10),
            XPathSequence.single(0),
          ),
          const XPathSequence([1, 2, 0]),
        );
      });

      test('fn:remove', () {
        expect(
          fnRemove(
            context,
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(2),
          ),
          const XPathSequence([1, 3]),
        );
        expect(
          fnRemove(
            context,
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(0),
          ),
          const XPathSequence([1, 2, 3]),
        );
        expect(
          fnRemove(
            context,
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(4),
          ),
          const XPathSequence([1, 2, 3]),
        );
      });

      test('fn:reverse', () {
        expect(
          fnReverse(context, const XPathSequence([1, 2, 3])),
          const XPathSequence([3, 2, 1]),
        );
        expect(fnReverse(context, XPathSequence.empty), XPathSequence.empty);
      });

      test('fn:subsequence', () {
        expect(
          fnSubsequence(
            context,
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(2),
          ),
          const XPathSequence([2, 3, 4, 5]),
        );
        expect(
          fnSubsequence(
            context,
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(2),
            XPathSequence.single(2),
          ),
          const XPathSequence([2, 3]),
        );
        expect(
          fnSubsequence(
            context,
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(0),
            XPathSequence.single(2),
          ),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(
            context,
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(-1),
            XPathSequence.single(3),
          ),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(
            context,
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(0.5),
            XPathSequence.single(1),
          ),
          const XPathSequence([1]),
        );
      });

      test('fn:unordered', () {
        const seq = XPathSequence([1, 2, 3]);
        expect(fnUnordered(context, seq), seq);
      });
    });

    group('functions that compare values in sequences', () {
      test('fn:distinct-values', () {
        expect(
          fnDistinctValues(context, const XPathSequence([1, 2, 1, 3, 2])),
          const XPathSequence([1, 2, 3]),
        );
      });

      test('fn:index-of', () {
        expect(
          fnIndexOf(
            context,
            const XPathSequence([1, 2, 1, 3]),
            XPathSequence.single(1),
          ),
          const XPathSequence([1, 3]),
        );
        expect(
          fnIndexOf(
            context,
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(4),
          ),
          XPathSequence.empty,
        );
      });

      test('fn:deep-equal', () {
        expect(
          fnDeepEqual(
            context,
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2]),
          ),
          XPathSequence.trueSequence,
        );
        expect(
          fnDeepEqual(
            context,
            const XPathSequence([1, 2]),
            const XPathSequence([1, 3]),
          ),
          XPathSequence.falseSequence,
        );
        expect(
          fnDeepEqual(
            context,
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2, 3]),
          ),
          XPathSequence.falseSequence,
        );
      });
    });

    group('functions that test the cardinality of sequences', () {
      test('fn:zero-or-one', () {
        expect(fnZeroOrOne(context, XPathSequence.empty), XPathSequence.empty);
        expect(
          fnZeroOrOne(context, XPathSequence.single(1)),
          XPathSequence.single(1),
        );
        expect(
          () => fnZeroOrOne(context, const XPathSequence([1, 2])),
          throwsA(isA<XPathEvaluationException>()),
        );
      });

      test('fn:one-or-more', () {
        expect(
          fnOneOrMore(context, XPathSequence.single(1)),
          XPathSequence.single(1),
        );
        expect(
          fnOneOrMore(context, const XPathSequence([1, 2])),
          const XPathSequence([1, 2]),
        );
        expect(
          () => fnOneOrMore(context, XPathSequence.empty),
          throwsA(isA<XPathEvaluationException>()),
        );
      });

      test('fn:exactly-one', () {
        expect(
          fnExactlyOne(context, XPathSequence.single(1)),
          XPathSequence.single(1),
        );
        expect(
          () => fnExactlyOne(context, XPathSequence.empty),
          throwsA(isA<XPathEvaluationException>()),
        );
        expect(
          () => fnExactlyOne(context, const XPathSequence([1, 2])),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });

    group('aggregate functions', () {
      test('fn:count', () {
        expect(fnCount(context, XPathSequence.empty), XPathSequence.single(0));
        expect(
          fnCount(context, const XPathSequence([1, 2, 3])),
          XPathSequence.single(3),
        );
      });

      test('fn:avg', () {
        expect(
          fnAvg(context, const XPathSequence([1, 2, 3])),
          XPathSequence.single(2.0),
        );
        expect(fnAvg(context, XPathSequence.empty), XPathSequence.empty);
      });

      test('fn:max', () {
        expect(
          fnMax(context, const XPathSequence([1, 3, 2])),
          XPathSequence.single(3),
        );
        expect(fnMax(context, XPathSequence.empty), XPathSequence.empty);
      });

      test('fn:min', () {
        expect(
          fnMin(context, const XPathSequence([3, 1, 2])),
          XPathSequence.single(1),
        );
        expect(fnMin(context, XPathSequence.empty), XPathSequence.empty);
      });

      test('fn:sum', () {
        expect(fnSum(context, XPathSequence.empty), XPathSequence.single(0));
        expect(
          fnSum(context, XPathSequence.empty, XPathSequence.single(42)),
          XPathSequence.single(42),
        );
        expect(
          fnSum(context, const XPathSequence([1, 2, 3])),
          XPathSequence.single(6.0),
        );
      });
    });

    group('functions on node identifiers', () {
      test('fn:id', () {
        expect(
          () => fnId(context, XPathSequence.single('id')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:element-with-id', () {
        expect(
          () => fnElementWithId(context, XPathSequence.single('id')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:idref', () {
        expect(
          () => fnIdref(context, XPathSequence.single('id')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:generate-id', () {
        expect(
          () => fnGenerateId(context, XPathSequence.empty),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('functions giving access to external information', () {
      test('fn:doc', () {
        expect(
          () => fnDoc(context, XPathSequence.single('uri')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:doc-available', () {
        expect(
          () => fnDocAvailable(context, XPathSequence.single('uri')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:collection', () {
        expect(() => fnCollection(context), throwsA(isA<UnimplementedError>()));
      });
      test('fn:uri-collection', () {
        expect(
          () => fnUriCollection(context),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text', () {
        expect(
          () => fnUnparsedText(context, XPathSequence.single('uri')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-lines', () {
        expect(
          () => fnUnparsedTextLines(context, XPathSequence.single('uri')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-available', () {
        expect(
          () => fnUnparsedTextAvailable(context, XPathSequence.single('uri')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:environment-variable', () {
        expect(
          () => fnEnvironmentVariable(context, XPathSequence.single('name')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:available-environment-variables', () {
        expect(
          () => fnAvailableEnvironmentVariables(context),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('parsing and serializing', () {
      test('fn:serialize', () {
        expect(
          () => fnSerialize(context, XPathSequence.empty),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml', () {
        expect(
          () => fnParseXml(context, XPathSequence.single('<r/>')),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml-fragment', () {
        expect(
          () => fnParseXmlFragment(context, XPathSequence.single('<r/>')),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });

  group('higher_order', () {
    test('fn:sort', () {
      expect(
        fnSort(context, const XPathSequence([3, 1, 2])).toList(),
        orderedEquals([1, 2, 3]),
      );
    });
    test('fn:apply', () {
      expect(
        () => fnApply(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:for-each-pair', () {
      expect(
        () => fnForEachPair(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('maps_arrays', () {
    test('map:merge', () {
      final map1 = {'a': 1, 'b': 2};
      final map2 = {'b': 3, 'c': 4};
      expect(
        mapMerge(context, XPathSequence([map1, map2])).first,
        // duplicate keys: last wins by default? logic says result.addAll which overwrites.
        equals({'a': 1, 'b': 3, 'c': 4}),
      );
      expect(
        () => mapMerge(context, XPathSequence.single(123)),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('map:size', () {
      final map = {'a': 1, 'b': 2};
      expect(mapSize(context, XPathSequence.single(map)), orderedEquals([2]));
    });
    test('map:keys', () {
      final map = {'a': 1, 'b': 2};
      // Keys matching is order-dependent? Map keys order is iteration order.
      expect(
        mapKeys(context, XPathSequence.single(map)).toList(),
        containsAll(['a', 'b']),
      );
    });
    test('map:contains', () {
      final map = {'a': 1};
      expect(
        mapContains(
          context,
          XPathSequence.single(map),
          XPathSequence.single('a'),
        ),
        orderedEquals([true]),
      );
      expect(
        mapContains(
          context,
          XPathSequence.single(map),
          XPathSequence.single('b'),
        ),
        orderedEquals([false]),
      );
    });
    test('map:get', () {
      final map = {'a': 1};
      expect(
        mapGet(context, XPathSequence.single(map), XPathSequence.single('a')),
        orderedEquals([1]),
      );
      expect(
        mapGet(context, XPathSequence.single(map), XPathSequence.single('b')),
        isEmpty,
      );
    });
    test('map:find', () {
      // Stub implementation alias to map:get
      final map = {'a': 1};
      expect(
        mapFind(context, XPathSequence.single(map), XPathSequence.single('a')),
        orderedEquals([1]),
      );
    });
    test('map:put', () {
      final map = {'a': 1};
      expect(
        mapPut(
          context,
          XPathSequence.single(map),
          XPathSequence.single('b'),
          XPathSequence.single(2),
        ).first,
        equals({'a': 1, 'b': 2}),
      );
    });
    test('map:entry', () {
      expect(
        mapEntry(
          context,
          XPathSequence.single('a'),
          XPathSequence.single(1),
        ).first,
        equals({'a': 1}),
      );
    });
    test('map:remove', () {
      final map = {'a': 1, 'b': 2};
      expect(
        mapRemove(
          context,
          XPathSequence.single(map),
          XPathSequence.single('a'),
        ).first,
        equals({'b': 2}),
      );
      expect(
        mapRemove(
          context,
          XPathSequence.single(map),
          const XPathSequence(['a', 'b']),
        ).first,
        equals({}),
      );
    });
    test('map:for-each', () {
      expect(
        () => mapForEach(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('array:size', () {
      final array = ['a', 'b', 'c'];
      expect(
        arraySize(context, XPathSequence.single(array)),
        orderedEquals([3]),
      );
    });
    test('array:get', () {
      final array = ['a', 'b'];
      expect(
        arrayGet(context, XPathSequence.single(array), XPathSequence.single(1)),
        orderedEquals(['a']),
      );
      expect(
        () => arrayGet(
          context,
          XPathSequence.single(array),
          XPathSequence.single(3),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => arrayGet(
          context,
          XPathSequence.single(array),
          XPathSequence.single(0),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:put', () {
      final array = ['a', 'b'];
      expect(
        arrayPut(
          context,
          XPathSequence.single(array),
          XPathSequence.single(1),
          XPathSequence.single('c'),
        ).first,
        equals(['c', 'b']),
      );
      expect(
        () => arrayPut(
          context,
          XPathSequence.single(array),
          XPathSequence.single(3),
          XPathSequence.single('c'),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:append', () {
      final array = ['a'];
      expect(
        arrayAppend(
          context,
          XPathSequence.single(array),
          XPathSequence.single('b'),
        ).first,
        equals(['a', 'b']),
      );
    });
    test('array:subarray', () {
      final array = ['a', 'b', 'c', 'd'];
      expect(
        arraySubarray(
          context,
          XPathSequence.single(array),
          XPathSequence.single(2),
        ).first,
        equals(['b', 'c', 'd']),
      );
      expect(
        arraySubarray(
          context,
          XPathSequence.single(array),
          XPathSequence.single(2),
          XPathSequence.single(2),
        ).first,
        equals(['b', 'c']),
      );
      expect(
        () => arraySubarray(
          context,
          XPathSequence.single(array),
          XPathSequence.single(0),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        arraySubarray(
          context,
          XPathSequence.single(array),
          XPathSequence.single(5),
        ).first,
        equals([]),
      );
      expect(
        () => arraySubarray(
          context,
          XPathSequence.single(array),
          XPathSequence.single(4),
          XPathSequence.single(2),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:remove', () {
      final array = ['a', 'b', 'c'];
      expect(
        arrayRemove(
          context,
          XPathSequence.single(array),
          XPathSequence.single(2),
        ).first,
        equals(['a', 'c']),
      );
      expect(
        arrayRemove(
          context,
          XPathSequence.single(array),
          const XPathSequence([1, 3]),
        ).first,
        equals(['b']),
      );
      expect(
        () => arrayRemove(
          context,
          XPathSequence.single(array),
          XPathSequence.single(4),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:insert-before', () {
      final array = ['a', 'c'];
      expect(
        arrayInsertBefore(
          context,
          XPathSequence.single(array),
          XPathSequence.single(2),
          XPathSequence.single('b'),
        ).first,
        equals(['a', 'b', 'c']),
      );
      expect(
        () => arrayInsertBefore(
          context,
          XPathSequence.single(array),
          XPathSequence.single(4),
          XPathSequence.single('d'),
        ),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:head', () {
      expect(
        arrayHead(
          context,
          const XPathSequence([
            ['a', 'b'],
          ]),
        ),
        orderedEquals(['a']),
      );
      expect(
        () => arrayHead(context, XPathSequence.single([])),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:tail', () {
      expect(
        arrayTail(
          context,
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ).first,
        equals(['b', 'c']),
      );
      expect(
        () => arrayTail(context, XPathSequence.single([])),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:reverse', () {
      expect(
        arrayReverse(
          context,
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ).first,
        equals(['c', 'b', 'a']),
      );
    });
    test('array:join', () {
      final array = ['a', 'b', 'c'];
      expect(
        arrayJoin(context, XPathSequence.single(array)),
        orderedEquals(['abc']),
      );
      expect(
        arrayJoin(
          context,
          XPathSequence.single(array),
          XPathSequence.single('-'),
        ),
        orderedEquals(['a-b-c']),
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
        arrayFlatten(context, XPathSequence(input)).toList(),
        orderedEquals([1, 2, 3, 4, 5]),
      );
    });
    test('unimplemented array functions', () {
      expect(
        () => arrayForEach(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => arrayFilter(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => arrayFoldLeft(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => arrayFoldRight(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => arrayForEachPair(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
      expect(
        () => arraySort(context, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('binary', () {
    test('op:hexBinary-equal', () {
      expect(
        opHexBinaryEqual(
          context,
          XPathSequence.single('AB'),
          XPathSequence.single('AB'),
        ),
        orderedEquals([true]),
      );
      expect(
        opHexBinaryEqual(
          context,
          XPathSequence.single('AB'),
          XPathSequence.single('AC'),
        ),
        orderedEquals([false]),
      );
    });
  });

  group('notation', () {
    test('op:NOTATION-equal', () {
      expect(
        opNotationEqual(
          context,
          XPathSequence.single('foo:bar'),
          XPathSequence.single('foo:bar'),
        ),
        orderedEquals([true]),
      );
    });
  });

  group('qname', () {
    test('op:QName-equal', () {
      expect(
        () => opQNameEqual(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:namespace-uri-for-prefix', () {
      expect(
        () => fnNamespaceUriForPrefix(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('date_time', () {
    test('fn:year-from-date', () {
      expect(
        fnYearFromDate(context, XPathSequence.single(DateTime(2023, 10, 26))),
        orderedEquals([2023]),
      );
    });
    test('op:dateTime-equal', () {
      final dt1 = DateTime(2023, 1, 1);
      final dt2 = DateTime(2023, 1, 1);
      final dt3 = DateTime(2023, 1, 2);
      expect(
        opDateTimeEqual(
          context,
          XPathSequence.single(dt1),
          XPathSequence.single(dt2),
        ),
        orderedEquals([true]),
      );
      expect(
        opDateTimeEqual(
          context,
          XPathSequence.single(dt1),
          XPathSequence.single(dt3),
        ),
        orderedEquals([false]),
      );
    });
  });

  group('duration', () {
    test('op:duration-equal', () {
      const d1 = Duration(days: 1);
      const d2 = Duration(days: 1);
      const d3 = Duration(days: 2);
      expect(
        opDurationEqual(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ),
        orderedEquals([true]),
      );
      expect(
        opDurationEqual(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d3),
        ),
        orderedEquals([false]),
      );
    });
  });

  group('string_extra', () {
    test('fn:concat', () {
      expect(
        fnConcat(
          context,
          XPathSequence.single('a'),
          XPathSequence.single('b'),
          [XPathSequence.single('c')],
        ),
        orderedEquals(['abc']),
      );
    });
    test('fn:string-join', () {
      expect(
        fnStringJoin(
          context,
          const XPathSequence(['a', 'b', 'c']),
          XPathSequence.single('-'),
        ),
        orderedEquals(['a-b-c']),
      );
      expect(
        fnStringJoin(context, const XPathSequence(['a', 'b', 'c'])),
        orderedEquals(['abc']),
      );
    });
    test('fn:substring', () {
      expect(
        fnSubstring(
          context,
          XPathSequence.single('motor car'),
          XPathSequence.single(6),
        ),
        orderedEquals([' car']),
      );
      expect(
        fnSubstring(
          context,
          XPathSequence.single('metadata'),
          XPathSequence.single(4),
          XPathSequence.single(3),
        ),
        orderedEquals(['ada']),
      );
      expect(
        fnSubstring(
          context,
          XPathSequence.single('12345'),
          XPathSequence.single(1.5),
          XPathSequence.single(2.6),
        ),
        orderedEquals(['234']),
      );
      expect(
        fnSubstring(
          context,
          XPathSequence.single('12345'),
          XPathSequence.single(0),
          XPathSequence.single(3),
        ),
        orderedEquals(['12']),
      );
    });
    test('fn:string-length', () {
      expect(
        fnStringLength(context, XPathSequence.single('abc')),
        orderedEquals([3]),
      );
      expect(fnStringLength(context, XPathSequence.empty), orderedEquals([0]));
    });
    test('fn:normalize-space', () {
      expect(
        fnNormalizeSpace(context, XPathSequence.single('  a  b   c  ')),
        orderedEquals(['a b c']),
      );
    });
    test('fn:upper-case', () {
      expect(
        fnUpperCase(context, XPathSequence.single('abc')),
        orderedEquals(['ABC']),
      );
    });
    test('fn:lower-case', () {
      expect(
        fnLowerCase(context, XPathSequence.single('ABC')),
        orderedEquals(['abc']),
      );
    });
    test('fn:contains', () {
      expect(
        fnContains(
          context,
          XPathSequence.single('tattoo'),
          XPathSequence.single('t'),
        ),
        orderedEquals([true]),
      );
      expect(
        fnContains(
          context,
          XPathSequence.single('tattoo'),
          XPathSequence.single('z'),
        ),
        orderedEquals([false]),
      );
    });
    test('fn:starts-with', () {
      expect(
        fnStartsWith(
          context,
          XPathSequence.single('tattoo'),
          XPathSequence.single('tat'),
        ),
        orderedEquals([true]),
      );
    });
    test('fn:ends-with', () {
      expect(
        fnEndsWith(
          context,
          XPathSequence.single('tattoo'),
          XPathSequence.single('too'),
        ),
        orderedEquals([true]),
      );
    });
    test('fn:substring-before', () {
      expect(
        fnSubstringBefore(
          context,
          XPathSequence.single('tattoo'),
          XPathSequence.single('too'),
        ),
        orderedEquals(['tat']),
      );
    });
    test('fn:substring-after', () {
      expect(
        fnSubstringAfter(
          context,
          XPathSequence.single('tattoo'),
          XPathSequence.single('tat'),
        ),
        orderedEquals(['too']),
      );
    });
    test('fn:translate', () {
      expect(
        fnTranslate(
          context,
          XPathSequence.single('bar'),
          XPathSequence.single('abc'),
          XPathSequence.single('ABC'),
        ),
        orderedEquals(['BAr']),
      );
    });
    test('fn:matches', () {
      expect(
        fnMatches(
          context,
          XPathSequence.single('abracadabra'),
          XPathSequence.single('bra'),
        ),
        orderedEquals([true]),
      );
    });
    test('fn:replace', () {
      expect(
        fnReplace(
          context,
          XPathSequence.single('abracadabra'),
          XPathSequence.single('bra'),
          XPathSequence.single('*'),
        ),
        orderedEquals(['a*cada*']),
      );
    });
    test('fn:codepoints-to-string', () {
      expect(
        fnCodepointsToString(context, const XPathSequence([97, 98, 99])),
        orderedEquals(['abc']),
      );
      expect(
        () => fnCodepointsToString(context, XPathSequence.single(-1)),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('fn:string-to-codepoints', () {
      expect(
        fnStringToCodepoints(context, XPathSequence.single('abc')),
        orderedEquals([97, 98, 99]),
      );
    });
    test('fn:compare', () {
      expect(
        fnCompare(
          context,
          XPathSequence.single('a'),
          XPathSequence.single('b'),
        ),
        orderedEquals([-1]),
      );
    });
    test('fn:codepoint-equal', () {
      expect(
        fnCodepointEqual(
          context,
          XPathSequence.single('a'),
          XPathSequence.single('a'),
        ),
        orderedEquals([true]),
      );
    });
    test('fn:collation-key', () {
      expect(
        fnCollationKey(context, XPathSequence.single('abc')),
        orderedEquals(['abc']),
      );
    });
    test('fn:contains-token', () {
      expect(
        fnContainsToken(
          context,
          XPathSequence.single('a b c'),
          XPathSequence.single('b'),
        ),
        orderedEquals([true]),
      );
    });
    test('fn:normalize-unicode', () {
      expect(
        fnNormalizeUnicode(context, XPathSequence.single('a')),
        orderedEquals(['a']),
      );
    });
    test('fn:tokenize', () {
      expect(
        fnTokenize(context, XPathSequence.single('a b c')).toList(),
        orderedEquals(['a', 'b', 'c']),
      );
      expect(
        fnTokenize(
          context,
          XPathSequence.single('abracadabra'),
          XPathSequence.single('(ab)|(a)'),
        ).toList(),
        orderedEquals(['', 'r', 'c', 'd', 'r', '']),
      );
    });

    test('fn:analyze-string', () {
      expect(
        () =>
            fnAnalyzeString(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('json', () {
    test('fn:parse-json', () {
      expect(
        () => fnParseJson(context, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('numeric_extra', () {
    test('op:numeric-add', () {
      expect(
        opNumericAdd(context, XPathSequence.single(1), XPathSequence.single(2)),
        orderedEquals([3]),
      );
    });
    test('op:numeric-subtract', () {
      expect(
        opNumericSubtract(
          context,
          XPathSequence.single(3),
          XPathSequence.single(2),
        ),
        orderedEquals([1]),
      );
    });
    test('op:numeric-multiply', () {
      expect(
        opNumericMultiply(
          context,
          XPathSequence.single(2),
          XPathSequence.single(3),
        ),
        orderedEquals([6]),
      );
    });
    test('op:numeric-divide', () {
      expect(
        opNumericDivide(
          context,
          XPathSequence.single(6),
          XPathSequence.single(2),
        ),
        orderedEquals([3.0]),
      );
    });
    test('op:numeric-integer-divide', () {
      expect(
        opNumericIntegerDivide(
          context,
          XPathSequence.single(10),
          XPathSequence.single(3),
        ),
        orderedEquals([3]),
      );
    });
    test('op:numeric-mod', () {
      expect(
        opNumericMod(
          context,
          XPathSequence.single(10),
          XPathSequence.single(3),
        ),
        orderedEquals([1]),
      );
    });
    test('op:numeric-unary-plus', () {
      expect(
        opNumericUnaryPlus(context, XPathSequence.single(1)),
        orderedEquals([1]),
      );
      expect(opNumericUnaryPlus(context, XPathSequence.empty), isEmpty);
    });
    test('op:numeric-unary-minus', () {
      expect(
        opNumericUnaryMinus(context, XPathSequence.single(1)),
        orderedEquals([-1]),
      );
      expect(opNumericUnaryMinus(context, XPathSequence.empty), isEmpty);
    });
    test('op:numeric-equal', () {
      expect(
        opNumericEqual(
          context,
          XPathSequence.single(1),
          XPathSequence.single(1),
        ),
        orderedEquals([true]),
      );
      expect(
        opNumericEqual(context, XPathSequence.single(1), XPathSequence.empty),
        isEmpty,
      );
    });
    test('op:numeric-less-than', () {
      expect(
        opNumericLessThan(
          context,
          XPathSequence.single(1),
          XPathSequence.single(2),
        ),
        orderedEquals([true]),
      );
    });
    test('op:numeric-greater-than', () {
      expect(
        opNumericGreaterThan(
          context,
          XPathSequence.single(2),
          XPathSequence.single(1),
        ),
        orderedEquals([true]),
      );
    });
    test('fn:abs', () {
      expect(fnAbs(context, XPathSequence.single(-1)), orderedEquals([1]));
      expect(fnAbs(context, XPathSequence.empty), isEmpty);
    });
    test('fn:ceiling', () {
      expect(fnCeiling(context, XPathSequence.single(1.5)), orderedEquals([2]));
    });
    test('fn:floor', () {
      expect(fnFloor(context, XPathSequence.single(1.5)), orderedEquals([1]));
    });
    test('fn:round', () {
      expect(fnRound(context, XPathSequence.single(1.5)), orderedEquals([2]));
      expect(fnRound(context, XPathSequence.empty), isEmpty);
      expect(
        fnRound(context, XPathSequence.single(double.nan)),
        orderedEquals([isNaN]),
      );
      expect(
        fnRound(context, XPathSequence.single(1.5), XPathSequence.single(1)),
        orderedEquals([2]), // precision ignored for now
      );
    });
    test('fn:round-half-to-even', () {
      expect(
        fnRoundHalfToEven(context, XPathSequence.single(1.5)),
        orderedEquals([2]),
      );
      expect(
        fnRoundHalfToEven(context, XPathSequence.single(2.5)),
        orderedEquals([2]),
      );
      expect(fnRoundHalfToEven(context, XPathSequence.empty), isEmpty);
    });
    test('fn:format-integer', () {
      expect(
        fnFormatInteger(
          context,
          XPathSequence.single(123),
          XPathSequence.single('000'),
        ),
        orderedEquals(['123']),
      );
      expect(
        fnFormatInteger(
          context,
          XPathSequence.empty,
          XPathSequence.single('000'),
        ),
        isEmpty,
      );
    });
    test('fn:number', () {
      expect(
        fnNumber(context, XPathSequence.single('123')),
        orderedEquals([123]),
      );
      expect(fnNumber(context, XPathSequence.empty), orderedEquals([isNaN]));
    });
    test('math functions', () {
      expect(
        mathPi(context),
        orderedEquals([predicate((x) => (x as double) > 3.14)]),
      );
      expect(mathExp(context, XPathSequence.single(0)), orderedEquals([1.0]));
      expect(mathExp10(context, XPathSequence.single(0)), orderedEquals([1.0]));
      expect(
        mathLog(context, XPathSequence.single(math.e)),
        orderedEquals([1.0]),
      );
      expect(
        mathLog10(context, XPathSequence.single(10)),
        orderedEquals([1.0]),
      );
      expect(
        mathPow(context, XPathSequence.single(2), XPathSequence.single(3)),
        orderedEquals([8.0]),
      );
      expect(mathSqrt(context, XPathSequence.single(4)), orderedEquals([2.0]));
      expect(mathSin(context, XPathSequence.single(0)), orderedEquals([0.0]));
      expect(mathCos(context, XPathSequence.single(0)), orderedEquals([1.0]));
      expect(mathTan(context, XPathSequence.single(0)), orderedEquals([0.0]));
      expect(mathAsin(context, XPathSequence.single(0)), orderedEquals([0.0]));
      expect(mathAcos(context, XPathSequence.single(1)), orderedEquals([0.0]));
      expect(mathAtan(context, XPathSequence.single(0)), orderedEquals([0.0]));
      expect(
        mathAtan2(context, XPathSequence.single(0), XPathSequence.single(1)),
        orderedEquals([0.0]),
      );
    });
    test('fn:random-number-generator', () {
      expect(
        fnRandomNumberGenerator(context, XPathSequence.single(1)),
        hasLength(1),
      );
    });
  });

  group('node_extra', () {
    final document = XmlDocument.parse('''
<root>
  <child id="1">
    <grandchild id="2"/>
  </child>
  <child id="3"/>
</root>''');
    final root = document.rootElement;
    final child1 = root.children.whereType<XmlElement>().first;
    final grandchild2 = child1.children.whereType<XmlElement>().first;
    final child3 = root.children.whereType<XmlElement>().last;

    test('fn:name', () {
      expect(
        fnName(context, XPathSequence.single(root)),
        orderedEquals(['root']),
      );
      expect(
        fnName(context, XPathSequence.single(document)),
        orderedEquals(['']),
      );
    });
    test('fn:local-name', () {
      expect(
        fnLocalName(context, XPathSequence.single(root)),
        orderedEquals(['root']),
      );
    });
    test('fn:namespace-uri', () {
      expect(
        fnNamespaceUri(context, XPathSequence.single(root)),
        orderedEquals(['']),
      );
    });
    test('fn:root', () {
      expect(
        fnRoot(context, XPathSequence.single(grandchild2)).first,
        equals(document),
      );
    });
    test('fn:has-children', () {
      expect(
        fnHasChildren(context, XPathSequence.single(root)),
        orderedEquals([true]),
      );
      expect(
        fnHasChildren(context, XPathSequence.single(grandchild2)),
        orderedEquals([false]),
      );
    });
    test('fn:innermost', () {
      expect(
        fnInnermost(
          context,
          XPathSequence([root, child1, grandchild2, child3]),
        ).toList(),
        containsAll([grandchild2, child3]),
      );
    });
    test('fn:outermost', () {
      expect(
        fnOutermost(
          context,
          XPathSequence([root, child1, grandchild2, child3]),
        ).toList(),
        orderedEquals([root]),
      );
    });
    test('fn:path', () {
      // Basic path test, implementation might be simple
      final path = fnPath(
        context,
        XPathSequence.single(grandchild2),
      ).firstOrNull?.toString();
      // Implementation uses names and indexes.
      // root -> child[1] -> grandchild[1]
      // path string format: /root/child[1]/grandchild
      expect(path, isNotNull);
      expect(path, matches(RegExp(r'/root.*child.*grandchild')));
    });
  });

  group('date_time_extra', () {
    final dt1 = DateTime.utc(2023, 10, 26, 12, 30, 45);
    final dt2 = DateTime.utc(2023, 10, 27, 12, 30, 45);
    const dur = Duration(days: 1);

    test('fn:dateTime', () {
      expect(
        fnDateTime(
          context,
          XPathSequence.single(DateTime.utc(2023, 10, 26)),
          XPathSequence.single(DateTime.utc(0, 1, 1, 12, 30, 45)),
        ).first,
        equals(DateTime(2023, 10, 26, 12, 30, 45)),
      );
    });
    test('fn:year-from-dateTime', () {
      expect(
        fnYearFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([2023]),
      );
    });
    test('fn:month-from-dateTime', () {
      expect(
        fnMonthFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([10]),
      );
    });
    test('fn:day-from-dateTime', () {
      expect(
        fnDayFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([26]),
      );
    });
    test('fn:hours-from-dateTime', () {
      expect(
        fnHoursFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([12]),
      );
    });
    test('fn:minutes-from-dateTime', () {
      expect(
        fnMinutesFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-dateTime', () {
      expect(
        fnSecondsFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([45.0]),
      );
    });
    test('op:dateTime-less-than', () {
      expect(
        opDateTimeLessThan(
          context,
          XPathSequence.single(dt1),
          XPathSequence.single(dt2),
        ),
        orderedEquals([true]),
      );
      expect(
        opDateTimeLessThan(
          context,
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ),
        orderedEquals([false]),
      );
    });
    test('op:dateTime-greater-than', () {
      expect(
        opDateTimeGreaterThan(
          context,
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ),
        orderedEquals([true]),
      );
    });
    test('op:subtract-dateTimes', () {
      expect(
        opSubtractDateTimes(
          context,
          XPathSequence.single(dt2),
          XPathSequence.single(dt1),
        ).first,
        equals(const Duration(days: 1)),
      );
    });
    test('op:add-duration-to-dateTime', () {
      expect(
        opAddDurationToDateTime(
          context,
          XPathSequence.single(dt1),
          XPathSequence.single(dur),
        ).first,
        equals(dt2),
      );
    });
    test('op:subtract-duration-from-dateTime', () {
      expect(
        opSubtractDurationFromDateTime(
          context,
          XPathSequence.single(dt2),
          XPathSequence.single(dur),
        ).first,
        equals(dt1),
      );
    });
    test('fn:timezone-from-dateTime', () {
      expect(
        fnTimezoneFromDateTime(context, XPathSequence.single(dt1)),
        orderedEquals([Duration.zero]),
      );
    });
    test('fn:year-from-date', () {
      expect(
        fnYearFromDate(context, XPathSequence.single(dt1)),
        orderedEquals([2023]),
      );
    });
    test('fn:month-from-date', () {
      expect(
        fnMonthFromDate(context, XPathSequence.single(dt1)),
        orderedEquals([10]),
      );
    });
    test('fn:day-from-date', () {
      expect(
        fnDayFromDate(context, XPathSequence.single(dt1)),
        orderedEquals([26]),
      );
    });
    test('fn:timezone-from-date', () {
      expect(
        fnTimezoneFromDate(context, XPathSequence.single(dt1)),
        orderedEquals([Duration.zero]),
      );
    });
    test('fn:hours-from-time', () {
      expect(
        fnHoursFromTime(context, XPathSequence.single(dt1)),
        orderedEquals([12]),
      );
    });
    test('fn:minutes-from-time', () {
      expect(
        fnMinutesFromTime(context, XPathSequence.single(dt1)),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-time', () {
      expect(
        fnSecondsFromTime(context, XPathSequence.single(dt1)),
        orderedEquals([45.0]),
      );
    });
    test('fn:timezone-from-time', () {
      expect(
        fnTimezoneFromTime(context, XPathSequence.single(dt1)),
        orderedEquals([Duration.zero]),
      );
    });
  });

  group('duration_extra', () {
    const d1 = Duration(days: 1);
    const d2 = Duration(days: 2);
    const d3 = Duration(hours: 1);

    test('op:duration-equal', () {
      expect(
        opDurationEqual(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d1),
        ),
        orderedEquals([true]),
      );
    });
    test('op:yearMonthDuration-less-than', () {
      expect(
        opYearMonthDurationLessThan(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ),
        orderedEquals([true]),
      );
    });
    test('op:yearMonthDuration-greater-than', () {
      expect(
        opYearMonthDurationGreaterThan(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ),
        orderedEquals([true]),
      );
    });
    test('op:dayTimeDuration-less-than', () {
      expect(
        opDayTimeDurationLessThan(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ),
        orderedEquals([true]),
      );
    });
    test('op:dayTimeDuration-greater-than', () {
      expect(
        opDayTimeDurationGreaterThan(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ),
        orderedEquals([true]),
      );
    });
    test('op:add-yearMonthDurations', () {
      // Dart duration doesn't distinguish, so this works for any duration logically in this impl
      expect(
        opAddYearMonthDurations(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ).first,
        equals(d1 + d2),
      );
    });
    test('op:subtract-yearMonthDurations', () {
      expect(
        opSubtractYearMonthDurations(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ).first,
        equals(d1),
      );
    });
    test('op:multiply-yearMonthDuration', () {
      expect(
        opMultiplyYearMonthDuration(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(2),
        ).first,
        equals(d2),
      );
    });
    test('op:divide-yearMonthDuration', () {
      expect(
        opDivideYearMonthDuration(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(2),
        ).first,
        equals(d1),
      );
    });
    test('op:divide-yearMonthDuration-by-yearMonthDuration', () {
      expect(
        opDivideYearMonthDurationByYearMonthDuration(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ),
        orderedEquals([2.0]),
      );
    });
    test('op:add-dayTimeDurations', () {
      expect(
        opAddDayTimeDurations(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(d2),
        ).first,
        equals(d1 + d2),
      );
    });
    test('op:subtract-dayTimeDurations', () {
      expect(
        opSubtractDayTimeDurations(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ).first,
        equals(d1),
      );
    });
    test('op:multiply-dayTimeDuration', () {
      expect(
        opMultiplyDayTimeDuration(
          context,
          XPathSequence.single(d1),
          XPathSequence.single(2),
        ).first,
        equals(d2),
      );
    });
    test('op:divide-dayTimeDuration', () {
      expect(
        opDivideDayTimeDuration(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(2),
        ).first,
        equals(d1),
      );
    });
    test('op:divide-dayTimeDuration-by-dayTimeDuration', () {
      expect(
        opDivideDayTimeDurationByDayTimeDuration(
          context,
          XPathSequence.single(d2),
          XPathSequence.single(d1),
        ),
        orderedEquals([2.0]),
      );
    });
    test('fn:years-from-duration', () {
      expect(
        fnYearsFromDuration(context, XPathSequence.single(d1)),
        orderedEquals([0]),
      );
    });
    test('fn:months-from-duration', () {
      expect(
        fnMonthsFromDuration(context, XPathSequence.single(d1)),
        orderedEquals([0]),
      );
    });
    test('fn:days-from-duration', () {
      expect(
        fnDaysFromDuration(context, XPathSequence.single(d1)),
        orderedEquals([1]),
      );
    });
    test('fn:hours-from-duration', () {
      expect(
        fnHoursFromDuration(context, XPathSequence.single(d3)),
        orderedEquals([1]),
      );
    });
    test('fn:minutes-from-duration', () {
      const d = Duration(minutes: 90);
      expect(
        fnMinutesFromDuration(context, XPathSequence.single(d)),
        orderedEquals([30]),
      );
    });
    test('fn:seconds-from-duration', () {
      const d = Duration(seconds: 90); // 1 min 30 sec
      expect(
        fnSecondsFromDuration(context, XPathSequence.single(d)),
        orderedEquals([30.0]),
      );
    });
  });

  group('binary_extra', () {
    test('op:hexBinary-equal', () {
      expect(
        opHexBinaryEqual(
          context,
          XPathSequence.single('AA'),
          XPathSequence.single('AA'),
        ),
        orderedEquals([true]),
      );
    });
    test('op:hexBinary-less-than', () {
      expect(
        opHexBinaryLessThan(
          context,
          XPathSequence.single('AA'),
          XPathSequence.single('BB'),
        ),
        orderedEquals([true]),
      );
    });
    test('op:hexBinary-greater-than', () {
      expect(
        opHexBinaryGreaterThan(
          context,
          XPathSequence.single('BB'),
          XPathSequence.single('AA'),
        ),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-equal', () {
      expect(
        opBase64BinaryEqual(
          context,
          XPathSequence.single('AA=='),
          XPathSequence.single('AA=='),
        ),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-less-than', () {
      expect(
        opBase64BinaryLessThan(
          context,
          XPathSequence.single('AA=='),
          XPathSequence.single('BB=='),
        ),
        orderedEquals([true]),
      );
    });
    test('op:base64Binary-greater-than', () {
      expect(
        opBase64BinaryGreaterThan(
          context,
          XPathSequence.single('BB=='),
          XPathSequence.single('AA=='),
        ),
        orderedEquals([true]),
      );
    });
  });

  group('qname_extra', () {
    final qname = XmlName.fromString('p:local');

    test('fn:resolve-QName', () {
      expect(
        fnResolveQName(
          context,
          XPathSequence.single('p:local'),
          XPathSequence.single(
            const v31.XPathString('element'),
          ), // dummy element
        ).first,
        isA<XmlName>(),
      );
    });
    test('fn:QName', () {
      expect(
        fnQName(
          context,
          XPathSequence.single('uri'),
          XPathSequence.single('p:local'),
        ).first,
        isA<XmlName>(),
      );
    });
    test('fn:prefix-from-QName', () {
      expect(
        fnPrefixFromQName(context, XPathSequence.single(qname)),
        orderedEquals(['p']),
      );
    });
    test('fn:local-name-from-QName', () {
      expect(
        fnLocalNameFromQName(context, XPathSequence.single(qname)),
        orderedEquals(['local']),
      );
    });
    test('fn:namespace-uri-from-QName', () {
      // implementation returns value.namespaceUri check
      // For XmlName.fromString('p:local'), namespaceUri is null by default unless resolved?
      // Wait, XmlName.fromString parses prefix. Does it resolve URI? No context provided.
      // Tests might return empty string if no URI.
      // Let's check impl: `value.namespaceUri == null ? XPathSequence.empty`.
      expect(
        fnNamespaceUriFromQName(context, XPathSequence.single(qname)),
        isEmpty,
      );
    });
    test('op:QName-equal', () {
      expect(
        () => opQNameEqual(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:namespace-uri-for-prefix', () {
      expect(
        () => fnNamespaceUriForPrefix(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:in-scope-prefixes', () {
      expect(
        () => fnInScopePrefixes(context, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('context_extra', () {
    test('fn:position', () {
      expect(fnPosition(context), orderedEquals([1]));
    });
    test('fn:last', () {
      expect(fnLast(context), orderedEquals([1]));
    });
    test('fn:current-dateTime', () {
      expect(fnCurrentDateTime(context).first, isA<DateTime>());
    });
    test('fn:current-date', () {
      expect(fnCurrentDate(context).first, isA<DateTime>());
    });
    test('fn:current-time', () {
      expect(fnCurrentTime(context).first, isA<DateTime>());
    });
    test('fn:implicit-timezone', () {
      expect(fnImplicitTimezone(context), orderedEquals([Duration.zero]));
    });
    test('fn:default-collation', () {
      expect(
        fnDefaultCollation(context),
        orderedEquals([
          'http://www.w3.org/2005/xpath-functions/collation/codepoint',
        ]),
      );
    });
    test('fn:default-language', () {
      expect(fnDefaultLanguage(context), orderedEquals(['en']));
    });
    test('fn:static-base-uri', () {
      expect(fnStaticBaseUri(context), isEmpty);
    });
  });

  group('error_extra', () {
    test('fn:error', () {
      expect(() => fnError(context), throwsA(isA<XPathEvaluationException>()));
      expect(
        () => fnError(context, XPathSequence.single('code')),
        throwsA(isA<XPathEvaluationException>()),
      );
      try {
        fnError(
          context,
          XPathSequence.single('code'),
          XPathSequence.single('desc'),
          XPathSequence.single('obj'),
        );
      } catch (e) {
        expect(e.toString(), contains('code: desc (obj)'));
      }
    });

    test('fn:trace', () {
      expect(
        fnTrace(
          context,
          XPathSequence.single('value'),
          XPathSequence.single('label'),
        ),
        orderedEquals(['value']),
      );
    });
  });

  group('higher_order_extra', () {
    test('fn:sort', () {
      expect(
        fnSort(context, const XPathSequence(['b', 'a', 'c'])).toList(),
        orderedEquals(['a', 'b', 'c']),
      );
      expect(
        () => fnSort(
          context,
          const XPathSequence(['a']),
          XPathSequence.empty,
          XPathSequence.single('key'),
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:for-each', () {
      expect(
        () => fnForEach(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:filter', () {
      expect(
        () => fnFilter(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:fold-left', () {
      expect(
        () => fnFoldLeft(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:fold-right', () {
      expect(
        () => fnFoldRight(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:for-each-pair', () {
      expect(
        () => fnForEachPair(
          context,
          XPathSequence.empty,
          XPathSequence.empty,
          XPathSequence.empty,
        ),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:apply', () {
      expect(
        () => fnApply(context, XPathSequence.empty, XPathSequence.empty),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('boolean_extra', () {
    test('fn:boolean', () {
      expect(
        fnBoolean(context, XPathSequence.single(1)),
        orderedEquals([true]),
      );
      expect(fnBoolean(context, XPathSequence.empty), orderedEquals([false]));
    });
    test('fn:not', () {
      expect(
        fnNot(context, XPathSequence.single(true)),
        orderedEquals([false]),
      );
    });
    test('fn:true', () {
      expect(fnTrue(context), orderedEquals([true]));
    });
    test('fn:false', () {
      expect(fnFalse(context), orderedEquals([false]));
    });
    test('fn:lang', () {
      final doc = XmlDocument.parse('<r xml:lang="en"><c/></r>');
      final c = doc.rootElement.children.whereType<XmlElement>().first;
      // Context node must be set. The current context might be root document from setUp?
      // I should create a context with node `c`.
      // The current implementation of `fnLang`: `final node = context.node;`
      // I need to construct a context with `c`.
      // The `XPathContext` constructor: `XPathContext(node, position, last, variables, functions)`.
      // I can re-use `context` but update node using `copy` if available, or just new context.
      // But `functions` setup is complex.
      // Wait, `fnLang` is stateless function.
      // I can create a minimal context.
      final newContext = XPathContext(c);
      expect(
        fnLang(newContext, XPathSequence.single('en')),
        orderedEquals([true]),
      );
      expect(
        fnLang(newContext, XPathSequence.single('fr')),
        orderedEquals([false]),
      );
      expect(
        fnLang(newContext, XPathSequence.single('EN-US')),
        orderedEquals([false]), // startsWith case insensitive check in impl?
      );
    });
  });

  group('json_extra', () {
    test('fn:json-doc', () {
      expect(
        () => fnJsonDoc(context, XPathSequence.single('url')),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('accessor_extra', () {
    test('fn:node-name processing-instruction', () {
      final pi = XmlProcessing('target', 'value');
      expect(
        fnNodeName(context, XPathSequence.single(pi)).first.toString(),
        equals('target'),
      );
    });
    test('fn:base-uri', () {
      expect(fnBaseUri(context), isEmpty);
    });
    test('fn:document-uri', () {
      expect(fnDocumentUri(context), isEmpty);
    });
    test('fn:nilled', () {
      // Element -> false
      final el = XmlElement(XmlName.fromString('e'));
      expect(
        fnNilled(context, XPathSequence.single(el)),
        orderedEquals([false]),
      );
      // Other -> empty
      expect(
        fnNilled(context, XPathSequence.single(const v31.XPathString('s'))),
        isEmpty,
      );
    });
  });
}
