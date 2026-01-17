import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/higher_order.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('higher_order', () {
    test('fn:sort', () {
      expect(
        fnSort(context, [
          const XPathSequence([3, 1, 2]),
        ]).toList(),
        [1, 2, 3],
      );
      expect(
        fnSort(context, [
          const XPathSequence(['b', 'a', 'c']),
        ]).toList(),
        ['a', 'b', 'c'],
      );
      // Sort with key
      expect(
        fnSort(context, [
          const XPathSequence(['apple', 'be', 'cat']),
          XPathSequence.empty,
          XPathSequence.single(
            (XPathContext context, List<XPathSequence> args) =>
                XPathSequence.single(args[0].toXPathString().length),
          ),
        ]).toList(),
        ['be', 'cat', 'apple'],
      );
    });
    test('fn:apply', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        fnApply(context, [
          XPathSequence.single(add),
          const XPathSequence.single([1, 2]),
        ]),
        [3],
      );
    });
    test('fn:for-each', () {
      XPathSequence double(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) * 2);
      expect(
        fnForEach(context, [
          const XPathSequence([1, 2, 3]),
          XPathSequence.single(double),
        ]).toList(),
        [2, 4, 6],
      );
    });
    test('fn:filter', () {
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) % 2 == 0);
      expect(
        fnFilter(context, [
          const XPathSequence([1, 2, 3, 4]),
          XPathSequence.single(isEven),
        ]).toList(),
        [2, 4],
      );
    });
    test('fn:fold-left', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) + (args[1].first as num));
      expect(
        fnFoldLeft(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          XPathSequence.single(add),
        ]).first,
        15,
      );
    });
    test('fn:fold-right', () {
      XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args[0].first as num) - (args[1].first as num));
      // (1 - (2 - (3 - (4 - (5 - 0))))) = 1 - (2 - (3 - (4 - 5))) = 1 - (2 - (3 - (-1))) = 1 - (2 - 4) = 1 - (-2) = 3
      expect(
        fnFoldRight(context, [
          const XPathSequence([1, 2, 3, 4, 5]),
          const XPathSequence.single(0),
          XPathSequence.single(sub),
        ]).first,
        3,
      );
    });
    test('fn:for-each-pair', () {
      XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(
            args[0].toXPathString() + args[1].toXPathString(),
          );
      expect(
        fnForEachPair(context, [
          const XPathSequence(['a', 'b', 'c']),
          const XPathSequence(['1', '2', '3']),
          XPathSequence.single(concat),
        ]).toList(),
        ['a1', 'b2', 'c3'],
      );
    });
    test('fn:function-lookup', () {
      expect(
        () => fnFunctionLookup(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-name', () {
      expect(
        () => fnFunctionName(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:function-arity', () {
      expect(
        () => fnFunctionArity(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:load-xquery-module', () {
      expect(
        () => fnLoadXqueryModule(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
    test('fn:transform', () {
      expect(
        () => fnTransform(context, const <XPathSequence>[]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
