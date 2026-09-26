import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/array.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

XPathSequence arraySeq(List<dynamic> list) =>
    XPathSequence.single(toXPathItem(list));

void main() {
  group('array:size', () {
    test('returns size of array', () {
      final array = ['a', 'b', 'c'];
      expect(fnArraySize(context, [arraySeq(array)]), isXPathSequence([3]));
    });
  });

  group('array:get', () {
    final array = ['a', 'b'];

    test('returns item at index', () {
      expect(
        fnArrayGet(context, [arraySeq(array), seq(1)]),
        isXPathSequence(['a']),
      );
    });

    test('throws exception for index out of bounds (too large)', () {
      expect(
        () => fnArrayGet(context, [arraySeq(array), seq(3)]),
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 3'),
        ),
      );
    });

    test('throws exception for index out of bounds (zero)', () {
      expect(
        () => fnArrayGet(context, [arraySeq(array), seq(0)]),
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
        fnArrayPut(context, [arraySeq(array), seq(1), seq('c')]),
        isXPathSequence([
          ['c', 'b'],
        ]),
      );
    });

    test('throws exception for index out of bounds', () {
      expect(
        () => fnArrayPut(context, [arraySeq(array), seq(3), seq('c')]),
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
        fnArrayAppend(context, [arraySeq(array), seq('b')]),
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
        fnArraySubarray(context, [arraySeq(array), seq(2)]),
        isXPathSequence([
          ['b', 'c', 'd'],
        ]),
      );
    });

    test('returns subarray with start and length', () {
      expect(
        fnArraySubarray(context, [arraySeq(array), seq(2), seq(2)]),
        isXPathSequence([
          ['b', 'c'],
        ]),
      );
    });

    test('throws exception for invalid range (zero start)', () {
      expect(
        () => fnArraySubarray(context, [arraySeq(array), seq(0)]),
        throwsA(
          isXPathEvaluationException(
            message: 'Invalid subarray range: 0, null',
          ),
        ),
      );
    });

    test('returns empty for index exceeding array size', () {
      expect(
        fnArraySubarray(context, [arraySeq(array), seq(5)]),
        isXPathSequence([isEmpty]),
      );
    });

    test('throws exception for invalid range (length exceeds bounds)', () {
      expect(
        () => fnArraySubarray(context, [arraySeq(array), seq(4), seq(2)]),
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
        fnArrayRemove(context, [arraySeq(array), seq(2)]),
        isXPathSequence([
          ['a', 'c'],
        ]),
      );
    });

    test('removes multiple items at indices', () {
      expect(
        fnArrayRemove(context, [
          arraySeq(array),
          seq([1, 3]),
        ]),
        isXPathSequence([
          ['b'],
        ]),
      );
    });

    test('throws exception for index out of bounds', () {
      expect(
        () => fnArrayRemove(context, [arraySeq(array), seq(4)]),
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
        fnArrayInsertBefore(context, [arraySeq(array), seq(2), seq('b')]),
        isXPathSequence([
          ['a', 'b', 'c'],
        ]),
      );
    });

    test('throws exception for index out of bounds', () {
      expect(
        () => fnArrayInsertBefore(context, [arraySeq(array), seq(4), seq('d')]),
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
          arraySeq(['a', 'b']),
        ]),
        isXPathSequence(['a']),
      );
    });

    test('throws exception for empty array', () {
      expect(
        () => fnArrayHead(context, [arraySeq([])]),
        throwsA(isXPathEvaluationException(message: 'Empty array')),
      );
    });
  });

  group('array:tail', () {
    test('returns remaining items', () {
      expect(
        fnArrayTail(context, [
          arraySeq(['a', 'b', 'c']),
        ]),
        isXPathSequence([
          ['b', 'c'],
        ]),
      );
    });

    test('throws exception for empty array', () {
      expect(
        () => fnArrayTail(context, [arraySeq([])]),
        throwsA(isXPathEvaluationException(message: 'Empty array')),
      );
    });
  });

  group('array:reverse', () {
    test('reverses array', () {
      expect(
        fnArrayReverse(context, [
          arraySeq(['a', 'b', 'c']),
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
          arraySeq([1, 2]),
        ]),
        isXPathSequence([
          [1, 2],
        ]),
      );
    });

    test('joins multiple arrays', () {
      expect(
        fnArrayJoin(context, [
          XPathSequence([
            toXPathItem([1, 2]),
            toXPathItem([3, 4, 5]),
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
      final input = XPathSequence([
        XPathInteger.fromInt(1),
        toXPathItem([2, 3]),
        toXPathItem([
          [4, 5],
        ]),
      ]);
      expect(
        fnArrayFlatten(context, [input]),
        isXPathSequence([1, 2, 3, 4, 5]),
      );
    });

    test('flattens nested sequences', () {
      final nestedSeq = XPathSequence([
        XPathInteger.fromInt(1),
        toXPathItem([2, 3]),
        toXPathItem([4]),
      ]);
      expect(
        fnArrayFlatten(context, [nestedSeq]),
        isXPathSequence([1, 2, 3, 4]),
      );
    });
  });

  group('array:for-each', () {
    test('applies function to each item', () {
      final array = [1, 2, 3];
      XPathSequence double(XPathContext context, List<XPathSequence> args) =>
          seq((args.single.single as XPathInteger).asInt * 2);
      final result = fnArrayForEach(context, [arraySeq(array), seq(double)]);
      expect(
        result,
        isXPathSequence([
          [2, 4, 6],
        ]),
      );
    });
  });

  group('array:filter', () {
    test('filters items using function', () {
      final array = [1, 2, 3, 4];
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) =>
          seq((args.single.single as XPathInteger).asInt % 2 == 0);
      final result = fnArrayFilter(context, [arraySeq(array), seq(isEven)]);
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
      XPathSequence add(XPathContext context, List<XPathSequence> args) => seq(
        (args[0].single as XPathInteger).asInt +
            (args[1].single as XPathInteger).asInt,
      );
      expect(
        fnArrayFoldLeft(context, [arraySeq(array), seq(0), seq(add)]),
        isXPathSequence([15]),
      );
    });
  });

  group('array:fold-right', () {
    test('folds from right', () {
      final array = [1, 2, 3, 4, 5];
      XPathSequence sub(XPathContext context, List<XPathSequence> args) => seq(
        (args[0].single as XPathInteger).asInt -
            (args[1].single as XPathInteger).asInt,
      );
      expect(
        fnArrayFoldRight(context, [arraySeq(array), seq(0), seq(sub)]),
        isXPathSequence([3]),
      );
    });
  });

  group('array:for-each-pair', () {
    test('applies function to pairs', () {
      final array1 = ['a', 'b', 'c'];
      final array2 = ['1', '2', '3'];
      XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
          seq('${args[0].single.stringValue}${args[1].single.stringValue}');
      final result = fnArrayForEachPair(context, [
        arraySeq(array1),
        arraySeq(array2),
        seq(concat),
      ]);
      expect(
        result,
        isXPathSequence([
          ['a1', 'b2', 'c3'],
        ]),
      );
    });
  });

  group('array:sort', () {
    test('sorts items', () {
      final array = [3, 1, 2];
      final result = fnArraySort(context, [arraySeq(array)]);
      expect(
        result,
        isXPathSequence([
          [1, 2, 3],
        ]),
      );
    });

    test('sorts items with key function', () {
      final array = ['apple', 'be', 'cat'];
      XPathSequence length(XPathContext context, List<XPathSequence> args) {
        final arg = args[0].first.stringValue;
        return seq(arg.length);
      }

      final result = fnArraySort(context, [
        arraySeq(array),
        XPathSequence.empty, // collation
        seq(length),
      ]);
      expect(
        result,
        isXPathSequence([
          ['be', 'cat', 'apple'],
        ]),
      );
    });

    test('sorts items with 2 arguments', () {
      final array = ['b', 'a'];
      final result = fnArraySort(context, [
        arraySeq(array),
        const XPathSequence.single(
          XPathString(
            'http://www.w3.org/2005/xpath-functions/collation/codepoint',
          ),
        ),
      ]);
      expect(
        result,
        isXPathSequence([
          ['a', 'b'],
        ]),
      );
    });

    test('sorts items with empty sequence key', () {
      final array = XPathArray([
        XPathSequence.single(XPathInteger.fromInt(2)),
        XPathSequence.empty,
        XPathSequence.single(XPathInteger.fromInt(1)),
      ]);
      final result = fnArraySort(context, [XPathSequence.single(array)]);
      expect(
        result,
        isXPathSequence([
          [isNull, 1, 2],
        ]),
      );
    });
  });
}
