import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/array.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('array:size', () {
    final array = ['a', 'b', 'c'];
    expect(arraySize(context, [XPathSequence.single(array)]), [3]);
  });
  test('array:get', () {
    final array = ['a', 'b'];
    expect(
      arrayGet(context, [
        XPathSequence.single(array),
        const XPathSequence.single(1),
      ]),
      ['a'],
    );
    expect(
      () => arrayGet(context, [
        XPathSequence.single(array),
        const XPathSequence.single(3),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(
      () => arrayGet(context, [
        XPathSequence.single(array),
        const XPathSequence.single(0),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('array:put', () {
    final array = ['a', 'b'];
    expect(
      arrayPut(context, [
        XPathSequence.single(array),
        const XPathSequence.single(1),
        const XPathSequence.single('c'),
      ]).first,
      ['c', 'b'],
    );
    expect(
      () => arrayPut(context, [
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
      arrayAppend(context, [
        XPathSequence.single(array),
        const XPathSequence.single('b'),
      ]).first,
      ['a', 'b'],
    );
  });
  test('array:subarray', () {
    final array = ['a', 'b', 'c', 'd'];
    expect(
      arraySubarray(context, [
        XPathSequence.single(array),
        const XPathSequence.single(2),
      ]).first,
      ['b', 'c', 'd'],
    );
    expect(
      arraySubarray(context, [
        XPathSequence.single(array),
        const XPathSequence.single(2),
        const XPathSequence.single(2),
      ]).first,
      ['b', 'c'],
    );
    expect(
      () => arraySubarray(context, [
        XPathSequence.single(array),
        const XPathSequence.single(0),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(
      arraySubarray(context, [
        XPathSequence.single(array),
        const XPathSequence.single(5),
      ]).first,
      isEmpty,
    );
    expect(
      () => arraySubarray(context, [
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
      arrayRemove(context, [
        XPathSequence.single(array),
        const XPathSequence.single(2),
      ]).first,
      ['a', 'c'],
    );
    expect(
      arrayRemove(context, [
        XPathSequence.single(array),
        const XPathSequence([1, 3]),
      ]).first,
      ['b'],
    );
    expect(
      () => arrayRemove(context, [
        XPathSequence.single(array),
        const XPathSequence.single(4),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('array:insert-before', () {
    final array = ['a', 'c'];
    expect(
      arrayInsertBefore(context, [
        XPathSequence.single(array),
        const XPathSequence.single(2),
        const XPathSequence.single('b'),
      ]).first,
      ['a', 'b', 'c'],
    );
    expect(
      () => arrayInsertBefore(context, [
        XPathSequence.single(array),
        const XPathSequence.single(4),
        const XPathSequence.single('d'),
      ]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('array:head', () {
    expect(
      arrayHead(context, [
        const XPathSequence([
          ['a', 'b'],
        ]),
      ]),
      ['a'],
    );
    expect(
      () => arrayHead(context, [const XPathSequence.single([])]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('array:tail', () {
    expect(
      arrayTail(context, [
        const XPathSequence([
          ['a', 'b', 'c'],
        ]),
      ]).first,
      ['b', 'c'],
    );
    expect(
      () => arrayTail(context, [const XPathSequence.single([])]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('array:reverse', () {
    expect(
      arrayReverse(context, [
        const XPathSequence([
          ['a', 'b', 'c'],
        ]),
      ]).first,
      ['c', 'b', 'a'],
    );
  });
  test('array:join', () {
    expect(
      arrayJoin(context, [
        const XPathSequence.single([1, 2]),
      ]).first,
      [1, 2],
    );
    expect(
      arrayJoin(context, [
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
    // Note: standard array:flatten is recursive.
    // My implementation might be too? Let's check.
    // Our implementation flattens recursively.
    expect(arrayFlatten(context, [XPathSequence(input)]).toList(), [
      1,
      2,
      3,
      4,
      5,
    ]);
  });
  test('array:for-each', () {
    final array = [1, 2, 3];
    XPathSequence double(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single((args[0].first as num) * 2);
    final result =
        arrayForEach(context, [
              XPathSequence.single(array),
              XPathSequence.single(double),
            ]).first
            as List;
    expect(result.map((e) => (e as Object).toXPathSequence().first).toList(), [
      2,
      4,
      6,
    ]);
  });
  test('array:filter', () {
    final array = [1, 2, 3, 4];
    XPathSequence isEven(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single((args[0].first as num) % 2 == 0);
    final result =
        arrayFilter(context, [
              XPathSequence.single(array),
              XPathSequence.single(isEven),
            ]).first
            as List;
    expect(result.map((e) => (e as Object).toXPathSequence().first).toList(), [
      2,
      4,
    ]);
  });
  test('array:fold-left', () {
    final array = [1, 2, 3, 4, 5];
    XPathSequence add(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single((args[0].first as num) + (args[1].first as num));
    expect(
      arrayFoldLeft(context, [
        XPathSequence.single(array),
        const XPathSequence.single(0),
        XPathSequence.single(add),
      ]).first,
      15,
    );
  });
  test('array:fold-right', () {
    final array = [1, 2, 3, 4, 5];
    XPathSequence sub(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single((args[0].first as num) - (args[1].first as num));
    expect(
      arrayFoldRight(context, [
        XPathSequence.single(array),
        const XPathSequence.single(0),
        XPathSequence.single(sub),
      ]).first,
      3,
    );
  });
  test('array:for-each-pair', () {
    final array1 = ['a', 'b', 'c'];
    final array2 = ['1', '2', '3'];
    XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single(args[0].toXPathString() + args[1].toXPathString());
    final result =
        arrayForEachPair(context, [
              XPathSequence.single(array1),
              XPathSequence.single(array2),
              XPathSequence.single(concat),
            ]).first
            as List;
    expect(
      result
          .map((e) => (e as Object).toXPathSequence().first.toString())
          .toList(),
      ['a1', 'b2', 'c3'],
    );
  });
  test('array:sort', () {
    final array = [3, 1, 2];
    final result =
        arraySort(context, [XPathSequence.single(array)]).first as List;
    expect(result.map((e) => (e as Object).toXPathSequence().first).toList(), [
      1,
      2,
      3,
    ]);
    // Sort with key
    final array2 = ['apple', 'be', 'cat'];
    XPathSequence length(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single(args[0].toXPathString().length);
    final result2 =
        arraySort(context, [
              XPathSequence.single(array2),
              XPathSequence.empty,
              XPathSequence.single(length),
            ]).first
            as List;
    expect(result2.map((e) => (e as Object).toXPathSequence().first).toList(), [
      'be',
      'cat',
      'apple',
    ]);
  });
}
