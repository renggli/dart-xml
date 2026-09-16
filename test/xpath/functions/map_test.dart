import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/map.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('map:merge', () {
    test('merges maps', () {
      final map1 = {'a': 1, 'b': 2};
      final map2 = {'b': 3, 'c': 4};
      expect(
        fnMapMerge(context, [
          XPathSequence([toXPathItem(map1), toXPathItem(map2)]),
        ]),
        isXPathSequence([
          {'a': 1, 'b': 3, 'c': 4},
        ]),
      );
    });

    test('throws for non-map item', () {
      expect(
        () => fnMapMerge(context, [seq(123)]),
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
      expect(fnMapSize(context, [seq(map)]), isXPathSequence([2]));
    });
  });

  group('map:keys', () {
    test('returns keys', () {
      final map = {'a': 1, 'b': 2};
      expect(
        fnMapKeys(context, [seq(map)]),
        isXPathSequence(containsAll(['a', 'b'])),
      );
    });
  });

  group('map:contains', () {
    test('returns true if contains', () {
      final map = {'a': 1};
      expect(
        fnMapContains(context, [seq(map), seq('a')]),
        isXPathSequence([true]),
      );
    });

    test('returns false if not contains', () {
      final map = {'a': 1};
      expect(
        fnMapContains(context, [seq(map), seq('b')]),
        isXPathSequence([false]),
      );
    });
  });

  group('map:get', () {
    test('returns value for key', () {
      final map = {'a': 1};
      expect(fnMapGet(context, [seq(map), seq('a')]), isXPathSequence([1]));
    });

    test('returns empty for missing key', () {
      final map = {'a': 1};
      expect(fnMapGet(context, [seq(map), seq('b')]), isXPathSequence(isEmpty));
    });
  });

  group('map:find', () {
    test('finds value', () {
      final map = {'a': 1};
      expect(
        fnMapFind(context, [seq(map), seq('a')]),
        isXPathSequence([
          [1],
        ]),
      );
    });

    test('finds value in nested list', () {
      final map = {'a': 1};
      final list = [
        map,
        {'a': 2},
      ];
      final result = fnMapFind(context, [seq(list), seq('a')]);
      expect(
        result,
        isXPathSequence([
          [1, 2],
        ]),
      );
    });
  });

  group('map:put', () {
    test('adds entry', () {
      final map = {'a': 1};
      expect(
        fnMapPut(context, [seq(map), seq('b'), seq(2)]),
        isXPathSequence([
          {'a': 1, 'b': 2},
        ]),
      );
    });
  });

  group('map:entry', () {
    test('creates entry', () {
      expect(
        fnMapEntry(context, [seq('a'), seq(1)]),
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
        fnMapRemove(context, [seq(map), seq('a')]),
        isXPathSequence([
          {'b': 2},
        ]),
      );
    });

    test('removes multiple entries', () {
      final map = {'a': 1, 'b': 2};
      expect(
        fnMapRemove(context, [
          seq(map),
          seq(['a', 'b']),
        ]),
        isXPathSequence([isEmpty]),
      );
    });
  });

  group('map:for-each', () {
    test('applies function to mapping', () {
      final map = {'a': 1, 'b': 2};
      XPathSequence concat(XPathContext context, List<XPathSequence> args) {
        final key = args[0].first.stringValue;
        final value = args[1].first.stringValue;
        return seq('$key$value');
      }

      expect(
        fnMapForEach(context, [seq(map), seq(concat)]),
        isXPathSequence(containsAll(['a1', 'b2'])),
      );
    });
  });
}
