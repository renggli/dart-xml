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
    group('parse errors', () {
      test('empty', () {
        assertDocumentParseError('', '"<" expected', 0);
        assertDocumentParseError(' ', '"<" expected', 1);
        assertDocumentParseError('\t', '"<" expected', 1);
        assertDocumentParseError('\n', '"<" expected', 1);
        assertDocumentParseError('  ', '"<" expected', 2);
        assertDocumentParseError('<!-- comment -->', '"<" expected', 16);
      });
      test('nesting', () {
        assertDocumentParseError(
            '<foo></bar>', 'Expected </foo>, but found </bar>', 5);
        assertDocumentParseError(
            '<foo><bar></foo>', 'Expected </bar>, but found </foo>', 10);
        assertDocumentParseError('<foo/><bar>', 'Expected end of input', 6);
      });
      test('closing', () {
        assertDocumentParseError('<data key="ab', '">" expected', 6);
        assertDocumentParseError('<data key', '">" expected', 6);
        assertDocumentParseError('<data', '">" expected', 5);
      });
      test('name', () {
        assertDocumentParseError('<>', 'Expected name', 1);
        assertDocumentParseError('<!-- comment', 'Expected name', 1);
        assertDocumentParseError('<![CDATA[ comment', 'Expected name', 1);
        assertDocumentParseError('<!DOCTYPE data', 'Expected name', 1);
        assertDocumentParseError('<?xml', 'Expected name', 1);
        assertDocumentParseError('<?processing', 'Expected name', 1);
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
        assertFragmentParseError('<foo>', '</ expected', 5);
        assertFragmentParseError(
            '<foo></bar>', 'Expected </foo>, but found </bar>', 5);
        assertFragmentParseError(
            '<foo><bar></foo>', 'Expected </bar>, but found </foo>', 10);
        assertFragmentParseError('<foo/><bar>', '</ expected', 11);
      });
      test('closing', () {
        assertFragmentParseError('<data key="ab', '">" expected', 6);
        assertFragmentParseError('<data key', '">" expected', 6);
        assertFragmentParseError('<data', '">" expected', 5);
      });
      test('name', () {
        assertFragmentParseError('<>', 'Expected name', 1);
        assertFragmentParseError('<!--', 'Expected name', 1);
        assertFragmentParseError('<![CDATA[', 'Expected name', 1);
        assertFragmentParseError('<!DOCTYPE', 'Expected name', 1);
        assertFragmentParseError('<?xml', 'Expected name', 1);
        assertFragmentParseError('<?processing', 'Expected name', 1);
      });
    });
  });
  test('parse deprecated', () {
    // ignore: deprecated_member_use_from_same_package
    final document = parse('<?xml version="1.0"?><schema/>');
    expect(document, isA<XmlDocument>());
  });
}
