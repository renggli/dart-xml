import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathMap', () {
    test('construction and basic properties', () {
      final map = XPathMap({
        const XPathString('a'): XPathSequence.single(XPathInteger.fromInt(1)),
        const XPathString('b'): XPathSequence.single(XPathInteger.fromInt(2)),
      });
      check(map.type).equals(xsMap);
      check(map.arity).equals(1);
      check(map.length).equals(2);
      check(map.isEmpty).isFalse();
      check(map.isNotEmpty).isTrue();
      check(map.keys.map((k) => k.stringValue).toSet()).deepEquals({'a', 'b'});
      check(map.get(const XPathString('a'))).isNotNull().isXPathSequence([1]);
      check(map.get(const XPathString('missing'))).isNull();
      check(map.toString()).contains('a: (1)');
    });

    test('empty map', () {
      const map = XPathMap.empty;
      check(map.isEmpty).isTrue();
      check(map.length).equals(0);
      check(map.toString()).equals('map{}');
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

      check(map(context, [const XPathSequence.single(XPathString('name'))]))
          .isXPathSequence(['Antigravity']);
      check(map(context, [XPathSequence.single(XPathInteger.fromInt(10))]))
          .isXPathSequence(['ten']);
      check(
        map(context, [const XPathSequence.single(XPathString('not-found'))]),
      ).isXPathSequence(isEmpty);

      check(() => map(context, [XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => map(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(
        () => map(context, [
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('sameKey logic for numeric equivalence and NaN', () {
      check(XPathMap.sameKey(XPathInteger.fromInt(1), const XPathDouble(1.0)))
          .isTrue();
      check(
        XPathMap.sameKey(
          const XPathDouble(double.nan),
          const XPathDouble(double.nan),
        ),
      ).isTrue();
      check(XPathMap.sameKey(const XPathString('x'), const XPathString('x')))
          .isTrue();
      check(XPathMap.sameKey(const XPathString('x'), const XPathString('y')))
          .isFalse();
    });

    test('keyHashCode is consistent with sameKey', () {
      final i1 = XPathInteger.fromInt(1);
      const d1 = XPathDouble(1.0);
      final dec1 = XPathDecimal.parse('1.0');
      check(XPathMap.keyHashCode(i1)).equals(XPathMap.keyHashCode(d1));
      check(XPathMap.keyHashCode(i1)).equals(XPathMap.keyHashCode(dec1));
      check(XPathMap.keyHashCode(const XPathDouble(double.nan)))
          .equals(XPathMap.keyHashCode(const XPathDouble(double.nan)));
    });

    test('createEntries creates a hash map adhering to sameKey', () {
      final entries = XPathMap.createEntries();
      entries[XPathInteger.fromInt(1)] = const XPathSequence.single(
        XPathString('one'),
      );
      entries[const XPathDouble(double.nan)] = const XPathSequence.single(
        XPathString('nan'),
      );

      check(entries[const XPathDouble(1.0)])
          .isNotNull()
          .isXPathSequence(['one']);
      check(entries[XPathDecimal.parse('1.0')])
          .isNotNull()
          .isXPathSequence(['one']);
      check(entries[const XPathDouble(double.nan)])
          .isNotNull()
          .isXPathSequence(['nan']);

      final map = XPathMap(entries);
      check(map.get(XPathDecimal.parse('1.0')))
          .isNotNull()
          .isXPathSequence(['one']);
      check(map.get(const XPathDouble(double.nan)))
          .isNotNull()
          .isXPathSequence(['nan']);
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

      check(m1).equals(m2);
      check(m1.hashCode).equals(m2.hashCode);
      check(m1 == m3).isFalse();
      check(m1 == m4).isFalse();
      check(m1 == Object()).isFalse();
    });
  });
}
