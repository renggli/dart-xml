import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  group('Atomization Semantics & Invariants', () {
    test(
      'empty sequence atomize yields empty iterable with zero allocations',
      () {
        const empty = XPathSequence.empty;
        final atomized = empty.atomize();
        expect(atomized.isEmpty, isTrue);
        expect(atomized.toList(), isEmpty);
      },
    );

    test(
      'sequence of empty arrays atomizes to empty iterable with isEmpty true',
      () {
        const emptyArr = XPathArray([]);
        final seq = XPathSequence([emptyArr, emptyArr]);
        final atomized = seq.atomize();
        expect(atomized.isEmpty, isTrue);
        expect(atomized.isNotEmpty, isFalse);
        expect(atomized.toList(), isEmpty);
        expect(atomized.length, equals(0));
        expect(atomized.iterator.moveNext(), isFalse);
      },
    );

    test(
      'sequence with mixture of empty arrays and items atomizes correctly',
      () {
        const emptyArr = XPathArray([]);
        final item = XPathInteger.fromInt(42);
        final seq = XPathSequence([emptyArr, item, emptyArr]);
        final atomized = seq.atomize();
        expect(atomized.isEmpty, isFalse);
        expect(atomized.isNotEmpty, isTrue);
        expect(atomized.toList(), equals([item]));
      },
    );

    test('single sequence of atomic returns self or equivalent atomic', () {
      final i = XPathInteger.fromInt(42);
      final s = XPathSequence.single(i);
      final singleAtomized = s.atomize();
      expect(singleAtomized.isNotEmpty, isTrue);
      expect(singleAtomized.last, same(i));
      expect(singleAtomized.single, same(i));
      expect(singleAtomized.elementAt(0), same(i));
      expect(() => singleAtomized.elementAt(1), throwsRangeError);
      expect(singleAtomized.contains(i), isTrue);
      expect(singleAtomized.contains(XPathInteger.fromInt(99)), isFalse);

      final atomized = singleAtomized.toList();
      expect(atomized.length, equals(1));
      expect(atomized.first, same(i));

      const str = XPathString('hello');
      const sStr = XPathSequence.single(str);
      expect(sStr.atomize().first, same(str));

      const b = XPathBoolean.trueInstance;
      const sBool = XPathSequence.single(b);
      expect(sBool.atomize().first, same(b));

      const d = XPathDouble(3.14);
      const sDouble = XPathSequence.single(d);
      expect(sDouble.atomize().first, same(d));
    });

    test('single sequence of element node produces single untypedAtomic', () {
      final doc = XmlDocument.parse(
        '<p>Hello <b>world</b> and <i>more</i></p>',
      );
      final elem = doc.rootElement;
      final atomized = XPathSequence.single(XPathNode(elem)).atomize().toList();
      expect(atomized.length, equals(1));
      expect(atomized.first, isA<XPathUntypedAtomic>());
      expect(atomized.first.stringValue, equals('Hello world and more'));
    });

    test('empty element node produces untypedAtomic with empty string', () {
      final doc = XmlDocument.parse('<empty/>');
      final atomized = XPathSequence.single(XPathNode(doc.rootElement))
          .atomize()
          .toList();
      expect(atomized.length, equals(1));
      expect(atomized.first, isA<XPathUntypedAtomic>());
      expect(atomized.first.stringValue, equals(''));
    });

    test('attribute and text nodes atomize to untypedAtomic', () {
      final doc = XmlDocument.parse('<root attr="test">content</root>');
      final attr = doc.rootElement.attributes.first;
      final text = doc.rootElement.children.first;

      final attrAtom = XPathSequence.single(XPathNode(attr)).atomize().first;
      expect(attrAtom, isA<XPathUntypedAtomic>());
      expect(attrAtom.stringValue, equals('test'));

      final textAtom = XPathSequence.single(XPathNode(text)).atomize().first;
      expect(textAtom, isA<XPathUntypedAtomic>());
      expect(textAtom.stringValue, equals('content'));
    });

    test('range sequence atomization yields sequence of XPathInteger', () {
      final range = XPathSequence.range(
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(3),
      );
      final atomized = range.atomize().toList();
      expect(atomized.length, equals(3));
      expect(atomized[0], equals(XPathInteger.fromInt(1)));
      expect(atomized[1], equals(XPathInteger.fromInt(2)));
      expect(atomized[2], equals(XPathInteger.fromInt(3)));
    });

    test('nested array atomization recursively flattens', () {
      final arr = XPathArray([
        XPathSequence([
          XPathArray([XPathSequence.single(XPathInteger.fromInt(1))]),
          XPathInteger.fromInt(2),
        ]),
        XPathSequence.single(XPathInteger.fromInt(3)),
      ]);
      final atomized = XPathSequence.single(arr).atomize().toList();
      expect(atomized.map((a) => a.toValue()).toList(), equals([1, 2, 3]));
    });

    test('map and function item atomization throws FOTY0013', () {
      final map = XPathMap({const XPathString('k'): seq(1)});
      expect(
        () => XPathSequence.single(map).atomize().toList(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOTY0013)),
      );

      XPathSequence dummy(XPathContext c, List<XPathSequence> a) =>
          XPathSequence.empty;
      final fn = dummy.toXPathFunction();
      expect(
        () => XPathSequence.single(fn).atomize().toList(),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FOTY0013)),
      );
    });
  });

  group('General Comparison Fast Paths (1-vs-1)', () {
    test('opGeneralEqual 1-vs-1 identical and different types', () {
      expect(opGeneralEqual(seq(42), seq(42)), XPathSequence.trueSequence);
      expect(opGeneralEqual(seq(42), seq(43)), XPathSequence.falseSequence);
      expect(opGeneralEqual(seq(42), seq(42.0)), XPathSequence.trueSequence);
      expect(
        opGeneralEqual(seq('abc'), seq('abc')),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(seq('abc'), seq('def')),
        XPathSequence.falseSequence,
      );
      expect(opGeneralEqual(seq(true), seq(true)), XPathSequence.trueSequence);
      expect(
        opGeneralEqual(seq(true), seq(false)),
        XPathSequence.falseSequence,
      );
    });

    test('opGeneralNotEqual 1-vs-1', () {
      expect(opGeneralNotEqual(seq(42), seq(42)), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(seq(42), seq(43)), XPathSequence.trueSequence);
      expect(
        opGeneralNotEqual(seq('a'), seq('a')),
        XPathSequence.falseSequence,
      );
      expect(opGeneralNotEqual(seq('a'), seq('b')), XPathSequence.trueSequence);
    });

    test('opGeneralLessThan and opGeneralLessThanOrEqual 1-vs-1', () {
      expect(opGeneralLessThan(seq(1), seq(2)), XPathSequence.trueSequence);
      expect(opGeneralLessThan(seq(2), seq(1)), XPathSequence.falseSequence);
      expect(opGeneralLessThan(seq(2), seq(2)), XPathSequence.falseSequence);

      expect(
        opGeneralLessThanOrEqual(seq(1), seq(2)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThanOrEqual(seq(2), seq(2)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThanOrEqual(seq(3), seq(2)),
        XPathSequence.falseSequence,
      );

      expect(opGeneralLessThan(seq('a'), seq('b')), XPathSequence.trueSequence);
      expect(
        opGeneralLessThan(seq('b'), seq('a')),
        XPathSequence.falseSequence,
      );
    });

    test('opGeneralGreaterThan and opGeneralGreaterThanOrEqual 1-vs-1', () {
      expect(opGeneralGreaterThan(seq(2), seq(1)), XPathSequence.trueSequence);
      expect(opGeneralGreaterThan(seq(1), seq(2)), XPathSequence.falseSequence);
      expect(opGeneralGreaterThan(seq(2), seq(2)), XPathSequence.falseSequence);

      expect(
        opGeneralGreaterThanOrEqual(seq(2), seq(1)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralGreaterThanOrEqual(seq(2), seq(2)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralGreaterThanOrEqual(seq(1), seq(2)),
        XPathSequence.falseSequence,
      );
    });
  });

  group('Untyped Atomic Conversions', () {
    test('untyped vs numeric converts untyped to xsDouble', () {
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('100')), seq(100)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('0100')), seq(100)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('100.5')), seq(100.5)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThan(seq(const XPathUntypedAtomic('99')), seq(100)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralGreaterThan(seq(const XPathUntypedAtomic('101')), seq(100)),
        XPathSequence.trueSequence,
      );
    });

    test('invalid untyped string to numeric throws FORG0001', () {
      expect(
        () =>
            opGeneralEqual(seq(const XPathUntypedAtomic('not_num')), seq(100)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001)),
      );
      expect(
        () => opGeneralLessThan(
          seq(const XPathUntypedAtomic('not_num')),
          seq(100),
        ),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001)),
      );
    });

    test('untyped vs untyped strictly performs string comparison', () {
      expect(
        opGeneralEqual(
          seq(const XPathUntypedAtomic('01')),
          seq(const XPathUntypedAtomic('1')),
        ),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralEqual(
          seq(const XPathUntypedAtomic('1')),
          seq(const XPathUntypedAtomic('1')),
        ),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThan(
          seq(const XPathUntypedAtomic('10')),
          seq(const XPathUntypedAtomic('2')),
        ),
        XPathSequence.trueSequence, // '10' < '2' in ASCII lexicographical order
      );
    });

    test('untyped vs string or anyURI compares as string', () {
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('foo')), seq('foo')),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThan(seq(const XPathUntypedAtomic('bar')), seq('foo')),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(
          seq(const XPathUntypedAtomic('http://x')),
          seq(const XPathAnyUri('http://x')),
        ),
        XPathSequence.trueSequence,
      );
    });

    test('untyped vs boolean converts to boolean', () {
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('true')), seq(true)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('false')), seq(false)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(seq(const XPathUntypedAtomic('1')), seq(true)),
        XPathSequence.trueSequence,
      );
      expect(
        () => opGeneralEqual(seq(const XPathUntypedAtomic('yes')), seq(true)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001)),
      );
    });
  });

  group('Empty Sequence Divergence (General vs Value)', () {
    test('general comparisons with empty sequence return falseSequence', () {
      expect(
        opGeneralEqual(XPathSequence.empty, seq(1)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralEqual(seq(1), XPathSequence.empty),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralEqual(XPathSequence.empty, XPathSequence.empty),
        XPathSequence.falseSequence,
      );

      expect(
        opGeneralNotEqual(XPathSequence.empty, seq(1)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralNotEqual(seq(1), XPathSequence.empty),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralNotEqual(XPathSequence.empty, XPathSequence.empty),
        XPathSequence.falseSequence,
      );

      expect(
        opGeneralLessThan(XPathSequence.empty, seq(1)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralGreaterThan(XPathSequence.empty, seq(1)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralLessThanOrEqual(XPathSequence.empty, seq(1)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralGreaterThanOrEqual(XPathSequence.empty, seq(1)),
        XPathSequence.falseSequence,
      );
    });

    test('value comparisons with empty sequence return empty sequence', () {
      expect(opValueEqual(XPathSequence.empty, seq(1)), XPathSequence.empty);
      expect(opValueEqual(seq(1), XPathSequence.empty), XPathSequence.empty);
      expect(
        opValueEqual(XPathSequence.empty, XPathSequence.empty),
        XPathSequence.empty,
      );

      expect(opValueNotEqual(XPathSequence.empty, seq(1)), XPathSequence.empty);
      expect(opValueLessThan(XPathSequence.empty, seq(1)), XPathSequence.empty);
      expect(
        opValueGreaterThan(XPathSequence.empty, seq(1)),
        XPathSequence.empty,
      );
      expect(
        opValueLessThanOrEqual(XPathSequence.empty, seq(1)),
        XPathSequence.empty,
      );
      expect(
        opValueGreaterThanOrEqual(XPathSequence.empty, seq(1)),
        XPathSequence.empty,
      );
    });
  });

  group('Multi-Item Existential Semantics', () {
    test('overlapping sequence comparison', () {
      expect(
        opGeneralEqual(seq([1, 2]), seq([2, 3])),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralEqual(seq([1, 2]), seq([3, 4])),
        XPathSequence.falseSequence,
      );
    });

    test('asymmetric != semantics', () {
      expect(
        opGeneralNotEqual(seq([1, 2]), seq([2, 3])),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralNotEqual(seq([1, 2]), seq(1)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralNotEqual(seq(1), seq([1, 2])),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralNotEqual(seq([1, 1]), seq(1)),
        XPathSequence.falseSequence,
      );
    });

    test('multi-item order comparison', () {
      expect(
        opGeneralLessThan(seq([5, 1]), seq([2, 0])),
        XPathSequence.trueSequence,
      ); // 1 < 2
      expect(
        opGeneralGreaterThan(seq([1, 2]), seq([5, 6])),
        XPathSequence.falseSequence,
      );
    });
  });

  group('Type Incompatibility & Error Handling', () {
    test('incompatible types in general comparison throw XPTY0004', () {
      expect(
        () => opGeneralEqual(seq(1), seq('1')),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralNotEqual(seq(1), seq('1')),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralEqual(seq(true), seq(1)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('ordering on QNames throws XPTY0004', () {
      const q1 = XPathQName(XmlName('a'));
      const q2 = XPathQName(XmlName('b'));
      expect(
        () => opGeneralLessThan(seq(q1), seq(q2)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opGeneralGreaterThan(seq(q1), seq(q2)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      // Equality is permitted
      expect(opGeneralEqual(seq(q1), seq(q1)), XPathSequence.trueSequence);
      expect(opGeneralEqual(seq(q1), seq(q2)), XPathSequence.falseSequence);
    });

    test('value comparison with > 1 items throws XPTY0004', () {
      expect(
        () => opValueEqual(seq([1, 2]), seq(1)),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => opValueEqual(seq(1), seq([1, 2])),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('NaN general comparisons return expected IEEE 754 results', () {
      expect(
        opGeneralEqual(seq(double.nan), seq(double.nan)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralNotEqual(seq(double.nan), seq(double.nan)),
        XPathSequence.trueSequence,
      );
      expect(
        opGeneralLessThan(seq(double.nan), seq(1.0)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralGreaterThan(seq(double.nan), seq(1.0)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralLessThanOrEqual(seq(double.nan), seq(1.0)),
        XPathSequence.falseSequence,
      );
      expect(
        opGeneralGreaterThanOrEqual(seq(double.nan), seq(1.0)),
        XPathSequence.falseSequence,
      );
    });
  });

  group('End-to-End XML DOM XPath Queries', () {
    const xml = '''
<catalog>
  <item id="100" active="true" price="29.99">
    <title>Widget Alpha</title>
    <tag>electronics</tag>
    <tag>sale</tag>
  </item>
  <item id="200" active="false" price="99.50">
    <title>Widget Beta</title>
    <tag>appliances</tag>
  </item>
  <item id="300" price="15.00">
    <title>Widget Gamma</title>
    <tag>sale</tag>
  </item>
  <item id="0400" active="true" price="5.00">
    <title>Widget Delta</title>
  </item>
</catalog>''';
    final doc = XmlDocument.parse(xml);
    final items = doc.findAllElements('item').toList();
    final item1 = items[0];
    final item2 = items[1];
    final item3 = items[2];
    final item4 = items[3];

    test('numeric attribute matching with untyped atomic coercion', () {
      expectXPath(doc, '//item[@id = 100]', [item1]);
      expectXPath(doc, '//item[@id = 400]', [item4]);
      expectXPath(doc, '//item[@price > 50]', [item2]);
      expectXPath(doc, '//item[@price <= 15.00]', [item3, item4]);
    });

    test('string title matching', () {
      expectXPath(doc, '//item[title = "Widget Gamma"]', [item3]);
      expectXPath(doc, '//item[title != "Widget Gamma"]', [
        item1,
        item2,
        item4,
      ]);
    });

    test('existential child tag matching', () {
      expectXPath(doc, '//item[tag = "sale"]', [item1, item3]);
      expectXPath(doc, '//item[tag != "sale"]', [item1, item2]);
    });

    test('missing attribute returns empty sequence which evaluates to false in predicate', () {
      expectXPath(doc, '//item[@missing = 100]', <String>[]);
      expectXPath(doc, '//item[@missing != 100]', <String>[]);
    });
  });
}
