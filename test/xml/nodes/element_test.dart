import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../utils/assertions.dart';
import '../../utils/matchers.dart';

void main() {
  test('basic', () {
    final document = XmlDocument.parse(
      '<ns:data key="value">Am I or are the other crazy?</ns:data>',
    );
    final node = document.rootElement;
    expect(node.qualifiedName, 'ns:data');
    expect(node.namespacePrefix, 'ns');
    expect(node.localName, 'data');
    expect(node.name.qualified, 'ns:data');
    expect(node.name.prefix, 'ns');
    expect(node.name.local, 'data');
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, hasLength(1));
    expect(node.children, hasLength(1));
    expect(node.descendants, hasLength(2));
    expect(node.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.innerText, 'Am I or are the other crazy?');
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.isSelfClosing, isTrue);
    expect(
      node.toString(),
      '<ns:data key="value">Am I or are the other crazy?</ns:data>',
    );
  });
  test('self-closing', () {
    final document = XmlDocument.parse('<data/>');
    final node = document.rootElement;
    expect(node.qualifiedName, 'data');
    expect(node.namespacePrefix, isNull);
    expect(node.localName, 'data');
    expect(node.name.qualified, 'data');
    expect(node.name.prefix, isNull);
    expect(node.name.local, 'data');
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.innerText, isEmpty);
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.isSelfClosing, isTrue);
    expect(node.toString(), '<data/>');
  });
  test('empty', () {
    final document = XmlDocument.parse('<data></data>');
    final node = document.rootElement;
    expect(node.name.qualified, 'data');
    expect(node.namespacePrefix, isNull);
    expect(node.localName, 'data');
    expect(node.name.qualified, 'data');
    expect(node.name.prefix, isNull);
    expect(node.name.local, 'data');
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isEmpty);
    expect(node.innerText, isEmpty);
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.isSelfClosing, isFalse);
    expect(node.toString(), '<data></data>');
  });
  test('builder', () {
    final document = XmlDocument.build((builder) {
      builder.declaration();
      builder.element('root', nest: 'Hello World');
    });
    assertDocumentInvariants(document);
    expect(
      document.toXmlString(),
      '<?xml version="1.0"?><root>Hello World</root>',
    );
  });
  test('nested', () {
    final document = XmlDocument.parse('<outer><inner/></outer>');
    final outer = document.rootElement;
    expect(outer.toString(), '<outer><inner/></outer>');
    final inner = outer.firstChild!;
    expect(outer.getElement('inner'), same(inner));
    expect(inner.parentElement, same(outer));
    expect(inner.toString(), '<inner/>');
  });
  test('constructor error', () {
    final document = XmlDocument.parse('<element attr="value1">text</element>');
    final node = document.rootElement;
    expect(
      () => XmlElement.tag('data', attributes: node.attributes),
      throwsA(isXmlParentException()),
    );
    expect(
      () => XmlElement.tag('data', children: node.children),
      throwsA(isXmlParentException()),
    );
  });
  test('add attribute', () {
    final document = XmlDocument.parse('<data/>');
    final node = document.rootElement;
    expect(node.getAttribute('attr'), isNull);
    expect(node.getAttributeNode('attr'), isNull);
    node.setAttribute('attr', 'value');
    expect(node.getAttribute('attr'), 'value');
    expect(node.getAttributeNode('attr')?.value, 'value');
    expect(node.toString(), '<data attr="value"/>');
  });
  test('add attribute with namespace', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" />');
    final node = document.rootElement;
    expect(node.getAttribute('attr', namespaceUri: 'uri'), isNull);
    expect(node.getAttributeNode('attr', namespaceUri: 'uri'), isNull);
    node.setAttribute('ns:attr', 'value', namespaceUri: 'uri');
    expect(node.getAttribute('attr', namespaceUri: 'uri'), 'value');
    expect(node.getAttributeNode('attr', namespaceUri: 'uri')?.value, 'value');
    expect(node.toString(), '<data xmlns:ns="uri" ns:attr="value"/>');
  });
  test('add attribute with namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" />');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri'), isNull);
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('ns:attr', 'value', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), 'value');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri')?.value, 'value');
    expect(node.toString(), '<data xmlns:ns="uri" ns:attr="value"/>');
  });
  test('add attribute with default namespace', () {
    final document = XmlDocument.parse('<data xmlns="uri" />');
    final node = document.rootElement;
    expect(node.getAttribute('attr', namespaceUri: 'uri'), isNull);
    expect(node.getAttributeNode('attr', namespaceUri: 'uri'), isNull);
    node.setAttribute('attr', 'value', namespaceUri: 'uri');
    expect(node.getAttribute('attr', namespaceUri: 'uri'), 'value');
    expect(node.getAttributeNode('attr', namespaceUri: 'uri')?.value, 'value');
    expect(node.toString(), '<data xmlns="uri" attr="value"/>');
  });
  test('add attribute with default namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns="uri" />');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri'), isNull);
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('attr', 'value', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), 'value');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri')?.value, 'value');
    expect(node.toString(), '<data xmlns="uri" attr="value"/>');
  });
  test('update attribute', () {
    final document = XmlDocument.parse('<data attr="old"/>');
    final node = document.rootElement;
    node.setAttribute('attr', 'new');
    expect(node.getAttribute('attr'), 'new');
    expect(node.getAttributeNode('attr')?.value, 'new');
    expect(node.toString(), '<data attr="new"/>');
  });
  test('update attribute with namespace', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    node.setAttribute('attr', 'new', namespaceUri: 'uri');
    expect(node.getAttribute('attr', namespaceUri: 'uri'), 'new');
    expect(node.getAttributeNode('attr', namespaceUri: 'uri')?.value, 'new');
    expect(node.toString(), '<data xmlns:ns="uri" ns:attr="new"/>');
  });
  test('update attribute with namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('attr', 'new', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), 'new');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri')?.value, 'new');
    expect(node.toString(), '<data xmlns:ns="uri" ns:attr="new"/>');
  });
  test('update attribute with default namespace', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    node.setAttribute('attr', 'new', namespaceUri: 'uri');
    expect(node.getAttribute('attr', namespaceUri: 'uri'), 'new');
    expect(node.getAttributeNode('attr', namespaceUri: 'uri')?.value, 'new');
    expect(node.toString(), '<data xmlns="uri" attr="new"/>');
  });
  test('update attribute with default namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.setAttribute('attr', 'new', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), 'new');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri')?.value, 'new');
    expect(node.toString(), '<data xmlns="uri" attr="new"/>');
  });
  test('remove attribute', () {
    final document = XmlDocument.parse('<data attr="old"/>');
    final node = document.rootElement;
    node.removeAttribute('attr');
    expect(node.getAttribute('attr'), isNull);
    expect(node.getAttributeNode('attr'), isNull);
    expect(node.toString(), '<data/>');
  });
  test('remove attribute with namespace', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    node.removeAttribute('attr', namespaceUri: 'uri');
    expect(node.getAttribute('attr', namespaceUri: 'uri'), isNull);
    expect(node.getAttributeNode('attr', namespaceUri: 'uri'), isNull);
    expect(node.toString(), '<data xmlns:ns="uri"/>');
  });
  test('remove attribute with namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns:ns="uri" ns:attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.removeAttribute('attr', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri'), isNull);
    expect(node.toString(), '<data xmlns:ns="uri"/>');
  });
  test('remove attribute with default namespace', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    node.removeAttribute('attr', namespaceUri: 'uri');
    expect(node.getAttribute('attr', namespaceUri: 'uri'), isNull);
    expect(node.getAttributeNode('attr', namespaceUri: 'uri'), isNull);
    expect(node.toString(), '<data xmlns="uri"/>');
  });
  test('remove attribute with default namespace (deprecated)', () {
    final document = XmlDocument.parse('<data xmlns="uri" attr="old"/>');
    final node = document.rootElement;
    // ignore: deprecated_member_use_from_same_package
    node.removeAttribute('attr', namespace: 'uri');
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttribute('attr', namespace: 'uri'), isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.getAttributeNode('attr', namespace: 'uri'), isNull);
    expect(node.toString(), '<data xmlns="uri"/>');
  });
}
