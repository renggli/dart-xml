import 'package:test/test.dart';
import 'package:xml/src/xpath/expressions/predicate.dart';
import 'package:xml/src/xpath/expressions/sequence.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/grammars/parser.dart';
import 'package:xml/src/xpath/xdm/atomic/numeric.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  const input =
      '<?xml version="1.0"?>'
      '<r><e1 a="1"/><e2 a="2" b="3"/><e3 b="4"/></r>';
  final document = XmlDocument.parse(input);
  final current = document.rootElement;
  test('index', () {
    expectXPath(current, 'e1[1]', ['<e1 a="1"/>']);
    expectXPath(current, 'e1[2]', []);
    expectXPath(current, 'e1[1.0]', ['<e1 a="1"/>']);
    expectXPath(current, 'e1[1.5]', []);
  });
  test('expression', () {
    expectXPath(current, '*[@a]', ['<e1 a="1"/>', '<e2 a="2" b="3"/>']);
    expectXPath(current, '*[@b]', ['<e2 a="2" b="3"/>', '<e3 b="4"/>']);
  });
  test('multiple', () {
    expectXPath(current, '*[@a][@b]', ['<e2 a="2" b="3"/>']);
    expectXPath(current, '*[@a][1]', ['<e1 a="1"/>']);
    expectXPath(current, '*[1][@a]', ['<e1 a="1"/>']);
    expectXPath(current, '*[position()=1]', ['<e1 a="1"/>']);
    expectXPath(current, '*[last()=3]', [
      '<e1 a="1"/>',
      '<e2 a="2" b="3"/>',
      '<e3 b="4"/>',
    ]);
    expectXPath(current, '*[last()]', ['<e3 b="4"/>']);
    expectXPath(current, 'e1[0]', []);
    expectXPath(current, 'e1[-1]', []);
    expectXPath(current, 'e1[1][2]', []);
  });

  group('Milestone 2: positional predicate early-exit and edge cases', () {
    final largeDoc = XmlDocument.build((builder) {
      builder.element(
        'root',
        nest: () {
          for (var i = 0; i < 1000; i++) {
            builder.element('item', attributes: {'id': '$i'});
          }
        },
      );
    });

    test('first index [1]', () {
      expectXPath(largeDoc, '/root/item[1]', ['<item id="0"/>']);
    });

    test('mid index [50]', () {
      expectXPath(largeDoc, '/root/item[50]', ['<item id="49"/>']);
    });

    test('last index [1000]', () {
      expectXPath(largeDoc, '/root/item[1000]', ['<item id="999"/>']);
    });

    test('out-of-bounds index [1001]', () {
      expectXPath(largeDoc, '/root/item[1001]', []);
    });

    test('zero index [0]', () {
      expectXPath(largeDoc, '/root/item[0]', []);
    });

    test('negative index [-5]', () {
      expectXPath(largeDoc, '/root/item[-5]', []);
    });

    test('fractional index [1.5]', () {
      expectXPath(largeDoc, '/root/item[1.5]', []);
    });

    test('integer float [1.0]', () {
      expectXPath(largeDoc, '/root/item[1.0]', ['<item id="0"/>']);
    });

    test('enormous BigInt index', () {
      expectXPath(largeDoc, '/root/item[999999999999999999999999999999]', []);
    });

    test('compound predicate with early-exit: item[@id = "500"][1]', () {
      expectXPath(largeDoc, '/root/item[@id = "500"][1]', ['<item id="500"/>']);
    });
  });

  group('predicate static analysis and constant indices', () {
    test('parenthesized constant index', () {
      expectXPath(current, 'e1[(1)]', ['<e1 a="1"/>']);
      expectXPath(current, 'e1[(2)]', []);
    });

    test('double constant indices', () {
      expectXPath(current, 'e1[1.0e0]', ['<e1 a="1"/>']);
      expectXPath(current, 'e1[2.0e0]', []);
      expectXPath(current, 'e1[1.5e0]', []);
      expectXPath(current, 'e1[-1.0e0]', []);
      expectXPath(current, 'e1[xs:double("NaN")]', []);
    });

    test('decimal and runtime numeric matches', () {
      expectXPath(current, 'e1[xs:decimal(1)]', ['<e1 a="1"/>']);
      expectXPath(current, 'e1[xs:decimal(2)]', []);
      expectXPath(current, 'e1[xs:decimal(1.5)]', []);
    });

    test('step collapsing with complex predicate expressions', () {
      expect(Predicate(parseExpression('(1, 2)')).isPositional, isTrue);
      expect(Predicate(parseExpression('(@a, @b)')).isPositional, isFalse);
      expect(
        Predicate(parseExpression('if (@a) then 1 else 2')).isPositional,
        isTrue,
      );
      expect(
        Predicate(parseExpression('if (@a) then true() else false()'))
            .isPositional,
        isFalse,
      );
      expect(Predicate(parseExpression('(1)[1]')).isPositional, isTrue);
      expect(Predicate(parseExpression('@a[@b]')).isPositional, isFalse);
      expect(Predicate(parseExpression('-position()')).isPositional, isTrue);
      expect(
        Predicate(parseExpression('@a || position()')).isPositional,
        isTrue,
      );
      expect(
        Predicate(parseExpression('(position(), 1)')).isPositional,
        isTrue,
      );
      expect(
        Predicate(parseExpression('if (position() = 1) then @a else @b'))
            .isPositional,
        isTrue,
      );
      expect(
        Predicate(parseExpression('(e1)[position() = 1]')).isPositional,
        isTrue,
      );
      expect(
        Predicate(parseExpression('-position() = -1')).isPositional,
        isTrue,
      );
      expect(
        Predicate(
          SequenceExpression([
            LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
          ]),
        ).constantIndex,
        equals(1),
      );

      expectXPath(document, '//e1[(@a, @a)]', ['<e1 a="1"/>']);
      expectXPath(document, '//e1[if (@a) then true() else false()]', [
        '<e1 a="1"/>',
      ]);
      expectXPath(document, '/r/*[-position() = -1]', ['<e1 a="1"/>']);
      expectXPath(document, '//e1[@a || "x" = "1x"]', ['<e1 a="1"/>']);
      expectXPath(document, '//r[e1[position() = 1]]', [
        '<r><e1 a="1"/><e2 a="2" b="3"/><e3 b="4"/></r>',
      ]);
    });
  });
}
