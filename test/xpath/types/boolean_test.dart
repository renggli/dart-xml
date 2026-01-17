import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/boolean.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');
  final node = document.findAllElements('a').single;
  // final context = XPathContext(document);

  group('boolean', () {
    test('cast from boolean', () {
      expect(true.toXPathBoolean(), true);
      expect(false.toXPathBoolean(), false);
    });
    test('cast from number', () {
      expect(1.toXPathBoolean(), true);
      expect(0.toXPathBoolean(), false);
      expect(double.nan.toXPathBoolean(), false);
    });
    test('cast from string', () {
      expect('abc'.toXPathBoolean(), true);
      expect(''.toXPathBoolean(), false);
    });
    test('cast from node', () {
      expect(node.toXPathBoolean(), true);
    });
    test('cast from sequence', () {
      expect(XPathSequence.empty.toXPathBoolean(), false);
      expect(XPathSequence.single(node).toXPathBoolean(), true);
      expect(XPathSequence([node, document]).toXPathBoolean(), true);
      expect(const XPathSequence([1]).toXPathBoolean(), true);
      expect(const XPathSequence([0]).toXPathBoolean(), false);
      expect(
        () => const XPathSequence([1, 2]).toXPathBoolean(),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
