import 'package:test/test.dart';
import 'package:xml/src/xpath/types/boolean.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsBoolean', () {
    test('name', () {
      expect(xsBoolean.name, 'xs:boolean');
    });
    test('matches', () {
      expect(xsBoolean.matches(true), isTrue);
      expect(xsBoolean.matches(false), isTrue);
      expect(xsBoolean.matches(1), isFalse);
      expect(xsBoolean.matches('true'), isFalse);
    });
    group('cast', () {
      test('from boolean', () {
        expect(xsBoolean.cast(true), true);
        expect(xsBoolean.cast(false), false);
      });
      test('from number', () {
        expect(xsBoolean.cast(1), true);
        expect(xsBoolean.cast(0), false);
        expect(xsBoolean.cast(double.nan), false);
      });
      test('from string', () {
        expect(
          () => xsBoolean.cast('abc'),
          throwsA(isXPathEvaluationException()),
        );
        expect(() => xsBoolean.cast(''), throwsA(isXPathEvaluationException()));
        expect(xsBoolean.cast('true'), true);
        expect(xsBoolean.cast('false'), false);
        expect(xsBoolean.cast('1'), true);
        expect(xsBoolean.cast('0'), false);
      });
      test('from node', () {
        final node = XmlElement(const XmlName.qualified('a'));
        expect(
          () => xsBoolean.cast(node),
          throwsA(isXPathEvaluationException()),
        );
      });
      test('from sequence', () {
        final node = XmlElement(const XmlName.qualified('a'));
        final document = XmlDocument([node]);
        expect(
          () => xsBoolean.cast(XPathSequence.empty),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsBoolean.cast(XPathSequence.single(node)),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsBoolean.cast(XPathSequence([node, document])),
          throwsA(isXPathEvaluationException()),
        );
        expect(xsBoolean.cast(const XPathSequence([1])), true);
        expect(xsBoolean.cast(const XPathSequence([0])), false);
        expect(
          () => xsBoolean.cast(const XPathSequence([1, 2])),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from (1, 2) to xs:boolean',
            ),
          ),
        );
      });
    });
  });
}
