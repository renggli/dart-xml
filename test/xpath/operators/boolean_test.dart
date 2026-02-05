import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/boolean.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('boolean', () {
    test('op:boolean-equal', () {
      expect(
        opBooleanEqual(XPathSequence.trueSequence, XPathSequence.trueSequence),
        [true],
      );
      expect(
        opBooleanEqual(XPathSequence.trueSequence, XPathSequence.falseSequence),
        [false],
      );
    });
    test('op:boolean-less-than', () {
      expect(
        opBooleanLessThan(
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ),
        [true],
      );
      expect(
        opBooleanLessThan(
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ),
        [false],
      );
    });
    test('op:boolean-greater-than', () {
      expect(
        opBooleanGreaterThan(
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ),
        [true],
      );
      expect(
        opBooleanGreaterThan(
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ),
        [false],
      );
    });
  });
  group('integration', () {
    final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');

    test('<', () {
      expectEvaluate(xml, '1 < 2', [isTrue]);
      expectEvaluate(xml, '2 < 2', [isFalse]);
      expectEvaluate(xml, '2 < 1', [isFalse]);
    });
    test('<=', () {
      expectEvaluate(xml, '1 <= 2', [isTrue]);
      expectEvaluate(xml, '2 <= 2', [isTrue]);
      expectEvaluate(xml, '2 <= 1', [isFalse]);
    });
    test('>', () {
      expectEvaluate(xml, '1 > 2', [isFalse]);
      expectEvaluate(xml, '2 > 2', [isFalse]);
      expectEvaluate(xml, '2 > 1', [isTrue]);
    });
    test('>=', () {
      expectEvaluate(xml, '1 >= 2', [isFalse]);
      expectEvaluate(xml, '2 >= 2', [isTrue]);
      expectEvaluate(xml, '2 >= 1', [isTrue]);
    });
    test('=', () {
      expectEvaluate(xml, '1 = 2', [isFalse]);
      expectEvaluate(xml, '2 = 2', [isTrue]);
      expectEvaluate(xml, '2 = 1', [isFalse]);
    });
    test('!=', () {
      expectEvaluate(xml, '1 != 2', [isTrue]);
      expectEvaluate(xml, '2 != 2', [isFalse]);
      expectEvaluate(xml, '2 != 1', [isTrue]);
    });
    test('and', () {
      expectEvaluate(xml, 'true() and true()', [isTrue]);
      expectEvaluate(xml, 'true() and false()', [isFalse]);
      expectEvaluate(xml, 'false() and true()', [isFalse]);
      expectEvaluate(xml, 'false() and false()', [isFalse]);
    });
    test('or', () {
      expectEvaluate(xml, 'true() or true()', [isTrue]);
      expectEvaluate(xml, 'true() or false()', [isTrue]);
      expectEvaluate(xml, 'false() or true()', [isTrue]);
      expectEvaluate(xml, 'false() or false()', [isFalse]);
    });
  });
}
