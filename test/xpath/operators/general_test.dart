import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/xml.dart';
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
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralLessThan(q1, q2),
        throwsA(isXPathEvaluationException()),
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
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralGreaterThan(q1, q2),
        throwsA(isXPathEvaluationException()),
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
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralLessThanOrEqual(q1, q2),
        throwsA(isXPathEvaluationException()),
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
    test('QName order comparison throws XPTY0004', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('a')));
      const q2 = XPathSequence.single(XPathQName(XmlName('b')));
      expect(
        () => opGeneralGreaterThanOrEqual(q1, q2),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('general comparison with QName, Duration, Binary, Untyped', () {
    test('QName equality and inequality', () {
      const q1 = XPathSequence.single(XPathQName(XmlName('foo')));
      const q2 = XPathSequence.single(XPathQName(XmlName('foo')));
      const q3 = XPathSequence.single(XPathQName(XmlName('bar')));
      expect(opGeneralEqual(q1, q2), XPathSequence.trueSequence);
      expect(opGeneralEqual(q1, q3), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(q1, q2), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(q1, q3), XPathSequence.trueSequence);
    });

    test('Duration equality and inequality', () {
      const d1 = XPathSequence.single(XPathDuration.dayTime(1000));
      const d2 = XPathSequence.single(XPathDuration.dayTime(1000));
      const d3 = XPathSequence.single(XPathDuration.dayTime(2000));
      expect(opGeneralEqual(d1, d2), XPathSequence.trueSequence);
      expect(opGeneralEqual(d1, d3), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(d1, d2), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(d1, d3), XPathSequence.trueSequence);
    });

    test('Binary equality and inequality', () {
      final b1 = XPathSequence.single(XPathBinary.fromHex('0102'));
      final b2 = XPathSequence.single(XPathBinary.fromHex('0102'));
      final b3 = XPathSequence.single(XPathBinary.fromHex('0304'));
      expect(opGeneralEqual(b1, b2), XPathSequence.trueSequence);
      expect(opGeneralEqual(b1, b3), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(b1, b2), XPathSequence.falseSequence);
      expect(opGeneralNotEqual(b1, b3), XPathSequence.trueSequence);
    });

    test('untypedAtomic comparisons', () {
      const u1 = XPathSequence.single(XPathUntypedAtomic('abc'));
      const u2 = XPathSequence.single(XPathUntypedAtomic('abc'));
      const u3 = XPathSequence.single(XPathUntypedAtomic('def'));
      expect(opGeneralEqual(u1, u2), XPathSequence.trueSequence);
      expect(opGeneralEqual(u1, u3), XPathSequence.falseSequence);

      const uDate = XPathSequence.single(
        XPathUntypedAtomic('2024-01-01T00:00:00Z'),
      );
      final date = XPathSequence.single(
        XPathDateTime.fromDateTime(DateTime.utc(2024, 1, 1), 0),
      );
      expect(opGeneralEqual(uDate, date), XPathSequence.trueSequence);
    });
  });
}
