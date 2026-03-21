import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opAnd', () {
    test('true and true', () {
      expect(opAnd(XPathSequence.trueSequence, XPathSequence.trueSequence), [
        true,
      ]);
    });
    test('true and false', () {
      expect(opAnd(XPathSequence.trueSequence, XPathSequence.falseSequence), [
        false,
      ]);
    });
    test('false and true', () {
      expect(opAnd(XPathSequence.falseSequence, XPathSequence.trueSequence), [
        false,
      ]);
    });
  });

  group('opOr', () {
    test('true or true', () {
      expect(opOr(XPathSequence.trueSequence, XPathSequence.trueSequence), [
        true,
      ]);
    });
    test('false or false', () {
      expect(opOr(XPathSequence.falseSequence, XPathSequence.falseSequence), [
        false,
      ]);
    });
    test('true or false', () {
      expect(opOr(XPathSequence.trueSequence, XPathSequence.falseSequence), [
        true,
      ]);
    });
    test('false or true', () {
      expect(opOr(XPathSequence.falseSequence, XPathSequence.trueSequence), [
        true,
      ]);
    });
  });

  group('opGeneralEqual', () {
    test('overlapping ranges', () {
      expect(
        opGeneralEqual(
          const XPathSequence([1, 2]),
          const XPathSequence([2, 3]),
        ),
        [true],
      );
    });
    test('disjoint ranges', () {
      expect(
        opGeneralEqual(
          const XPathSequence([1, 2]),
          const XPathSequence([3, 4]),
        ),
        [false],
      );
    });
    test('type coercion', () {
      expect(
        opGeneralEqual(const XPathSequence([1]), const XPathSequence(['1'])),
        [true],
      );
    });
  });

  group('opGeneralNotEqual', () {
    test('overlapping with not equal', () {
      expect(
        opGeneralNotEqual(
          const XPathSequence([1, 2]),
          const XPathSequence([2, 3]),
        ),
        [true],
      );
    });
    test('single value equal', () {
      expect(
        opGeneralNotEqual(const XPathSequence([1]), const XPathSequence([1])),
        [false],
      );
    });
    test('type coercion', () {
      expect(
        opGeneralNotEqual(const XPathSequence([1]), const XPathSequence(['1'])),
        [false],
      );
    });
  });

  group('opGeneralLessThan', () {
    test('less than', () {
      expect(
        opGeneralLessThan(
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ),
        [true],
      );
    });
  });

  group('opGeneralGreaterThan', () {
    test('greater than', () {
      expect(
        opGeneralGreaterThan(
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ),
        [true],
      );
    });
  });

  group('opGeneralLessThanOrEqual', () {
    test('less than or equal', () {
      expect(
        opGeneralLessThanOrEqual(
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ),
        [true],
      );
    });
  });

  group('opGeneralGreaterThanOrEqual', () {
    test('greater than or equal', () {
      expect(
        opGeneralGreaterThanOrEqual(
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ),
        [true],
      );
    });
  });
}
