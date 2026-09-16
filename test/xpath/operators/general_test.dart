import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

XPathSequence intSeq(List<int> values) =>
    XPathSequence(values.map(XPathInteger.fromInt));

void main() {
  group('opAnd', () {
    test('true and true', () {
      expect(
        opAnd(XPathSequence.trueSequence, XPathSequence.trueSequence),
        XPathSequence.trueSequence,
      );
    });
    test('true and false', () {
      expect(
        opAnd(XPathSequence.trueSequence, XPathSequence.falseSequence),
        XPathSequence.falseSequence,
      );
    });
    test('false and true', () {
      expect(
        opAnd(XPathSequence.falseSequence, XPathSequence.trueSequence),
        XPathSequence.falseSequence,
      );
    });
  });

  group('opOr', () {
    test('true or true', () {
      expect(
        opOr(XPathSequence.trueSequence, XPathSequence.trueSequence),
        XPathSequence.trueSequence,
      );
    });
    test('false or false', () {
      expect(
        opOr(XPathSequence.falseSequence, XPathSequence.falseSequence),
        XPathSequence.falseSequence,
      );
    });
    test('true or false', () {
      expect(
        opOr(XPathSequence.trueSequence, XPathSequence.falseSequence),
        XPathSequence.trueSequence,
      );
    });
    test('false or true', () {
      expect(
        opOr(XPathSequence.falseSequence, XPathSequence.trueSequence),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGeneralEqual', () {
    test('overlapping ranges', () {
      expect(
        opGeneralEqual(intSeq([1, 2]), intSeq([2, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('disjoint ranges', () {
      expect(
        opGeneralEqual(intSeq([1, 2]), intSeq([3, 4])),
        XPathSequence.falseSequence,
      );
    });
    test('type coercion with untypedAtomic', () {
      expect(
        opGeneralEqual(
          intSeq([1]),
          XPathSequence([const XPathUntypedAtomic('1')]),
        ),
        XPathSequence.trueSequence,
      );
      expect(
        () => opGeneralEqual(
          intSeq([1]),
          XPathSequence([const XPathString('1')]),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralNotEqual', () {
    test('overlapping with not equal', () {
      expect(
        opGeneralNotEqual(intSeq([1, 2]), intSeq([2, 3])),
        XPathSequence.trueSequence,
      );
    });
    test('single value equal', () {
      expect(
        opGeneralNotEqual(intSeq([1]), intSeq([1])),
        XPathSequence.falseSequence,
      );
    });
    test('type coercion with untypedAtomic', () {
      expect(
        opGeneralNotEqual(
          intSeq([1]),
          XPathSequence([const XPathUntypedAtomic('1')]),
        ),
        XPathSequence.falseSequence,
      );
      expect(
        () => opGeneralNotEqual(
          intSeq([1]),
          XPathSequence([const XPathString('1')]),
        ),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('opGeneralLessThan', () {
    test('less than', () {
      expect(
        opGeneralLessThan(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGeneralGreaterThan', () {
    test('greater than', () {
      expect(
        opGeneralGreaterThan(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGeneralLessThanOrEqual', () {
    test('less than or equal', () {
      expect(
        opGeneralLessThanOrEqual(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
  });

  group('opGeneralGreaterThanOrEqual', () {
    test('greater than or equal', () {
      expect(
        opGeneralGreaterThanOrEqual(intSeq([1, 2]), intSeq([0, 3])),
        XPathSequence.trueSequence,
      );
    });
  });
}
