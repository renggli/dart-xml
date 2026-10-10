import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathArray', () {
    test('construction and basic properties', () {
      const arr = XPathArray([
        XPathSequence.single(XPathString('first')),
        XPathSequence.single(XPathString('second')),
      ]);
      check(arr.type).equals(xsArray);
      check(arr.arity).equals(1);
      check(arr.length).equals(2);
      check(arr.isEmpty).isFalse();
      check(arr.isNotEmpty).isTrue();
      check(arr[0]).isXPathSequence(['first']);
      check(arr[1]).isXPathSequence(['second']);
      check(arr.toString()).equals('[(first), (second)]');
    });

    test('empty array', () {
      const arr = XPathArray.empty;
      check(arr.isEmpty).isTrue();
      check(arr.length).equals(0);
      check(arr.toString()).equals('[]');
    });

    test('callable as function with 1-based indexing', () {
      const arr = XPathArray([
        XPathSequence.single(XPathString('a')),
        XPathSequence.single(XPathString('b')),
      ]);
      final res1 = arr(context, [
        XPathSequence.single(XPathInteger.fromInt(1)),
      ]);
      check(res1).isXPathSequence(['a']);

      final res2 = arr(context, [
        XPathSequence.single(XPathInteger.fromInt(2)),
      ]);
      check(res2).isXPathSequence(['b']);

      check(() => arr(context, [XPathSequence.single(XPathInteger.fromInt(0))]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => arr(context, [XPathSequence.single(XPathInteger.fromInt(3))]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(
        () =>
            arr(context, [const XPathSequence.single(XPathString('invalid'))]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(() => arr(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(
        () => arr(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('equality and hashCode', () {
      const a1 = XPathArray([XPathSequence.single(XPathString('x'))]);
      const a2 = XPathArray([XPathSequence.single(XPathString('x'))]);
      const a3 = XPathArray([XPathSequence.single(XPathString('y'))]);
      const a4 = XPathArray([]);

      check(a1).equals(a2);
      check(a1.hashCode).equals(a2.hashCode);
      check(a1 == a3).isFalse();
      check(a1 == a4).isFalse();
      check(a1 == Object()).isFalse();
    });
  });
}
