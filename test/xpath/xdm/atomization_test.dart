import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('Atomization Semantics & Invariants', () {
    test(
      'empty sequence atomize yields empty iterable with zero allocations',
      () {
        const empty = XPathSequence.empty;
        final atomized = empty.atomize();
        check(atomized.isEmpty).isTrue();
        check(atomized.toList()).isEmpty();
      },
    );

    test(
      'sequence of empty arrays atomizes to empty iterable with isEmpty true',
      () {
        const emptyArr = XPathArray([]);
        final seq = XPathSequence([emptyArr, emptyArr]);
        final atomized = seq.atomize();
        check(atomized.isEmpty).isTrue();
        check(atomized.isNotEmpty).isFalse();
        check(atomized.toList()).isEmpty();
        check(atomized.length).equals(0);
        check(atomized.iterator.moveNext()).isFalse();
      },
    );

    test(
      'sequence with mixture of empty arrays and items atomizes correctly',
      () {
        const emptyArr = XPathArray([]);
        final item = XPathInteger.fromInt(42);
        final seq = XPathSequence([emptyArr, item, emptyArr]);
        final atomized = seq.atomize();
        check(atomized.isEmpty).isFalse();
        check(atomized.isNotEmpty).isTrue();
        check(atomized.toList()).deepEquals([item]);
      },
    );

    test('single sequence of atomic returns self or equivalent atomic', () {
      final i = XPathInteger.fromInt(42);
      final s = XPathSequence.single(i);
      final singleAtomized = s.atomize();
      check(singleAtomized.isNotEmpty).isTrue();
      check(singleAtomized.last).identicalTo(i);
      check(singleAtomized.single).identicalTo(i);
      check(singleAtomized.elementAt(0)).identicalTo(i);
      check(() => singleAtomized.elementAt(1)).throws<RangeError>();
      check(singleAtomized.contains(i)).isTrue();
      check(singleAtomized.contains(XPathInteger.fromInt(99))).isFalse();

      final atomized = singleAtomized.toList();
      check(atomized.length).equals(1);
      check(atomized.first).identicalTo(i);

      const str = XPathString('hello');
      const sStr = XPathSequence.single(str);
      check(sStr.atomize().first).identicalTo(str);

      const b = XPathBoolean.trueInstance;
      const sBool = XPathSequence.single(b);
      check(sBool.atomize().first).identicalTo(b);

      const d = XPathDouble(3.14);
      const sDouble = XPathSequence.single(d);
      check(sDouble.atomize().first).identicalTo(d);
    });

    test('single sequence of element node produces single untypedAtomic', () {
      final doc = XmlDocument.parse(
        '<p>Hello <b>world</b> and <i>more</i></p>',
      );
      final elem = doc.rootElement;
      final atomized = XPathSequence.single(XPathNode(elem)).atomize().toList();
      check(atomized.length).equals(1);
      check(atomized.first).isA<XPathUntypedAtomic>();
      check(atomized.first.stringValue).equals('Hello world and more');
    });

    test('empty element node produces untypedAtomic with empty string', () {
      final doc = XmlDocument.parse('<empty/>');
      final atomized = XPathSequence.single(XPathNode(doc.rootElement))
          .atomize()
          .toList();
      check(atomized.length).equals(1);
      check(atomized.first).isA<XPathUntypedAtomic>();
      check(atomized.first.stringValue).equals('');
    });

    test('attribute and text nodes atomize to untypedAtomic', () {
      final doc = XmlDocument.parse('<root attr="test">content</root>');
      final attr = doc.rootElement.attributes.first;
      final text = doc.rootElement.children.first;

      final attrAtom = XPathSequence.single(XPathNode(attr)).atomize().first;
      check(attrAtom).isA<XPathUntypedAtomic>();
      check(attrAtom.stringValue).equals('test');

      final textAtom = XPathSequence.single(XPathNode(text)).atomize().first;
      check(textAtom).isA<XPathUntypedAtomic>();
      check(textAtom.stringValue).equals('content');
    });

    test('range sequence atomization yields sequence of XPathInteger', () {
      final range = XPathSequence.range(
        XPathInteger.fromInt(1),
        XPathInteger.fromInt(3),
      );
      final atomized = range.atomize().toList();
      check(atomized.length).equals(3);
      check(atomized[0]).equals(XPathInteger.fromInt(1));
      check(atomized[1]).equals(XPathInteger.fromInt(2));
      check(atomized[2]).equals(XPathInteger.fromInt(3));
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
      check(atomized.map((a) => a.toValue()).toList()).deepEquals([1, 2, 3]);
    });

    test('map and function item atomization throws FOTY0013', () {
      final map = XPathMap({const XPathString('k'): seq(1)});
      check(() => XPathSequence.single(map).atomize().toList())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOTY0013),
          );

      XPathSequence dummy(XPathContext c, List<XPathSequence> a) =>
          XPathSequence.empty;
      final fn = dummy.toXPathFunction();
      check(() => XPathSequence.single(fn).atomize().toList())
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOTY0013),
          );
    });
  });

  group('General Comparison Fast Paths (1-vs-1)', () {
    test('opGeneralEqual 1-vs-1 identical and different types', () {
      check(opGeneralEqual(seq(42), seq(42)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(42), seq(43)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralEqual(seq(42), seq(42.0)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq('abc'), seq('abc')))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq('abc'), seq('def')))
          .equals(XPathSequence.falseSequence);
      check(opGeneralEqual(seq(true), seq(true)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(true), seq(false)))
          .equals(XPathSequence.falseSequence);
    });

    test('opGeneralNotEqual 1-vs-1', () {
      check(opGeneralNotEqual(seq(42), seq(42)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(seq(42), seq(43)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(seq('a'), seq('a')))
          .equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(seq('a'), seq('b')))
          .equals(XPathSequence.trueSequence);
    });

    test('opGeneralLessThan and opGeneralLessThanOrEqual 1-vs-1', () {
      check(opGeneralLessThan(seq(1), seq(2)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(seq(2), seq(1)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralLessThan(seq(2), seq(2)))
          .equals(XPathSequence.falseSequence);

      check(opGeneralLessThanOrEqual(seq(1), seq(2)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThanOrEqual(seq(2), seq(2)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThanOrEqual(seq(3), seq(2)))
          .equals(XPathSequence.falseSequence);

      check(opGeneralLessThan(seq('a'), seq('b')))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(seq('b'), seq('a')))
          .equals(XPathSequence.falseSequence);
    });

    test('opGeneralGreaterThan and opGeneralGreaterThanOrEqual 1-vs-1', () {
      check(opGeneralGreaterThan(seq(2), seq(1)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralGreaterThan(seq(1), seq(2)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralGreaterThan(seq(2), seq(2)))
          .equals(XPathSequence.falseSequence);

      check(opGeneralGreaterThanOrEqual(seq(2), seq(1)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralGreaterThanOrEqual(seq(2), seq(2)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralGreaterThanOrEqual(seq(1), seq(2)))
          .equals(XPathSequence.falseSequence);
    });
  });

  group('Untyped Atomic Conversions', () {
    test('untyped vs numeric converts untyped to xsDouble', () {
      check(opGeneralEqual(seq(const XPathUntypedAtomic('100')), seq(100)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(const XPathUntypedAtomic('0100')), seq(100)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(const XPathUntypedAtomic('100.5')), seq(100.5)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(seq(const XPathUntypedAtomic('99')), seq(100)))
          .equals(XPathSequence.trueSequence);
      check(
        opGeneralGreaterThan(seq(const XPathUntypedAtomic('101')), seq(100)),
      ).equals(XPathSequence.trueSequence);
    });

    test('invalid untyped string to numeric throws FORG0001', () {
      check(
        () =>
            opGeneralEqual(seq(const XPathUntypedAtomic('not_num')), seq(100)),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
      );
      check(
        () => opGeneralLessThan(
          seq(const XPathUntypedAtomic('not_num')),
          seq(100),
        ),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
      );
    });

    test('untyped vs untyped strictly performs string comparison', () {
      check(
        opGeneralEqual(
          seq(const XPathUntypedAtomic('01')),
          seq(const XPathUntypedAtomic('1')),
        ),
      ).equals(XPathSequence.falseSequence);
      check(
        opGeneralEqual(
          seq(const XPathUntypedAtomic('1')),
          seq(const XPathUntypedAtomic('1')),
        ),
      ).equals(XPathSequence.trueSequence);
      check(
        opGeneralLessThan(
          seq(const XPathUntypedAtomic('10')),
          seq(const XPathUntypedAtomic('2')),
        ),
      ).equals(XPathSequence.trueSequence);
    });

    test('untyped vs string or anyURI compares as string', () {
      check(opGeneralEqual(seq(const XPathUntypedAtomic('foo')), seq('foo')))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(seq(const XPathUntypedAtomic('bar')), seq('foo')))
          .equals(XPathSequence.trueSequence);
      check(
        opGeneralEqual(
          seq(const XPathUntypedAtomic('http://x')),
          seq(const XPathAnyUri('http://x')),
        ),
      ).equals(XPathSequence.trueSequence);
    });

    test('untyped vs boolean converts to boolean', () {
      check(opGeneralEqual(seq(const XPathUntypedAtomic('true')), seq(true)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(const XPathUntypedAtomic('false')), seq(false)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(const XPathUntypedAtomic('1')), seq(true)))
          .equals(XPathSequence.trueSequence);
      check(
        () => opGeneralEqual(seq(const XPathUntypedAtomic('yes')), seq(true)),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FORG0001),
      );
    });
  });

  group('Empty Sequence Divergence (General vs Value)', () {
    test('general comparisons with empty sequence return falseSequence', () {
      check(opGeneralEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralEqual(seq(1), XPathSequence.empty))
          .equals(XPathSequence.falseSequence);
      check(opGeneralEqual(XPathSequence.empty, XPathSequence.empty))
          .equals(XPathSequence.falseSequence);

      check(opGeneralNotEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(seq(1), XPathSequence.empty))
          .equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(XPathSequence.empty, XPathSequence.empty))
          .equals(XPathSequence.falseSequence);

      check(opGeneralLessThan(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralGreaterThan(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralLessThanOrEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralGreaterThanOrEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.falseSequence);
    });

    test('value comparisons with empty sequence return empty sequence', () {
      check(opValueEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.empty);
      check(opValueEqual(seq(1), XPathSequence.empty))
          .equals(XPathSequence.empty);
      check(opValueEqual(XPathSequence.empty, XPathSequence.empty))
          .equals(XPathSequence.empty);

      check(opValueNotEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.empty);
      check(opValueLessThan(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.empty);
      check(opValueGreaterThan(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.empty);
      check(opValueLessThanOrEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.empty);
      check(opValueGreaterThanOrEqual(XPathSequence.empty, seq(1)))
          .equals(XPathSequence.empty);
    });
  });

  group('Multi-Item Existential Semantics', () {
    test('overlapping sequence comparison', () {
      check(opGeneralEqual(seq([1, 2]), seq([2, 3])))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq([1, 2]), seq([3, 4])))
          .equals(XPathSequence.falseSequence);
    });

    test('asymmetric != semantics', () {
      check(opGeneralNotEqual(seq([1, 2]), seq([2, 3])))
          .equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(seq([1, 2]), seq(1)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(seq(1), seq([1, 2])))
          .equals(XPathSequence.trueSequence);
      check(opGeneralNotEqual(seq([1, 1]), seq(1)))
          .equals(XPathSequence.falseSequence);
    });

    test('multi-item order comparison', () {
      check(opGeneralLessThan(seq([5, 1]), seq([2, 0])))
          .equals(XPathSequence.trueSequence); // 1 < 2
      check(opGeneralGreaterThan(seq([1, 2]), seq([5, 6])))
          .equals(XPathSequence.falseSequence);
    });
  });

  group('Type Incompatibility & Error Handling', () {
    test('incompatible types in general comparison throw XPTY0004', () {
      check(() => opGeneralEqual(seq(1), seq('1')))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralNotEqual(seq(1), seq('1')))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralEqual(seq(true), seq(1)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });

    test('ordering on QNames throws XPTY0004', () {
      const q1 = XPathQName(XmlName('a'));
      const q2 = XPathQName(XmlName('b'));
      check(() => opGeneralLessThan(seq(q1), seq(q2)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opGeneralGreaterThan(seq(q1), seq(q2)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      // Equality is permitted
      check(opGeneralEqual(seq(q1), seq(q1)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralEqual(seq(q1), seq(q2)))
          .equals(XPathSequence.falseSequence);
    });

    test('value comparison with > 1 items throws XPTY0004', () {
      check(() => opValueEqual(seq([1, 2]), seq(1)))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
      check(() => opValueEqual(seq(1), seq([1, 2])))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
          );
    });

    test('NaN general comparisons return expected IEEE 754 results', () {
      check(opGeneralEqual(seq(double.nan), seq(double.nan)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralNotEqual(seq(double.nan), seq(double.nan)))
          .equals(XPathSequence.trueSequence);
      check(opGeneralLessThan(seq(double.nan), seq(1.0)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralGreaterThan(seq(double.nan), seq(1.0)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralLessThanOrEqual(seq(double.nan), seq(1.0)))
          .equals(XPathSequence.falseSequence);
      check(opGeneralGreaterThanOrEqual(seq(double.nan), seq(1.0)))
          .equals(XPathSequence.falseSequence);
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
