import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');
  final node = document.findAllElements('a').single;

  test('cast from number', () {
    expect(123.toXPathNumber(), 123);
    expect(123.45.toXPathNumber(), 123.45);
  });
  test('cast from boolean', () {
    expect(true.toXPathNumber(), 1);
    expect(false.toXPathNumber(), 0);
  });
  test('cast from string', () {
    expect('123'.toXPathNumber(), 123);
    expect('abc'.toXPathNumber(), isNaN);
  });
  test('cast from node', () {
    expect(node.toXPathNumber(), 1);
  });
  test('cast from sequence', () {
    expect(
      () => XPathSequence.empty.toXPathNumber(),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(const XPathSequence.single(123).toXPathNumber(), 123);
    expect(
      () => const XPathSequence([123, 456]).toXPathNumber(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
}
