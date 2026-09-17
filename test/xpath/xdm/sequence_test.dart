import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/functions/array.dart';
import 'package:xml/src/xpath/xdm/functions/map.dart';
import 'package:xml/src/xpath/xdm/item.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  group('XPathSequence', () {
    test('empty sequence constants and properties', () {
      const empty = XPathSequence.empty;
      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);
      expect(empty.length, equals(0));
      expect(empty.singleOrNull, isNull);
      expect(empty.ebv, isFalse);
      expect(empty.effectiveBooleanValue, isFalse);
      expect(empty.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(empty.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(empty.hasCardinality(XPathCardinality.oneOrMore), isFalse);
      expect(empty.hasCardinality(XPathCardinality.exactlyOne), isFalse);
      expect(empty.toString(), equals('()'));
      expect(empty.nodes, isEmpty);
      expect(empty.atomize(), isEmpty);
    });

    test('single sequence properties', () {
      const item = XPathString('test');
      const seq = XPathSequence.single(item);
      expect(seq.isEmpty, isFalse);
      expect(seq.isNotEmpty, isTrue);
      expect(seq.length, equals(1));
      expect(seq.singleOrNull, equals(item));
      expect(seq.ebv, isTrue);
      expect(seq.effectiveBooleanValue, isTrue);
      expect(seq.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(seq.hasCardinality(XPathCardinality.zeroOrOne), isTrue);
      expect(seq.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(seq.hasCardinality(XPathCardinality.exactlyOne), isTrue);
      expect(seq.toString(), equals('(test)'));
      expect(seq.atomize(), equals([item]));
    });

    test('singletons', () {
      expect(XPathSequence.trueSequence.ebv, isTrue);
      expect(XPathSequence.falseSequence.ebv, isFalse);
      expect(XPathSequence.emptyMap.singleOrNull, equals(XPathMap.empty));
      expect(XPathSequence.emptyArray.singleOrNull, equals(XPathArray.empty));
    });

    test('factory([items]) creates empty, single, or list sequence', () {
      expect(XPathSequence(), same(XPathSequence.empty));
      expect(XPathSequence([]), same(XPathSequence.empty));
      final single = XPathSequence([const XPathString('a')]);
      expect(single.length, equals(1));
      final multi = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      expect(multi.length, equals(2));
      expect(multi.toString(), equals('(a, b)'));
      expect(multi.singleOrNull, isNull);
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
      expect(seq.length, equals(8));
      expect(seq.nodes, equals([el]));
      expect(
        seq.atomize().map((a) => a.stringValue).toList(),
        equals(['1', 'str', 'true', '5', '2.5', '', 'nested', 'inner']),
      );
    });

    test('toItem converts types or throws', () {
      expect(XPathSequence.toItem(42), equals(XPathInteger.fromInt(42)));
      expect(
        XPathSequence.toItem(BigInt.from(42)),
        equals(XPathInteger.fromInt(42)),
      );
      expect(XPathSequence.toItem(3.14), equals(const XPathDouble(3.14)));
      expect(XPathSequence.toItem('hi'), equals(const XPathString('hi')));
      expect(XPathSequence.toItem(true), equals(XPathBoolean.trueInstance));
      final el = XmlElement(const XmlName.qualified('a'));
      expect(XPathSequence.toItem(el), equals(XPathNode(el)));
      expect(
        XPathSequence.toItem(const XPathString('item')),
        equals(const XPathString('item')),
      );
      expect(
        () => XPathSequence.toItem(Object()),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('cached sequence memoizes traversal', () {
      var counter = 0;
      final iterable = Iterable<XPathItem>.generate(3, (i) {
        counter++;
        return XPathInteger.fromInt(i);
      });
      final cached = XPathSequence.cached(iterable);
      expect(counter, equals(0));
      expect(cached.toList().length, equals(3));
      expect(counter, equals(3));
      expect(cached.toList().length, equals(3));
      expect(counter, equals(3));
    });

    test('range sequence', () {
      final r = XPathSequence.range(
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(3),
      );
      expect(r.length, equals(3));
      expect(
        r.toList().map((i) => (i as XPathInteger).value.toInt()).toList(),
        equals([1, 2, 3]),
      );
      expect(r.isEmpty, isFalse);
      expect(r.isNotEmpty, isTrue);

      final rEmpty = XPathSequence.range(
        XPathInteger.fromInt(5),
        XPathInteger.fromInt(3),
      );
      expect(rEmpty, same(XPathSequence.empty));

      expect(
        () => XPathSequence.range(
          XPathInteger.fromInt(1),
          XPathInteger.fromInt(20000000),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('atomize flattens arrays', () {
      const arr = XPathArray([
        XPathSequence.single(XPathString('a')),
        XPathSequence.single(XPathString('b')),
      ]);
      final seq = XPathSequence([arr, const XPathString('c')]);
      expect(
        seq.atomize().map((a) => a.stringValue).toList(),
        equals(['a', 'b', 'c']),
      );
    });

    test('ebv with node sequence and multi-item error', () {
      final node = XPathNode(XmlElement(const XmlName.qualified('a')));
      final nodeSeq = XPathSequence([node, node]);
      expect(nodeSeq.ebv, isTrue);

      final strSeq = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      expect(() => strSeq.ebv, throwsA(isXPathEvaluationException()));
    });

    test('cardinality checks for multi-item sequence', () {
      final multi = XPathSequence([
        const XPathString('a'),
        const XPathString('b'),
      ]);
      expect(multi.hasCardinality(XPathCardinality.zeroOrMore), isTrue);
      expect(multi.hasCardinality(XPathCardinality.oneOrMore), isTrue);
      expect(multi.hasCardinality(XPathCardinality.zeroOrOne), isFalse);
      expect(multi.hasCardinality(XPathCardinality.exactlyOne), isFalse);
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

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1 == s3, isFalse);
      expect(s1 == s4, isFalse);
      expect(s1 == Object(), isFalse);
    });
  });
}
