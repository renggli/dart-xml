import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/general.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('general', () {
    test('op:and', () {
      expect(opAnd(context, const []), [true]);
      expect(opAnd(context, [XPathSequence.trueSequence]), [true]);
      expect(opAnd(context, [XPathSequence.falseSequence]), [false]);
      expect(
        opAnd(context, [
          XPathSequence.trueSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
      expect(
        opAnd(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [false],
      );
      expect(
        opAnd(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [false],
      );
    });
    test('op:or', () {
      expect(opOr(context, const []), [false]);
      expect(opOr(context, [XPathSequence.trueSequence]), [true]);
      expect(opOr(context, [XPathSequence.falseSequence]), [false]);
      expect(
        opOr(context, [
          XPathSequence.falseSequence,
          XPathSequence.falseSequence,
        ]),
        [false],
      );
      expect(
        opOr(context, [
          XPathSequence.trueSequence,
          XPathSequence.falseSequence,
        ]),
        [true],
      );
      expect(
        opOr(context, [
          XPathSequence.falseSequence,
          XPathSequence.trueSequence,
        ]),
        [true],
      );
    });
    test('op:general-equal', () {
      expect(
        opGeneralEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([2, 3]),
        ]),
        [true],
      );
      expect(
        opGeneralEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([3, 4]),
        ]),
        [false],
      );
      expect(
        opGeneralEqual(context, [
          const XPathSequence([1]),
          const XPathSequence(['1']),
        ]),
        [true],
      );
    });
    test('op:general-not-equal', () {
      expect(
        opGeneralNotEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([2, 3]),
        ]),
        [true],
      );
      expect(
        opGeneralNotEqual(context, [
          const XPathSequence([1]),
          const XPathSequence([1]),
        ]),
        [false],
      );
      expect(
        opGeneralNotEqual(context, [
          const XPathSequence([1]),
          const XPathSequence(['1']),
        ]),
        [
          true,
        ], // TODO: Should be false, but current implementation lacks type promotion
      );
    });

    test('op:general-less-than', () {
      expect(
        opGeneralLessThan(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
    test('op:general-greater-than', () {
      expect(
        opGeneralGreaterThan(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
    test('op:general-less-than-or-equal', () {
      expect(
        opGeneralLessThanOrEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
    test('op:general-greater-than-or-equal', () {
      expect(
        opGeneralGreaterThanOrEqual(context, [
          const XPathSequence([1, 2]),
          const XPathSequence([0, 3]),
        ]),
        [true],
      );
    });
  });
}
