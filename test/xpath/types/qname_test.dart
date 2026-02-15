import 'package:test/test.dart';
import 'package:xml/src/xpath/types/qname.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  group('xsQName', () {
    test('name', () {
      expect(xsQName.name, 'xs:QName()');
    });
    test('matches', () {
      expect(xsQName.matches(const XmlName('foo')), isTrue);
      expect(xsQName.matches('foo'), isFalse);
      expect(xsQName.matches(123), isFalse);
    });
    group('cast', () {
      test('from XmlName', () {
        const name = XmlName('foo');
        expect(xsQName.cast(name), same(name));
      });
      test('from String', () {
        expect(xsQName.cast('foo').qualified, 'foo');
        expect(xsQName.cast('prefix:local').qualified, 'prefix:local');
      });
      test('from XPathSequence (single)', () {
        const name = XmlName('foo');
        expect(xsQName.cast(const XPathSequence([name])), same(name));
        expect(xsQName.cast(const XPathSequence([name])).qualified, 'foo');
      });
      test('from XPathSequence (empty)', () {
        expect(
          () => xsQName.cast(XPathSequence.empty),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to xs:QName()',
            ),
          ),
        );
      });
      test('from XPathSequence (multiple)', () {
        expect(
          () => xsQName.cast(const XPathSequence([XmlName('a'), XmlName('b')])),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from (a, b) to xs:QName()',
            ),
          ),
        );
      });
      test('from invalid type', () {
        expect(
          () => xsQName.cast(123),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123 to xs:QName()',
            ),
          ),
        );
      });
    });
  });
}
