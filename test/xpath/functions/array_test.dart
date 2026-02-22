import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/array.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('array functions', () {
    test('array:size', () {
      final array = ['a', 'b', 'c'];
      expect(
        fnArraySize(context, [XPathSequence.single(array)]),
        isXPathSequence([3]),
      );
    });
    test('array:get', () {
      final array = ['a', 'b'];
      expect(
        fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
        ]),
        isXPathSequence(['a']),
      );
      expect(
        () => fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 3'),
        ),
      );
      expect(
        () => fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 0'),
        ),
      );
    });
    test('array:put', () {
      final array = ['a', 'b'];
      expect(
        fnArrayPut(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
          const XPathSequence.single('c'),
        ]),
        isXPathSequence([
          ['c', 'b'],
        ]),
      );
      expect(
        () => fnArrayPut(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
          const XPathSequence.single('c'),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 3'),
        ),
      );
    });
    test('array:append', () {
      final array = ['a'];
      expect(
        fnArrayAppend(context, [
          XPathSequence.single(array),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([
          ['a', 'b'],
        ]),
      );
    });
    test('array:subarray', () {
      final array = ['a', 'b', 'c', 'd'];
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([
          ['b', 'c', 'd'],
        ]),
      );
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([
          ['b', 'c'],
        ]),
      );
      expect(
        () => fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
        ]),
        throwsA(
          isXPathEvaluationException(
            message: 'Invalid subarray range: 0, null',
          ),
        ),
      );
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(5),
        ]),
        isXPathSequence([isEmpty]),
      );
      expect(
        () => fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
          const XPathSequence.single(2),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Invalid subarray range: 4, 2'),
        ),
      );
    });
    test('array:remove', () {
      final array = ['a', 'b', 'c'];
      expect(
        fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([
          ['a', 'c'],
        ]),
      );
      expect(
        fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence([1, 3]),
        ]),
        isXPathSequence([
          ['b'],
        ]),
      );
      expect(
        () => fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 4'),
        ),
      );
    });
    test('array:insert-before', () {
      final array = ['a', 'c'];
      expect(
        fnArrayInsertBefore(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([
          ['a', 'b', 'c'],
        ]),
      );
      expect(
        () => fnArrayInsertBefore(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
          const XPathSequence.single('d'),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 4'),
        ),
      );
    });
    test('array:head', () {
      expect(
        fnArrayHead(context, [
          const XPathSequence([
            ['a', 'b'],
          ]),
        ]),
        isXPathSequence(['a']),
      );
      expect(
        () => fnArrayHead(context, [const XPathSequence.single([])]),
        throwsA(isXPathEvaluationException(message: 'Empty array')),
      );
    });
    test('array:tail', () {
      expect(
        fnArrayTail(context, [
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ]),
        isXPathSequence([
          ['b', 'c'],
        ]),
      );
      expect(
        () => fnArrayTail(context, [const XPathSequence.single([])]),
        throwsA(isXPathEvaluationException(message: 'Empty array')),
      );
    });
    test('array:reverse', () {
      expect(
        fnArrayReverse(context, [
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ]),
        isXPathSequence([
          ['c', 'b', 'a'],
        ]),
      );
    });
    test('array:join', () {
      expect(
        fnArrayJoin(context, [
          const XPathSequence.single([1, 2]),
        ]),
        isXPathSequence([
          [1, 2],
        ]),
      );
      expect(
        fnArrayJoin(context, [
          const XPathSequence([
            [1, 2],
            [3, 4, 5],
          ]),
        ]),
        isXPathSequence([
          [1, 2, 3, 4, 5],
        ]),
      );
    });
    test('array:flatten', () {
      final input = [
        1,
        [2, 3],
        [
          [4, 5],
        ],
      ];
      expect(
        fnArrayFlatten(context, [XPathSequence(input)]),
        isXPathSequence([1, 2, 3, 4, 5]),
      );
      final nestedSeq = [
        1,
        const XPathSequence([2, 3]),
        [4],
      ];
      expect(
        fnArrayFlatten(context, [XPathSequence(nestedSeq)]),
        isXPathSequence([1, 2, 3, 4]),
      );
    });
    test('array:for-each', () {
      final array = [1, 2, 3];
      XPathSequence double(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args.single.single as num) * 2);
      final result = fnArrayForEach(context, [
        XPathSequence.single(array),
        XPathSequence.single(double),
      ]);
      expect(result, [
        [2, 4, 6],
      ]);
    });
    test('array:filter', () {
      final array = [1, 2, 3, 4];
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single((args.single.single as num) % 2 == 0);
      final result = fnArrayFilter(context, [
        XPathSequence.single(array),
        XPathSequence.single(isEven),
      ]);
      expect(
        result,
        isXPathSequence([
          [2, 4],
        ]),
      );
    });
    test('array:fold-left', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence add(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(
            (args[0].single as num) + (args[1].single as num),
          );
      expect(
        fnArrayFoldLeft(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
          XPathSequence.single(add),
        ]),
        isXPathSequence([15]),
      );
    });
    test('array:fold-right', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single(
            (args[0].single as num) - (args[1].single as num),
          );
      expect(
        fnArrayFoldRight(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
          XPathSequence.single(sub),
        ]),
        isXPathSequence([3]),
      );
    });
    test('array:for-each-pair', () {
      final array1 = ['a', 'b', 'c'];
      final array2 = ['1', '2', '3'];
      XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
          XPathSequence.single('${args[0].single}${args[1].single}');
      final result = fnArrayForEachPair(context, [
        XPathSequence.single(array1),
        XPathSequence.single(array2),
        XPathSequence.single(concat),
      ]);
      expect(result, [
        ['a1', 'b2', 'c3'],
      ]);
    });
    test('array:sort', () {
      final array = [3, 1, 2];
      final result = fnArraySort(context, [XPathSequence.single(array)]);
      expect(
        result,
        isXPathSequence({
          [1, 2, 3],
        }),
      );
    });
    test('array:sort (with key)', () {
      final array = ['apple', 'be', 'cat'];
      XPathSequence length(XPathContext context, List<XPathSequence> args) {
        final arg = args[0];
        return XPathSequence.single(xsString.cast(arg).length);
      }

      final result = fnArraySort(context, [
        XPathSequence.single(array),
        XPathSequence.empty, // collation
        XPathSequence.single(length),
      ]);
      expect(
        result,
        isXPathSequence([
          ['be', 'cat', 'apple'],
        ]),
      );
    });
  });
}
