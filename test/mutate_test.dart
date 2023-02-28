import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'utils/assertions.dart';
import 'utils/matchers.dart';

@isTest
void mutatingTest<T extends XmlNode>(String description, String before,
    void Function(T node) action, String after) {
  test(description, () {
    final document = XmlDocument.parse(before);
    final node = <XmlNode>[document]
        .followedBy(document.descendants)
        .whereType<T>()
        .first;
    action(node);
    document.normalize();
    expect(document.toXmlString(), after, reason: 'should be modified');
    assertDocumentTreeInvariants(document);
  });
}

@isTest
void throwingTest<T extends XmlNode>(String description, String before,
    void Function(T node) action, Matcher matcher) {
  test(description, () {
    final document = XmlDocument.parse(before);
    final node = <XmlNode>[document]
        .followedBy(document.descendants)
        .whereType<T>()
        .first;
    expect(() => action(node), matcher);
    expect(document.toXmlString(), before, reason: 'should not be modified');
    assertDocumentTreeInvariants(document);
  });
}

void main() {
  group('update', () {
    mutatingTest<XmlAttribute>(
      'element (attribute value)',
      '<element attr="value"/>',
      (node) => node.value = 'update',
      '<element attr="update"/>',
    );
    mutatingTest<XmlElement>(
      'element (self-closing: false)',
      '<element/>',
      (node) => node.isSelfClosing = false,
      '<element></element>',
    );
    mutatingTest<XmlElement>(
      'element (self-closing: true)',
      '<element></element>',
      (node) => node.isSelfClosing = true,
      '<element/>',
    );
    mutatingTest<XmlCDATA>(
      'cdata (value)',
      '<element><![CDATA[text]]></element>',
      (node) => node.value = 'update',
      '<element><![CDATA[update]]></element>',
    );
    mutatingTest<XmlCDATA>(
      'cdata (text)',
      '<element><![CDATA[text]]></element>',
      // ignore: deprecated_member_use_from_same_package
      (node) => node.text = 'update',
      '<element><![CDATA[update]]></element>',
    );
    mutatingTest<XmlComment>(
      'comment (value)',
      '<element><!--comment--></element>',
      (node) => node.value = 'update',
      '<element><!--update--></element>',
    );
    mutatingTest<XmlComment>(
      'comment (text)',
      '<element><!--comment--></element>',
      // ignore: deprecated_member_use_from_same_package
      (node) => node.text = 'update',
      '<element><!--update--></element>',
    );
    mutatingTest<XmlText>(
      'text (value)',
      '<element>text</element>',
      (node) => node.value = 'update',
      '<element>update</element>',
    );
    mutatingTest<XmlText>(
      'text (text)',
      '<element>text</element>',
      // ignore: deprecated_member_use_from_same_package
      (node) => node.text = 'update',
      '<element>update</element>',
    );
    mutatingTest<XmlProcessing>(
      'processing (value)',
      '<?processing text?><element/>',
      (node) => node.value = 'update',
      '<?processing update?><element/>',
    );
    mutatingTest<XmlProcessing>(
      'processing (text)',
      '<?processing text?><element/>',
      // ignore: deprecated_member_use_from_same_package
      (node) => node.text = 'update',
      '<?processing update?><element/>',
    );
    mutatingTest<XmlDeclaration>(
      'declaration (version)',
      '<?xml version="1.0"?><element/>',
      (node) => node.version = "1.5",
      '<?xml version="1.5"?><element/>',
    );
    mutatingTest<XmlDeclaration>(
      'declaration (encoding)',
      '<?xml encoding="latin"?><element/>',
      (node) => node.encoding = "utf-8",
      '<?xml encoding="utf-8"?><element/>',
    );
    mutatingTest<XmlDeclaration>(
      'declaration (standalone)',
      '<?xml standalone="yes"?><element/>',
      (node) => node.standalone = false,
      '<?xml standalone="no"?><element/>',
    );
  });
  group('add', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element/>',
      (node) => node.attributes.add(XmlAttribute(XmlName('attr'), 'value')),
      '<element attr="value"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element/>',
      (node) => node.children.add(XmlText('Hello World')),
      '<element>Hello World</element>',
    );
    mutatingTest<XmlElement>(
      'element (copy attribute)',
      '<element1 attr="value"><element2/></element1>',
      (node) =>
          node.children.first.attributes.add(node.attributes.first.copy()),
      '<element1 attr="value"><element2 attr="value"/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (copy children)',
      '<element1><element2/></element1>',
      (node) => node.children.add(node.children.first.copy()),
      '<element1><element2/><element2/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (fragment children)',
      '<element1/>',
      (node) {
        final fragment = XmlDocumentFragment([
          XmlText('Hello'),
          XmlElement(XmlName('element2')),
          XmlComment('comment'),
        ]);
        node.children.add(fragment);
      },
      '<element1>Hello<element2/><!--comment--></element1>',
    );
    mutatingTest<XmlElement>(
      'element (repeated fragment children)',
      '<element1/>',
      (node) {
        final fragment = XmlDocumentFragment([XmlElement(XmlName('element2'))]);
        node.children
          ..add(fragment)
          ..add(fragment);
      },
      '<element1><element2/><element2/></element1>',
    );
    final wrong = XmlAttribute(XmlName('invalid'), 'invalid');
    throwingTest<XmlDocument>(
      'element (attribute children)',
      '<element/>',
      (node) => node.children.add(wrong),
      throwsA(isXmlNodeTypeException(
          node: wrong, types: contains(XmlNodeType.ELEMENT))),
    );
    throwingTest<XmlDocument>(
      'element (parent error)',
      '<element1><element2/></element1>',
      (node) => node.children.add(node.firstChild!),
      throwsA(isXmlParentException()),
    );
  });
  group('addAll', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element/>',
      (node) =>
          node.attributes.addAll([XmlAttribute(XmlName('attr'), 'value')]),
      '<element attr="value"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element/>',
      (node) => node.children.addAll([XmlText('Hello World')]),
      '<element>Hello World</element>',
    );
    mutatingTest<XmlElement>(
      'element (copy attribute)',
      '<element1 attr="value"><element2/></element1>',
      (node) =>
          node.children.first.attributes.addAll([node.attributes.first.copy()]),
      '<element1 attr="value"><element2 attr="value"/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (copy children)',
      '<element1><element2/></element1>',
      (node) => node.children.addAll([node.children.first.copy()]),
      '<element1><element2/><element2/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (fragment children)',
      '<element1/>',
      (node) {
        final fragment = XmlDocumentFragment([
          XmlText('Hello'),
          XmlElement(XmlName('element2')),
          XmlComment('comment'),
        ]);
        node.children.addAll([fragment]);
      },
      '<element1>Hello<element2/><!--comment--></element1>',
    );
    mutatingTest<XmlElement>(
      'element (repeated fragment children)',
      '<element1/>',
      (node) {
        final fragment = XmlDocumentFragment([XmlElement(XmlName('element2'))]);
        node.children.addAll([fragment, fragment]);
      },
      '<element1><element2/><element2/></element1>',
    );
    final wrong = XmlAttribute(XmlName('invalid'), 'invalid');
    throwingTest<XmlDocument>(
      'element (attribute children)',
      '<element/>',
      (node) => node.children.addAll([wrong]),
      throwsA(isXmlNodeTypeException(
          node: wrong, types: contains(XmlNodeType.ELEMENT))),
    );
    throwingTest<XmlDocument>(
      'element (parent error)',
      '<element1><element2/></element1>',
      (node) => node.children.addAll([node.firstChild!]),
      throwsA(isXmlParentException()),
    );
  });
  group('innerText', () {
    mutatingTest<XmlElement>(
      'empty with text',
      '<element/>',
      (node) {
        expect(node.innerText, '');
        node.innerText = 'inner text';
        expect(node.innerText, 'inner text');
      },
      '<element>inner text</element>',
    );
    mutatingTest<XmlElement>(
      'empty with text (encoded)',
      '<element/>',
      (node) {
        expect(node.innerText, '');
        node.innerText = '<child>';
        expect(node.innerText, '<child>');
      },
      '<element>&lt;child></element>',
    );
    mutatingTest<XmlElement>(
      'multiple with text',
      '<element>multiple <child/>nodes</element>',
      (node) {
        expect(node.innerText, 'multiple nodes');
        node.innerText = 'replaced';
        expect(node.innerText, 'replaced');
      },
      '<element>replaced</element>',
    );
    mutatingTest<XmlElement>(
      'text with empty',
      '<element>contents</element>',
      (node) {
        expect(node.innerText, 'contents');
        node.innerText = '';
        expect(node.children, isEmpty);
        expect(node.innerText, '');
      },
      '<element/>',
    );
    throwingTest<XmlElement>(
      'unsupported text node',
      '<element>contents</element>',
      (node) {
        expect(node.firstChild, isA<XmlText>());
        node.firstChild!.innerText = 'error';
      },
      throwsA(isXmlNodeTypeException(
        message: 'XmlNodeType.TEXT cannot have child nodes.',
        node: isA<XmlText>(),
        types: isEmpty,
      )),
    );
  });
  group('innerXml', () {
    mutatingTest<XmlElement>(
      'empty with multiple',
      '<element/>',
      (node) {
        expect(node.innerXml, '');
        node.innerXml = '<child1/> and <child2/>';
        expect(node.innerXml, '<child1/> and <child2/>');
      },
      '<element><child1/> and <child2/></element>',
    );
    mutatingTest<XmlElement>(
      'multiple with empty',
      '<element><child1/> and <child2/></element>',
      (node) {
        expect(node.innerXml, '<child1/> and <child2/>');
        node.innerXml = '';
        expect(node.children, isEmpty);
        expect(node.innerXml, '');
      },
      '<element/>',
    );
    throwingTest<XmlElement>(
      'unsupported text node',
      '<element>contents</element>',
      (node) {
        expect(node.firstChild, isA<XmlText>());
        node.firstChild!.innerXml = 'error';
      },
      throwsA(isXmlNodeTypeException(
        message: 'XmlNodeType.TEXT cannot have child nodes.',
        node: isA<XmlText>(),
        types: isEmpty,
      )),
    );
  });
  group('outerXml', () {
    mutatingTest<XmlElement>(
      'single with other',
      '<element><child/></element>',
      (node) {
        expect(node.firstChild!.outerXml, '<child/>');
        node.firstChild!.outerXml = '<other/>';
        expect(node.firstChild!.outerXml, '<other/>');
      },
      '<element><other/></element>',
    );
    mutatingTest<XmlElement>(
      'single with multiple',
      '<element><child/></element>',
      (node) {
        final child = node.firstChild!;
        expect(child.outerXml, '<child/>');
        child.outerXml = '<child1/> and <child2/>';
      },
      '<element><child1/> and <child2/></element>',
    );
    mutatingTest<XmlElement>(
      'multiple with empty',
      '<element><child1/> and <child2/></element>',
      (node) {
        expect(node.children[1].outerXml, ' and ');
        node.children[1].outerXml = '';
        expect(node.children.length, 2);
      },
      '<element><child1/><child2/></element>',
    );
  });
  group('insert', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1"/>',
      (node) =>
          node.attributes.insert(1, XmlAttribute(XmlName('attr2'), 'value2')),
      '<element attr1="value1" attr2="value2"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element>Hello</element>',
      (node) => node.children.insert(1, XmlText(' World')),
      '<element>Hello World</element>',
    );
    mutatingTest<XmlElement>(
      'element (copy attribute)',
      '<element1 attr1="value1"><element2 attr2="value2"/></element1>',
      (node) => node.children.first.attributes
          .insert(1, node.attributes.first.copy()),
      '<element1 attr1="value1"><element2 attr2="value2" attr1="value1"/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (copy children)',
      '<element1><element2/></element1>',
      (node) => node.children.insert(1, node.children.first.copy()),
      '<element1><element2/><element2/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (fragment children)',
      '<element1><element2/></element1>',
      (node) {
        final fragment = XmlDocumentFragment([
          XmlText('Hello'),
          XmlElement(XmlName('element3')),
          XmlComment('comment'),
        ]);
        node.children.insert(1, fragment);
      },
      '<element1><element2/>Hello<element3/><!--comment--></element1>',
    );
    mutatingTest<XmlElement>(
      'element (repeated fragment children)',
      '<element1><element2/></element1>',
      (node) {
        final fragment = XmlDocumentFragment([XmlElement(XmlName('element3'))]);
        node.children
          ..insert(0, fragment)
          ..insert(2, fragment);
      },
      '<element1><element3/><element2/><element3/></element1>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1"/>',
      (node) =>
          node.attributes.insert(2, XmlAttribute(XmlName('attr2'), 'value2')),
      throwsRangeError,
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element>Hello</element>',
      (node) => node.children.insert(2, XmlText(' World')),
      throwsRangeError,
    );
    final wrong = XmlAttribute(XmlName('invalid'), 'invalid');
    throwingTest<XmlDocument>(
      'element (attribute children)',
      '<element/>',
      (node) => node.children.insert(0, wrong),
      throwsA(isXmlNodeTypeException(
          node: wrong, types: contains(XmlNodeType.ELEMENT))),
    );
    throwingTest<XmlDocument>(
      'element (parent error)',
      '<element1><element2/></element1>',
      (node) => node.children.insert(0, node.firstChild!),
      throwsA(isXmlParentException()),
    );
  });
  group('insertAll', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1"/>',
      (node) => node.attributes
          .insertAll(1, [XmlAttribute(XmlName('attr2'), 'value2')]),
      '<element attr1="value1" attr2="value2"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element>Hello</element>',
      (node) => node.children.insertAll(1, [XmlText(' World')]),
      '<element>Hello World</element>',
    );
    mutatingTest<XmlElement>(
      'element (copy attribute)',
      '<element1 attr1="value1"><element2 attr2="value2"/></element1>',
      (node) => node.children.first.attributes
          .insertAll(1, [node.attributes.first.copy()]),
      '<element1 attr1="value1"><element2 attr2="value2" attr1="value1"/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (copy children)',
      '<element1><element2/></element1>',
      (node) => node.children.insertAll(1, [node.children.first.copy()]),
      '<element1><element2/><element2/></element1>',
    );
    mutatingTest<XmlElement>(
      'element (fragment children)',
      '<element1><element2/></element1>',
      (node) {
        final fragment = XmlDocumentFragment([
          XmlText('Hello'),
          XmlElement(XmlName('element3')),
          XmlComment('comment'),
        ]);
        node.children.insertAll(1, [fragment]);
      },
      '<element1><element2/>Hello<element3/><!--comment--></element1>',
    );
    mutatingTest<XmlElement>(
      'element (repeated fragment children)',
      '<element1><element2/></element1>',
      (node) {
        final fragment = XmlDocumentFragment([XmlElement(XmlName('element3'))]);
        node.children.insertAll(0, [fragment, fragment]);
      },
      '<element1><element3/><element3/><element2/></element1>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1"/>',
      (node) => node.attributes
          .insertAll(2, [XmlAttribute(XmlName('attr2'), 'value2')]),
      throwsRangeError,
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element>Hello</element>',
      (node) => node.children.insertAll(2, [XmlText(' World')]),
      throwsRangeError,
    );
    final wrong = XmlAttribute(XmlName('invalid'), 'invalid');
    throwingTest<XmlDocument>(
      'element (attribute children)',
      '<element/>',
      (node) => node.children.insertAll(0, [wrong]),
      throwsA(isXmlNodeTypeException(
          node: wrong, types: contains(XmlNodeType.ELEMENT))),
    );
    throwingTest<XmlDocument>(
      'element (parent error)',
      '<element1><element2/></element1>',
      (node) => node.children.insertAll(0, [node.firstChild!]),
      throwsA(isXmlParentException()),
    );
  });
  group('[]=', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1"/>',
      (node) => node.attributes[0] = XmlAttribute(XmlName('attr2'), 'value2'),
      '<element attr2="value2"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element>Hello World</element>',
      (node) => node.children[0] = XmlText('Dart rocks'),
      '<element>Dart rocks</element>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1"/>',
      (node) => node.attributes[2] = XmlAttribute(XmlName('attr2'), 'value2'),
      throwsRangeError,
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element>Hello</element>',
      (node) => node.children[2] = XmlText(' World'),
      throwsRangeError,
    );
    final wrong = XmlAttribute(XmlName('invalid'), 'invalid');
    throwingTest<XmlDocument>(
      'element (attribute children)',
      '<element1><element2/></element1>',
      (node) => node.children[0] = wrong,
      throwsA(isXmlNodeTypeException(
          node: wrong, types: contains(XmlNodeType.ELEMENT))),
    );
    throwingTest<XmlDocument>(
      'element (parent error)',
      '<element1><element2/></element1>',
      (node) => node.children[0] = node.firstChild!,
      throwsA(isXmlParentException()),
    );
  });
  group('remove', () {
    mutatingTest<XmlElement>(
      'attribute',
      '<element attr="value"/>',
      (node) => node.attributes.first.remove(),
      '<element/>',
    );
    mutatingTest<XmlElement>(
      'element',
      '<element>Hello World</element>',
      (node) => node.children.first.remove(),
      '<element/>',
    );
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr="value"/>',
      (node) => node.attributes.remove(node.attributes.first),
      '<element/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element>Hello World</element>',
      (node) => node.children.remove(node.children.first),
      '<element/>',
    );
    mutatingTest<XmlElement>(
      'element (attribute children)',
      '<element>Hello World</element>',
      (node) {
        final wrong = XmlAttribute(XmlName('invalid'), 'invalid');
        node.children.remove(wrong);
      },
      '<element>Hello World</element>',
    );
  });
  group('removeAt', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.removeAt(1),
      '<element attr1="value1"/>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.removeAt(2),
      throwsRangeError,
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element>Hello World</element>',
      (node) => node.children.removeAt(0),
      '<element/>',
    );
    throwingTest<XmlDocument>(
      'element (children range error)',
      '<element>Hello World</element>',
      (node) => node.children.removeAt(2),
      throwsRangeError,
    );
  });
  group('removeWhere', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) =>
          node.attributes.removeWhere((node) => node.localName == 'attr2'),
      '<element attr1="value1"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.removeWhere(
          (node) => node is XmlElement && node.localName == 'element3'),
      '<element1><element2/></element1>',
    );
  });
  group('retainWhere', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) =>
          node.attributes.retainWhere((node) => node.localName == 'attr1'),
      '<element attr1="value1"/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.retainWhere(
          (node) => node is XmlElement && node.localName == 'element2'),
      '<element1><element2/></element1>',
    );
  });
  group('clear', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.clear(),
      '<element/>',
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.clear(),
      '<element1/>',
    );
  });
  group('removeLast', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.removeLast(),
      '<element attr1="value1"/>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element/>',
      (node) => node.attributes.removeLast(),
      throwsRangeError,
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element>Hello World</element>',
      (node) => node.children.removeLast(),
      '<element/>',
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element/>',
      (node) => node.children.removeLast(),
      throwsRangeError,
    );
  });
  group('removeRange', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.removeRange(0, 1),
      '<element attr2="value2"/>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.removeRange(0, 3),
      throwsRangeError,
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.removeRange(1, 2),
      '<element1><element2/></element1>',
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.removeRange(0, 3),
      throwsRangeError,
    );
  });
  group('setRange', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.setRange(0, 1, [
        XmlAttribute(XmlName('attr3'), 'value3'),
      ]),
      '<element attr3="value3" attr2="value2"/>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.setRange(0, 3, [
        XmlAttribute(XmlName('attr3'), 'value3'),
        XmlAttribute(XmlName('attr4'), 'value4'),
        XmlAttribute(XmlName('attr5'), 'value5'),
      ]),
      throwsRangeError,
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.setRange(1, 2, [
        XmlElement(XmlName('element4')),
      ]),
      '<element1><element2/><element4/></element1>',
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.setRange(0, 3, [
        XmlElement(XmlName('element4')),
        XmlElement(XmlName('element5')),
        XmlElement(XmlName('element6')),
      ]),
      throwsRangeError,
    );
  });
  group('replace', () {
    mutatingTest<XmlElement>(
      'element node with text',
      '<element><child/></element>',
      (node) => node.firstChild!.replace(XmlText('child')),
      '<element>child</element>',
    );
    mutatingTest<XmlElement>(
      'element text with node',
      '<element>child</element>',
      (node) => node.firstChild!.replace(XmlElement(XmlName('child'))),
      '<element><child/></element>',
    );
    mutatingTest<XmlElement>(
      'element attribute with attribute',
      '<element attr1="value1"/>',
      (node) => node.attributes.first
          .replace(XmlAttribute(XmlName('attr2'), "value2")),
      '<element attr2="value2"/>',
    );
    mutatingTest<XmlElement>(
      'element text with empty fragment',
      '<element><child/></element>',
      (node) => node.firstChild!.replace(XmlDocumentFragment()),
      '<element/>',
    );
    mutatingTest<XmlElement>(
      'element text with one element fragment',
      '<element><child/></element>',
      (node) => node.firstChild!.replace(XmlDocumentFragment([
        XmlText('child'),
      ])),
      '<element>child</element>',
    );
    mutatingTest<XmlElement>(
      'element text with multiple element fragment',
      '<element><child/></element>',
      (node) => node.firstChild!.replace(XmlDocumentFragment([
        XmlElement(XmlName('child1')),
        XmlElement(XmlName('child2')),
      ])),
      '<element><child1/><child2/></element>',
    );
    mutatingTest<XmlElement>(
      'element node with multiple element fragment',
      '<element>before<child/>after</element>',
      (node) => node.children[1].replace(XmlDocumentFragment([
        XmlElement(XmlName('child1')),
        XmlElement(XmlName('child2')),
      ])),
      '<element>before<child1/><child2/>after</element>',
    );
  });
  group('replaceRange', () {
    mutatingTest<XmlElement>(
      'element (attributes)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes
          .replaceRange(0, 1, [XmlAttribute(XmlName('attr3'), 'value3')]),
      '<element attr3="value3" attr2="value2"/>',
    );
    throwingTest<XmlElement>(
      'element (attribute range error)',
      '<element attr1="value1" attr2="value2"/>',
      (node) => node.attributes.replaceRange(0, 3, [
        XmlAttribute(XmlName('attr3'), 'value3'),
        XmlAttribute(XmlName('attr4'), 'value4'),
        XmlAttribute(XmlName('attr5'), 'value5')
      ]),
      throwsRangeError,
    );
    mutatingTest<XmlElement>(
      'element (children)',
      '<element1><element2/><element3/></element1>',
      (node) =>
          node.children.replaceRange(1, 2, [XmlElement(XmlName('element4'))]),
      '<element1><element2/><element4/></element1>',
    );
    throwingTest<XmlElement>(
      'element (children range error)',
      '<element1><element2/><element3/></element1>',
      (node) => node.children.replaceRange(0, 3, [
        XmlElement(XmlName('element4')),
        XmlElement(XmlName('element5')),
        XmlElement(XmlName('element6')),
      ]),
      throwsRangeError,
    );
  });
  group('unsupported method', () {
    throwingTest<XmlDocument>(
      'fillRange',
      '<element/>',
      (node) => node.children.fillRange(0, 1),
      throwsUnsupportedError,
    );
    throwingTest<XmlDocument>(
      'setAll',
      '<element/>',
      (node) => node.children.setAll(0, []),
      throwsUnsupportedError,
    );
    throwingTest<XmlDocument>(
      'length',
      '<element/>',
      (node) => node.children.length = 2,
      throwsUnsupportedError,
    );
  });
}
