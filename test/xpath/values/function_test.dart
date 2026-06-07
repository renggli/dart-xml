import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/types/function.dart';
import 'package:xml/src/xpath/values/function.dart';
import 'package:xml/src/xpath/values/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  final document = XmlDocument.parse('<r/>');
  final context = const XPathConfiguration.raw().context(document);

  group('XPathFunction value tests', () {
    test('from XPathFunction', () {
      XPathSequence myFunction(
        XPathContext context,
        List<XPathSequence> arguments,
      ) => const XPathSequence.single('ok');

      final function = xsFunction.cast(myFunction);
      expect(function, isA<XPathFunction>());
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
        throwsA(
          isXPathEvaluationException(message: 'Array index out of bounds: 4'),
        ),
      );
      expect(
        () => function(context, []),
        throwsA(
          isXPathEvaluationException(
            message: 'Arrays expect exactly 1 argument, but got 0',
          ),
        ),
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
      expect(result2.isEmpty, isTrue); // Returns empty sequence for missing key
      expect(
        () => function(context, []),
        throwsA(
          isXPathEvaluationException(
            message: 'Maps expects exactly 1 argument, but got 0',
          ),
        ),
      );
    });
  });
}
