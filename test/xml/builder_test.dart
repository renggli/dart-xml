import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../utils/assertions.dart';
import '../utils/checks.dart';

void main() {
  test('basic', () {
    final builder = XmlBuilder();
    builder.declaration(encoding: 'UTF-8');
    builder.processing(
      'xml-stylesheet',
      'href="/style.css" type="text/css" title="default stylesheet"',
    );
    builder.element(
      'bookstore',
      nest: () {
        builder.comment('Only one book?');
        builder.element(
          'book',
          nest: () {
            builder.element(
              'title',
              nest: () {
                builder.attribute('lang', 'en');
                builder.text('Harry ');
                builder.cdata('Potter');
              },
            );
            builder.element('price', nest: 29.99);
          },
        );
      },
    );
    final document = builder.buildDocument();
    final actual = document.toString();
    const expected =
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<?xml-stylesheet href="/style.css" type="text/css" title="default stylesheet"?>'
        '<bookstore>'
        '<!--Only one book?-->'
        '<book>'
        '<title lang="en">Harry <![CDATA[Potter]]></title>'
        '<price>29.99</price>'
        '</book>'
        '</bookstore>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(document);
  });
  test('all', () {
    final builder = XmlBuilder();
    builder.declaration();
    builder.doctype('note', systemId: 'Note.dtd');
    builder.processing('processing', 'instruction');
    builder.element(
      'element1',
      attributes: {'attribute1': 'value1'},
      nest: () {
        builder.attribute(
          'attribute2',
          'value2',
          attributeType: XmlAttributeType.DOUBLE_QUOTE,
        );
        builder.attribute(
          'attribute3',
          'value3',
          attributeType: XmlAttributeType.SINGLE_QUOTE,
        );
        builder.element('element2');
        builder.comment('comment');
        builder.cdata('cdata');
        builder.text('textual');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<?xml version="1.0"?>'
        '<!DOCTYPE note SYSTEM "Note.dtd">'
        '<?processing instruction?>'
        '<element1 attribute1="value1" attribute2="value2" '
        'attribute3=\'value3\'>'
        '<element2/>'
        '<!--comment-->'
        '<![CDATA[cdata]]>'
        'textual'
        '</element1>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('self-closing', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.element('self-closing-default');
        builder.element('self-closing-true', isSelfClosing: true);
        builder.element(
          'self-closing-true-with-children',
          isSelfClosing: true,
          nest: '!',
        );
        builder.element('self-closing-false', isSelfClosing: false);
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element>'
        '<self-closing-default/>'
        '<self-closing-true/>'
        '<self-closing-true-with-children>!</self-closing-true-with-children>'
        '<self-closing-false></self-closing-false>'
        '</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested callback', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.element('nested');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element><nested/></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested callback with inner builder', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: (XmlBuilder innerBuilder) {
        check(innerBuilder).identicalTo(builder);
        innerBuilder.element('nested');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element><nested/></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested string', () {
    final builder = XmlBuilder();
    builder.element('element', nest: 'string');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element>string</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested iterable', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: [
        () => builder.text('st'),
        'ri',
        ['n', 'g'],
      ],
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element>string</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (element)', () {
    final builder = XmlBuilder();
    final nested = XmlElement(const XmlName.qualified('nested'));
    builder.element('element', nest: nested);
    final xml = builder.buildDocument();
    check(xml.children[0].children[0].toXmlString())
        .equals(nested.toXmlString());
    check(xml.children[0].children[0]).not((it) => it.identicalTo(nested));
    final actual = xml.toString();
    const expected = '<element><nested/></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (element, repeated)', () {
    final builder = XmlBuilder();
    final nested = XmlElement(const XmlName.qualified('nested'));
    builder.element('element', nest: [nested, nested]);
    final xml = builder.buildDocument();
    check(xml.children[0].children[0].toXmlString())
        .equals(nested.toXmlString());
    check(xml.children[0].children[0]).not((it) => it.identicalTo(nested));
    check(xml.children[0].children[1].toXmlString())
        .equals(nested.toXmlString());
    check(xml.children[0].children[1]).not((it) => it.identicalTo(nested));
    final actual = xml.toString();
    const expected = '<element><nested/><nested/></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (text)', () {
    final builder = XmlBuilder();
    final nested = XmlText('text');
    builder.element('element', nest: nested);
    final xml = builder.buildDocument();
    check(xml.children[0].children[0].toXmlString())
        .equals(nested.toXmlString());
    check(xml.children[0].children[0]).not((it) => it.identicalTo(nested));
    final actual = xml.toString();
    const expected = '<element>text</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (text, repeated)', () {
    final builder = XmlBuilder();
    final nested = XmlText('text');
    builder.element('element', nest: [nested, nested]);
    final xml = builder.buildDocument();
    check(xml.children[0].children[0].value).equals('texttext');
    check(xml.children[0].children[0]).not((it) => it.identicalTo(nested));
    final actual = xml.toString();
    const expected = '<element>texttext</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (data)', () {
    final builder = XmlBuilder();
    final nested = XmlComment('abc');
    builder.element('element', nest: nested);
    final xml = builder.buildDocument();
    check(xml.children[0].children[0].toXmlString())
        .equals(nested.toXmlString());
    check(xml.children[0].children[0]).not((it) => it.identicalTo(nested));
    final actual = xml.toString();
    const expected = '<element><!--abc--></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (attribute)', () {
    final builder = XmlBuilder();
    final nested = XmlAttribute(const XmlName.qualified('foo'), 'bar');
    builder.element('element', nest: nested);
    final xml = builder.buildDocument();
    check(xml.children[0].attributes[0].toXmlString())
        .equals(nested.toXmlString());
    check(xml.children[0].attributes[0]).not((it) => it.identicalTo(nested));
    final actual = xml.toString();
    const expected = '<element foo="bar"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('nested node (document)', () {
    final builder = XmlBuilder();
    final nested = XmlDocument([]);
    check(() => builder.element('element', nest: nested))
        .throws<ArgumentError>();
  });
  test('nested node (document fragment)', () {
    final builder = XmlBuilder();
    final nested = XmlDocumentFragment([XmlText('foo'), XmlComment('bar')]);
    builder.element('element', nest: nested);
    final xml = builder.buildDocument();
    check(xml.children[0].children[0].toXmlString())
        .equals(nested.children[0].toXmlString());
    check(xml.children[0].children[0])
        .not((it) => it.identicalTo(nested.children[0]));
    check(xml.children[0].children[1].toXmlString())
        .equals(nested.children[1].toXmlString());
    check(xml.children[0].children[1])
        .not((it) => it.identicalTo(nested.children[1]));
    final actual = xml.toString();
    const expected = '<element>foo<!--bar--></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('text', () {
    final builder = XmlBuilder();
    builder.element(
      'text',
      nest: () {
        builder.text('abc');
        builder.text('');
        builder.text('def');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<text>abcdef</text>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('doctype (plain)', () {
    final builder = XmlBuilder()
      ..doctype('note')
      ..element('root');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<!DOCTYPE note><root/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('doctype (system ID)', () {
    final builder = XmlBuilder()
      ..doctype('note', systemId: 'system.dtd')
      ..element('root');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<!DOCTYPE note SYSTEM "system.dtd"><root/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('doctype (public ID)', () {
    final builder = XmlBuilder()
      ..doctype('note', publicId: 'public.dtd', systemId: 'system.dtd')
      ..element('root');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<!DOCTYPE note PUBLIC "public.dtd" "system.dtd"><root/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('doctype (internal subset)', () {
    final builder = XmlBuilder()
      ..doctype('note', internalSubset: '<!ELEMENT br EMPTY>')
      ..element('root');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<!DOCTYPE note [<!ELEMENT br EMPTY>]><root/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('doctype (error)', () {
    final builder = XmlBuilder();
    check(() => builder.doctype('note', publicId: 'public.dtd'))
        .throws<ArgumentError>();
  });
  test('attribute', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.attribute('foo', 'bar');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    check(actual).equals('<element foo="bar"/>');
    assertDocumentInvariants(xml);
  });
  test('attribute (single quote)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.attribute(
          'foo',
          'bar',
          attributeType: XmlAttributeType.SINGLE_QUOTE,
        );
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    check(actual).equals('<element foo=\'bar\'/>');
    assertDocumentInvariants(xml);
  });
  test('attribute (replaced)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.attribute('foo', 'bar');
        builder.attribute('foo', 'zork');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    check(actual).equals('<element foo="zork"/>');
    assertDocumentInvariants(xml);
  });
  test('attribute (removed)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.attribute('foo', 'bar');
        builder.attribute('foo', null);
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    check(actual).equals('<element/>');
    assertDocumentInvariants(xml);
  });
  test('attribute (multiple)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        for (var i = 1; i <= 5; i++) {
          builder.attribute('a$i', i);
        }
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    check(actual).equals('<element a1="1" a2="2" a3="3" a4="4" a5="5"/>');
    assertDocumentInvariants(xml);
  });
  test('attribute (update)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.attribute('lang', 'en');
        builder.attribute('lang', 'de');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element lang="de"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('attribute (update with namespace)', () {
    const namespaceUris = {
      'xhtml': 'http://www.w3.org/1999/xhtml',
      'xlink': 'http://www.w3.org/1999/xlink',
    };
    final builder = XmlBuilder();
    builder.element(
      'element',
      namespaceUris: namespaceUris,
      nest: () {
        for (final prefix in namespaceUris.keys) {
          builder.attribute('lang', 'en', namespacePrefix: prefix);
        }
        for (final uri in namespaceUris.values) {
          builder.attribute('lang', 'de', namespaceUri: uri);
        }
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element '
        'xmlns:xhtml="http://www.w3.org/1999/xhtml" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" '
        'xhtml:lang="de" xlink:lang="de"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('attribute (update with namespace, deprecated)', () {
    const namespaces = {
      'http://www.w3.org/1999/xhtml': 'xhtml',
      'http://www.w3.org/1999/xlink': 'xlink',
    };
    final builder = XmlBuilder();
    builder.element(
      'element',
      // ignore: deprecated_member_use_from_same_package
      namespaces: namespaces,
      nest: () {
        for (final uri in namespaces.keys) {
          // ignore: deprecated_member_use_from_same_package
          builder.attribute('lang', 'en', namespace: uri);
        }
        for (final uri in namespaces.keys) {
          // ignore: deprecated_member_use_from_same_package
          builder.attribute('lang', 'de', namespace: uri);
        }
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element '
        'xmlns:xhtml="http://www.w3.org/1999/xhtml" '
        'xmlns:xlink="http://www.w3.org/1999/xlink" '
        'xhtml:lang="de" xlink:lang="de"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('attribute (update with unknown namespace)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.attribute('xhtml:lang', 'en');
        builder.attribute('xhtml:lang', 'de');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element xhtml:lang="de"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('xml', () {
    final builder = XmlBuilder();
    builder.xml('<element attr="value"/>');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element attr="value"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('xml (nested)', () {
    final builder = XmlBuilder();
    builder.element(
      'outer',
      nest: () {
        builder.xml('<inner attr="value"/>');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<outer><inner attr="value"/></outer>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('xml (multiple)', () {
    final builder = XmlBuilder();
    builder.element(
      'outer',
      nest: () {
        builder.xml('<inner1/>');
        builder.xml('<inner2>hello</inner2>');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<outer><inner1/><inner2>hello</inner2></outer>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('xml (invalid)', () {
    final builder = XmlBuilder();
    builder.element(
      'outer',
      nest: () {
        check(() => builder.xml('<broken>')).throws<XmlTagException>()
          ..message.contains('Missing closing tag </broken>')
          ..expectedName.equals('broken')
          ..actualName.isNull()
          ..buffer.equals('<broken>')
          ..position.equals(8);
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<outer/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('namespace binding', () {
    const uri = 'http://www.w3.org/2001/XMLSchema';
    final builder = XmlBuilder();
    builder.element(
      'schema',
      nest: () {
        builder.namespaceUri('xsd', uri);
        builder.attribute('lang', 'en', namespacePrefix: 'xsd');
        builder.attribute('country', 'uk', namespaceUri: uri);
        builder.element('element1', namespacePrefix: 'xsd');
        builder.element('element2', namespaceUri: uri);
      },
      namespaceUri: uri,
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xsd:lang="en" xsd:country="uk">'
        '<xsd:element1/>'
        '<xsd:element2/>'
        '</xsd:schema>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('namespace binding (deprecated)', () {
    const uri = 'http://www.w3.org/2001/XMLSchema';
    final builder = XmlBuilder();
    builder.element(
      'schema',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace(uri, 'xsd');
        // ignore: deprecated_member_use_from_same_package
        builder.attribute('lang', 'en', namespace: uri);
        // ignore: deprecated_member_use_from_same_package
        builder.element('element', namespace: uri);
      },
      // ignore: deprecated_member_use_from_same_package
      namespace: uri,
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xsd:lang="en">'
        '<xsd:element/>'
        '</xsd:schema>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('default namespace binding', () {
    const uri = 'http://www.w3.org/2001/XMLSchema';
    final builder = XmlBuilder();
    builder.element(
      'schema',
      nest: () {
        builder.namespaceUri(null, uri);
        builder.attribute('lang', 'en');
        builder.attribute('country', 'en', namespaceUri: uri);
        builder.element('element1');
        builder.element('element2', namespaceUri: uri);
      },
      namespaceUri: uri,
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<schema xmlns="http://www.w3.org/2001/XMLSchema" lang="en" country="en">'
        '<element1/>'
        '<element2/>'
        '</schema>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('default namespace binding (deprecated)', () {
    const uri = 'http://www.w3.org/2001/XMLSchema';
    final builder = XmlBuilder();
    builder.element(
      'schema',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace(uri);
        // ignore: deprecated_member_use_from_same_package
        builder.attribute('lang', 'en', namespace: uri);
        // ignore: deprecated_member_use_from_same_package
        builder.element('element', namespace: uri);
      },
      // ignore: deprecated_member_use_from_same_package
      namespace: uri,
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<schema xmlns="http://www.w3.org/2001/XMLSchema" lang="en">'
        '<element/>'
        '</schema>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('undefined namespace', () {
    final builder = XmlBuilder();
    check(() => builder.element('element', namespaceUri: 'http://foo.com/'))
        .throws<ArgumentError>();
    check(() => builder.element('element', namespacePrefix: 'http://foo.com/'))
        .throws<ArgumentError>();
  });
  test('both prefix and uri', () {
    final builder = XmlBuilder();
    check(
      () => builder.element(
        'element',
        namespacePrefix: 'foo',
        namespaceUri: 'http://foo.com/',
      ),
    ).throws<ArgumentError>();
    builder.element(
      'element',
      nest: () {
        check(
          () => builder.attribute(
            'attr',
            'value',
            namespacePrefix: 'foo',
            namespaceUri: 'http://foo.com/',
          ),
        ).throws<ArgumentError>();
      },
    );
  });
  test('undefined namespace (deprecated)', () {
    final builder = XmlBuilder();
    check(() => builder.element('element', namespace: 'http://foo.com/'))
        .throws<ArgumentError>();
  });
  test('invalid namespace', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        check(() => builder.namespaceUri('xml', 'http://foo.com/'))
            .throws<ArgumentError>();
        check(() => builder.namespaceUri('xmlns', 'http://2.foo.com/'))
            .throws<ArgumentError>();
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('invalid namespace prefix (URL)', () {
    final builder = XmlBuilder();
    check(() => builder.namespaceUri('http://foo.com/', 'uri'))
        .throws<AssertionError>();
  }, skip: !hasAssertionsEnabled());
  test('invalid namespace (deprecated)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        check(() => builder.namespace('http://foo.com/', 'xml'))
            .throws<ArgumentError>();
        check(() => builder.namespace('http://2.foo.com/', 'xmlns'))
            .throws<ArgumentError>();
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('conflicting namespace', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.namespaceUri('foo', 'http://foo.com/');
        check(() => builder.namespaceUri('foo', 'http://2.foo.com/'))
            .throws<ArgumentError>();
      },
      namespaceUri: 'http://foo.com/',
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<foo:element xmlns:foo="http://foo.com/"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('conflicting namespace (deprecated)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace('http://foo.com/', 'foo');
        check(() => builder.namespace('http://2.foo.com/', 'foo'))
            .throws<ArgumentError>();
      },
      // ignore: deprecated_member_use_from_same_package
      namespace: 'http://foo.com/',
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<foo:element xmlns:foo="http://foo.com/"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('unused namespace', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.namespaceUri('foo', 'http://foo.com/');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element xmlns:foo="http://foo.com/"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('unused namespace (deprecated)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace('http://foo.com/', 'foo');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element xmlns:foo="http://foo.com/"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('unused namespace (optimized)', () {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.element(
      'element',
      nest: () {
        builder.namespaceUri('foo', 'http://foo.com/');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('unused namespace (optimized, deprecated)', () {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.element(
      'element',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace('http://foo.com/', 'foo');
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('duplicate namespace', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        builder.namespaceUri('foo', 'http://foo.com/');
        builder.element(
          'outer',
          nest: () {
            builder.namespaceUri('foo', 'http://foo.com/');
            builder.element(
              'inner',
              nest: () {
                builder.namespaceUri('foo', 'http://foo.com/');
                builder.attribute('lang', 'en', namespacePrefix: 'foo');
              },
            );
          },
        );
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element xmlns:foo="http://foo.com/">'
        '<outer xmlns:foo="http://foo.com/">'
        '<inner xmlns:foo="http://foo.com/" foo:lang="en"/>'
        '</outer>'
        '</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('duplicate namespace (deprecated)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace('http://foo.com/', 'foo');
        builder.element(
          'outer',
          nest: () {
            // ignore: deprecated_member_use_from_same_package
            builder.namespace('http://foo.com/', 'foo');
            builder.element(
              'inner',
              nest: () {
                // ignore: deprecated_member_use_from_same_package
                builder.namespace('http://foo.com/', 'foo');
                // ignore: deprecated_member_use_from_same_package
                builder.attribute('lang', 'en', namespace: 'http://foo.com/');
              },
            );
          },
        );
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element xmlns:foo="http://foo.com/">'
        '<outer xmlns:foo="http://foo.com/">'
        '<inner xmlns:foo="http://foo.com/" foo:lang="en"/>'
        '</outer>'
        '</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('duplicate namespace on attribute (optimized)', () {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.element(
      'element',
      nest: () {
        builder.namespaceUri('foo', 'http://foo.com/');
        builder.element(
          'outer',
          nest: () {
            builder.namespaceUri('foo', 'http://foo.com/');
            builder.element(
              'inner',
              nest: () {
                builder.namespaceUri('foo', 'http://foo.com/');
                builder.attribute('lang', 'en', namespacePrefix: 'foo');
              },
            );
          },
        );
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element xmlns:foo="http://foo.com/">'
        '<outer>'
        '<inner foo:lang="en"/>'
        '</outer>'
        '</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('duplicate namespace on attribute (optimized, deprecated)', () {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.element(
      'element',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace('http://foo.com/', 'foo');
        builder.element(
          'outer',
          nest: () {
            // ignore: deprecated_member_use_from_same_package
            builder.namespace('http://foo.com/', 'foo');
            builder.element(
              'inner',
              nest: () {
                // ignore: deprecated_member_use_from_same_package
                builder.namespace('http://foo.com/', 'foo');
                // ignore: deprecated_member_use_from_same_package
                builder.attribute('lang', 'en', namespace: 'http://foo.com/');
              },
            );
          },
        );
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element xmlns:foo="http://foo.com/">'
        '<outer>'
        '<inner foo:lang="en"/>'
        '</outer>'
        '</element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('duplicate namespace on element (optimized)', () {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.element(
      'element',
      nest: () {
        builder.namespaceUri('foo', 'http://foo.com/');
        builder.element(
          'outer',
          nest: () {
            builder.namespaceUri('foo', 'http://foo.com/');
            builder.element('inner', namespaceUri: 'http://foo.com/');
          },
        );
      },
    );
    final actual = builder.buildDocument().toString();
    const expected =
        '<element xmlns:foo="http://foo.com/">'
        '<outer>'
        '<foo:inner/>'
        '</outer>'
        '</element>';
    check(actual).equals(expected);
  });
  test('duplicate namespace on element (optimized, deprecated)', () {
    final builder = XmlBuilder(optimizeNamespaces: true);
    builder.element(
      'element',
      nest: () {
        // ignore: deprecated_member_use_from_same_package
        builder.namespace('http://foo.com/', 'foo');
        builder.element(
          'outer',
          nest: () {
            // ignore: deprecated_member_use_from_same_package
            builder.namespace('http://foo.com/', 'foo');
            // ignore: deprecated_member_use_from_same_package
            builder.element('inner', namespace: 'http://foo.com/');
          },
        );
      },
    );
    final actual = builder.buildDocument().toString();
    const expected =
        '<element xmlns:foo="http://foo.com/">'
        '<outer>'
        '<foo:inner/>'
        '</outer>'
        '</element>';
    check(actual).equals(expected);
  });
  test('namespace defined with element', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      namespaceUris: {'foo': 'http://foo.com/', null: 'http://bar.com/'},
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element xmlns:foo="http://foo.com/" '
        'xmlns="http://bar.com/"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('namespace defined with element (deprecated)', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      // ignore: deprecated_member_use_from_same_package
      namespaces: {'http://foo.com/': 'foo', 'http://bar.com/': null},
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element xmlns:foo="http://foo.com/" '
        'xmlns="http://bar.com/"/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('entities cdata escape', () {
    final builder = XmlBuilder();
    builder.element('element', nest: '<test><![CDATA[string]]></test>');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<element>&lt;test>&lt;![CDATA[string]]&gt;&lt;/test></element>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('declaration', () {
    final builder = XmlBuilder();
    builder.declaration(
      version: '0.5',
      encoding: 'ASCII',
      standalone: true,
      attributes: {'foo': 'bar'},
    );
    builder.element('data');
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected =
        '<?xml version="0.5" encoding="ASCII" standalone="yes" foo="bar"?>'
        '<data/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('declaration outside of document', () {
    final builder = XmlBuilder();
    check(() => builder.element('data', nest: builder.declaration))
        .throws<XmlNodeTypeException>()
      ..message.startsWith('Got XmlNodeType.DECLARATION')
      ..node.isNotNull()
      ..types.contains(XmlNodeType.ELEMENT);
  });
  test('exception during nesting', () {
    final builder = XmlBuilder();
    builder.element(
      'outer',
      nest: () {
        check(
          () =>
              builder.element('inner', nest: () => throw UnimplementedError()),
        ).throws<UnsupportedError>();
      },
    );
    final document = builder.buildDocument();
    final actual = document.toString();
    const expected = '<outer/>';
    check(actual).equals(expected);
  });
  test('incomplete builder', () {
    final builder = XmlBuilder();
    builder.element(
      'element',
      nest: () {
        check(builder.buildDocument).throws<StateError>();
      },
    );
    final xml = builder.buildDocument();
    final actual = xml.toString();
    const expected = '<element/>';
    check(actual).equals(expected);
    assertDocumentTreeInvariants(xml);
  });
  test('reused builder', () {
    final builder = XmlBuilder();
    builder.element('element-one');
    final firstDocument = builder.buildDocument();
    check(firstDocument.toString()).equals('<element-one/>');
    builder.element('element-two');
    final secondDocument = builder.buildDocument();
    check(secondDocument.toString()).equals('<element-two/>');
  });
  test('fragment builder', () {
    final builder = XmlBuilder();
    builder.element('element-one');
    builder.element('element-two');
    final xml = builder.buildFragment();
    assertFragmentInvariants(xml);
  });
}
