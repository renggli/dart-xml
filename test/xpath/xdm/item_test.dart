import 'package:test/test.dart';
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
      expect(node.type, equals(xsElement));
      expect(node.node, same(el));
      expect(node.stringValue, equals('hello'));
      expect(node.effectiveBooleanValue, isTrue);
      final atomized = node.atomize();
      expect(atomized, isA<XPathUntypedAtomic>());
      expect(atomized.stringValue, equals('hello'));
      expect(node.toString(), equals(el.toString()));
    });

    test('attribute node type and stringValue', () {
      final attr = XmlAttribute(const XmlName.qualified('id'), '123');
      final node = XPathNode(attr);
      expect(node.type, equals(xsAttribute));
      expect(node.stringValue, equals('123'));
      expect(node.atomize(), equals(const XPathUntypedAtomic('123')));
    });

    test('text node type and stringValue', () {
      final txt = XmlText('text value');
      final node = XPathNode(txt);
      expect(node.type, equals(xsText));
      expect(node.stringValue, equals('text value'));
    });

    test('comment node type and stringValue', () {
      final cmt = XmlComment('comment content');
      final node = XPathNode(cmt);
      expect(node.type, equals(xsComment));
      expect(node.stringValue, equals('comment content'));
    });

    test('processing instruction node type and stringValue', () {
      final pi = XmlProcessing('target', 'data text');
      final node = XPathNode(pi);
      expect(node.type, equals(xsProcessingInstruction));
      expect(node.stringValue, equals('data text'));
    });

    test('document node type and stringValue', () {
      final doc = XmlDocument.parse('<r><a>foo</a><b>bar</b></r>');
      final node = XPathNode(doc);
      expect(node.type, equals(xsDocument));
      expect(node.stringValue, equals('foobar'));
    });

    test('document fragment node type', () {
      final frag = XmlDocumentFragment([XmlText('frag')]);
      final node = XPathNode(frag);
      expect(node.type, equals(xsDocument));
      expect(node.stringValue, equals('frag'));
    });

    test('equality and hashCode', () {
      final el1 = XmlElement(const XmlName.qualified('a'));
      final el2 = XmlElement(const XmlName.qualified('a'));
      final n1 = XPathNode(el1);
      final n1Same = XPathNode(el1);
      final n2 = XPathNode(el2);

      expect(n1, equals(n1Same));
      expect(n1.hashCode, equals(n1Same.hashCode));
      expect(n1 == n2, isFalse);
      expect(n1 == Object(), isFalse);
    });
  });
}
