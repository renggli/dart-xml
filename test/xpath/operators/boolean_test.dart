import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/boolean.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  group('op:boolean-equal', () {
    test('true with true', () {
      expect(
        opBooleanEqual(XPathSequence.trueSequence, XPathSequence.trueSequence),
        [true],
      );
    });
    test('true with false', () {
      expect(
        opBooleanEqual(XPathSequence.trueSequence, XPathSequence.falseSequence),
        [false],
      );
    });
  });

  group('op:boolean-less-than', () {
    test('false with true', () {
      expect(
        opBooleanLessThan(
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ),
        [true],
      );
    });
    test('true with true', () {
      expect(
        opBooleanLessThan(
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ),
        [false],
      );
    });
  });

  group('op:boolean-greater-than', () {
    test('true with false', () {
      expect(
        opBooleanGreaterThan(
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ),
        [true],
      );
    });
    test('false with true', () {
      expect(
        opBooleanGreaterThan(
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ),
        [false],
      );
    });
  });

  final xml = XmlDocument.parse('<r><a>1</a><b>2<c/>3</b></r>');

  group('<', () {
    test('less than', () {
      expectEvaluate(xml, '1 < 2', [isTrue]);
    });
    test('equal is not less than', () {
      expectEvaluate(xml, '2 < 2', [isFalse]);
    });
    test('greater is not less than', () {
      expectEvaluate(xml, '2 < 1', [isFalse]);
    });
  });

  group('<=', () {
    test('less than', () {
      expectEvaluate(xml, '1 <= 2', [isTrue]);
    });
    test('equal', () {
      expectEvaluate(xml, '2 <= 2', [isTrue]);
    });
    test('greater is not less than or equal', () {
      expectEvaluate(xml, '2 <= 1', [isFalse]);
    });
  });

  group('>', () {
    test('less is not greater than', () {
      expectEvaluate(xml, '1 > 2', [isFalse]);
    });
    test('equal is not greater than', () {
      expectEvaluate(xml, '2 > 2', [isFalse]);
    });
    test('greater than', () {
      expectEvaluate(xml, '2 > 1', [isTrue]);
    });
  });

  group('>=', () {
    test('less is not greater than or equal', () {
      expectEvaluate(xml, '1 >= 2', [isFalse]);
    });
    test('equal', () {
      expectEvaluate(xml, '2 >= 2', [isTrue]);
    });
    test('greater than', () {
      expectEvaluate(xml, '2 >= 1', [isTrue]);
    });
  });

  group('=', () {
    test('different is not equal', () {
      expectEvaluate(xml, '1 = 2', [isFalse]);
    });
    test('equal', () {
      expectEvaluate(xml, '2 = 2', [isTrue]);
    });
  });

  group('!=', () {
    test('different is not equal', () {
      expectEvaluate(xml, '1 != 2', [isTrue]);
    });
    test('equal', () {
      expectEvaluate(xml, '2 != 2', [isFalse]);
    });
  });

  group('and', () {
    test('true and true', () {
      expectEvaluate(xml, 'true() and true()', [isTrue]);
    });
    test('true and false', () {
      expectEvaluate(xml, 'true() and false()', [isFalse]);
    });
    test('false and true', () {
      expectEvaluate(xml, 'false() and true()', [isFalse]);
    });
    test('false and false', () {
      expectEvaluate(xml, 'false() and false()', [isFalse]);
    });
  });

  group('or', () {
    test('true or true', () {
      expectEvaluate(xml, 'true() or true()', [isTrue]);
    });
    test('true or false', () {
      expectEvaluate(xml, 'true() or false()', [isTrue]);
    });
    test('false or true', () {
      expectEvaluate(xml, 'false() or true()', [isTrue]);
    });
    test('false or false', () {
      expectEvaluate(xml, 'false() or false()', [isFalse]);
    });
  });
}
