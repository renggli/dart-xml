import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/src/xpath/xdm/types.dart';

void main() {
  group('XPathType hierarchy and subtypes', () {
    test('primitive type relations', () {
      expect(xsInteger.isSubtypeOf(xsDecimal), isTrue);
      expect(xsDecimal.isSubtypeOf(xsNumeric), isTrue);
      expect(xsInteger.isSubtypeOf(xsNumeric), isTrue);
      expect(xsDouble.isSubtypeOf(xsNumeric), isTrue);
      expect(xsFloat.isSubtypeOf(xsNumeric), isTrue);
      expect(xsNumeric.isSubtypeOf(xsAnyAtomicType), isTrue);
      expect(xsString.isSubtypeOf(xsAnyAtomicType), isTrue);
      expect(xsAnyAtomicType.isSubtypeOf(xsItem), isTrue);
      expect(xsElement.isSubtypeOf(xsNode), isTrue);
      expect(xsAttribute.isSubtypeOf(xsNode), isTrue);
      expect(xsNode.isSubtypeOf(xsItem), isTrue);
      expect(xsFunction.isSubtypeOf(xsItem), isTrue);
      expect(xsMap.isSubtypeOf(xsFunction), isTrue);
      expect(xsArray.isSubtypeOf(xsFunction), isTrue);
      expect(xsString.isSubtypeOf(xsInteger), isFalse);
    });

    test('matchesItem and matchesSequence', () {
      final intItem = XPathInteger.fromInt(10);
      expect(xsInteger.matchesItem(intItem), isTrue);
      expect(xsDecimal.matchesItem(intItem), isTrue);
      expect(xsNumeric.matchesItem(intItem), isTrue);
      expect(xsString.matchesItem(intItem), isFalse);

      final seq = XPathSequence.single(intItem);
      expect(xsInteger.matchesSequence(seq), isTrue);
      expect(xsInteger.matchesSequence(XPathSequence.empty), isFalse);
      expect(
        xsInteger.matchesSequence(XPathSequence([intItem, intItem])),
        isFalse,
      );
    });

    test('toString returns name', () {
      expect(xsInteger.toString(), equals('xs:integer'));
      expect(xsString.toString(), equals('xs:string'));
      expect(xsItem.toString(), equals('item()'));
    });
  });

  group('XPathSequenceType', () {
    test('cardinality matching: zeroOrMore', () {
      const type = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrMore,
      );
      expect(type.isAtomic, isFalse);
      expect(type.matchesSequence(XPathSequence.empty), isTrue);
      expect(
        type.matchesSequence(XPathSequence([const XPathString('a')])),
        isTrue,
      );
      expect(
        type.matchesSequence(
          XPathSequence([const XPathString('a'), const XPathString('b')]),
        ),
        isTrue,
      );
      expect(
        type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])),
        isFalse,
      );
    });

    test('cardinality matching: zeroOrOne', () {
      const type = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.zeroOrOne,
      );
      expect(type.matchesSequence(XPathSequence.empty), isTrue);
      expect(
        type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])),
        isTrue,
      );
      expect(
        type.matchesSequence(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        isFalse,
      );
    });

    test('cardinality matching: oneOrMore', () {
      const type = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.oneOrMore,
      );
      expect(type.matchesSequence(XPathSequence.empty), isFalse);
      expect(
        type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])),
        isTrue,
      );
      expect(
        type.matchesSequence(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        isTrue,
      );
    });

    test('cardinality matching: exactlyOne', () {
      const type = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.exactlyOne,
      );
      expect(type.matchesSequence(XPathSequence.empty), isFalse);
      expect(
        type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])),
        isTrue,
      );
      expect(
        type.matchesSequence(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        isFalse,
      );
    });

    test('toString formatting', () {
      const t1 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrMore,
      );
      expect(t1.toString(), equals('xs:string*'));
      const t2 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrOne,
      );
      expect(t2.toString(), equals('xs:string?'));
      const t3 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.oneOrMore,
      );
      expect(t3.toString(), equals('xs:string+'));
      const t4 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.exactlyOne,
      );
      expect(t4.toString(), equals('xs:string'));
      expect(xsEmptySequence.toString(), equals('empty-sequence()'));
    });
  });

  group('standardTypes', () {
    test('lookup standard names and aliases', () {
      expect(standardTypes['xs:integer'], equals(xsInteger));
      expect(standardTypes['integer'], equals(xsInteger));
      expect(standardTypes['xs:string'], equals(xsString));
      expect(standardTypes['xs:boolean'], equals(xsBoolean));
      expect(standardTypes['item()'], equals(xsItem));
      expect(standardTypes['node()'], equals(xsNode));
      expect(standardTypes['element()'], equals(xsElement));
      expect(standardTypes['attribute()'], equals(xsAttribute));
      expect(standardTypes['map(*)'], equals(xsMap));
      expect(standardTypes['array(*)'], equals(xsArray));
      expect(standardTypes['non-existent-type'], isNull);
    });
  });
}
