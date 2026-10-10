import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';

void main() {
  group('XPathCardinality', () {
    test('toString returns occurrence suffix', () {
      check('${XPathCardinality.exactlyOne}').equals('');
      check('${XPathCardinality.zeroOrOne}').equals('?');
      check('${XPathCardinality.oneOrMore}').equals('+');
      check('${XPathCardinality.zeroOrMore}').equals('*');
    });

    group('isSubtypeOf', () {
      // exactlyOne (∅) is the most specific: subtype of everything.
      test('exactlyOne is subtype of every cardinality', () {
        check(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.exactlyOne),
        ).isTrue();
        check(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.zeroOrOne),
        ).isTrue();
        check(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.oneOrMore),
        ).isTrue();
        check(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.zeroOrMore),
        ).isTrue();
      });

      // zeroOrOne (?) is subtype of ? and * only.
      test('zeroOrOne subtype relations', () {
        check(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.exactlyOne),
        ).isFalse();
        check(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.zeroOrOne),
        ).isTrue();
        check(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.oneOrMore),
        ).isFalse();
        check(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.zeroOrMore),
        ).isTrue();
      });

      // oneOrMore (+) is subtype of + and * only.
      test('oneOrMore subtype relations', () {
        check(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.exactlyOne),
        ).isFalse();
        check(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.zeroOrOne),
        ).isFalse();
        check(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.oneOrMore),
        ).isTrue();
        check(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.zeroOrMore),
        ).isTrue();
      });

      // zeroOrMore (*) is the most general: only subtype of itself.
      test('zeroOrMore is only subtype of itself', () {
        check(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.exactlyOne),
        ).isFalse();
        check(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.zeroOrOne),
        ).isFalse();
        check(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.oneOrMore),
        ).isFalse();
        check(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.zeroOrMore),
        ).isTrue();
      });
    });
  });
}
