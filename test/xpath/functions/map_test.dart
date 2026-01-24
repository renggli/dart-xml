import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/map.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('op:same-key', () {
    expect(
      opSameKey(context, [
        const XPathSequence.single('a'),
        const XPathSequence.single('a'),
      ]),
      XPathSequence.trueSequence,
    );
    expect(
      opSameKey(context, [
        const XPathSequence.single(double.nan),
        const XPathSequence.single(double.nan),
      ]),
      XPathSequence.trueSequence,
    );
    expect(
      opSameKey(context, [
        const XPathSequence.single('a'),
        const XPathSequence.single('b'),
      ]),
      XPathSequence.falseSequence,
    );
  });
  test('map:merge', () {
    final map1 = {'a': 1, 'b': 2};
    final map2 = {'b': 3, 'c': 4};
    expect(
      mapMerge(context, [
        XPathSequence([map1, map2]),
      ]).first,
      // duplicate keys: last wins by default? logic says result.addAll which overwrites.
      {'a': 1, 'b': 3, 'c': 4},
    );
    expect(
      () => mapMerge(context, [const XPathSequence.single(123)]),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('map:size', () {
    final map = {'a': 1, 'b': 2};
    expect(mapSize(context, [XPathSequence.single(map)]), [2]);
  });
  test('map:keys', () {
    final map = {'a': 1, 'b': 2};
    // Keys matching is order-dependent? Map keys order is iteration order.
    expect(
      mapKeys(context, [XPathSequence.single(map)]).toList(),
      containsAll(['a', 'b']),
    );
  });
  test('map:contains', () {
    final map = {'a': 1};
    expect(
      mapContains(context, [
        XPathSequence.single(map),
        const XPathSequence.single('a'),
      ]),
      [true],
    );
    expect(
      mapContains(context, [
        XPathSequence.single(map),
        const XPathSequence.single('b'),
      ]),
      [false],
    );
  });
  test('map:get', () {
    final map = {'a': 1};
    expect(
      mapGet(context, [
        XPathSequence.single(map),
        const XPathSequence.single('a'),
      ]),
      [1],
    );
    expect(
      mapGet(context, [
        XPathSequence.single(map),
        const XPathSequence.single('b'),
      ]),
      isEmpty,
    );
  });
  test('map:find', () {
    // Stub implementation alias to map:get
    final map = {'a': 1};
    expect(
      mapFind(context, [
        XPathSequence.single(map),
        const XPathSequence.single('a'),
      ]),
      [1],
    );
  });
  test('map:put', () {
    final map = {'a': 1};
    expect(
      mapPut(context, [
        XPathSequence.single(map),
        const XPathSequence.single('b'),
        const XPathSequence.single(2),
      ]).first,
      {'a': 1, 'b': 2},
    );
  });
  test('map:entry', () {
    expect(
      mapEntry(context, [
        const XPathSequence.single('a'),
        const XPathSequence.single(1),
      ]).first,
      {'a': 1},
    );
  });
  test('map:remove', () {
    final map = {'a': 1, 'b': 2};
    expect(
      mapRemove(context, [
        XPathSequence.single(map),
        const XPathSequence.single('a'),
      ]).first,
      {'b': 2},
    );
    expect(
      mapRemove(context, [
        XPathSequence.single(map),
        const XPathSequence(['a', 'b']),
      ]).first,
      const <dynamic, dynamic>{},
    );
  });
  test('map:for-each', () {
    final map = {'a': 1, 'b': 2};
    XPathSequence concat(XPathContext context, List<XPathSequence> args) =>
        XPathSequence.single(args[0].toXPathString() + args[1].toXPathString());
    expect(
      mapForEach(context, [
        XPathSequence.single(map),
        XPathSequence.single(concat),
      ]).toList(),
      containsAll(['a1', 'b2']),
    );
  });
}
