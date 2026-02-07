import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/function.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r/>');
  final context = XPathContext(document);

  group('xsFunction', () {
    test('name', () {
      expect(xsFunction.name, 'function(*)');
    });
    test('matches', () {
      XPathSequence myFunction(
        XPathContext context,
        List<XPathSequence> arguments,
      ) => XPathSequence.empty;
      expect(xsFunction.matches(myFunction), isTrue);
      expect(xsFunction.matches('foo'), isFalse);
    });
    group('cast', () {
      test('from XPathFunction', () {
        XPathSequence myFunction(
          XPathContext context,
          List<XPathSequence> arguments,
        ) => const XPathSequence.single('ok');

        final function = xsFunction.cast(myFunction);
        expect(function, myFunction);
        expect(function(context, []), ['ok']);
      });
      test('from XPathArray (array as function)', () {
        const array = ['a', 'b', 'c'];
        final function = xsFunction.cast(array);
        final result1 = function(context, [const XPathSequence.single(1)]);
        expect(result1, ['a']);
        final result2 = function(context, [const XPathSequence.single(2)]);
        expect(result2, ['b']);
        expect(
          () => function(context, [const XPathSequence.single(4)]),
          throwsA(isA<XPathEvaluationException>()),
        );
        expect(
          () => function(context, []),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from XPathMap (map as function)', () {
        const map = {'key1': 'val1', 'key2': 'val2'};
        final function = xsFunction.cast(map);
        final result1 = function(context, [const XPathSequence.single('key1')]);
        expect(result1, ['val1']);
        final result2 = function(context, [
          const XPathSequence.single('unknown'),
        ]);
        expect(
          result2.isEmpty,
          isTrue,
        ); // Returns empty sequence for missing key?
        expect(
          () => function(context, []),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from XPathSequence', () {
        XPathSequence myFunction(
          XPathContext context,
          List<XPathSequence> arguments,
        ) => const XPathSequence.single('sequence-ok');

        final sequence = XPathSequence.single(myFunction);
        final function = xsFunction.cast(sequence);
        expect(function(context, []), ['sequence-ok']);
      });
      test('from XPathSequence (empty)', () {
        expect(
          () => xsFunction.cast(XPathSequence.empty),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from unsupported type', () {
        expect(
          () => xsFunction.cast('string'),
          throwsA(isA<XPathEvaluationException>()),
        );
        expect(
          () => xsFunction.cast(123),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
  });
}
