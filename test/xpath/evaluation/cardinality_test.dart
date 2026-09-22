import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';

void main() {
  group('XPathCardinality', () {
    test('toString returns occurrence suffix', () {
      expect('${XPathCardinality.exactlyOne}', '');
      expect('${XPathCardinality.zeroOrOne}', '?');
      expect('${XPathCardinality.oneOrMore}', '+');
      expect('${XPathCardinality.zeroOrMore}', '*');
    });

    group('isSubtypeOf', () {
      // exactlyOne (∅) is the most specific: subtype of everything.
      test('exactlyOne is subtype of every cardinality', () {
        expect(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.exactlyOne),
          isTrue,
        );
        expect(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.zeroOrOne),
          isTrue,
        );
        expect(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.oneOrMore),
          isTrue,
        );
        expect(
          XPathCardinality.exactlyOne.isSubtypeOf(XPathCardinality.zeroOrMore),
          isTrue,
        );
      });

      // zeroOrOne (?) is subtype of ? and * only.
      test('zeroOrOne subtype relations', () {
        expect(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.exactlyOne),
          isFalse,
        );
        expect(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.zeroOrOne),
          isTrue,
        );
        expect(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.oneOrMore),
          isFalse,
        );
        expect(
          XPathCardinality.zeroOrOne.isSubtypeOf(XPathCardinality.zeroOrMore),
          isTrue,
        );
      });

      // oneOrMore (+) is subtype of + and * only.
      test('oneOrMore subtype relations', () {
        expect(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.exactlyOne),
          isFalse,
        );
        expect(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.zeroOrOne),
          isFalse,
        );
        expect(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.oneOrMore),
          isTrue,
        );
        expect(
          XPathCardinality.oneOrMore.isSubtypeOf(XPathCardinality.zeroOrMore),
          isTrue,
        );
      });

      // zeroOrMore (*) is the most general: only subtype of itself.
      test('zeroOrMore is only subtype of itself', () {
        expect(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.exactlyOne),
          isFalse,
        );
        expect(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.zeroOrOne),
          isFalse,
        );
        expect(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.oneOrMore),
          isFalse,
        );
        expect(
          XPathCardinality.zeroOrMore.isSubtypeOf(XPathCardinality.zeroOrMore),
          isTrue,
        );
      });
    });
  });
}
