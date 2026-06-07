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
      expect(xsFunction.matches(<Object, Object>{}), isTrue);
      expect(xsFunction.matches(<Object>[]), isTrue);
      expect(xsFunction.matches({'key': 'value'}), isTrue);
      expect(xsFunction.matches([1, 2, 3]), isTrue);
      expect(xsFunction.matches('foo'), isFalse);
    });
    group('cast', () {
      test('from XPathFunction', () {
        XPathSequence myFunction(
          XPathContext context,
          List<XPathSequence> arguments,
        ) => const XPathSequence.single('ok');

        final function = xsFunction.cast(myFunction);
        expect(function, isA<XPathFunction>());
        expect(function(context, []), ['ok']);
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
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to function(*)',
            ),
          ),
        );
      });
      test('from unsupported type', () {
        expect(
          () => xsFunction.cast('string'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from string to function(*)',
            ),
          ),
        );
        expect(
          () => xsFunction.cast(123),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123 to function(*)',
            ),
          ),
        );
      });
    });
  });
}
