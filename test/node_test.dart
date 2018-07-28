library xml.test.node_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'assertions.dart';

void main() {
  test('element', () {
    XmlDocument document =
        parse('<ns:data key="value">Am I or are the other crazy?</ns:data>');
    XmlElement node = document.rootElement;
    expect(node.name, XmlName.fromString('ns:data'));
    expect(node.parent, same(document));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, hasLength(1));
    expect(node.children, hasLength(1));
    expect(node.descendants, hasLength(2));
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.nodeType, XmlNodeType.ELEMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.ELEMENT');
    expect(node.toString(),
        '<ns:data key="value">Am I or are the other crazy?</ns:data>');
  });
  test('element (readopt name)', () {
    XmlDocument document = parse('<element attr="value1">text</element>');
    XmlElement node = document.rootElement;
    expect(() => XmlElement(node.name), throwsArgumentError);
    expect(() => XmlElement(XmlName('data'), node.attributes),
        throwsArgumentError);
    expect(() => XmlElement(XmlName('data'), [], node.children),
        throwsArgumentError);
  });
  test('attribute', () {
    XmlDocument document =
        parse('<data ns:attr="Am I or are the other crazy?" />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(node.name, XmlName.fromString('ns:attr'));
    expect(node.value, 'Am I or are the other crazy?');
    expect(node.attributeType, XmlAttributeType.DOUBLE_QUOTE);
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, isEmpty);
    expect(node.nodeType, XmlNodeType.ATTRIBUTE);
    expect(node.nodeType.toString(), 'XmlNodeType.ATTRIBUTE');
    expect(node.toString(), 'ns:attr="Am I or are the other crazy?"');
  });
  test('attribute (empty)', () {
    XmlDocument document = parse('<data attr="" />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(node.value, '');
    expect(node.toString(), 'attr=""');
  });
  test('attribute (character references)', () {
    XmlDocument document =
        parse('<data ns:attr="&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;" />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(node.value, '<>&\'"\n\r\t');
    expect(node.toString(), 'ns:attr="&lt;>&amp;\'&quot;&#xA;&#xD;&#x9;"');
  });
  test('attribute (single)', () {
    XmlDocument document =
        parse('<data ns:attr=\'Am I or are the other crazy?\' />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(node.name, XmlName.fromString('ns:attr'));
    expect(node.value, 'Am I or are the other crazy?');
    expect(node.attributeType, XmlAttributeType.SINGLE_QUOTE);
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, isEmpty);
    expect(node.nodeType, XmlNodeType.ATTRIBUTE);
    expect(node.nodeType.toString(), 'XmlNodeType.ATTRIBUTE');
    expect(node.toString(), "ns:attr='Am I or are the other crazy?'");
  });
  test('attribute (single, empty)', () {
    XmlDocument document = parse('<data attr=\'\' />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(node.value, '');
    expect(node.toString(), "attr=''");
  });
  test('attribute (single, character references)', () {
    XmlDocument document =
        parse('<data ns:attr=\'&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;\' />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(node.value, '<>&\'"\n\r\t');
    expect(node.toString(), "ns:attr='&lt;>&amp;&apos;\"&#xA;&#xD;&#x9;'");
  });
  test('attribute (readopt name)', () {
    XmlDocument document =
        parse('<data ns:attr=\'&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;\' />');
    XmlAttribute node = document.rootElement.attributes.single;
    expect(() => XmlAttribute(node.name, ''), throwsArgumentError);
  });
  test('text', () {
    XmlDocument document = parse('<data>Am I or are the other crazy?</data>');
    XmlText node = document.rootElement.children.single;
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.nodeType, XmlNodeType.TEXT);
    expect(node.nodeType.toString(), 'XmlNodeType.TEXT');
    expect(node.toString(), 'Am I or are the other crazy?');
  });
  test('text (character references)', () {
    XmlDocument document = parse('<data>&lt;&gt;&amp;&apos;&quot;</data>');
    XmlText node = document.rootElement.children.single;
    expect(node.text, '<>&\'"');
    expect(node.toString(), '&lt;>&amp;\'"');
  });
  test('text (nested)', () {
    XmlDocument root =
        parse('<p>Am <i>I</i> or are the <b>other</b><!-- very --> crazy?</p>');
    expect(root.rootElement.text, 'Am I or are the other crazy?');
  });
  test('cdata', () {
    XmlDocument document = parse('<data>'
        '<![CDATA[Methinks <word> it <word> is like a weasel!]]>'
        '</data>');
    expect(document.rootElement.text,
        'Methinks <word> it <word> is like a weasel!');
    XmlCDATA node = document.rootElement.children.single;
    expect(node.text, 'Methinks <word> it <word> is like a weasel!');
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.CDATA);
    expect(node.nodeType.toString(), 'XmlNodeType.CDATA');
    expect(node.toString(),
        '<![CDATA[Methinks <word> it <word> is like a weasel!]]>');
    expect(node.descendants, isEmpty);
  });
  test('processing', () {
    XmlDocument document = parse('<?xml version="1.0"?><data/>');
    XmlProcessing node = document.firstChild;
    expect(node.target, 'xml');
    expect(node.text, 'version="1.0"');
    expect(node.parent, same(document));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.nodeType, XmlNodeType.PROCESSING);
    expect(node.nodeType.toString(), 'XmlNodeType.PROCESSING');
    expect(node.toString(), '<?xml version="1.0"?>');
    expect(node.descendants, isEmpty);
  });
  test('comment', () {
    XmlDocument document =
        parse('<data><!--Am I or are the other crazy?--></data>');
    XmlComment node = document.rootElement.children.single;
    expect(node.parent, same(document.rootElement));
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, 'Am I or are the other crazy?');
    expect(node.nodeType, XmlNodeType.COMMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.COMMENT');
    expect(node.toString(), '<!--Am I or are the other crazy?-->');
  });
  test('document', () {
    XmlDocument document = parse('<data />');
    XmlDocument node = document.document;
    expect(node.parent, isNull);
    expect(node.root, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, hasLength(1));
    expect(node.descendants, hasLength(1));
    expect(node.text, isNull);
    expect(node.nodeType, XmlNodeType.DOCUMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT');
    expect(node.toString(), '<data />');
  });
  test('document definition', () {
    XmlDocument document = parse('<?xml version="1.0" encoding="UTF-8" ?>'
        '<element />');
    XmlDocument node = document.document;
    expect(node.children, hasLength(2));
    expect(node.descendants, hasLength(2));
    expect(
        node.toString(),
        '<?xml version="1.0" encoding="UTF-8" ?>'
        '<element />');
  });
  test('document comments and whitespace', () {
    XmlDocument document = parse('<?xml version="1.0" encoding="UTF-8"?> '
        '<!-- before -->\n<element />\t<!-- after -->');
    XmlDocument node = document.document;
    expect(node.children, hasLength(7));
    expect(node.descendants, hasLength(7));
    expect(
        node.toString(),
        '<?xml version="1.0" encoding="UTF-8"?> '
        '<!-- before -->\n<element />\t<!-- after -->');
    expect(
        node.toXmlString(pretty: true),
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!-- before -->\n<element />\n<!-- after -->');
  });
  test('document empty', () {
    XmlDocument document = XmlDocument();
    expect(document.doctypeElement, isNull);
    expect(() => document.rootElement, throwsStateError);
  });
  test('document type', () {
    XmlDocument document =
        parse('<!DOCTYPE html [<!-- internal subset -->]><data />');
    XmlDoctype node = document.doctypeElement;
    expect(node.parent, same(document));
    expect(node.document, same(document));
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, 'html [<!-- internal subset -->]');
    expect(node.nodeType, XmlNodeType.DOCUMENT_TYPE);
    expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT_TYPE');
    expect(node.toString(), '<!DOCTYPE html [<!-- internal subset -->]>');
  });
  test('document fragment empty', () {
    XmlDocumentFragment node = XmlDocumentFragment();
    assertCopyInvariants(node);
    expect(node.parent, isNull);
    expect(node.root, node);
    expect(node.document, isNull);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.descendants, isEmpty);
    expect(node.text, isNull);
    expect(node.nodeType, XmlNodeType.DOCUMENT_FRAGMENT);
    expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT_FRAGMENT');
    expect(node.toString(), '#document-fragment');
    expect(const XmlVisitor().visit(node), isNull);
  });
}
