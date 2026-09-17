import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/functions/array.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/src/xpath/xdm/types.dart';
import 'package:xml/xml.dart';

import '../../../utils/matchers.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathArray', () {
    test('construction and basic properties', () {
      const arr = XPathArray([
        XPathSequence.single(XPathString('first')),
        XPathSequence.single(XPathString('second')),
      ]);
      expect(arr.type, equals(xsArray));
      expect(arr.arity, equals(1));
      expect(arr.length, equals(2));
      expect(arr.isEmpty, isFalse);
      expect(arr.isNotEmpty, isTrue);
      expect(arr[0], isXPathSequence(['first']));
      expect(arr[1], isXPathSequence(['second']));
      expect(arr.toString(), equals('[(first), (second)]'));
    });

    test('empty array', () {
      const arr = XPathArray.empty;
      expect(arr.isEmpty, isTrue);
      expect(arr.length, equals(0));
      expect(arr.toString(), equals('[]'));
    });

    test('callable as function with 1-based indexing', () {
      const arr = XPathArray([
        XPathSequence.single(XPathString('a')),
        XPathSequence.single(XPathString('b')),
      ]);
      final res1 = arr(context, [
        XPathSequence.single(XPathInteger.fromInt(1)),
      ]);
      expect(res1, isXPathSequence(['a']));

      final res2 = arr(context, [
        XPathSequence.single(XPathInteger.fromInt(2)),
      ]);
      expect(res2, isXPathSequence(['b']));

      expect(
        () => arr(context, [XPathSequence.single(XPathInteger.fromInt(0))]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => arr(context, [XPathSequence.single(XPathInteger.fromInt(3))]),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () =>
            arr(context, [const XPathSequence.single(XPathString('invalid'))]),
        throwsA(isXPathEvaluationException()),
      );
      expect(() => arr(context, []), throwsA(isXPathEvaluationException()));
      expect(
        () => arr(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('equality and hashCode', () {
      const a1 = XPathArray([XPathSequence.single(XPathString('x'))]);
      const a2 = XPathArray([XPathSequence.single(XPathString('x'))]);
      const a3 = XPathArray([XPathSequence.single(XPathString('y'))]);
      const a4 = XPathArray([]);

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1 == a3, isFalse);
      expect(a1 == a4, isFalse);
      expect(a1 == Object(), isFalse);
    });
  });
}
