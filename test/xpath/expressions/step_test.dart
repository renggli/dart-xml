import 'dart:math';

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/expressions/axis.dart';
import 'package:xml/src/xpath/expressions/name.dart';
import 'package:xml/src/xpath/expressions/path.dart';
import 'package:xml/src/xpath/expressions/step.dart';
import 'package:xml/src/xpath/grammars/parser.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('reverse axis predicate evaluation order', () {
    const input = '<root><a id="1"/><b id="2"/><c id="3"/><d id="4"/></root>';
    final doc = XmlDocument.parse(input);
    final d = doc.findAllElements('d').single;

    test('preceding-sibling with single positional predicate', () {
      expectXPath(d, 'preceding-sibling::*[1]', ['<c id="3"/>']);
      expectXPath(d, 'preceding-sibling::*[2]', ['<b id="2"/>']);
      expectXPath(d, 'preceding-sibling::*[3]', ['<a id="1"/>']);
    });

    test('preceding-sibling with multiple predicates', () {
      expectXPath(d, 'preceding-sibling::*[position() < 3][1]', [
        '<c id="3"/>',
      ]);
      expectXPath(d, 'preceding-sibling::*[position() < 3][2]', [
        '<b id="2"/>',
      ]);
      expectXPath(d, 'preceding-sibling::*[1][1]', ['<c id="3"/>']);
    });

    test('ancestor with multiple predicates', () {
      const nested = '<top><mid><leaf/></mid></top>';
      final docNested = XmlDocument.parse(nested);
      final leaf = docNested.findAllElements('leaf').single;
      expectXPath(leaf, 'ancestor::*[1]', ['<mid><leaf/></mid>']);
      expectXPath(leaf, 'ancestor::*[2]', ['<top><mid><leaf/></mid></top>']);
      expectXPath(leaf, 'ancestor::*[1][1]', ['<mid><leaf/></mid>']);
      expectXPath(leaf, 'ancestor::*[position() <= 2][2]', [
        '<top><mid><leaf/></mid></top>',
      ]);
    });
  });

  group('missing context item error (XPDY0002)', () {
    final emptyContext = const XPathConfiguration.raw().context();

    test('StepExpression throws XPDY0002 when context item is absent', () {
      const step = StepExpression(ChildAxis(), nodeTest: NodeNameTest());
      check(() => step(emptyContext)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPDY0002),
      );
    });

    test('RootNodeExpression throws XPDY0002 when context item is absent', () {
      const rootStep = RootNodeExpression();
      check(() => rootStep(emptyContext))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPDY0002),
          );
    });
  });

  group('non-node context item error (XPTY0019)', () {
    test('step throws XPTY0019 when context item is not a node', () {
      final intContext = const XPathConfiguration.raw().context(42);
      const step = StepExpression(ChildAxis(), nodeTest: NodeNameTest());
      check(() => step(intContext)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0019),
      );
    });

    test('root throws XPTY0019 when context item is not a node', () {
      final intContext = const XPathConfiguration.raw().context(42);
      const rootStep = RootNodeExpression();
      check(() => rootStep(intContext))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0019),
          );
    });
  });

  group('multi-parent // vs descendant:: semantics', () {
    const xml = '''
<catalog>
  <cat id="1">
    <item id="a1" price="10"/>
    <item id="a2" price="20"/>
  </cat>
  <cat id="2">
    <item id="b1" price="15"/>
    <item id="b2" price="25"/>
  </cat>
  <cat id="3">
    <item id="c1" price="30"/>
    <item id="c2" price="40"/>
  </cat>
</catalog>''';

    final doc = XmlDocument.parse(xml);

    List<String> getIds(String query) => doc
        .xpath(query)
        .map((node) => (node as XmlElement).getAttribute('id')!)
        .toList();

    test('//item[1] returns first item of EVERY parent category', () {
      check(getIds('//item[1]')).deepEquals(['a1', 'b1', 'c1']);
    });

    test('(//item)[1] returns ONLY first item in entire document', () {
      check(getIds('(//item)[1]')).deepEquals(['a1']);
    });

    test('descendant::item[1] returns ONLY first item in entire document', () {
      check(getIds('/descendant::item[1]')).deepEquals(['a1']);
    });

    test('//item[last()] returns last item of EVERY parent category', () {
      check(getIds('//item[last()]')).deepEquals(['a2', 'b2', 'c2']);
    });

    test('(//item)[last()] returns ONLY last item in entire document', () {
      check(getIds('(//item)[last()]')).deepEquals(['c2']);
    });

    test('//item[2] returns second item of EVERY parent category', () {
      check(getIds('//item[2]')).deepEquals(['a2', 'b2', 'c2']);
    });

    test('//item[3] returns empty because no parent has 3 items', () {
      check(getIds('//item[3]')).isEmpty();
    });

    test(
      '//item[position() > 1] returns second items across all categories',
      () {
        check(getIds('//item[position() > 1]')).deepEquals(['a2', 'b2', 'c2']);
      },
    );

    test('//item[@price > 18] collapses and returns matching items in document order', () {
      check(getIds('//item[@price > 18]')).deepEquals(['a2', 'b2', 'c1', 'c2']);
      check(getIds('/descendant::item[@price > 18]'))
          .deepEquals(['a2', 'b2', 'c1', 'c2']);
    });

    test('//item[@price > 12][1] returns 1st matching item PER category', () {
      check(getIds('//item[@price > 12][1]')).deepEquals(['a2', 'b1', 'c1']);
      check(getIds('(//item[@price > 12])[1]')).deepEquals(['a2']);
    });
  });

  group('XPathInteger intValue and pooling', () {
    test('intValue is cached on construction for valid 64-bit int', () {
      final a = XPathInteger.fromInt(42);
      check(a.intValue).equals(42);
      check(a.asInt).equals(42);

      final b = XPathInteger(BigInt.from(1000));
      check(b.intValue).equals(1000);
      check(b.asInt).equals(1000);
    });

    test('intValue is null for values exceeding 64-bit signed int', () {
      final huge = BigInt.parse('999999999999999999999999999999');
      final val = XPathInteger(huge);
      check(val.intValue).isNull();
      check(val.equalsInt(42)).isFalse();
    });

    test('pools small integers 0 through 128 in fromInt for xsInteger', () {
      for (var i = 0; i <= 128; i++) {
        final a = XPathInteger.fromInt(i);
        final b = XPathInteger.fromInt(i);
        check(identical(a, b)).isTrue();
        check(a.intValue).equals(i);
      }
      check(identical(XPathInteger.fromInt(0), XPathInteger.zero)).isTrue();

      final over = XPathInteger.fromInt(129);
      final over2 = XPathInteger.fromInt(129);
      check(identical(over, over2)).isFalse();
      check(over).equals(over2);
      check(over.intValue).equals(129);
    });

    test('fromInt with non-xsInteger type does not use pool', () {
      final a = XPathInteger.fromInt(5, xsPositiveInteger);
      final b = XPathInteger.fromInt(5, xsPositiveInteger);
      check(identical(a, b)).isFalse();
      check(a.type).equals(xsPositiveInteger);
      check(a.intValue).equals(5);
    });

    test('parse fast path uses int.tryParse', () {
      final p1 = XPathInteger.parse('  42  ');
      check(identical(p1, XPathInteger.fromInt(42))).isTrue();
      check(p1.intValue).equals(42);

      final p2 = XPathInteger.parse('-999');
      check(p2.intValue).equals(-999);

      final pHuge = XPathInteger.parse('123456789012345678901234567890');
      check(pHuge.intValue).isNull();
      check(pHuge.value).equals(BigInt.parse('123456789012345678901234567890'));
    });

    test('equalsInt compares primitive int directly without BigInt alloc', () {
      final a = XPathInteger.fromInt(100);
      check(a.equalsInt(100)).isTrue();
      check(a.equalsInt(99)).isFalse();

      final huge = XPathInteger(BigInt.parse('999999999999999999999999999999'));
      check(huge.equalsInt(100)).isFalse();
    });

    test('operator == fast path when both have intValue', () {
      final a = XPathInteger.fromInt(500);
      final b = XPathInteger.fromInt(500);
      check(a == b).isTrue();
      check(a == XPathInteger.fromInt(501)).isFalse();
    });
  });

  group('Predicate staticPosition and isDefinitelyNonPositional', () {
    test('staticPosition correctly detects integer literals', () {
      final p1 = parseExpression('item[1]') as StepExpression;
      check(p1.predicates.first.staticPosition).equals(1);

      final p100 = parseExpression('item[100]') as StepExpression;
      check(p100.predicates.first.staticPosition).equals(100);
    });

    test('staticPosition detects whole double literals', () {
      final pFloat = parseExpression('item[1.0]') as StepExpression;
      check(pFloat.predicates.first.staticPosition).equals(1);
    });

    test('staticPosition returns 0 for non-matching numeric constants', () {
      final pZero = parseExpression('item[0]') as StepExpression;
      check(pZero.predicates.first.staticPosition).equals(0);

      final pNeg = parseExpression('item[-1]') as StepExpression;
      check(
        pNeg.predicates.first.staticPosition == null ||
            pNeg.predicates.first.staticPosition! <= 0,
      ).isTrue();

      final pFrac = parseExpression('item[1.5]') as StepExpression;
      check(pFrac.predicates.first.staticPosition).equals(0);
    });

    test(
      'staticPosition returns null for non-constant or non-numeric expressions',
      () {
        final pAttr = parseExpression('item[@id = "1"]') as StepExpression;
        check(pAttr.predicates.first.staticPosition).isNull();

        final pPos = parseExpression('item[position() = 1]') as StepExpression;
        check(pPos.predicates.first.staticPosition).isNull();

        final pLast = parseExpression('item[last()]') as StepExpression;
        check(pLast.predicates.first.staticPosition).isNull();

        final pVar = parseExpression('item[\$x]') as StepExpression;
        check(pVar.predicates.first.staticPosition).isNull();
      },
    );

    test('isDefinitelyNonPositional returns true for attribute comparisons and booleans', () {
      final pEq = parseExpression('item[@id = "100"]') as StepExpression;
      check(pEq.predicates.first.isDefinitelyNonPositional).isTrue();
      check(pEq.predicates.first.isPositional).isFalse();

      final pComp = parseExpression('item[@price > 50]') as StepExpression;
      check(pComp.predicates.first.isDefinitelyNonPositional).isTrue();

      final pAnd = parseExpression('item[@a and @b]') as StepExpression;
      check(pAnd.predicates.first.isDefinitelyNonPositional).isTrue();

      final pOr = parseExpression('item[@a or @b]') as StepExpression;
      check(pOr.predicates.first.isDefinitelyNonPositional).isTrue();

      final pNot = parseExpression('item[not(@disabled)]') as StepExpression;
      check(pNot.predicates.first.isDefinitelyNonPositional).isTrue();

      final pContains =
          parseExpression('item[contains(@name, "x")]') as StepExpression;
      check(pContains.predicates.first.isDefinitelyNonPositional).isTrue();

      final pStarts =
          parseExpression('item[starts-with(@id, "a")]') as StepExpression;
      check(pStarts.predicates.first.isDefinitelyNonPositional).isTrue();

      final pEnds =
          parseExpression('item[ends-with(@id, "z")]') as StepExpression;
      check(pEnds.predicates.first.isDefinitelyNonPositional).isTrue();

      final pEmpty = parseExpression('item[empty(@opt)]') as StepExpression;
      check(pEmpty.predicates.first.isDefinitelyNonPositional).isTrue();

      final pExists = parseExpression('item[exists(@opt)]') as StepExpression;
      check(pExists.predicates.first.isDefinitelyNonPositional).isTrue();

      final pAttrExists = parseExpression('item[@id]') as StepExpression;
      check(pAttrExists.predicates.first.isDefinitelyNonPositional).isTrue();

      final pChildExists = parseExpression('item[title]') as StepExpression;
      check(pChildExists.predicates.first.isDefinitelyNonPositional).isTrue();
    });

    test(
      'isDefinitelyNonPositional returns false for positional predicates',
      () {
        final p1 = parseExpression('item[1]') as StepExpression;
        check(p1.predicates.first.isDefinitelyNonPositional).isFalse();
        check(p1.predicates.first.isPositional).isTrue();

        final pPos = parseExpression('item[position() = 1]') as StepExpression;
        check(pPos.predicates.first.isDefinitelyNonPositional).isFalse();
        check(pPos.predicates.first.isPositional).isTrue();

        final pLast = parseExpression('item[last()]') as StepExpression;
        check(pLast.predicates.first.isDefinitelyNonPositional).isFalse();
        check(pLast.predicates.first.isPositional).isTrue();

        final pPosComp =
            parseExpression('item[position() > 2]') as StepExpression;
        check(pPosComp.predicates.first.isDefinitelyNonPositional).isFalse();
        check(pPosComp.predicates.first.isPositional).isTrue();

        final pVar = parseExpression('item[\$v]') as StepExpression;
        check(pVar.predicates.first.isDefinitelyNonPositional).isFalse();
        check(pVar.predicates.first.isPositional).isTrue();

        final pArith = parseExpression('item[1 + 1]') as StepExpression;
        check(pArith.predicates.first.isDefinitelyNonPositional).isFalse();
        check(pArith.predicates.first.isPositional).isTrue();
      },
    );
  });

  group('Step collapsing and order preservation', () {
    test('collapses //item[@id="100"] to DescendantAxis with predicates', () {
      final expr = parseExpression('//item[@id="100"]') as PathExpression;
      check(expr.steps).length.equals(2);
      check(expr.steps[0]).isA<RootNodeExpression>();
      final step = expr.steps[1] as StepExpression;
      check(step.axis).isA<DescendantAxis>();
      check(step.predicates).length.equals(1);
      check(expr.isOrderPreserved).isTrue();
    });

    test('collapses //*[@id="100"] to DescendantAxis', () {
      final expr = parseExpression('//*[@id="100"]') as PathExpression;
      check(expr.steps).length.equals(2);
      final step = expr.steps[1] as StepExpression;
      check(step.axis).isA<DescendantAxis>();
      check(expr.isOrderPreserved).isTrue();
    });

    test('collapses //self::item[@id="100"] to DescendantOrSelfAxis', () {
      final expr = parseExpression('//self::item[@id="100"]') as PathExpression;
      check(expr.steps).length.equals(2);
      final step = expr.steps[1] as StepExpression;
      check(step.axis).isA<DescendantOrSelfAxis>();
      check(step.predicates).length.equals(1);
    });

    test('collapses relative path div//item[@id="100"]', () {
      final expr = parseExpression('div//item[@id="100"]') as PathExpression;
      check(expr.steps).length.equals(2);
      check((expr.steps[0] as StepExpression).axis).isA<ChildAxis>();
      check((expr.steps[1] as StepExpression).axis).isA<DescendantAxis>();
      check((expr.steps[1] as StepExpression).predicates).length.equals(1);
    });

    test('strictly avoids collapsing positional predicates', () {
      final p1 = parseExpression('//item[1]') as PathExpression;
      check(p1.steps).length.equals(3);
      check((p1.steps[1] as StepExpression).axis).isA<DescendantOrSelfAxis>();
      check((p1.steps[2] as StepExpression).axis).isA<ChildAxis>();

      final pLast = parseExpression('//item[last()]') as PathExpression;
      check(pLast.steps).length.equals(3);
      check((pLast.steps[1] as StepExpression).axis)
          .isA<DescendantOrSelfAxis>();
      check((pLast.steps[2] as StepExpression).axis).isA<ChildAxis>();

      final pPos = parseExpression('//item[position() = 1]') as PathExpression;
      check(pPos.steps).length.equals(3);
      check((pPos.steps[1] as StepExpression).axis).isA<DescendantOrSelfAxis>();
      check((pPos.steps[2] as StepExpression).axis).isA<ChildAxis>();

      final pMixed1 = parseExpression('//item[@id="1"][1]') as PathExpression;
      check(pMixed1.steps).length.equals(3);
      check((pMixed1.steps[1] as StepExpression).axis)
          .isA<DescendantOrSelfAxis>();
      check((pMixed1.steps[2] as StepExpression).axis).isA<ChildAxis>();

      final pMixed2 = parseExpression('//item[1][@id="1"]') as PathExpression;
      check(pMixed2.steps).length.equals(3);
      check((pMixed2.steps[1] as StepExpression).axis)
          .isA<DescendantOrSelfAxis>();
      check((pMixed2.steps[2] as StepExpression).axis).isA<ChildAxis>();

      final pVar = parseExpression('//item[\$idx]') as PathExpression;
      check(pVar.steps).length.equals(3);
      check((pVar.steps[1] as StepExpression).axis).isA<DescendantOrSelfAxis>();
      check((pVar.steps[2] as StepExpression).axis).isA<ChildAxis>();
    });
  });

  group('Execution correctness and semantic boundaries', () {
    const multiParentXml = '''
<root>
  <group id="g1">
    <item id="1" active="true"/>
    <item id="2" active="false"/>
    <item id="3" active="true"/>
  </group>
  <group id="g2">
    <item id="4" active="true"/>
    <item id="5" active="true"/>
  </group>
  <group id="g3">
    <item id="6" active="false"/>
  </group>
</root>''';
    final doc = XmlDocument.parse(multiParentXml);

    test('//item[1] returns the 1st child of each parent element', () {
      expectXPath(doc, '//item[1]', [
        '<item id="1" active="true"/>',
        '<item id="4" active="true"/>',
        '<item id="6" active="false"/>',
      ]);
    });

    test('descendant::item[1] and (//item)[1] return ONLY the 1st item in document', () {
      expectXPath(doc, '/descendant::item[1]', [
        '<item id="1" active="true"/>',
      ]);
      expectXPath(doc, '(//item)[1]', ['<item id="1" active="true"/>']);
    });

    test('//item[last()] returns the last child of each parent element', () {
      expectXPath(doc, '//item[last()]', [
        '<item id="3" active="true"/>',
        '<item id="5" active="true"/>',
        '<item id="6" active="false"/>',
      ]);
      expectXPath(doc, '(//item)[last()]', ['<item id="6" active="false"/>']);
    });

    test('//item[2] returns 2nd child of parents that have at least 2', () {
      expectXPath(doc, '//item[2]', [
        '<item id="2" active="false"/>',
        '<item id="5" active="true"/>',
      ]);
    });

    test('//item[@active = "true"] collapses and preserves document order', () {
      expectXPath(doc, '//item[@active = "true"]', [
        '<item id="1" active="true"/>',
        '<item id="3" active="true"/>',
        '<item id="4" active="true"/>',
        '<item id="5" active="true"/>',
      ]);
    });

    test('//item[@active = "true"][1] evaluates per parent category', () {
      expectXPath(doc, '//item[@active = "true"][1]', [
        '<item id="1" active="true"/>',
        '<item id="4" active="true"/>',
      ]);
    });

    test('postfix predicate direct indexing', () {
      expectEvaluate(doc, '(1 to 10)[1]', [1]);
      expectEvaluate(doc, '(1 to 10)[5]', [5]);
      expectEvaluate(doc, '(1 to 10)[10]', [10]);
      expectEvaluate(doc, '(1 to 10)[0]', <int>[]);
      expectEvaluate(doc, '(1 to 10)[-1]', <int>[]);
      expectEvaluate(doc, '(1 to 10)[11]', <int>[]);
    });
  });

  group('Adversarial - Extreme XPathInteger & Numeric Edge Cases', () {
    test('64-bit int boundaries and overflow handling', () {
      if (identical(0, 0.0)) {
        // Skip on JavaScript runtimes which only support 53-bit integers.
        return;
      }
      final maxInt = int.parse('9223372036854775807');
      final minInt = int.parse('-9223372036854775808');

      final maxVal = XPathInteger.fromInt(maxInt);
      check(maxVal.intValue).equals(maxInt);
      check(maxVal.asInt).equals(maxInt);
      check(maxVal.equalsInt(maxInt)).isTrue();

      final minVal = XPathInteger.fromInt(minInt);
      check(minVal.intValue).equals(minInt);
      check(minVal.asInt).equals(minInt);
      check(minVal.equalsInt(minInt)).isTrue();

      final overflowPos = BigInt.parse('9223372036854775808');
      final valOver = XPathInteger(overflowPos);
      check(valOver.intValue).isNull();
      check(valOver.equalsInt(maxInt)).isFalse();

      final overflowNeg = BigInt.parse('-9223372036854775809');
      final valUnder = XPathInteger(overflowNeg);
      check(valUnder.intValue).isNull();
      check(valUnder.equalsInt(minInt)).isFalse();
    });

    test('Small integer pool boundary 128 vs 129', () {
      final p128a = XPathInteger.fromInt(128);
      final p128b = XPathInteger.fromInt(128);
      check(identical(p128a, p128b)).isTrue();

      final p129a = XPathInteger.fromInt(129);
      final p129b = XPathInteger.fromInt(129);
      check(identical(p129a, p129b)).isFalse();
      check(p129a == p129b).isTrue();

      final pNeg = XPathInteger.fromInt(-1);
      final pNeg2 = XPathInteger.fromInt(-1);
      check(identical(pNeg, pNeg2)).isFalse();
      check(pNeg == pNeg2).isTrue();
    });

    test('Cross-type equality with cached intValue', () {
      final int42 = XPathInteger.fromInt(42);
      final dec42 = XPathDecimal.fromInt(42);
      const dbl42 = XPathDouble(42.0);
      const dbl42_5 = XPathDouble(42.5);

      check(int42 == dec42).isTrue();
      check(int42 == dbl42).isTrue();
      check(int42 == dbl42_5).isFalse();
    });

    test('Floating and special numeric predicates in execution', () {
      final doc = XmlDocument.parse('''
<root>
  <e id="1"/>
  <e id="2"/>
  <e id="3"/>
</root>''');

      check(doc.xpath('//e[0]')).isEmpty();
      check(doc.xpath('//e[-1]')).isEmpty();
      check(doc.xpath('//e[-99999999999999999999]')).isEmpty();
      check(doc.xpath('//e[99999999999999999999]')).isEmpty();
      check(doc.xpath('//e[1.5]')).isEmpty();
      check(doc.xpath('//e[2.7]')).isEmpty();

      final e1 = doc.xpath('//e[1.0]').toList();
      check(e1).length.equals(1);
      check((e1.first as XmlElement).getAttribute('id')).equals('1');

      final e2 = doc.xpath('//e[2.0]').toList();
      check(e2).length.equals(1);
      check((e2.first as XmlElement).getAttribute('id')).equals('2');
    });
  });

  group('Adversarial - Step Collapsing Soundness Verification', () {
    void verifyCollapsing(String query, {required bool shouldCollapse}) {
      final expr = parseExpression(query);
      check(expr).isA<PathExpression>();
      final path = expr as PathExpression;
      if (shouldCollapse) {
        check(
          because: 'Expected $query to collapse into 2 steps',
          path.steps.length,
        ).equals(2);
        check(path.steps.first).isA<RootNodeExpression>();
        final step = path.steps[1] as StepExpression;
        check(step.axis is DescendantAxis || step.axis is DescendantOrSelfAxis)
            .isTrue();
      } else {
        check(
          because: 'Expected $query NOT to collapse',
          path.steps.length,
        ).isGreaterOrEqual(3);
      }
    }

    test('Non-positional predicates that MUST collapse', () {
      verifyCollapsing('//item[@type = "book"]', shouldCollapse: true);
      verifyCollapsing(
        '//item[@price > 10 and @price < 100]',
        shouldCollapse: true,
      );
      verifyCollapsing('//item[not(@disabled)]', shouldCollapse: true);
      verifyCollapsing('//item[boolean(@active)]', shouldCollapse: true);
      verifyCollapsing('//item[empty(@tags)]', shouldCollapse: true);
      verifyCollapsing('//item[exists(@tags)]', shouldCollapse: true);
      verifyCollapsing(
        '//item[contains(@name, "widget")]',
        shouldCollapse: true,
      );
      verifyCollapsing(
        '//item[starts-with(@code, "US")]',
        shouldCollapse: true,
      );
      verifyCollapsing('//item[ends-with(@code, "99")]', shouldCollapse: true);
      verifyCollapsing(
        '//item[matches(@code, "^[A-Z]+")]',
        shouldCollapse: true,
      );
      verifyCollapsing('//item[@a or @b]', shouldCollapse: true);
      verifyCollapsing('//item[child::title]', shouldCollapse: true);
      verifyCollapsing('//item[self::item]', shouldCollapse: true);
      verifyCollapsing('//item[string-length(@id) > 2]', shouldCollapse: true);
    });

    test('Positional or indeterminate predicates that MUST NOT collapse', () {
      verifyCollapsing('//item[1]', shouldCollapse: false);
      verifyCollapsing('//item[100]', shouldCollapse: false);
      verifyCollapsing('//item[last()]', shouldCollapse: false);
      verifyCollapsing('//item[position() = 1]', shouldCollapse: false);
      verifyCollapsing('//item[position() < 5]', shouldCollapse: false);
      verifyCollapsing('//item[position() = last()]', shouldCollapse: false);
      verifyCollapsing('//item[not(position() = 1)]', shouldCollapse: false);
      verifyCollapsing('//item[empty(position())]', shouldCollapse: false);
      verifyCollapsing('//item[@id = position()]', shouldCollapse: false);
      verifyCollapsing('//item[string-length(@id)]', shouldCollapse: false);
      verifyCollapsing('//item[count(sub)]', shouldCollapse: false);
      verifyCollapsing('//item[\$var]', shouldCollapse: false);
      verifyCollapsing('//item[1 + 1]', shouldCollapse: false);
      verifyCollapsing('//item[@id = "1"][1]', shouldCollapse: false);
      verifyCollapsing('//item[1][@id = "1"]', shouldCollapse: false);
    });
  });

  group('Adversarial - Reverse Axes and Short-Circuiting', () {
    const xml = '''
<doc>
  <section id="s1">
    <para id="p1">One</para>
    <para id="p2">Two</para>
    <para id="p3">Three</para>
    <para id="p4">Four</para>
  </section>
  <section id="s2">
    <para id="p5">Five</para>
    <para id="p6">Six</para>
  </section>
</doc>''';

    final doc = XmlDocument.parse(xml);

    test(
      'preceding-sibling with positional predicate returns closest sibling',
      () {
        final p3 = doc.xpath('//para[@id="p3"]').single as XmlElement;
        final prev1 = p3.xpath('preceding-sibling::para[1]').toList();
        check(prev1).length.equals(1);
        check((prev1.first as XmlElement).getAttribute('id')).equals('p2');

        final prev2 = p3.xpath('preceding-sibling::para[2]').toList();
        check(prev2).length.equals(1);
        check((prev2.first as XmlElement).getAttribute('id')).equals('p1');

        final prev3 = p3.xpath('preceding-sibling::para[3]').toList();
        check(prev3).isEmpty();
      },
    );

    test('ancestor with positional predicate returns nearest ancestor', () {
      final p1 = doc.xpath('//para[@id="p1"]').single as XmlElement;
      final anc1 = p1.xpath('ancestor::*[1]').toList();
      check(anc1).length.equals(1);
      check((anc1.first as XmlElement).name.local).equals('section');

      final anc2 = p1.xpath('ancestor::*[2]').toList();
      check(anc2).length.equals(1);
      check((anc2.first as XmlElement).name.local).equals('doc');

      final anc3 = p1.xpath('ancestor::*[3]').toList();
      check(anc3).isEmpty();
    });
  });

  group('Adversarial - Randomized Novel Trees & Fuzzing (100 Trees)', () {
    final rng = Random(42);

    XmlDocument generateRandomTree(int targetNodes) {
      final builder = XmlBuilder();
      var nodeCount = 0;

      void addSubtree(int depth) {
        if (nodeCount >= targetNodes || depth > 5) return;
        final childCount = rng.nextInt(4) + 1;
        for (var i = 0; i < childCount; i++) {
          if (nodeCount >= targetNodes) break;
          nodeCount++;
          final tag = ['item', 'entry', 'data', 'elem'][rng.nextInt(4)];
          final idVal = nodeCount;
          final catVal = rng.nextInt(5);
          final activeVal = rng.nextBool() ? 'true' : 'false';

          builder.element(
            tag,
            attributes: {'id': '$idVal', 'cat': '$catVal', 'active': activeVal},
            nest: () {
              if (rng.nextDouble() < 0.6) {
                addSubtree(depth + 1);
              }
            },
          );
        }
      }

      builder.element('root', nest: () => addSubtree(1));
      return builder.buildDocument();
    }

    test('Fuzzing 100 random trees: compare optimized // against unoptimized', () {
      const queriesToTest = [
        '//item[@active = "true"]',
        '//entry[@cat = "2"]',
        '//data[@id > 10]',
        '//elem[not(@active = "false")]',
        '//*[@cat = "0"]',
        '//item[@active = "true"][@cat = "1"]',
        '//item[1]',
        '//entry[1]',
        '//data[2]',
        '//elem[last()]',
        '(//item)[1]',
        '(//entry)[2]',
        '(//data)[last()]',
      ];

      for (var treeIdx = 0; treeIdx < 100; treeIdx++) {
        final doc = generateRandomTree(50);

        for (final q in queriesToTest) {
          final optimizedResult = doc.xpath(q).toList();

          // Construct unoptimized ground truth:
          // In XPath 3.1, //X[P] is semantically equivalent to /(descendant-or-self::node())/child::X[P]
          // Parenthesizing (descendant-or-self::node()) prevents AST step collapsing in PathExpression.
          String unoptimizedQuery;
          if (q.startsWith('//')) {
            unoptimizedQuery =
                '/(descendant-or-self::node())/child::${q.substring(2)}';
          } else if (q.startsWith('(//')) {
            unoptimizedQuery =
                '(/(descendant-or-self::node())/child::${q.substring(3)}';
          } else {
            unoptimizedQuery = q;
          }

          final unoptimizedResult = doc.xpath(unoptimizedQuery).toList();

          check(
            because:
                'Tree $treeIdx: Query "$q" mismatch with unoptimized "$unoptimizedQuery"',
            optimizedResult.length,
          ).equals(unoptimizedResult.length);

          for (var k = 0; k < optimizedResult.length; k++) {
            final optNode = optimizedResult[k];
            final unoptNode = unoptimizedResult[k];
            check(
              because:
                  'Tree $treeIdx, query "$q", item $k: identity mismatch between optimized and unoptimized',
              identical(optNode, unoptNode),
            ).isTrue();
          }
        }
      }
    });

    test('Fuzzing multi-parent positional semantics: //tag[1] vs descendant::tag[1]', () {
      for (var treeIdx = 0; treeIdx < 20; treeIdx++) {
        final doc = generateRandomTree(60);

        final multiParentItems = doc.xpath('//item[1]').toList();
        final singleFirstItem = doc.xpath('/descendant::item[1]').toList();

        if (multiParentItems.isNotEmpty) {
          check(singleFirstItem).length.equals(1);
          check(identical(multiParentItems.first, singleFirstItem.first))
              .isTrue();
        } else {
          check(singleFirstItem).isEmpty();
        }

        final allItems = doc.xpath('//item').toList();
        if (allItems.length >= 2) {
          final parentCount = allItems
              .map((e) => (e as XmlElement).parent)
              .toSet()
              .length;
          if (parentCount > 1) {
            // //item[1] MUST have selected more than 1 item if multiple parents exist
            check(
              because: 'Tree $treeIdx: //item[1] must return 1 item per parent',
              multiParentItems.length,
            ).isGreaterThan(1);
          }
        }
      }
    });
  });
}
