import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';
import 'package:xml/src/xpath/functions/node.dart';
import 'package:xml/src/xpath/xdm/function_item.dart';
import 'package:xml/xpath.dart';

/// The arity-1 variant of `fn:name` with declared param `node()?` and return `xs:string`.
XPathFunctionItem get fnName1 =>
    (fnName as XPathOverloadedFunction).byArity[1]!;

void main() {
  group('XPathType hierarchy and subtypes', () {
    test('primitive type relations', () {
      check(xsInteger.isSubtypeOf(xsDecimal)).isTrue();
      check(xsDecimal.isSubtypeOf(xsNumeric)).isTrue();
      check(xsInteger.isSubtypeOf(xsNumeric)).isTrue();
      check(xsDouble.isSubtypeOf(xsNumeric)).isTrue();
      check(xsFloat.isSubtypeOf(xsNumeric)).isTrue();
      check(xsNumeric.isSubtypeOf(xsAnyAtomicType)).isTrue();
      check(xsString.isSubtypeOf(xsAnyAtomicType)).isTrue();
      check(xsAnyAtomicType.isSubtypeOf(xsItem)).isTrue();
      check(xsElement.isSubtypeOf(xsNode)).isTrue();
      check(xsAttribute.isSubtypeOf(xsNode)).isTrue();
      check(xsNode.isSubtypeOf(xsItem)).isTrue();
      check(xsFunction.isSubtypeOf(xsItem)).isTrue();
      check(xsMap.isSubtypeOf(xsFunction)).isTrue();
      check(xsArray.isSubtypeOf(xsFunction)).isTrue();
      check(xsString.isSubtypeOf(xsInteger)).isFalse();
    });

    test('matchesItem and matchesSequence', () {
      final intItem = XPathInteger.fromInt(10);
      check(xsInteger.matchesItem(intItem)).isTrue();
      check(xsDecimal.matchesItem(intItem)).isTrue();
      check(xsNumeric.matchesItem(intItem)).isTrue();
      check(xsString.matchesItem(intItem)).isFalse();

      final seq = XPathSequence.single(intItem);
      check(xsInteger.matchesSequence(seq)).isTrue();
      check(xsInteger.matchesSequence(XPathSequence.empty)).isFalse();
      check(xsInteger.matchesSequence(XPathSequence([intItem, intItem])))
          .isFalse();
    });

    test('toString returns name', () {
      check(xsInteger.toString()).equals('xs:integer');
      check(xsString.toString()).equals('xs:string');
      check(xsItem.toString()).equals('item()');
    });
  });

  group('XPathSequenceType', () {
    test('cardinality matching: zeroOrMore', () {
      const type = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrMore,
      );
      check(type.isAtomic).isFalse();
      check(type.matchesSequence(XPathSequence.empty)).isTrue();
      check(type.matchesSequence(XPathSequence([const XPathString('a')])))
          .isTrue();
      check(
        type.matchesSequence(
          XPathSequence([const XPathString('a'), const XPathString('b')]),
        ),
      ).isTrue();
      check(type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])))
          .isFalse();
    });

    test('cardinality matching: zeroOrOne', () {
      const type = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.zeroOrOne,
      );
      check(type.matchesSequence(XPathSequence.empty)).isTrue();
      check(type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])))
          .isTrue();
      check(
        type.matchesSequence(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
      ).isFalse();
    });

    test('cardinality matching: oneOrMore', () {
      const type = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.oneOrMore,
      );
      check(type.matchesSequence(XPathSequence.empty)).isFalse();
      check(type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])))
          .isTrue();
      check(
        type.matchesSequence(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
      ).isTrue();
    });

    test('cardinality matching: exactlyOne', () {
      const type = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.exactlyOne,
      );
      check(type.matchesSequence(XPathSequence.empty)).isFalse();
      check(type.matchesSequence(XPathSequence([XPathInteger.fromInt(1)])))
          .isTrue();
      check(
        type.matchesSequence(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
      ).isFalse();
    });

    test('toString formatting', () {
      const t1 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrMore,
      );
      check(t1.toString()).equals('xs:string*');
      const t2 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.zeroOrOne,
      );
      check(t2.toString()).equals('xs:string?');
      const t3 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.oneOrMore,
      );
      check(t3.toString()).equals('xs:string+');
      const t4 = XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.exactlyOne,
      );
      check(t4.toString()).equals('xs:string');
      check(xsEmptySequence.toString()).equals('empty-sequence()');
    });
  });

  group('standardTypes', () {
    test('lookup standard names and aliases', () {
      check(standardTypes['xs:integer']).equals(xsInteger);
      check(standardTypes['integer']).equals(xsInteger);
      check(standardTypes['xs:string']).equals(xsString);
      check(standardTypes['xs:boolean']).equals(xsBoolean);
      check(standardTypes['item()']).equals(xsItem);
      check(standardTypes['node()']).equals(xsNode);
      check(standardTypes['element()']).equals(xsElement);
      check(standardTypes['attribute()']).equals(xsAttribute);
      check(standardTypes['map(*)']).equals(xsMap);
      check(standardTypes['array(*)']).equals(xsArray);
      check(standardTypes['non-existent-type']).isNull();
    });
  });

  group('XPathArrayType', () {
    test('isAny for default constructor', () {
      const t = XPathArrayType();
      check(t.name).equals('array(*)');
      check(t.memberType).equals(xsSequence);
    });

    test('named member type', () {
      const t = XPathArrayType(xsInteger);
      check(t.name).equals('array(xs:integer)');
    });

    test('isSubtypeOf hierarchy', () {
      const anyArray = XPathArrayType();
      const intArray = XPathArrayType(xsInteger);
      // typed array is subtype of array(*) (the constant)
      check(intArray.isSubtypeOf(xsArray)).isTrue();
      // typed array is subtype of anyArray
      check(intArray.isSubtypeOf(anyArray)).isTrue();
      // array(*) is subtype of function(*) and item()
      check(xsArray.isSubtypeOf(xsFunction)).isTrue();
      check(xsArray.isSubtypeOf(xsItem)).isTrue();
      // anyArray is subtype of anyArray
      check(anyArray.isSubtypeOf(anyArray)).isTrue();
      // anyArray is NOT subtype of typed array
      check(anyArray.isSubtypeOf(intArray)).isFalse();
      // intArray is NOT subtype of string array
      check(intArray.isSubtypeOf(const XPathArrayType(xsString))).isFalse();
    });

    test('matchesItem filters by member type', () {
      const arr = XPathArray([]);
      const anyArray = XPathArrayType();
      check(anyArray.matchesItem(arr)).isTrue();

      final intArr = XPathArray([
        XPathSequence.single(XPathInteger.fromInt(1)),
        XPathSequence.single(XPathInteger.fromInt(2)),
      ]);
      const intArray = XPathArrayType(xsInteger);
      check(intArray.matchesItem(intArr)).isTrue();

      const strArray = XPathArrayType(xsString);
      check(strArray.matchesItem(intArr)).isFalse();
    });
  });

  group('XPathMapType', () {
    test('wildcard map', () {
      const t = XPathMapType();
      check(t.name).equals('map(*)');
    });

    test('typed map name', () {
      const t = XPathMapType(xsInteger, xsString);
      check(t.name).equals('map(xs:integer, xs:string)');
    });

    test('isSubtypeOf hierarchy', () {
      const anyMap = XPathMapType();
      const intStrMap = XPathMapType(xsInteger, xsString);
      // typed map is subtype of map(*)
      check(intStrMap.isSubtypeOf(xsMap)).isTrue();
      check(intStrMap.isSubtypeOf(anyMap)).isTrue();
      // map(*) is subtype of function(*) and item()
      check(xsMap.isSubtypeOf(xsFunction)).isTrue();
      check(xsMap.isSubtypeOf(xsItem)).isTrue();
      // anyMap is NOT subtype of typed map
      check(anyMap.isSubtypeOf(intStrMap)).isFalse();
      // map(xs:integer, xs:string) IS subtype of map(xs:decimal, xs:string)
      // (xs:integer is subtype of xs:decimal, xs:string is subtype of xs:string)
      check(intStrMap.isSubtypeOf(const XPathMapType(xsDecimal, xsString)))
          .isTrue();
    });

    test('isSubtypeOf function type (map-as-function)', () {
      const intStrMap = XPathMapType(xsInteger, xsString);
      // map(xs:integer, xs:string) is subtype of function(xs:anyAtomicType) as item()*
      check(
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
      ).isTrue();
      // map(xs:integer, xs:string) is NOT subtype of function(xs:string) as item()*
      // because xs:integer is NOT subtype of xs:string
      check(
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
      ).isFalse();
    });
  });

  group('XPathFunctionType', () {
    test('wildcard function', () {
      const t = XPathFunctionType();
      check(t.name).equals('function(*)');
      check(t.isAny).isTrue();
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
      check(t.name).equals('function(xs:integer) as xs:string');
    });

    test('isSubtypeOf hierarchy', () {
      const anyFn = XPathFunctionType();
      // Any typed function is subtype of function(*)
      check(
        const XPathFunctionType(
          parameterTypes: [
            XPathSequenceType(
              itemType: xsInteger,
              cardinality: XPathCardinality.exactlyOne,
            ),
          ],
        ).isSubtypeOf(anyFn),
      ).isTrue();
      // function(*) is subtype of function(*) (same)
      check(anyFn.isSubtypeOf(anyFn)).isTrue();
      // function(*) is subtype of xsFunction and xsItem
      check(anyFn.isSubtypeOf(xsFunction)).isTrue();
      check(anyFn.isSubtypeOf(xsItem)).isTrue();
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
      check(fnNodeOptStr.isSubtypeOf(testElemStr)).isTrue();
      // Not the reverse: function(element()) as xs:string is NOT subtype of
      // function(node()?) as xs:string (node()? is NOT subtype of element())
      check(testElemStr.isSubtypeOf(fnNodeOptStr)).isFalse();
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
      check(anyFnType.matchesItem(fnName1)).isTrue();
      // Exact declared type matches.
      check(fnType.matchesItem(fnName1)).isTrue();
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
      check(wrongReturnType.matchesItem(fnName1)).isFalse();
    });

    test('equality and hashCode on XPathFunctionType', () {
      const fn1 = XPathFunctionType();
      const fn2 = XPathFunctionType();
      check(fn1 == fn2).isTrue();
      check(fn1.hashCode).equals(fn2.hashCode);
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

      check(xsEmptySequence.isSubtypeOf(optStr)).isTrue();
      check(xsEmptySequence.isSubtypeOf(starStr)).isTrue();
      check(xsEmptySequence.isSubtypeOf(oneStr)).isFalse();
      check(xsEmptySequence.isSubtypeOf(xsItem)).isFalse();
      check(xsEmptySequence.isSubtypeOf(xsEmptySequence)).isTrue();
    });

    test('matchesItem and matchesSequence', () {
      check(xsEmptySequence.matchesItem(XPathInteger.fromInt(1))).isFalse();
      check(xsEmptySequence.matchesSequence(XPathSequence.empty)).isTrue();
      check(
        xsEmptySequence.matchesSequence(
          XPathSequence.single(XPathInteger.fromInt(1)),
        ),
      ).isFalse();
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

      check(intStrMapType.matchesItem(validMap)).isTrue();
      check(intStrMapType.matchesItem(invalidKeyMap)).isFalse();
      check(intStrMapType.matchesItem(invalidValMap)).isFalse();
      check(intStrMapType.matchesItem(XPathInteger.fromInt(1))).isFalse();
    });

    test('equality and hashCode', () {
      const map1 = XPathMapType(xsInteger, xsString);
      const map2 = XPathMapType(xsInteger, xsString);
      const map3 = XPathMapType(xsInteger, xsInteger);
      check(map1 == map2).isTrue();
      check(map1 == map3).isFalse();
      check(map1.hashCode).equals(map2.hashCode);
    });
  });

  group('Additional type hierarchy edge cases', () {
    test('XPathSequenceType exactlyOne isSubtypeOf atomic type and matchesItem/hashCode', () {
      const seqType = XPathSequenceType(
        itemType: xsInteger,
        cardinality: XPathCardinality.exactlyOne,
      );
      check(seqType.isSubtypeOf(xsNumeric)).isTrue();
      check(seqType.isSubtypeOf(xsString)).isFalse();
      check(seqType.matchesItem(XPathInteger.fromInt(42))).isTrue();
      check(seqType.matchesItem(const XPathString('abc'))).isFalse();
      check(seqType.hashCode).isA<int>();
    });

    test('XPathArrayType hashCode', () {
      const arrType = XPathArrayType(xsInteger);
      check(arrType.hashCode).equals(xsInteger.hashCode);
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
      check(validFnType.matchesItem(mapItem)).isTrue();

      // Return type does not accept empty sequence
      const invalidEmptyReturnFnType = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsString,
      );
      check(invalidEmptyReturnFnType.matchesItem(mapItem)).isFalse();

      // Invalid param type (non-atomic)
      const invalidParamFnType = XPathFunctionType(
        parameterTypes: [xsNode],
        returnType: XPathSequenceType(
          itemType: xsString,
          cardinality: XPathCardinality.zeroOrOne,
        ),
      );
      check(invalidParamFnType.matchesItem(mapItem)).isFalse();
    });

    test('XPathFunctionType matching XPathArray', () {
      const arrItem = XPathArray([XPathSequence.single(XPathString('first'))]);
      const validArrFnType = XPathFunctionType(
        parameterTypes: [xsInteger],
        returnType: xsString,
      );
      check(validArrFnType.matchesItem(arrItem)).isTrue();

      const invalidParamArrFnType = XPathFunctionType(
        parameterTypes: [xsString],
        returnType: xsString,
      );
      check(invalidParamArrFnType.matchesItem(arrItem)).isFalse();

      const invalidReturnArrFnType = XPathFunctionType(
        parameterTypes: [xsInteger],
        returnType: xsInteger,
      );
      check(invalidReturnArrFnType.matchesItem(arrItem)).isFalse();
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
      check(fn1 == fn2).isTrue();
      check(fn1 == fn3).isFalse();
      check(fn1.hashCode).equals(fn2.hashCode);
    });
  });
}
