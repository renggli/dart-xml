import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../../utils/checks.dart';

void main() {
  test('named namespace', () {
    final document = XmlDocument.parse('<root xmlns:a="urn:a"/>');
    final node = document.rootElement.namespaces.first;
    check(node.name.qualified).equals('a');
    check(node.name.prefix).isNull();
    check(node.name.local).equals('a');
    check(node.parent).identicalTo(document.rootElement);
    check(node.parentElement).identicalTo(document.rootElement);
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(2);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).isEmpty();
    check(node.value).equals('urn:a');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.innerText).isEmpty();
    check(node.nodeType).equals(XmlNodeType.NAMESPACE);
    check(node.toString()).equals('xmlns:a="urn:a"');
  });
  test('default namespace', () {
    final document = XmlDocument.parse('<root xmlns="urn:a"/>');
    final node = document.rootElement.namespaces.first;
    check(node.name.qualified).equals('');
    check(node.name.prefix).isNull();
    check(node.name.local).equals('');
    check(node.parent).identicalTo(document.rootElement);
    check(node.parentElement).identicalTo(document.rootElement);
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(2);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).isEmpty();
    check(node.value).equals('urn:a');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.innerText).isEmpty();
    check(node.nodeType).equals(XmlNodeType.NAMESPACE);
    check(node.toString()).equals('xmlns="urn:a"');
  });
  test('root namespace', () {
    final document = XmlDocument.parse('<root/>');
    final node = document.rootElement.namespaces.first;
    check(node.name.qualified).equals('xml');
    check(node.name.prefix).isNull();
    check(node.name.local).equals('xml');
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).isEmpty();
    check(node.value).equals('http://www.w3.org/XML/1998/namespace');
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.innerText).isEmpty();
    check(node.nodeType).equals(XmlNodeType.NAMESPACE);
    check(node.toString())
        .equals('xmlns:xml="http://www.w3.org/XML/1998/namespace"');
  });
  test('copy', () {
    final document = XmlDocument.parse('<root xmlns:a="urn:a"/>');
    final node = document.rootElement.namespaces.first;
    final copy = node.copy();
    check(copy.name.qualified).equals(node.name.qualified);
    check(copy.name.prefix).equals(node.name.prefix);
    check(copy.name.local).equals(node.name.local);
    check(copy.value).equals(node.value);
    check(copy.parent).isNull();
    check(copy).not((it) => it.identicalTo(node));
  });
  test('in-scope namespaces (explicit prefixes)', () {
    final document = XmlDocument.parse(
      '<root xmlns:a="urn:a"><child xmlns:b="urn:b"/></root>',
    );
    check(document.rootElement.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns:a="urn:a"'),
    ]);
    check(document.rootElement.firstElementChild!.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns:a="urn:a"'),
      isXmlNode<XmlNamespace>('xmlns:b="urn:b"'),
    ]);
  });
  test('in-scope namespaces (default namespace)', () {
    final document = XmlDocument.parse(
      '<root xmlns="urn:root"><child/></root>',
    );
    check(document.rootElement.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns="urn:root"'),
    ]);
    check(document.rootElement.firstElementChild!.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns="urn:root"'),
    ]);
  });
  test('in-scope namespaces (shadowing prefix)', () {
    final document = XmlDocument.parse(
      '<root xmlns:p="urn:a"><child xmlns:p="urn:b"/></root>',
    );
    check(document.rootElement.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns:p="urn:a"'),
    ]);
    check(document.rootElement.firstElementChild!.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns:p="urn:b"'),
    ]);
  });
  test('in-scope namespaces (un-declaring default namespace)', () {
    final document = XmlDocument.parse(
      '<root xmlns="urn:root"><child xmlns=""/></root>',
    );
    check(document.rootElement.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
      isXmlNode<XmlNamespace>('xmlns="urn:root"'),
    ]);
    check(document.rootElement.firstElementChild!.namespaces).unorderedMatches([
      isXmlNode<XmlNamespace>(
        'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ),
    ]);
  });
}
