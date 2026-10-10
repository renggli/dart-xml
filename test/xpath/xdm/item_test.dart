import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/item.dart';
import 'package:xml/src/xpath/xdm/types.dart';
import 'package:xml/xml.dart';

void main() {
  group('XPathNode', () {
    test('element node type, atomize, stringValue, ebv', () {
      final el = XmlElement(const XmlName.qualified('root'), [], [
        XmlText('hello'),
      ]);
      final node = XPathNode(el);
      check(node.type).equals(xsElement);
      check(node.node).identicalTo(el);
      check(node.stringValue).equals('hello');
      check(node.effectiveBooleanValue).isTrue();
      final atomized = node.atomize();
      check(atomized).isA<XPathUntypedAtomic>();
      check(atomized.stringValue).equals('hello');
      check(node.toString()).equals(el.toString());
    });

    test('attribute node type and stringValue', () {
      final attr = XmlAttribute(const XmlName.qualified('id'), '123');
      final node = XPathNode(attr);
      check(node.type).equals(xsAttribute);
      check(node.stringValue).equals('123');
      check(node.atomize()).equals(const XPathUntypedAtomic('123'));
    });

    test('text node type and stringValue', () {
      final txt = XmlText('text value');
      final node = XPathNode(txt);
      check(node.type).equals(xsText);
      check(node.stringValue).equals('text value');
    });

    test('comment node type and stringValue', () {
      final cmt = XmlComment('comment content');
      final node = XPathNode(cmt);
      check(node.type).equals(xsComment);
      check(node.stringValue).equals('comment content');
    });

    test('processing instruction node type and stringValue', () {
      final pi = XmlProcessing('target', 'data text');
      final node = XPathNode(pi);
      check(node.type).equals(xsProcessingInstruction);
      check(node.stringValue).equals('data text');
    });

    test('document node type and stringValue', () {
      final doc = XmlDocument.parse('<r><a>foo</a><b>bar</b></r>');
      final node = XPathNode(doc);
      check(node.type).equals(xsDocument);
      check(node.stringValue).equals('foobar');
    });

    test('document fragment node type', () {
      final frag = XmlDocumentFragment([XmlText('frag')]);
      final node = XPathNode(frag);
      check(node.type).equals(xsDocument);
      check(node.stringValue).equals('frag');
    });

    test('equality and hashCode', () {
      final el1 = XmlElement(const XmlName.qualified('a'));
      final el2 = XmlElement(const XmlName.qualified('a'));
      final n1 = XPathNode(el1);
      final n1Same = XPathNode(el1);
      final n2 = XPathNode(el2);

      check(n1).equals(n1Same);
      check(n1.hashCode).equals(n1Same.hashCode);
      check(n1 == n2).isFalse();
      check(n1 == Object()).isFalse();
    });
  });
}
