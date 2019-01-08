library xml.test.node_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'assertions.dart';

void main() {
  test('element', () {
    final document =
        parse('<ns:data key="value">Am I or are the other crazy?</ns:data>');
    final node = document.rootElement;
    expect(node.name, XmlName.fromString('ns:data'));
    expect(node.parent, same(document));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, hasLength(1));
    expect(node.children, hasLength(1));
    expect(node.descendants, hasLength(2));
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.ELEMENT');
    expect(node.isSelfClosing, isTrue);
    expect(node.toString(),
        '<ns:data key="value">Am I or are the other crazy?</ns:data>');
  });
  test('element (self-closing)', () {
    final document = parse('<data/>');
    final node = document.rootElement;
    expect(node.name, XmlName.fromString('data'));
    expect(node.parent, same(document));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, '');
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.ELEMENT');
    expect(node.isSelfClosing, isTrue);
    expect(node.toString(), '<data/>');
  });
  test('element (empty, but not self-closing)', () {
    final document = parse('<data></data>');
    final node = document.rootElement;
    expect(node.name, XmlName.fromString('data'));
    expect(node.parent, same(document));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, '');
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.ELEMENT');
    expect(node.isSelfClosing, isFalse);
    expect(node.toString(), '<data></data>');
  });
  test('element (readopt name)', () {
    final document = parse('<element attr="value1">text</element>');
    final node = document.rootElement;
    expect(() => XmlElement(node.name), throwsA(isXmlParentException));
    expect(() => XmlElement(XmlName('data'), node.attributes),
        throwsA(isXmlParentException));
    expect(() => XmlElement(XmlName('data'), [], node.children),
        throwsA(isXmlParentException));
  });
  test('attribute', () {
    final document = parse('<data ns:attr="Am I or are the other crazy?" />');
    final node = document.rootElement.attributes.single;
    expect(node.name, XmlName.fromString('ns:attr'));
    expect(node.value, 'Am I or are the other crazy?');
    expect(node.attributeType, XmlAttributeType.DOUBLE_QUOTE);
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, isEmpty);
    expect(node.nodeType, XmlNodeType.ATTRIBUTE);
    expect(node.nodeType.toString(), 'XmlNodeType.ATTRIBUTE');
    expect(node.toString(), 'ns:attr="Am I or are the other crazy?"');
  });
  test('attribute (empty)', () {
    final document = parse('<data attr="" />');
    final node = document.rootElement.attributes.single;
    expect(node.value, '');
    expect(node.toString(), 'attr=""');
  });
  test('attribute (character references)', () {
    final document =
        parse('<data ns:attr="&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;" />');
    final node = document.rootElement.attributes.single;
    expect(node.value, '<>&\'"\n\r\t');
    expect(node.toString(), 'ns:attr="&lt;>&amp;\'&quot;&#xA;&#xD;&#x9;"');
  });
  test('attribute (single)', () {
    final document = parse('<data ns:attr=\'Am I or are the other crazy?\' />');
    final node = document.rootElement.attributes.single;
    expect(node.name, XmlName.fromString('ns:attr'));
    expect(node.value, 'Am I or are the other crazy?');
    expect(node.attributeType, XmlAttributeType.SINGLE_QUOTE);
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, isEmpty);
    expect(node.nodeType, XmlNodeType.ATTRIBUTE);
    expect(node.nodeType.toString(), 'XmlNodeType.ATTRIBUTE');
    expect(node.toString(), "ns:attr='Am I or are the other crazy?'");
  });
  test('attribute (single, empty)', () {
    final document = parse('<data attr=\'\' />');
    final node = document.rootElement.attributes.single;
    expect(node.value, '');
    expect(node.toString(), "attr=''");
  });
  test('attribute (single, character references)', () {
    final document =
        parse('<data ns:attr=\'&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;\' />');
    final node = document.rootElement.attributes.single;
    expect(node.value, '<>&\'"\n\r\t');
    expect(node.toString(), "ns:attr='&lt;>&amp;&apos;\"&#xA;&#xD;&#x9;'");
  });
  test('attribute (readopt name)', () {
    final document =
        parse('<data ns:attr=\'&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;\' />');
    final node = document.rootElement.attributes.single;
    expect(() => XmlAttribute(node.name, ''), throwsA(isXmlParentException));
  });
  test('text', () {
    final document = parse('<data>Am I or are the other crazy?</data>');
    final node = document.rootElement.children.single;
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.nodeType, XmlNodeType.TEXT);
    expect(node.nodeType.toString(), 'XmlNodeType.TEXT');
    expect(node.toString(), 'Am I or are the other crazy?');
  });
  test('text (character references)', () {
    final document = parse('<data>&lt;&gt;&amp;&apos;&quot;</data>');
    final node = document.rootElement.children.single;
    expect(node.text, '<>&\'"');
    expect(node.toString(), '&lt;>&amp;\'"');
  });
  test('text (nested)', () {
    final root =
        parse('<p>Am <i>I</i> or are the <b>other</b><!-- very --> crazy?</p>');
    expect(root.rootElement.text, 'Am I or are the other crazy?');
  });
  test('cdata', () {
    final document = parse('<data>'
        '<![CDATA[Methinks <word> it <word> is like a weasel!]]>'
        '</data>');
    expect(document.rootElement.text,
        'Methinks <word> it <word> is like a weasel!');
    final node = document.rootElement.children.single;
    expect(node.text, 'Methinks <word> it <word> is like a weasel!');
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.CDATA);
    expect(node.nodeType.toString(), 'XmlNodeType.CDATA');
    expect(node.toString(),
        '<![CDATA[Methinks <word> it <word> is like a weasel!]]>');
    expect(node.descendants, isEmpty);
  });
  test('processing', () {
    final document = parse('<?xml version="1.0"?><data/>');
    final XmlProcessing node = document.firstChild;
    expect(node.target, 'xml');
    expect(node.text, 'version="1.0"');
    expect(node.parent, same(document));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.PROCESSING);
    expect(node.nodeType.toString(), 'XmlNodeType.PROCESSING');
    expect(node.toString(), '<?xml version="1.0"?>');
    expect(node.descendants, isEmpty);
  });
  test('comment', () {
    final document = parse('<data><!--Am I or are the other crazy?--></data>');
    final node = document.rootElement.children.single;
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 2);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.nodeType, XmlNodeType.COMMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.COMMENT');
    expect(node.toString(), '<!--Am I or are the other crazy?-->');
  });
  test('document', () {
    final document = parse('<data/>');
    final node = document.document;
    expect(node.parent, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.depth, 0);
    expect(node.attributes, isEmpty);
    expect(node.children, hasLength(1));
    expect(node.descendants, hasLength(1));
    expect(node.text, isNull);
    expect(node.nodeType, XmlNodeType.DOCUMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT');
    expect(node.toString(), '<data/>');
  });
  test('document definition', () {
    final document = parse('<?xml version="1.0" encoding="UTF-8" ?>'
        '<element/>');
    final node = document.document;
    expect(node.children, hasLength(2));
    expect(node.descendants, hasLength(2));
    expect(
        node.toString(),
        '<?xml version="1.0" encoding="UTF-8" ?>'
        '<element/>');
  });
  test('document comments and whitespace', () {
    final document = parse('<?xml version="1.0" encoding="UTF-8"?> '
        '<!-- before -->\n<element/>\t<!-- after -->');
    final node = document.document;
    expect(node.children, hasLength(7));
    expect(node.descendants, hasLength(7));
    expect(
        node.toString(),
        '<?xml version="1.0" encoding="UTF-8"?> '
        '<!-- before -->\n<element/>\t<!-- after -->');
    expect(
        node.toXmlString(pretty: true),
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!-- before -->\n<element/>\n<!-- after -->');
  });
  test('document empty', () {
    final document = XmlDocument();
    expect(document.doctypeElement, isNull);
    expect(() => document.rootElement, throwsStateError);
  });
  test('document type', () {
    final document =
        parse('<!DOCTYPE html [<!-- internal subset -->]><data />');
    final node = document.doctypeElement;
    expect(node.parent, same(document));
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, 'html [<!-- internal subset -->]');
    expect(node.nodeType, XmlNodeType.DOCUMENT_TYPE);
    expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT_TYPE');
    expect(node.toString(), '<!DOCTYPE html [<!-- internal subset -->]>');
  });
  test('document fragment empty', () {
    final node = XmlDocumentFragment();
    assertCopyInvariants(node);
    expect(node.parent, isNull);
    expect(node.root, node);
    expect(node.document, isNull);
    expect(node.depth, 0);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, isNull);
    expect(node.nodeType, XmlNodeType.DOCUMENT_FRAGMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT_FRAGMENT');
    expect(node.toString(), '#document-fragment');
  });
}
