import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');

  group('xsString', () {
    test('name', () {
      expect(xsString.name, 'xs:string');
    });
    test('matches', () {
      expect(xsString.matches('abc'), isTrue);
      expect(xsString.matches(123), isFalse);
    });
    group('cast', () {
      test('from string', () {
        expect(xsString.cast('abc'), 'abc');
        expect(xsString.cast(''), '');
      });
      test('from boolean', () {
        expect(xsString.cast(true), 'true');
        expect(xsString.cast(false), 'false');
      });
      test('from number', () {
        expect(xsString.cast(123), '123');
        expect(xsString.cast(123.45), '123.45');
        expect(xsString.cast(123.0), '123');
        expect(xsString.cast(0), '0');
        expect(xsString.cast(0.0), '0');
        expect(xsString.cast(-0.0), '0');
        expect(xsString.cast(double.nan), 'NaN');
        expect(xsString.cast(double.infinity), 'INF');
        expect(xsString.cast(double.negativeInfinity), '-INF');
      });
      test('from node', () {
        expect(xsString.cast(document), '123');
        expect(xsString.cast(document.rootElement), '123');
        expect(xsString.cast(document.findAllElements('b').first), '23');
        expect(xsString.cast(XmlText('foo')), 'foo');
        expect(xsString.cast(XmlCDATA('bar')), 'bar');
        expect(xsString.cast(XmlComment('baz')), 'baz');
        expect(xsString.cast(XmlProcessing('target', 'qux')), 'qux');
      });
      test('from sequence', () {
        expect(xsString.cast(XPathSequence.empty), '');
        expect(xsString.cast(const XPathSequence.single('abc')), 'abc');
        expect(xsString.cast(const XPathSequence.single(123)), '123');
        expect(
          () => xsString.cast(const XPathSequence(['a', 'b'])),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
      test('from unsupported', () {
        expect(
          () => xsString.cast(Object()),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });
  });
}
