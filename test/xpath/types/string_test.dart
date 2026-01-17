import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');
  // final node = document.findAllElements('a').single; // Not used in string tests directly but used in others
  // final context = XPathContext(document); // Not used

  group('string', () {
    test('cast from string', () {
      expect('abc'.toXPathString(), 'abc');
      expect(''.toXPathString(), '');
    });
    test('cast from boolean', () {
      expect(true.toXPathString(), 'true');
      expect(false.toXPathString(), 'false');
    });
    test('cast from number', () {
      expect(123.toXPathString(), '123');
      expect(123.45.toXPathString(), '123.45');
      expect(123.0.toXPathString(), '123');
      expect(0.toXPathString(), '0');
      expect(0.0.toXPathString(), '0');
      expect((-0.0).toXPathString(), '0');
      expect(double.nan.toXPathString(), 'NaN');
      expect(double.infinity.toXPathString(), 'INF');
      expect(double.negativeInfinity.toXPathString(), '-INF');
    });
    test('cast from node', () {
      expect(document.toXPathString(), '123');
      expect(document.rootElement.toXPathString(), '123');
      expect(document.findAllElements('b').first.toXPathString(), '23');
      expect(XmlText('foo').toXPathString(), 'foo');
      expect(XmlCDATA('bar').toXPathString(), 'bar');
      expect(XmlComment('baz').toXPathString(), 'baz');
      expect(XmlProcessing('target', 'qux').toXPathString(), 'qux');
    });
    test('cast from sequence', () {
      expect(XPathSequence.empty.toXPathString(), '');
      expect(const XPathSequence.single('abc').toXPathString(), 'abc');
      expect(const XPathSequence.single(123).toXPathString(), '123');
      expect(
        () => const XPathSequence(['a', 'b']).toXPathString(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
