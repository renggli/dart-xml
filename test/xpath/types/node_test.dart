import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/node.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');
  final node = document.findAllElements('a').single;

  test('cast from number', () {
    expect(() => 123.toXPathNode(), throwsA(isA<XPathEvaluationException>()));
    expect(
      () => 123.45.toXPathNode(),
      throwsA(isA<XPathEvaluationException>()),
    );
  });
  test('cast from boolean', () {
    expect(() => true.toXPathNode(), throwsA(isA<XPathEvaluationException>()));
    expect(() => false.toXPathNode(), throwsA(isA<XPathEvaluationException>()));
  });
  test('cast from string', () {
    expect(() => 'abc'.toXPathNode(), throwsA(isA<XPathEvaluationException>()));
  });
  test('cast from node', () {
    expect(node.toXPathNode(), node);
    expect(document.toXPathNode(), document);
  });
  test('cast from sequence', () {
    expect(
      () => XPathSequence.empty.toXPathNode(),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(XPathSequence.single(node).toXPathNode(), node);
    expect(
      () => [node, document].toXPathNode(),
      throwsA(isA<XPathEvaluationException>()),
    );
    expect(() => [1].toXPathNode(), throwsA(isA<XPathEvaluationException>()));
  });
}
