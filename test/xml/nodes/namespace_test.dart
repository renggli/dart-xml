import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  test('named namespace', () {
    final document = XmlDocument.parse('<root xmlns:a="urn:a"/>');
    final node = document.rootElement.namespaces.first;
    expect(node.name.qualified, 'a');
    expect(node.name.prefix, isNull);
    expect(node.name.local, 'a');
    expect(node.parent, same(document.rootElement));
    expect(node.parentElement, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.value, 'urn:a');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.innerText, isEmpty);
    expect(node.nodeType, XmlNodeType.NAMESPACE);
    expect(node.toString(), 'xmlns:a="urn:a"');
  });
  test('default namespace', () {
    final document = XmlDocument.parse('<root xmlns="urn:a"/>');
    final node = document.rootElement.namespaces.first;
    expect(node.name.qualified, '');
    expect(node.name.prefix, isNull);
    expect(node.name.local, '');
    expect(node.parent, same(document.rootElement));
    expect(node.parentElement, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.value, 'urn:a');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.innerText, isEmpty);
    expect(node.nodeType, XmlNodeType.NAMESPACE);
    expect(node.toString(), 'xmlns="urn:a"');
  });
  test('root namespace', () {
    final document = XmlDocument.parse('<root/>');
    final node = document.rootElement.namespaces.first;
    expect(node.name.qualified, 'xml');
    expect(node.name.prefix, isNull);
    expect(node.name.local, 'xml');
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.value, 'http://www.w3.org/XML/1998/namespace');
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.innerText, isEmpty);
    expect(node.nodeType, XmlNodeType.NAMESPACE);
    expect(node.toString(), 'xmlns:xml="http://www.w3.org/XML/1998/namespace"');
  });
  test('in-scope namespaces (explicit prefixes)', () {
    final document = XmlDocument.parse(
      '<root xmlns:a="urn:a"><child xmlns:b="urn:b"/></root>',
    );
    expect(
      document.rootElement.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns:a="urn:a"'),
      ]),
    );
    expect(
      document.rootElement.firstElementChild!.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns:a="urn:a"'),
        isXmlNode<XmlNamespace>('xmlns:b="urn:b"'),
      ]),
    );
  });
  test('in-scope namespaces (default namespace)', () {
    final document = XmlDocument.parse(
      '<root xmlns="urn:root"><child/></root>',
    );
    expect(
      document.rootElement.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns="urn:root"'),
      ]),
    );
    expect(
      document.rootElement.firstElementChild!.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns="urn:root"'),
      ]),
    );
  });
  test('in-scope namespaces (shadowing prefix)', () {
    final document = XmlDocument.parse(
      '<root xmlns:p="urn:a"><child xmlns:p="urn:b"/></root>',
    );
    expect(
      document.rootElement.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns:p="urn:a"'),
      ]),
    );
    expect(
      document.rootElement.firstElementChild!.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns:p="urn:b"'),
      ]),
    );
  });
  test('in-scope namespaces (un-declaring default namespace)', () {
    final document = XmlDocument.parse(
      '<root xmlns="urn:root"><child xmlns=""/></root>',
    );
    expect(
      document.rootElement.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
        isXmlNode<XmlNamespace>('xmlns="urn:root"'),
      ]),
    );
    expect(
      document.rootElement.firstElementChild!.namespaces,
      unorderedEquals([
        isXmlNode<XmlNamespace>(
          'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ),
      ]),
    );
  });
}
