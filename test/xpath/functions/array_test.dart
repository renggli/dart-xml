import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/array.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('array functions', () {
    test('array:size', () {
      final array = ['a', 'b', 'c'];
      expect(fnArraySize(context, [XPathSequence.single(array)]), [3]);
    });
    test('array:get', () {
      final array = ['a', 'b'];
      expect(
        fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
        ]),
        ['a'],
      );
      expect(
        () => fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:put', () {
      final array = ['a', 'b'];
      expect(
        fnArrayPut(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
          const XPathSequence.single('c'),
        ]).first,
        ['c', 'b'],
      );
      expect(
        () => fnArrayPut(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
          const XPathSequence.single('c'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:append', () {
      final array = ['a'];
      expect(
        fnArrayAppend(context, [
          XPathSequence.single(array),
          const XPathSequence.single('b'),
        ]).first,
        ['a', 'b'],
      );
    });
    test('array:subarray', () {
      final array = ['a', 'b', 'c', 'd'];
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]).first,
        ['b', 'c', 'd'],
      );
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single(2),
        ]).first,
        ['b', 'c'],
      );
      expect(
        () => fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(5),
        ]).first,
        isEmpty,
      );
      expect(
        () => fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
          const XPathSequence.single(2),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:remove', () {
      final array = ['a', 'b', 'c'];
      expect(
        fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]).first,
        ['a', 'c'],
      );
      expect(
        fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence([1, 3]),
        ]).first,
        ['b'],
      );
      expect(
        () => fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:insert-before', () {
      final array = ['a', 'c'];
      expect(
        fnArrayInsertBefore(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
          const XPathSequence.single('b'),
        ]).first,
        ['a', 'b', 'c'],
      );
      expect(
        () => fnArrayInsertBefore(context, [
          XPathSequence.single(array),
          const XPathSequence.single(4),
          const XPathSequence.single('d'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:head', () {
      expect(
        fnArrayHead(context, [
          const XPathSequence([
            ['a', 'b'],
          ]),
        ]),
        ['a'],
      );
      expect(
        () => fnArrayHead(context, [const XPathSequence.single([])]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:tail', () {
      expect(
        fnArrayTail(context, [
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ]).first,
        ['b', 'c'],
      );
      expect(
        () => fnArrayTail(context, [const XPathSequence.single([])]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('array:reverse', () {
      expect(
        fnArrayReverse(context, [
          const XPathSequence([
            ['a', 'b', 'c'],
          ]),
        ]).first,
        ['c', 'b', 'a'],
      );
    });
    test('array:join', () {
      expect(
        fnArrayJoin(context, [
          const XPathSequence.single([1, 2]),
        ]).first,
        [1, 2],
      );
      expect(
        fnArrayJoin(context, [
          const XPathSequence([
            [1, 2],
            [3, 4, 5],
          ]),
        ]).first,
        [1, 2, 3, 4, 5],
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
      expect(fnArrayFlatten(context, [XPathSequence(input)]).toList(), [
        1,
        2,
        3,
        4,
        5,
      ]);
    });
    test('array:for-each', () {
      final array = [1, 2, 3];
      XPathSequence double(XPathContext context, List<XPathSequence> args) {
        final arg = args[0];
        return XPathSequence.single((arg.first as num) * 2);
      }

      final result =
          fnArrayForEach(context, [
                XPathSequence.single(array),
                XPathSequence.single(double),
              ]).first
              as List;
      expect(
        result.map((e) => XPathSequence.single(e as Object).first).toList(),
        [2, 4, 6],
      );
    });
    test('array:filter', () {
      final array = [1, 2, 3, 4];
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) {
        final arg = args[0];
        return XPathSequence.single((arg.first as num) % 2 == 0);
      }

      final result =
          fnArrayFilter(context, [
                XPathSequence.single(array),
                XPathSequence.single(isEven),
              ]).first
              as List;
      expect(
        result.map((e) => XPathSequence.single(e as Object).first).toList(),
        [2, 4],
      );
    });
    test('array:fold-left', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence add(XPathContext context, List<XPathSequence> args) {
        final acc = args[0];
        final item = args[1];
        return XPathSequence.single((acc.first as num) + (item.first as num));
      }

      expect(
        fnArrayFoldLeft(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
          XPathSequence.single(add),
        ]),
        [15],
      );
    });
    test('array:fold-right', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence sub(XPathContext context, List<XPathSequence> args) {
        final item = args[0];
        final acc = args[1];
        return XPathSequence.single((item.first as num) - (acc.first as num));
      }

      expect(
        fnArrayFoldRight(context, [
          XPathSequence.single(array),
          const XPathSequence.single(0),
          XPathSequence.single(sub),
        ]),
        [3],
      );
    });
    test('array:for-each-pair', () {
      final array1 = ['a', 'b', 'c'];
      final array2 = ['1', '2', '3'];
      XPathSequence concat(XPathContext context, List<XPathSequence> args) {
        final a = args[0];
        final b = args[1];
        return XPathSequence.single(xsString.cast(a) + xsString.cast(b));
      }

      final result =
          fnArrayForEachPair(context, [
                XPathSequence.single(array1),
                XPathSequence.single(array2),
                XPathSequence.single(concat),
              ]).first
              as List;
      expect(
        result.map((e) => (e as XPathSequence).first.toString()).toList(),
        ['a1', 'b2', 'c3'],
      );
    });
    test('array:sort', () {
      final array = [3, 1, 2];
      final result =
          fnArraySort(context, [XPathSequence.single(array)]).first as List;
      expect(
        result.map((e) => XPathSequence.single(e as Object).first).toList(),
        [1, 2, 3],
      );
      // Sort with key
      final array2 = ['apple', 'be', 'cat'];
      XPathSequence length(XPathContext context, List<XPathSequence> args) {
        final arg = args[0];
        return XPathSequence.single(xsString.cast(arg).length);
      }

      final result2 =
          fnArraySort(context, [
                XPathSequence.single(array2),
                XPathSequence.empty, // collation
                XPathSequence.single(length),
              ]).first
              as List;
      expect(
        result2.map((e) => XPathSequence.single(e as Object).first).toList(),
        ['be', 'cat', 'apple'],
      );
    });
  });
}
