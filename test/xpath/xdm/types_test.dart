import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';
import 'package:xml/src/xpath/functions/node.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/function_item.dart';
import 'package:xml/src/xpath/xdm/functions/array.dart';
import 'package:xml/src/xpath/xdm/functions/map.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/src/xpath/xdm/types.dart';

/// The arity-1 variant of `fn:name` with declared param `node()?` and return `xs:string`.
XPathFunctionItem get fnName1 =>
    (fnName as XPathOverloadedFunction).byArity[1]!;

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

  group('XPathArrayType', () {
    test('isAny for default constructor', () {
      const t = XPathArrayType();
      expect(t.name, equals('array(*)'));
      expect(t.memberType, equals(xsSequence));
    });

    test('named member type', () {
      const t = XPathArrayType(xsInteger);
      expect(t.name, equals('array(xs:integer)'));
    });

    test('isSubtypeOf hierarchy', () {
      const anyArray = XPathArrayType();
      const intArray = XPathArrayType(xsInteger);
      // typed array is subtype of array(*) (the constant)
      expect(intArray.isSubtypeOf(xsArray), isTrue);
      // typed array is subtype of anyArray
      expect(intArray.isSubtypeOf(anyArray), isTrue);
      // array(*) is subtype of function(*) and item()
      expect(xsArray.isSubtypeOf(xsFunction), isTrue);
      expect(xsArray.isSubtypeOf(xsItem), isTrue);
      // anyArray is subtype of anyArray
      expect(anyArray.isSubtypeOf(anyArray), isTrue);
      // anyArray is NOT subtype of typed array
      expect(anyArray.isSubtypeOf(intArray), isFalse);
      // intArray is NOT subtype of string array
      expect(intArray.isSubtypeOf(const XPathArrayType(xsString)), isFalse);
    });

    test('matchesItem filters by member type', () {
      const arr = XPathArray([]);
      const anyArray = XPathArrayType();
      expect(anyArray.matchesItem(arr), isTrue);

      final intArr = XPathArray([
        XPathSequence.single(XPathInteger.fromInt(1)),
        XPathSequence.single(XPathInteger.fromInt(2)),
      ]);
      const intArray = XPathArrayType(xsInteger);
      expect(intArray.matchesItem(intArr), isTrue);

      const strArray = XPathArrayType(xsString);
      expect(strArray.matchesItem(intArr), isFalse);
    });
  });

  group('XPathMapType', () {
    test('wildcard map', () {
      const t = XPathMapType();
      expect(t.name, equals('map(*)'));
    });

    test('typed map name', () {
      const t = XPathMapType(xsInteger, xsString);
      expect(t.name, equals('map(xs:integer, xs:string)'));
    });

    test('isSubtypeOf hierarchy', () {
      const anyMap = XPathMapType();
      const intStrMap = XPathMapType(xsInteger, xsString);
      // typed map is subtype of map(*)
      expect(intStrMap.isSubtypeOf(xsMap), isTrue);
      expect(intStrMap.isSubtypeOf(anyMap), isTrue);
      // map(*) is subtype of function(*) and item()
      expect(xsMap.isSubtypeOf(xsFunction), isTrue);
      expect(xsMap.isSubtypeOf(xsItem), isTrue);
      // anyMap is NOT subtype of typed map
      expect(anyMap.isSubtypeOf(intStrMap), isFalse);
      // map(xs:integer, xs:string) IS subtype of map(xs:decimal, xs:string)
      // (xs:integer is subtype of xs:decimal, xs:string is subtype of xs:string)
      expect(
        intStrMap.isSubtypeOf(const XPathMapType(xsDecimal, xsString)),
        isTrue,
      );
    });

    test('isSubtypeOf function type (map-as-function)', () {
      const intStrMap = XPathMapType(xsInteger, xsString);
      // map(xs:integer, xs:string) is subtype of function(xs:anyAtomicType) as item()*
      expect(
        intStrMap.isSubtypeOf(
          const XPathFunctionType(
            parameterTypes: [
              XPathSequenceType(
                itemType: xsAnyAtomicType,
                cardinality: XPathCardinality.exactlyOne,
              ),
            ],
            returnType: XPathSequenceType(
              itemType: xsItem,
              cardinality: XPathCardinality.zeroOrMore,
            ),
          ),
        ),
        isTrue,
      );
      // map(xs:integer, xs:string) is NOT subtype of function(xs:string) as item()*
      // because xs:integer is NOT subtype of xs:string
      expect(
        intStrMap.isSubtypeOf(
          const XPathFunctionType(
            parameterTypes: [
              XPathSequenceType(
                itemType: xsString,
                cardinality: XPathCardinality.exactlyOne,
              ),
            ],
          ),
        ),
        isFalse,
      );
    });
  });

  group('XPathFunctionType', () {
    test('wildcard function', () {
      const t = XPathFunctionType();
      expect(t.name, equals('function(*)'));
      expect(t.isAny, isTrue);
    });

    test('typed function name', () {
      const t = XPathFunctionType(
        parameterTypes: [
          XPathSequenceType(
            itemType: xsInteger,
            cardinality: XPathCardinality.exactlyOne,
          ),
        ],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.exactlyOne,
        ),
      );
      expect(t.name, equals('function(xs:integer) as xs:string'));
    });

    test('isSubtypeOf hierarchy', () {
      const anyFn = XPathFunctionType();
      // Any typed function is subtype of function(*)
      expect(
        const XPathFunctionType(
          parameterTypes: [
            XPathSequenceType(
              itemType: xsInteger,
              cardinality: XPathCardinality.exactlyOne,
            ),
          ],
        ).isSubtypeOf(anyFn),
        isTrue,
      );
      // function(*) is subtype of function(*) (same)
      expect(anyFn.isSubtypeOf(anyFn), isTrue);
      // function(*) is subtype of xsFunction and xsItem
      expect(anyFn.isSubtypeOf(xsFunction), isTrue);
      expect(anyFn.isSubtypeOf(xsItem), isTrue);
    });

    test('isSubtypeOf contravariance and covariance', () {
      // function(node()?) as xs:string is subtype of function(element()) as xs:string
      // because element() IS subtype of node()? (contravariance: test param subtype of fn param)
      const fnNodeOptStr = XPathFunctionType(
        parameterTypes: [
          XPathSequenceType(
            itemType: xsNode,
            cardinality: XPathCardinality.zeroOrOne,
          ),
        ],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.exactlyOne,
        ),
      );
      const testElemStr = XPathFunctionType(
        parameterTypes: [
          XPathSequenceType(
            itemType: xsElement,
            cardinality: XPathCardinality.exactlyOne,
          ),
        ],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.exactlyOne,
        ),
      );
      expect(fnNodeOptStr.isSubtypeOf(testElemStr), isTrue);
      // Not the reverse: function(element()) as xs:string is NOT subtype of
      // function(node()?) as xs:string (node()? is NOT subtype of element())
      expect(testElemStr.isSubtypeOf(fnNodeOptStr), isFalse);
    });

    test('matchesItem on typed function item', () {
      const fnType = XPathFunctionType(
        parameterTypes: [
          XPathSequenceType(
            itemType: xsNode,
            cardinality: XPathCardinality.zeroOrOne,
          ),
        ],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.exactlyOne,
        ),
      );
      // Wildcard function(*) matches any function item.
      const anyFnType = XPathFunctionType();
      expect(anyFnType.matchesItem(fnName1), isTrue);
      // Exact declared type matches.
      expect(fnType.matchesItem(fnName1), isTrue);
      // Mismatched return type is not a match.
      const wrongReturnType = XPathFunctionType(
        parameterTypes: [
          XPathSequenceType(
            itemType: xsNode,
            cardinality: XPathCardinality.zeroOrOne,
          ),
        ],
        returnType: XPathSequenceType(
          itemType: xsInteger,
          cardinality: XPathCardinality.exactlyOne,
        ),
      );
      expect(wrongReturnType.matchesItem(fnName1), isFalse);
    });

    test('equality and hashCode on XPathFunctionType', () {
      const fn1 = XPathFunctionType();
      const fn2 = XPathFunctionType();
      expect(fn1 == fn2, isTrue);
      expect(fn1.hashCode, equals(fn2.hashCode));
    });
  });

  group('xsEmptySequenceType', () {
    test('isSubtypeOf sequence types with optional cardinality', () {
      const optStr = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrOne,
      );
      const starStr = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrMore,
      );
      const oneStr = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.exactlyOne,
      );

      expect(xsEmptySequence.isSubtypeOf(optStr), isTrue);
      expect(xsEmptySequence.isSubtypeOf(starStr), isTrue);
      expect(xsEmptySequence.isSubtypeOf(oneStr), isFalse);
      expect(xsEmptySequence.isSubtypeOf(xsItem), isFalse);
      expect(xsEmptySequence.isSubtypeOf(xsEmptySequence), isTrue);
    });

    test('matchesItem and matchesSequence', () {
      expect(xsEmptySequence.matchesItem(XPathInteger.fromInt(1)), isFalse);
      expect(xsEmptySequence.matchesSequence(XPathSequence.empty), isTrue);
      expect(
        xsEmptySequence.matchesSequence(
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
        isFalse,
      );
    });
  });

  group('XPathMapType matchesItem and equality', () {
    test('matchesItem validates key and value types', () {
      const intStrMapType = XPathMapType(xsInteger, xsString);
      final validMap = XPathMap({
        XPathInteger.fromInt(1): const XPathSequence.single(XPathString('one')),
      });
      final invalidKeyMap = XPathMap({
        const XPathString('1'): const XPathSequence.single(XPathString('one')),
      });
      final invalidValMap = XPathMap({
        XPathInteger.fromInt(1): XPathSequence.single(XPathInteger.fromInt(1)),
      });

      expect(intStrMapType.matchesItem(validMap), isTrue);
      expect(intStrMapType.matchesItem(invalidKeyMap), isFalse);
      expect(intStrMapType.matchesItem(invalidValMap), isFalse);
      expect(intStrMapType.matchesItem(XPathInteger.fromInt(1)), isFalse);
    });

    test('equality and hashCode', () {
      const map1 = XPathMapType(xsInteger, xsString);
      const map2 = XPathMapType(xsInteger, xsString);
      const map3 = XPathMapType(xsInteger, xsInteger);
      expect(map1 == map2, isTrue);
      expect(map1 == map3, isFalse);
      expect(map1.hashCode, equals(map2.hashCode));
    });
  });

  group('Additional type hierarchy edge cases', () {
    test('XPathSequenceType exactlyOne isSubtypeOf atomic type and matchesItem/hashCode', () {
      const seqType = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.exactlyOne,
      );
      expect(seqType.isSubtypeOf(xsNumeric), isTrue);
      expect(seqType.isSubtypeOf(xsString), isFalse);
      expect(seqType.matchesItem(XPathInteger.fromInt(42)), isTrue);
      expect(seqType.matchesItem(const XPathString('abc')), isFalse);
      expect(seqType.hashCode, isA<int>());
    });

    test('XPathArrayType hashCode', () {
      const arrType = XPathArrayType(xsInteger);
      expect(arrType.hashCode, equals(xsInteger.hashCode));
    });

    test('XPathFunctionType matching XPathMap', () {
      final mapItem = XPathMap({
        const XPathString('key'): const XPathSequence.single(
          XPathString('val'),
        ),
      });
      const validFnType = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.zeroOrOne,
        ),
      );
      expect(validFnType.matchesItem(mapItem), isTrue);

      // Return type does not accept empty sequence
      const invalidEmptyReturnFnType = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsString,
      );
      expect(invalidEmptyReturnFnType.matchesItem(mapItem), isFalse);

      // Invalid param type (non-atomic)
      const invalidParamFnType = XPathFunctionType(
        parameterTypes: [xsNode],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.zeroOrOne,
        ),
      );
      expect(invalidParamFnType.matchesItem(mapItem), isFalse);
    });

    test('XPathFunctionType matching XPathArray', () {
      const arrItem = XPathArray([XPathSequence.single(XPathString('first'))]);
      const validArrFnType = XPathFunctionType(
        parameterTypes: [xsInteger],
        returnType: xsString,
      );
      expect(validArrFnType.matchesItem(arrItem), isTrue);

      const invalidParamArrFnType = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsString,
      );
      expect(invalidParamArrFnType.matchesItem(arrItem), isFalse);

      const invalidReturnArrFnType = XPathFunctionType(
        parameterTypes: [xsInteger],
        returnType: xsInteger,
      );
      expect(invalidReturnArrFnType.matchesItem(arrItem), isFalse);
    });

    test('XPathFunctionType equality and hashCode with parameterTypes', () {
      const fn1 = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsInteger,
      );
      const fn2 = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsInteger,
      );
      const fn3 = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsString,
      );
      expect(fn1 == fn2, isTrue);
      expect(fn1 == fn3, isFalse);
      expect(fn1.hashCode, equals(fn2.hashCode));
    });
  });
}
