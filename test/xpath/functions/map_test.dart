import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/map.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('map:merge', () {
    test('merges maps', () {
      final map1 = {'a': 1, 'b': 2};
      final map2 = {'b': 3, 'c': 4};
      check(
        fnMapMerge(context, [
          XPathSequence([toXPathItem(map1), toXPathItem(map2)]),
        ]),
      ).isXPathSequence([
        {'a': 1, 'b': 2, 'c': 4},
      ]);
    });

    test('throws for non-map item', () {
      check(() => fnMapMerge(context, [seq(123)]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123 to map(*)',
            ),
          );
    });
    test('merges maps with options', () {
      final map1 = {'a': 1};
      final map2 = {'a': 2};
      check(
        fnMapMerge(context, [
          XPathSequence([toXPathItem(map1), toXPathItem(map2)]),
          seq({'duplicates': 'use-last'}),
        ]),
      ).isXPathSequence([
        {'a': 2},
      ]);
    });
  });

  group('map:size', () {
    test('returns size', () {
      final map = {'a': 1, 'b': 2};
      check(fnMapSize(context, [seq(map)])).isXPathSequence([2]);
    });
  });

  group('map:keys', () {
    test('returns keys', () {
      final map = {'a': 1, 'b': 2};
      check(fnMapKeys(context, [seq(map)])).unwrapped
          .unorderedEquals(['a', 'b']);
    });
  });

  group('map:contains', () {
    test('returns true if contains', () {
      final map = {'a': 1};
      check(fnMapContains(context, [seq(map), seq('a')]))
          .isXPathSequence([true]);
    });

    test('returns false if not contains', () {
      final map = {'a': 1};
      check(fnMapContains(context, [seq(map), seq('b')]))
          .isXPathSequence([false]);
    });
  });

  group('map:get', () {
    test('returns value for key', () {
      final map = {'a': 1};
      check(fnMapGet(context, [seq(map), seq('a')])).isXPathSequence([1]);
    });

    test('returns empty for missing key', () {
      final map = {'a': 1};
      check(fnMapGet(context, [seq(map), seq('b')])).isXPathSequence(isEmpty);
    });
  });

  group('map:find', () {
    test('finds value', () {
      final map = {'a': 1};
      check(fnMapFind(context, [seq(map), seq('a')])).isXPathSequence([
        [1],
      ]);
    });

    test('finds value in nested list', () {
      final map = {'a': 1};
      final list = [
        map,
        {'a': 2},
      ];
      final result = fnMapFind(context, [seq(list), seq('a')]);
      check(result).isXPathSequence([
        [1, 2],
      ]);
    });

    test('finds value in XPathArray', () {
      final array = XPathArray([
        XPathSequence.single(
          XPathMap({
            const XPathString('a'): XPathSequence.single(
              XPathInteger.fromInt(42),
            ),
          }),
        ),
      ]);
      final result = fnMapFind(context, [
        XPathSequence.single(array),
        const XPathSequence.single(XPathString('a')),
      ]);
      check(result).isXPathSequence([
        [42],
      ]);
    });
  });

  group('map:put', () {
    test('adds entry', () {
      final map = {'a': 1};
      check(fnMapPut(context, [seq(map), seq('b'), seq(2)])).isXPathSequence([
        {'a': 1, 'b': 2},
      ]);
    });
  });

  group('map:entry', () {
    test('creates entry', () {
      check(fnMapEntry(context, [seq('a'), seq(1)])).isXPathSequence([
        {'a': 1},
      ]);
    });
  });

  group('map:remove', () {
    test('removes entry', () {
      final map = {'a': 1, 'b': 2};
      check(fnMapRemove(context, [seq(map), seq('a')])).isXPathSequence([
        {'b': 2},
      ]);
    });

    test('removes multiple entries', () {
      final map = {'a': 1, 'b': 2};
      check(
        fnMapRemove(context, [
          seq(map),
          seq(['a', 'b']),
        ]),
      ).isXPathSequence([isEmpty]);
    });
  });

  group('map:merge', () {
    test('defaults to use-first on duplicates', () {
      final m1 = {'a': 1};
      final m2 = {'a': 2};
      final result = fnMapMerge(context, [
        XPathSequence([seq(m1).first, seq(m2).first]),
      ]);
      check(fnMapGet(context, [result, seq('a')])).isXPathSequence([1]);
    });

    test('supports duplicates: use-last', () {
      final m1 = {'a': 1};
      final m2 = {'a': 2};
      final options = {'duplicates': 'use-last'};
      final result = fnMapMerge(context, [
        XPathSequence([seq(m1).first, seq(m2).first]),
        seq(options),
      ]);
      check(fnMapGet(context, [result, seq('a')])).isXPathSequence([2]);
    });

    test('supports duplicates: combine', () {
      final m1 = {'a': 1};
      final m2 = {'a': 2};
      final options = {'duplicates': 'combine'};
      final result = fnMapMerge(context, [
        XPathSequence([seq(m1).first, seq(m2).first]),
        seq(options),
      ]);
      check(fnMapGet(context, [result, seq('a')])).isXPathSequence([1, 2]);
    });

    test('supports duplicates: reject', () {
      final m1 = {'a': 1};
      final m2 = {'a': 2};
      final options = {'duplicates': 'reject'};
      check(
        () => fnMapMerge(context, [
          XPathSequence([seq(m1).first, seq(m2).first]),
          seq(options),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0003),
      );
    });

    test('throws FOJS0005 for invalid duplicate option', () {
      final m1 = {'a': 1};
      final options = {'duplicates': 'invalid-mode'};
      check(
        () => fnMapMerge(context, [
          XPathSequence([seq(m1).first]),
          seq(options),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FOJS0005),
      );
    });

    test('throws XPTY0004 for empty sequence options', () {
      final m1 = {'a': 1};
      check(
        () => fnMapMerge(context, [
          XPathSequence([seq(m1).first]),
          XPathSequence.empty,
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
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

      check(fnMapForEach(context, [seq(map), seq(concat)])).unwrapped
          .unorderedEquals(['a1', 'b2']);
    });
  });
}
