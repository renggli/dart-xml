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
  group('array:size', () {
    test('returns size of array', () {
      final array = ['a', 'b', 'c'];
      expect(
        fnArraySize(context, [XPathSequence.single(array)]),
        isXPathSequence([3]),
      );
    });
  });

  group('array:get', () {
    final array = ['a', 'b'];

    test('returns item at index', () {
      expect(
        fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(1),
        ]),
        isXPathSequence(['a']),
      );
    });

    test('throws exception for index out of bounds (too large)', () {
      expect(
        () => fnArrayGet(context, [
          XPathSequence.single(array),
          const XPathSequence.single(3),
        ]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 3'),
        ),
      );
    });

    test('throws exception for index out of bounds (zero)', () {
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
  });

  group('array:put', () {
    final array = ['a', 'b'];

    test('replaces item at index', () {
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
    });

    test('throws exception for index out of bounds', () {
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
  });

  group('array:append', () {
    test('appends item to array', () {
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
  });

  group('array:subarray', () {
    final array = ['a', 'b', 'c', 'd'];

    test('returns subarray with start index', () {
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([
          ['b', 'c', 'd'],
        ]),
      );
    });

    test('returns subarray with start and length', () {
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
    });

    test('throws exception for invalid range (zero start)', () {
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
    });

    test('returns empty for index exceeding array size', () {
      expect(
        fnArraySubarray(context, [
          XPathSequence.single(array),
          const XPathSequence.single(5),
        ]),
        isXPathSequence([isEmpty]),
      );
    });

    test('throws exception for invalid range (length exceeds bounds)', () {
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
  });

  group('array:remove', () {
    final array = ['a', 'b', 'c'];

    test('removes item at index', () {
      expect(
        fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([
          ['a', 'c'],
        ]),
      );
    });

    test('removes multiple items at indices', () {
      expect(
        fnArrayRemove(context, [
          XPathSequence.single(array),
          const XPathSequence([1, 3]),
        ]),
        isXPathSequence([
          ['b'],
        ]),
      );
    });

    test('throws exception for index out of bounds', () {
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
  });

  group('array:insert-before', () {
    final array = ['a', 'c'];

    test('inserts item before index', () {
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
    });

    test('throws exception for index out of bounds', () {
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
  });

  group('array:head', () {
    test('returns first item', () {
      expect(
        fnArrayHead(context, [
          const XPathSequence([
            ['a', 'b'],
          ]),
        ]),
        isXPathSequence(['a']),
      );
    });

    test('throws exception for empty array', () {
      expect(
        () => fnArrayHead(context, [const XPathSequence.single([])]),
        throwsA(isXPathEvaluationException(message: 'Empty array')),
      );
    });
  });

  group('array:tail', () {
    test('returns remaining items', () {
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
    });

    test('throws exception for empty array', () {
      expect(
        () => fnArrayTail(context, [const XPathSequence.single([])]),
        throwsA(isXPathEvaluationException(message: 'Empty array')),
      );
    });
  });

  group('array:reverse', () {
    test('reverses array', () {
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
  });

  group('array:join', () {
    test('returns single array unchanged', () {
      expect(
        fnArrayJoin(context, [
          const XPathSequence.single([1, 2]),
        ]),
        isXPathSequence([
          [1, 2],
        ]),
      );
    });

    test('joins multiple arrays', () {
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
  });

  group('array:flatten', () {
    test('flattens nested arrays', () {
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
    });

    test('flattens nested sequences', () {
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
  });

  group('array:for-each', () {
    test('applies function to each item', () {
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
  });

  group('array:filter', () {
    test('filters items using function', () {
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
  });

  group('array:fold-left', () {
    test('folds from left', () {
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
  });

  group('array:fold-right', () {
    test('folds from right', () {
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
  });

  group('array:for-each-pair', () {
    test('applies function to pairs', () {
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
  });

  group('array:sort', () {
    test('sorts items', () {
      final array = [3, 1, 2];
      final result = fnArraySort(context, [XPathSequence.single(array)]);
      expect(
        result,
        isXPathSequence({
          [1, 2, 3],
        }),
      );
    });

    test('sorts items with key function', () {
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
