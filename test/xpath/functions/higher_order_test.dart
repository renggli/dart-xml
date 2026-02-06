import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/types.dart';
import 'package:xml/src/xpath/functions/higher_order.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('higher-order functions', () {
    test('fn:sort', () {
      expect(
        fnSort(context, [
          const XPathSequence([3, 1, 2]),
        ]),
        const XPathSequence([1, 2, 3]),
      );
      expect(
        fnSort(context, [
          const XPathSequence(['b', 'a', 'c']),
        ]),
        const XPathSequence(['a', 'b', 'c']),
      );
      // Sort with key
      expect(
        fnSort(context, [
          const XPathSequence(['apple', 'be', 'cat']),
          XPathSequence.empty, // collation
          XPathSequence.single(
            (XPathContext context, XPathSequence arg) =>
                XPathSequence.single(arg.toXPathString().length),
          ),
        ]),
        const XPathSequence(['be', 'cat', 'apple']),
      );
    });
    test('fn:apply', () {
      XPathSequence add(
        XPathContext context,
        XPathSequence a,
        XPathSequence b,
      ) => XPathSequence.single((a.first as num) + (b.first as num));
      expect(
        fnApply(context, [
          XPathSequence.single(add),
          const XPathSequence([1, 2]),
        ]),
        [3],
      );
    });
    test('fn:for-each', () {
      XPathSequence double(XPathContext context, XPathSequence arg) =>
          XPathSequence.single((arg.first as num) * 2);
      expect(
        fnForEach(context, [
          const XPathSequence([1, 2, 3]),
          XPathSequence.single(double),
        ]),
        [2, 4, 6],
      );
    });
    test('fn:filter', () {
      XPathSequence isEven(XPathContext context, XPathSequence arg) =>
          XPathSequence.single((arg.first as num) % 2 == 0);
      expect(
        fnFilter(context, [
          const XPathSequence([1, 2, 3, 4]),
          XPathSequence.single(isEven),
        ]),
        [2, 4],
      );
    });
    test('fn:fold-left', () {
      XPathSequence add(
        XPathContext context,
        XPathSequence acc,
        XPathSequence item,
      ) => XPathSequence.single((acc.first as num) + (item.first as num));
      expect(
        fnFoldLeft(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          XPathSequence.single(add),
        ]),
        [15],
      );
    });
    test('fn:fold-right', () {
      XPathSequence sub(
        XPathContext context,
        XPathSequence item,
        XPathSequence acc,
      ) => XPathSequence.single((item.first as num) - (acc.first as num));
      // (1 - (2 - (3 - (4 - (5 - 0))))) = 1 - (2 - (3 - (4 - 5))) = 1 - (2 - (3 - (-1))) = 1 - (2 - 4) = 1 - (-2) = 3
      expect(
        fnFoldRight(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          XPathSequence.single(sub),
        ]),
        [3],
      );
    });
    test('fn:for-each-pair', () {
      XPathSequence concat(
        XPathContext context,
        XPathSequence a,
        XPathSequence b,
      ) => XPathSequence.single(a.toXPathString() + b.toXPathString());
      expect(
        fnForEachPair(context, [
          const XPathSequence(['a', 'b', 'c']),
          const XPathSequence(['1', '2', '3']),
          XPathSequence.single(concat),
        ]),
        ['a1', 'b2', 'c3'],
      );
    });
    test('fn:function-lookup', () {
      expect(
        () => fnFunctionLookup(context, [
          const XPathSequence.single('name'),
          const XPathSequence.single(1),
        ]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-name', () {
      expect(
        fnFunctionName(context, [
          XPathSequence.single(
            (XPathContext context, XPathSequence arg) => XPathSequence.empty,
          ),
        ]),
        isEmpty,
      );
    });
    test('fn:function-arity', () {
      expect(
        fnFunctionArity(context, [
          XPathSequence.single(
            (XPathContext context, XPathSequence arg) => XPathSequence.empty,
          ),
        ]),
        [0],
      );
    });
    test('fn:load-xquery-module', () {
      expect(
        () => fnLoadXqueryModule(context, [const XPathSequence.single('uri')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:transform', () {
      expect(
        () => fnTransform(context, [XPathSequence.emptyMap]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
