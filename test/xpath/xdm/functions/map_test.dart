import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/functions/map.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/src/xpath/xdm/types.dart';
import 'package:xml/xml.dart';

import '../../../utils/matchers.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathMap', () {
    test('construction and basic properties', () {
      final map = XPathMap({
        const XPathString('a'): XPathSequence.single(XPathInteger.fromInt(1)),
        const XPathString('b'): XPathSequence.single(XPathInteger.fromInt(2)),
      });
      expect(map.type, equals(xsMap));
      expect(map.arity, equals(1));
      expect(map.length, equals(2));
      expect(map.isEmpty, isFalse);
      expect(map.isNotEmpty, isTrue);
      expect(map.keys.map((k) => k.stringValue).toSet(), equals({'a', 'b'}));
      expect(map.get(const XPathString('a')), isXPathSequence([1]));
      expect(map.get(const XPathString('missing')), isNull);
      expect(map.toString(), contains('a: (1)'));
    });

    test('empty map', () {
      const map = XPathMap.empty;
      expect(map.isEmpty, isTrue);
      expect(map.length, equals(0));
      expect(map.toString(), equals('map{}'));
    });

    test('callable as function with key lookup', () {
      final map = XPathMap({
        const XPathString('name'): const XPathSequence.single(
          XPathString('Antigravity'),
        ),
        XPathInteger.fromInt(10): const XPathSequence.single(
          XPathString('ten'),
        ),
      });

      expect(
        map(context, [const XPathSequence.single(XPathString('name'))]),
        isXPathSequence(['Antigravity']),
      );
      expect(
        map(context, [XPathSequence.single(XPathInteger.fromInt(10))]),
        isXPathSequence(['ten']),
      );
      expect(
        map(context, [const XPathSequence.single(XPathString('not-found'))]),
        isXPathSequence(isEmpty),
      );

      expect(
        () => map(context, [XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
      expect(() => map(context, []), throwsA(isXPathEvaluationException()));
      expect(
        () => map(context, [
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('sameKey logic for numeric equivalence and NaN', () {
      expect(
        XPathMap.sameKey(XPathInteger.fromInt(1), const XPathDouble(1.0)),
        isTrue,
      );
      expect(
        XPathMap.sameKey(
          const XPathDouble(double.nan),
          const XPathDouble(double.nan),
        ),
        isTrue,
      );
      expect(
        XPathMap.sameKey(const XPathString('x'), const XPathString('x')),
        isTrue,
      );
      expect(
        XPathMap.sameKey(const XPathString('x'), const XPathString('y')),
        isFalse,
      );
    });

    test('equality and hashCode', () {
      final m1 = XPathMap({
        const XPathString('k'): XPathSequence.single(XPathInteger.fromInt(1)),
      });
      final m2 = XPathMap({
        const XPathString('k'): XPathSequence.single(XPathInteger.fromInt(1)),
      });
      final m3 = XPathMap({
        const XPathString('k'): XPathSequence.single(XPathInteger.fromInt(2)),
      });
      const m4 = XPathMap({});

      expect(m1, equals(m2));
      expect(m1.hashCode, equals(m2.hashCode));
      expect(m1 == m3, isFalse);
      expect(m1 == m4, isFalse);
      expect(m1 == Object(), isFalse);
    });
  });
}
