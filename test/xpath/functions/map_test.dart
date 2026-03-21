import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/map.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('map:merge', () {
    test('merges maps', () {
      final map1 = {'a': 1, 'b': 2};
      final map2 = {'b': 3, 'c': 4};
      expect(
        fnMapMerge(context, [
          XPathSequence([map1, map2]),
        ]),
        isXPathSequence([
          {'a': 1, 'b': 3, 'c': 4},
        ]),
      );
    });

    test('throws for non-map item', () {
      expect(
        () => fnMapMerge(context, [const XPathSequence.single(123)]),
        throwsA(
          isXPathEvaluationException(
            message: 'Unsupported cast from 123 to map(*)',
          ),
        ),
      );
    });
  });

  group('map:size', () {
    test('returns size', () {
      final map = {'a': 1, 'b': 2};
      expect(
        fnMapSize(context, [XPathSequence.single(map)]),
        isXPathSequence([2]),
      );
    });
  });

  group('map:keys', () {
    test('returns keys', () {
      final map = {'a': 1, 'b': 2};
      expect(
        fnMapKeys(context, [XPathSequence.single(map)]),
        isXPathSequence(containsAll(['a', 'b'])),
      );
    });
  });

  group('map:contains', () {
    test('returns true if contains', () {
      final map = {'a': 1};
      expect(
        fnMapContains(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('returns false if not contains', () {
      final map = {'a': 1};
      expect(
        fnMapContains(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence([false]),
      );
    });
  });

  group('map:get', () {
    test('returns value for key', () {
      final map = {'a': 1};
      expect(
        fnMapGet(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([1]),
      );
    });

    test('returns empty for missing key', () {
      final map = {'a': 1};
      expect(
        fnMapGet(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('map:find', () {
    test('finds value', () {
      final map = {'a': 1};
      expect(
        fnMapFind(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        [
          [1],
        ],
      );
    });

    test('finds value in nested list', () {
      final map = {'a': 1};
      final list = [
        map,
        {'a': 2},
      ];
      final result = fnMapFind(context, [
        XPathSequence.single(list),
        const XPathSequence.single('a'),
      ]);
      expect(result, [
        [1, 2],
      ]);
    });
  });

  group('map:put', () {
    test('adds entry', () {
      final map = {'a': 1};
      expect(
        fnMapPut(context, [
          XPathSequence.single(map),
          const XPathSequence.single('b'),
          const XPathSequence.single(2),
        ]),
        isXPathSequence([
          {'a': 1, 'b': 2},
        ]),
      );
    });
  });

  group('map:entry', () {
    test('creates entry', () {
      expect(
        fnMapEntry(context, [
          const XPathSequence.single('a'),
          const XPathSequence.single(1),
        ]),
        isXPathSequence([
          {'a': 1},
        ]),
      );
    });
  });

  group('map:remove', () {
    test('removes entry', () {
      final map = {'a': 1, 'b': 2};
      expect(
        fnMapRemove(context, [
          XPathSequence.single(map),
          const XPathSequence.single('a'),
        ]),
        isXPathSequence([
          {'b': 2},
        ]),
      );
    });

    test('removes multiple entries', () {
      final map = {'a': 1, 'b': 2};
      expect(
        fnMapRemove(context, [
          XPathSequence.single(map),
          const XPathSequence(['a', 'b']),
        ]),
        isXPathSequence([isEmpty]),
      );
    });
  });

  group('map:for-each', () {
    test('applies function to mapping', () {
      final map = {'a': 1, 'b': 2};
      XPathSequence concat(XPathContext context, List<XPathSequence> args) {
        final key = args[0];
        final value = args[1];
        return XPathSequence.single(xsString.cast(key) + xsString.cast(value));
      }

      expect(
        fnMapForEach(context, [
          XPathSequence.single(map),
          XPathSequence.single(concat),
        ]),
        isXPathSequence(containsAll(['a1', 'b2'])),
      );
    });
  });
}
