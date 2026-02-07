import 'package:test/test.dart';
import 'package:xml/src/xpath/operators/general.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

void main() {
  test('op:and', () {
    expect(opAnd(XPathSequence.trueSequence, XPathSequence.trueSequence), [
      true,
    ]);
    expect(opAnd(XPathSequence.trueSequence, XPathSequence.falseSequence), [
      false,
    ]);
    expect(opAnd(XPathSequence.falseSequence, XPathSequence.trueSequence), [
      false,
    ]);
  });
  test('op:or', () {
    expect(opOr(XPathSequence.trueSequence, XPathSequence.trueSequence), [
      true,
    ]);
    expect(opOr(XPathSequence.falseSequence, XPathSequence.falseSequence), [
      false,
    ]);
    expect(opOr(XPathSequence.trueSequence, XPathSequence.falseSequence), [
      true,
    ]);
    expect(opOr(XPathSequence.falseSequence, XPathSequence.trueSequence), [
      true,
    ]);
  });
  test('op:general-equal', () {
    expect(
      opGeneralEqual(const XPathSequence([1, 2]), const XPathSequence([2, 3])),
      [true],
    );
    expect(
      opGeneralEqual(const XPathSequence([1, 2]), const XPathSequence([3, 4])),
      [false],
    );
    expect(
      opGeneralEqual(const XPathSequence([1]), const XPathSequence(['1'])),
      [true],
    );
  });
  test('op:general-not-equal', () {
    expect(
      opGeneralNotEqual(
        const XPathSequence([1, 2]),
        const XPathSequence([2, 3]),
      ),
      [true],
    );
    expect(
      opGeneralNotEqual(const XPathSequence([1]), const XPathSequence([1])),
      [false],
    );
    expect(
      opGeneralNotEqual(const XPathSequence([1]), const XPathSequence(['1'])),
      [false],
    );
  });

  test('op:general-less-than', () {
    expect(
      opGeneralLessThan(
        const XPathSequence([1, 2]),
        const XPathSequence([0, 3]),
      ),
      [true],
    );
  });
  test('op:general-greater-than', () {
    expect(
      opGeneralGreaterThan(
        const XPathSequence([1, 2]),
        const XPathSequence([0, 3]),
      ),
      [true],
    );
  });
  test('op:general-less-than-or-equal', () {
    expect(
      opGeneralLessThanOrEqual(
        const XPathSequence([1, 2]),
        const XPathSequence([0, 3]),
      ),
      [true],
    );
  });
  test('op:general-greater-than-or-equal', () {
    expect(
      opGeneralGreaterThanOrEqual(
        const XPathSequence([1, 2]),
        const XPathSequence([0, 3]),
      ),
      [true],
    );
  });
}
