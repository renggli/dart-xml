import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

void main() {
  group('XPathSequence', () {
    test('empty sequence constants and properties', () {
      const empty = XPathSequence.empty;
      check(empty.isEmpty).isTrue();
      check(empty.isNotEmpty).isFalse();
      check(empty.length).equals(0);
      check(empty.singleOrNull).isNull();
      check(empty.ebv).isFalse();
      check(empty.effectiveBooleanValue).isFalse();
      check(empty.hasCardinality(XPathCardinality.zeroOrMore)).isTrue();
      check(empty.hasCardinality(XPathCardinality.zeroOrOne)).isTrue();
      check(empty.hasCardinality(XPathCardinality.oneOrMore)).isFalse();
      check(empty.hasCardinality(XPathCardinality.exactlyOne)).isFalse();
      check(empty.toString()).equals('()');
      check(empty.nodes).isEmpty();
      check(empty.atomize()).isEmpty();
    });

    test('single sequence properties', () {
      const item = XPathString('test');
      const seq = XPathSequence.single(item);
      check(seq.isEmpty).isFalse();
      check(seq.isNotEmpty).isTrue();
      check(seq.length).equals(1);
      check(seq.singleOrNull).equals(item);
      check(seq.ebv).isTrue();
      check(seq.effectiveBooleanValue).isTrue();
      check(seq.hasCardinality(XPathCardinality.zeroOrMore)).isTrue();
      check(seq.hasCardinality(XPathCardinality.zeroOrOne)).isTrue();
      check(seq.hasCardinality(XPathCardinality.oneOrMore)).isTrue();
      check(seq.hasCardinality(XPathCardinality.exactlyOne)).isTrue();
      check(seq.toString()).equals('(test)');
      check(seq.atomize()).deepEquals([item]);
    });

    test('singletons', () {
      check(XPathSequence.trueSequence.ebv).isTrue();
      check(XPathSequence.falseSequence.ebv).isFalse();
      check(XPathSequence.emptyMap.singleOrNull).equals(XPathMap.empty);
      check(XPathSequence.emptyArray.singleOrNull).equals(XPathArray.empty);
    });

    test('factory([items]) creates empty, single, or list sequence', () {
      check(XPathSequence()).identicalTo(XPathSequence.empty);
      check(XPathSequence([])).identicalTo(XPathSequence.empty);
      final single = XPathSequence([const XPathString('a')]);
      check(single.length).equals(1);
      final multi = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      check(multi.length).equals(2);
      check(multi.toString()).equals('(a, b)');
      check(multi.singleOrNull).isNull();
    });

    test('from(items) flattens nested sequences and converts primitives', () {
      final el = XmlElement(const XmlName.qualified('x'));
      final seq = XPathSequence.from([
        1,
        'str',
        true,
        BigInt.from(5),
        2.5,
        el,
        null,
        [const XPathString('nested')],
        XPathSequence([const XPathString('inner')]),
      ]);
      check(seq.length).equals(8);
      check(seq.nodes).deepEquals([el]);
      check(seq.atomize().map((a) => a.stringValue).toList())
          .deepEquals(['1', 'str', 'true', '5', '2.5', '', 'nested', 'inner']);
    });

    test('toItem converts types or throws', () {
      check(XPathSequence.toItem(42)).equals(XPathInteger.fromInt(42));
      check(XPathSequence.toItem(BigInt.from(42)))
          .equals(XPathInteger.fromInt(42));
      check(XPathSequence.toItem(3.14)).equals(const XPathDouble(3.14));
      check(XPathSequence.toItem('hi')).equals(const XPathString('hi'));
      check(XPathSequence.toItem(true)).equals(XPathBoolean.trueInstance);
      final el = XmlElement(const XmlName.qualified('a'));
      check(XPathSequence.toItem(el)).equals(XPathNode(el));
      check(XPathSequence.toItem(const XPathString('item')))
          .equals(const XPathString('item'));
      check(() => XPathSequence.toItem(Object()))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('range sequence', () {
      final r = XPathSequence.range(
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(3),
      );
      check(r.length).equals(3);
      check(r.toList().map((i) => (i as XPathInteger).value.toInt()).toList())
          .deepEquals([1, 2, 3]);
      check(r.isEmpty).isFalse();
      check(r.isNotEmpty).isTrue();

      final rEmpty = XPathSequence.range(
        XPathInteger.fromInt(5),
        XPathInteger.fromInt(3),
      );
      check(rEmpty).identicalTo(XPathSequence.empty);

      final rSingle = XPathSequence.range(
        XPathInteger.fromInt(5),
        XPathInteger.fromInt(5),
      );
      check(rSingle.singleOrNull).equals(XPathInteger.fromInt(5));
      check(r.singleOrNull).isNull();

      check(
        () => XPathSequence.range(
          XPathInteger.fromInt(1),
          XPathInteger.fromInt(20000000),
        ),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('atomize flattens arrays', () {
      const arr = XPathArray([
        XPathSequence.single(XPathString('a')),
        XPathSequence.single(XPathString('b')),
      ]);
      final seq = XPathSequence([arr, const XPathString('c')]);
      check(seq.atomize().map((a) => a.stringValue).toList())
          .deepEquals(['a', 'b', 'c']);
    });

    test('ebv with node sequence and multi-item error', () {
      final node = XPathNode(XmlElement(const XmlName.qualified('a')));
      final nodeSeq = XPathSequence([node, node]);
      check(nodeSeq.ebv).isTrue();

      final strSeq = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      check(() => strSeq.ebv)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('cardinality checks for multi-item sequence', () {
      final multi = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      check(multi.hasCardinality(XPathCardinality.zeroOrMore)).isTrue();
      check(multi.hasCardinality(XPathCardinality.oneOrMore)).isTrue();
      check(multi.hasCardinality(XPathCardinality.zeroOrOne)).isFalse();
      check(multi.hasCardinality(XPathCardinality.exactlyOne)).isFalse();
    });

    test('equality and hashCode', () {
      final s1 = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      final s2 = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      final s3 = XPathSequence([const XPathString('a')]);
      final s4 = XPathSequence([
        const XPathString('a'),
        const XPathString('c'),
      ]);

      check(s1).equals(s2);
      check(s1.hashCode).equals(s2.hashCode);
      check(s1 == s3).isFalse();
      check(s1 == s4).isFalse();
      check(s1 == Object()).isFalse();
    });

    test('fromObject converts various types', () {
      check(XPathSequence.fromObject(null)).identicalTo(XPathSequence.empty);
      check(XPathSequence.fromObject(XPathSequence.empty))
          .identicalTo(XPathSequence.empty);
      check(XPathSequence.fromObject(42).toValue()).equals(42);
      check(XPathSequence.fromObject('hello').toValue()).equals('hello');
      check(XPathSequence.fromObject(true).toValue()).equals(true);
      check(XPathSequence.fromObject([1, 2, 3]).toValue())
          .isA<Iterable<dynamic>>()
          .deepEquals([1, 2, 3]);
      check(XPathSequence.fromObject({'a': 1, 'b': 2}).toValue())
          .isA<Map<dynamic, dynamic>>()
          .deepEquals({'a': 1, 'b': 2});
      final now = DateTime.utc(2025, 1, 1);
      check(XPathSequence.fromObject(now).toValue()).equals(now);
      const dur = Duration(seconds: 30);
      check(XPathSequence.fromObject(dur).toValue()).equals(dur);
    });

    test('toValue unwraps empty, single, and multiple items', () {
      check(XPathSequence.empty.toValue()).isNull();
      check(const XPathSequence.single(XPathString('abc')).toValue())
          .equals('abc');
      check(
        XPathSequence([const XPathString('a'), XPathInteger.fromInt(1)])
            .toValue(),
      ).isA<Iterable<dynamic>>().deepEquals(['a', 1]);
    });

    test('ebv on single-element range sequence', () {
      final range = XPathSequence.range(
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(1),
      );
      check(range.ebv).isTrue();
      final rangeZero = XPathSequence.range(
        XPathInteger.fromInt(0),
        XPathInteger.fromInt(0),
      );
      check(rangeZero.ebv).isFalse();
    });
  });
}
