import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/map.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('map:merge', () {
    final map1 = {'a': 1, 'b': 2};
    final map2 = {'b': 3, 'c': 4};
    expect(
      fnMapMerge(context, [
        XPathSequence([map1, map2]),
      ]),
      // duplicate keys: last wins by default? logic says result.addAll which overwrites.
      isXPathSequence([
        {'a': 1, 'b': 3, 'c': 4},
      ]),
    );
    expect(
      () => fnMapMerge(context, [const XPathSequence.single(123)]),
      throwsA(
        isXPathEvaluationException(
          message: 'Unsupported cast from 123 to map(*)',
        ),
      ),
    );
  });
  test('map:size', () {
    final map = {'a': 1, 'b': 2};
    expect(
      fnMapSize(context, [XPathSequence.single(map)]),
      isXPathSequence([2]),
    );
  });
  test('map:keys', () {
    final map = {'a': 1, 'b': 2};
    // Keys matching is order-dependent? Map keys order is iteration order.
    expect(
      fnMapKeys(context, [XPathSequence.single(map)]),
      isXPathSequence(containsAll(['a', 'b'])),
    );
  });
  test('map:contains', () {
    final map = {'a': 1};
    expect(
      fnMapContains(context, [
        XPathSequence.single(map),
        const XPathSequence.single('a'),
      ]),
      isXPathSequence([true]),
    );
    expect(
      fnMapContains(context, [
        XPathSequence.single(map),
        const XPathSequence.single('b'),
      ]),
      isXPathSequence([false]),
    );
  });
  test('map:get', () {
    final map = {'a': 1};
    expect(
      fnMapGet(context, [
        XPathSequence.single(map),
        const XPathSequence.single('a'),
      ]),
      isXPathSequence([1]),
    );
    expect(
      fnMapGet(context, [
        XPathSequence.single(map),
        const XPathSequence.single('b'),
      ]),
      isXPathSequence(isEmpty),
    );
  });
  test('map:find', () {
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
  test('map:put', () {
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
  test('map:entry', () {
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
  test('map:remove', () {
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
    expect(
      fnMapRemove(context, [
        XPathSequence.single(map),
        const XPathSequence(['a', 'b']),
      ]),
      isXPathSequence([isEmpty]),
    );
  });
  test('map:for-each', () {
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
}
