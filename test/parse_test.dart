import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'assertions.dart';

void main() {
  group('document', () {
    test('cdata', () {
      assertDocumentParseInvariants('<data><![CDATA[]]></data>');
    });
    test('cdata with xml', () {
      assertDocumentParseInvariants('<data><![CDATA[<data></data>]]></data>');
    });
    test('comment', () {
      assertDocumentParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
          '<schema><!-- comment --></schema>');
    });
    test('comment with xml', () {
      assertDocumentParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
          '<schema><!-- <foo></foo> --></schema>');
    });
    test('declaration', () {
      assertDocumentParseInvariants('<?xml?><data />');
    });
    test('declaration with attribute', () {
      assertDocumentParseInvariants('<?xml version="1.0"?><data />');
    });
    test('doctype (system)', () {
      assertDocumentParseInvariants(
          '<!DOCTYPE root-name SYSTEM "uri-reference">'
          '<root />');
    });
    test('doctype (public)', () {
      assertDocumentParseInvariants(
          '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">'
          '<root />');
    });
    test('doctype (subset)', () {
      assertDocumentParseInvariants('<!DOCTYPE root ['
          '  <!ELEMENT root (child)>'
          '  <!ATTLIST root attribute #IMPLIED>'
          '  <!ENTITY copy "©">'
          ']>'
          '<root />');
    });
    test('doctype (combined)', () {
      assertDocumentParseInvariants('<!DOCTYPE root SYSTEM "uri-reference" ['
          '  <!ELEMENT root (child)>'
          '  <!ATTLIST root attribute #IMPLIED>'
          '  <!ENTITY copy "©">'
          ']>'
          '<root />');
    });
    test('element', () {
      assertDocumentParseInvariants('<root/>');
      assertDocumentParseInvariants('<root />');
      assertDocumentParseInvariants('<root key="value"/>');
      assertDocumentParseInvariants('<root key="value" />');
    });
    test('element with namespace', () {
      assertDocumentParseInvariants('<xs:schema xs:attr="1"></xs:schema>');
    });
    test('element with closing', () {
      assertDocumentParseInvariants('<schema></schema>');
    });
    test('element with double quote attribute', () {
      assertDocumentParseInvariants('<schema foo="bar"></schema>');
    });
    test('element with single quote attribute', () {
      assertDocumentParseInvariants('<schema foo=\'bar\'></schema>');
    });
    test('processing instruction', () {
      assertDocumentParseInvariants('<?pi?><data />');
    });
    test('processing instruction with attribute', () {
      assertDocumentParseInvariants('<?pi foo="bar"?><data />');
    });
    group('empty', () {
      test('completely', () {
        final document = XmlDocument.parse('');
        expect(document.children, isEmpty);
        expect(document.declaration, isNull);
        expect(document.doctypeElement, isNull);
        expect(() => document.rootElement, throwsStateError);
      });
      test('whitespace', () {
        final document = XmlDocument.parse(' ');
        expect(document.children, hasLength(1));
        expect(document.declaration, isNull);
        expect(document.doctypeElement, isNull);
        expect(() => document.rootElement, throwsStateError);
      });
      test('doctype and comment', () {
        final document = XmlDocument.parse('<?xml version="1.0"?><!--empty-->');
        expect(document.children, hasLength(2));
        expect(document.declaration, isNotNull);
        expect(document.doctypeElement, isNull);
        expect(() => document.rootElement, throwsStateError);
      });
    });
    group('parse errors', () {
      test('nesting', () {
        expect(
            () => XmlDocument.parse('<foo></bar>'),
            throwsA(isXmlTagException(
              message: 'Expected </foo>, but found </bar>',
              position: 5,
            )));
        expect(
            () => XmlDocument.parse('<bar>'),
            throwsA(isXmlTagException(
              message: 'Missing </bar>',
              position: 5,
            )));
        expect(
            () => XmlDocument.parse('</bar>'),
            throwsA(isXmlTagException(
              message: 'Unexpected </bar>',
              position: 0,
            )));
      });
      test('element', () {
        expect(
            () => XmlDocument.parse('<'),
            throwsA(isXmlParserException(
              message: 'name expected',
              position: 1,
            )));
        expect(
            () => XmlDocument.parse('<data'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 5,
            )));
        expect(
            () => XmlDocument.parse('<data key'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 6,
            )));
        expect(
            () => XmlDocument.parse('<data key="ab'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 6,
            )));
      });
      test('comment', () {
        expect(
            () => XmlDocument.parse('<!--'),
            throwsA(isXmlParserException(
              message: '"-->" expected',
              position: 4,
            )));
        expect(
            () => XmlDocument.parse('<!-- comment'),
            throwsA(isXmlParserException(
              message: '"-->" expected',
              position: 4,
            )));
      });
      test('cdata', () {
        expect(
            () => XmlDocument.parse('<![CDATA['),
            throwsA(isXmlParserException(
              message: '"]]>" expected',
              position: 9,
            )));
        expect(
            () => XmlDocument.parse('<![CDATA[ cdata'),
            throwsA(isXmlParserException(
              message: '"]]>" expected',
              position: 9,
            )));
      });
      test('doctype', () {
        expect(
            () => XmlDocument.parse('<!DOCTYPE'),
            throwsA(isXmlParserException(
              message: 'whitespace expected',
              position: 9,
            )));
        expect(
            () => XmlDocument.parse('<!DOCTYPE data'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 14,
            )));
        expect(
            () => XmlDocument.parse('<!DOCTYPE data ['),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 15,
            )));
      });
      test('declaration', () {
        expect(
            () => XmlDocument.parse('<?'),
            throwsA(isXmlParserException(
              message: 'name expected',
              position: 2,
            )));
        expect(
            () => XmlDocument.parse('<?xml'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 5,
            )));
        expect(
            () => XmlDocument.parse('<?xml version'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 6,
            )));
        expect(
            () => XmlDocument.parse('<?xml version='),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 6,
            )));
        expect(
            () => XmlDocument.parse('<?xml version="1.0'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 6,
            )));
      });
      test('processing', () {
        expect(
            () => XmlDocument.parse('<?'),
            throwsA(isXmlParserException(
              message: 'name expected',
              position: 2,
            )));
        expect(
            () => XmlDocument.parse('<?processing'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 12,
            )));
        expect(
            () => XmlDocument.parse('<?processing whatever'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 12,
            )));
      });
    });
  });
  group('fragment', () {
    test('cdata', () {
      assertFragmentParseInvariants('<![CDATA[]]>');
    });
    test('cdata with xml', () {
      assertFragmentParseInvariants('<![CDATA[<data></data>]]>');
    });
    test('comment', () {
      assertFragmentParseInvariants('<!-- comment -->');
    });
    test('comment with xml', () {
      assertFragmentParseInvariants('<!-- <foo></foo> -->');
    });
    test('declaration', () {
      assertFragmentParseInvariants('<?xml?><data />');
    });
    test('declaration with attribute', () {
      assertFragmentParseInvariants('<?xml version="1.0"?><data />');
    });
    test('doctype (system)', () {
      assertFragmentParseInvariants(
          '<!DOCTYPE root-name SYSTEM "uri-reference">');
    });
    test('doctype (public)', () {
      assertFragmentParseInvariants(
          '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">');
    });
    test('doctype (subset)', () {
      assertFragmentParseInvariants('<!DOCTYPE root ['
          '  <!ELEMENT root (child)>'
          '  <!ATTLIST root attribute #IMPLIED>'
          '  <!ENTITY copy "©">'
          ']>');
    });
    test('doctype (combined)', () {
      assertFragmentParseInvariants('<!DOCTYPE root SYSTEM "uri-reference" ['
          '  <!ELEMENT root (child)>'
          '  <!ATTLIST root attribute #IMPLIED>'
          '  <!ENTITY copy "©">'
          ']>');
    });
    test('element', () {
      assertFragmentParseInvariants('<root/>');
      assertFragmentParseInvariants('<root />');
      assertFragmentParseInvariants('<root key="value"/>');
      assertFragmentParseInvariants('<root key="value" />');
    });
    test('element with namespace', () {
      assertFragmentParseInvariants('<xs:schema xs:attr="1"></xs:schema>');
    });
    test('element with closing', () {
      assertFragmentParseInvariants('<schema></schema>');
    });
    test('element double quote attribute', () {
      assertFragmentParseInvariants('<schema foo="bar"></schema>');
    });
    test('element single quote attribute', () {
      assertFragmentParseInvariants('<schema foo=\'bar\'></schema>');
    });
    test('processing instruction', () {
      assertFragmentParseInvariants('<?pi?><data />');
    });
    test('processing instruction with attribute', () {
      assertFragmentParseInvariants('<?pi foo="bar"?><data />');
    });
    test('text', () {
      assertFragmentParseInvariants('I have a heart I swear I do, '
          'Just not baby when it comes to you.');
    });
    test('empty', () {
      assertFragmentParseInvariants('');
      assertFragmentParseInvariants(' ');
      assertFragmentParseInvariants('\t');
      assertFragmentParseInvariants('\n');
      assertFragmentParseInvariants('  ');
    });
    group('parse errors', () {
      test('nesting', () {
        expect(
            () => XmlDocumentFragment.parse('<foo></bar>'),
            throwsA(isXmlTagException(
              message: 'Expected </foo>, but found </bar>',
              position: 5,
            )));
        expect(
            () => XmlDocumentFragment.parse('<bar>'),
            throwsA(isXmlTagException(
              message: 'Missing </bar>',
              position: 5,
            )));
        expect(
            () => XmlDocumentFragment.parse('</bar>'),
            throwsA(isXmlTagException(
              message: 'Unexpected </bar>',
              position: 0,
            )));
      });
      test('element', () {
        expect(
            () => XmlDocumentFragment.parse('<'),
            throwsA(isXmlParserException(
              message: 'name expected',
              position: 1,
            )));
        expect(
            () => XmlDocumentFragment.parse('<data'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 5,
            )));
        expect(
            () => XmlDocumentFragment.parse('<data key'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 6,
            )));
        expect(
            () => XmlDocumentFragment.parse('<data key="ab'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 6,
            )));
      });
      test('comment', () {
        expect(
            () => XmlDocumentFragment.parse('<!--'),
            throwsA(isXmlParserException(
              message: '"-->" expected',
              position: 4,
            )));
        expect(
            () => XmlDocumentFragment.parse('<!-- comment'),
            throwsA(isXmlParserException(
              message: '"-->" expected',
              position: 4,
            )));
      });
      test('cdata', () {
        expect(
            () => XmlDocumentFragment.parse('<![CDATA['),
            throwsA(isXmlParserException(
              message: '"]]>" expected',
              position: 9,
            )));
        expect(
            () => XmlDocumentFragment.parse('<![CDATA[ cdata'),
            throwsA(isXmlParserException(
              message: '"]]>" expected',
              position: 9,
            )));
      });
      test('doctype', () {
        expect(
            () => XmlDocumentFragment.parse('<!DOCTYPE'),
            throwsA(isXmlParserException(
              message: 'whitespace expected',
              position: 9,
            )));
        expect(
            () => XmlDocumentFragment.parse('<!DOCTYPE data'),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 14,
            )));
        expect(
            () => XmlDocumentFragment.parse('<!DOCTYPE data ['),
            throwsA(isXmlParserException(
              message: '">" expected',
              position: 15,
            )));
      });
      test('declaration', () {
        expect(
            () => XmlDocumentFragment.parse('<?'),
            throwsA(isXmlParserException(
              message: 'name expected',
              position: 2,
            )));
        expect(
            () => XmlDocumentFragment.parse('<?xml'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 5,
            )));
        expect(
            () => XmlDocumentFragment.parse('<?xml version'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 6,
            )));
        expect(
            () => XmlDocumentFragment.parse('<?xml version='),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 6,
            )));
        expect(
            () => XmlDocumentFragment.parse('<?xml version="1.0'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 6,
            )));
      });
      test('processing', () {
        expect(
            () => XmlDocumentFragment.parse('<?'),
            throwsA(isXmlParserException(
              message: 'name expected',
              position: 2,
            )));
        expect(
            () => XmlDocumentFragment.parse('<?processing'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 12,
            )));
        expect(
            () => XmlDocumentFragment.parse('<?processing whatever'),
            throwsA(isXmlParserException(
              message: '"?>" expected',
              position: 12,
            )));
      });
    });
  });
}
