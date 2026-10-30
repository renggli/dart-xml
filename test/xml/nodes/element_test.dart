import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../../utils/assertions.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<ns:data key="value">Am I or are the other crazy?</ns:data>',
    );
    final node = document.rootElement;
    check(node.qualifiedName).equals('ns:data');
    check(node.namespacePrefix).equals('ns');
    check(node.localName).equals('data');
    check(node.name.qualified).equals('ns:data');
    check(node.name.prefix).equals('ns');
    check(node.name.local).equals('data');
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).length.equals(1);
    check(node.elementAttributes).length.equals(1);
    check(node.children).length.equals(1);
    check(node.descendants).length.equals(2);
    check(node.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('Am I or are the other crazy?');
    check(node.innerText).equals('Am I or are the other crazy?');
    check(node.nodeType).equals(XmlNodeType.ELEMENT);
    check(node.isSelfClosing).isTrue();
    check(node.toString())
        .equals('<ns:data key="value">Am I or are the other crazy?</ns:data>');
  });
  test('self-closing', () {
    final document = XmlDocument.parse('<data/>');
    final node = document.rootElement;
    check(node.qualifiedName).equals('data');
    check(node.namespacePrefix).isNull();
    check(node.localName).equals('data');
    check(node.name.qualified).equals('data');
    check(node.name.prefix).isNull();
    check(node.name.local).equals('data');
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).isEmpty();
    check(node.descendants).isEmpty();
    check(node.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.innerText).isEmpty();
    check(node.nodeType).equals(XmlNodeType.ELEMENT);
    check(node.isSelfClosing).isTrue();
    check(node.toString()).equals('<data/>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<data></data>');
    final node = document.rootElement;
    check(node.name.qualified).equals('data');
    check(node.namespacePrefix).isNull();
    check(node.localName).equals('data');
    check(node.name.qualified).equals('data');
    check(node.name.prefix).isNull();
    check(node.name.local).equals('data');
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.root).identicalTo(document);
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.children).isEmpty();
    check(node.descendants).isEmpty();
    check(node.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).isEmpty();
    check(node.innerText).isEmpty();
    check(node.nodeType).equals(XmlNodeType.ELEMENT);
    check(node.isSelfClosing).isFalse();
    check(node.toString()).equals('<data></data>');
  });
  test('builder', () {
    final document = XmlDocument.build((builder) {
      builder.declaration();
      builder.element('root', nest: 'Hello World');
    });
    assertDocumentInvariants(document);
    check(document.toXmlString())
        .equals('<?xml version="1.0"?><root>Hello World</root>');
  });
  test('nested', () {
    final document = XmlDocument.parse('<outer><inner/></outer>');
    final outer = document.rootElement;
    check(outer.toString()).equals('<outer><inner/></outer>');
    final inner = outer.firstElementChild!;
    check(outer.getElement('inner')).identicalTo(inner);
    check(inner.parentElement).identicalTo(outer);
    check(inner.toString()).equals('<inner/>');
  });
  test('move constructor', () {
    final document = XmlDocument.parse('<element attr="value1">text</element>');
    final node = document.rootElement;
    final attr = node.attributes.first;
    final child = node.children.first;
    final data = XmlElement.tag('data', attributes: node.attributes);
    check(data.attributes).contains(attr);
    check(node.attributes).isEmpty(); // moved out
    check(node.elementAttributes).isEmpty();
    final data2 = XmlElement.tag('data2', children: node.children);
    check(data2.children).contains(child);
    check(node.children).isEmpty(); // moved out
  });
  test('add attribute', () {
    final document = XmlDocument.parse('<data/>');
    final node = document.rootElement;
    check(node.getAttribute('attr')).isNull();
    check(node.getAttributeNode('attr')).isNull();
    node.setAttribute('attr', 'value');
    check(node.getAttribute('attr')).equals('value');
    check(node.getAttributeNode('attr')?.value).equals('value');
    check(node.toString()).equals('<data attr="value"/>');
  });
  test('add attribute with namespace', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" />');
    final node = document.rootElement;
    check(node.getAttribute('attr', namespaceUri: 'uri')).isNull();
    check(node.getAttributeNode('attr', namespaceUri: 'uri')).isNull();
    node.setAttribute('ns:attr', 'value', namespaceUri: 'uri');
    check(node.getAttribute('attr', namespaceUri: 'uri')).equals('value');
    check(node.getAttributeNode('attr', namespaceUri: 'uri')?.value)
        .equals('value');
    check(node.toString()).equals('<data xmlns:ns="uri" ns:attr="value"/>');
  });
  test('add attribute with namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" />');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')).isNull();
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('ns:attr', 'value', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).equals('value');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')?.value)
        .equals('value');
    check(node.toString()).equals('<data xmlns:ns="uri" ns:attr="value"/>');
  });
  test('add attribute with default namespace', () {
    final document = XmlDocument.parse('<data xmlns="uri" />');
    final node = document.rootElement;
    check(node.getAttribute('attr', namespaceUri: 'uri')).isNull();
    check(node.getAttributeNode('attr', namespaceUri: 'uri')).isNull();
    node.setAttribute('attr', 'value', namespaceUri: 'uri');
    check(node.getAttribute('attr', namespaceUri: 'uri')).equals('value');
    check(node.getAttributeNode('attr', namespaceUri: 'uri')?.value)
        .equals('value');
    check(node.toString()).equals('<data xmlns="uri" attr="value"/>');
  });
  test('add attribute with default namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns="uri" />');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')).isNull();
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('attr', 'value', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).equals('value');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')?.value)
        .equals('value');
    check(node.toString()).equals('<data xmlns="uri" attr="value"/>');
  });
  test('update attribute', () {
    final document = XmlDocument.parse('<data attr="old"/>');
    final node = document.rootElement;
    node.setAttribute('attr', 'new');
    check(node.getAttribute('attr')).equals('new');
    check(node.getAttributeNode('attr')?.value).equals('new');
    check(node.toString()).equals('<data attr="new"/>');
  });
  test('update attribute with namespace', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    node.setAttribute('attr', 'new', namespaceUri: 'uri');
    check(node.getAttribute('attr', namespaceUri: 'uri')).equals('new');
    check(node.getAttributeNode('attr', namespaceUri: 'uri')?.value)
        .equals('new');
    check(node.toString()).equals('<data xmlns:ns="uri" ns:attr="new"/>');
  });
  test('update attribute with namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('attr', 'new', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).equals('new');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')?.value).equals('new');
    check(node.toString()).equals('<data xmlns:ns="uri" ns:attr="new"/>');
  });
  test('update attribute with default namespace', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    node.setAttribute('attr', 'new', namespaceUri: 'uri');
    check(node.getAttribute('attr', namespaceUri: 'uri')).equals('new');
    check(node.getAttributeNode('attr', namespaceUri: 'uri')?.value)
        .equals('new');
    check(node.toString()).equals('<data xmlns="uri" attr="new"/>');
  });
  test('update attribute with default namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('attr', 'new', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).equals('new');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')?.value).equals('new');
    check(node.toString()).equals('<data xmlns="uri" attr="new"/>');
  });
  test('remove attribute', () {
    final document = XmlDocument.parse('<data attr="old"/>');
    final node = document.rootElement;
    node.removeAttribute('attr');
    check(node.getAttribute('attr')).isNull();
    check(node.getAttributeNode('attr')).isNull();
    check(node.toString()).equals('<data/>');
  });
  test('remove attribute with namespace', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    node.removeAttribute('attr', namespaceUri: 'uri');
    check(node.getAttribute('attr', namespaceUri: 'uri')).isNull();
    check(node.getAttributeNode('attr', namespaceUri: 'uri')).isNull();
    check(node.toString()).equals('<data xmlns:ns="uri"/>');
  });
  test('remove attribute with namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.removeAttribute('attr', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')).isNull();
    check(node.toString()).equals('<data xmlns:ns="uri"/>');
  });
  test('remove attribute with default namespace', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    node.removeAttribute('attr', namespaceUri: 'uri');
    check(node.getAttribute('attr', namespaceUri: 'uri')).isNull();
    check(node.getAttributeNode('attr', namespaceUri: 'uri')).isNull();
    check(node.toString()).equals('<data xmlns="uri"/>');
  });
  test('remove attribute with default namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.removeAttribute('attr', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttribute('attr', namespace: 'uri')).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.getAttributeNode('attr', namespace: 'uri')).isNull();
    check(node.toString()).equals('<data xmlns="uri"/>');
  });
  test('elementAttributes and isNamespaceDeclaration', () {
    final document = XmlDocument.parse(
      '<data xmlns="default-uri" xmlns:p="prefix-uri" regular="value" p:xmlns="not-a-ns"/>',
    );
    final node = document.rootElement;
    check(node.attributes).length.equals(4);
    check(node.attributes[0].isNamespaceDeclaration).isTrue();
    check(node.attributes[1].isNamespaceDeclaration).isTrue();
    check(node.attributes[2].isNamespaceDeclaration).isFalse();
    check(node.attributes[3].isNamespaceDeclaration).isFalse();

    final elementAttrs = node.elementAttributes.toList();
    check(elementAttrs).length.equals(2);
    check(elementAttrs[0].name.qualified).equals('regular');
    check(elementAttrs[0].value).equals('value');
    check(elementAttrs[1].name.qualified).equals('p:xmlns');
    check(elementAttrs[1].value).equals('not-a-ns');
  });
}
