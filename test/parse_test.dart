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
    test('parse errors', () {
      assertDocumentParseError(
          '<foo></bar>', 'Expected </foo>, but found </bar> at 1:6');
      assertDocumentParseError('<data key="ab', '">" expected at 1:7');
      assertDocumentParseError('<data key', '">" expected at 1:7');
      assertDocumentParseError('<data', '">" expected at 1:6');
      assertDocumentParseError('<>', 'Expected name at 1:2');
      assertDocumentParseError('<!-- comment', 'Expected name at 1:2');
      assertDocumentParseError('<![CDATA[ comment', 'Expected name at 1:2');
      assertDocumentParseError('<!DOCTYPE data', 'Expected name at 1:2');
      assertDocumentParseError('<?xml', 'Expected name at 1:2');
      assertDocumentParseError('<?processing', 'Expected name at 1:2');
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
    });
    test('parse errors', () {
      assertFragmentParseError(
          '<foo></bar>', 'Expected </foo>, but found </bar> at 1:6');
      assertFragmentParseError('<data key="ab', 'end of input expected at 1:1');
      assertFragmentParseError('<data key', 'end of input expected at 1:1');
      assertFragmentParseError('<data', 'end of input expected at 1:1');
      assertFragmentParseError('<>', 'end of input expected at 1:1');
      assertFragmentParseError('<!--', 'end of input expected at 1:1');
      assertFragmentParseError('<![CDATA[', 'end of input expected at 1:1');
      assertFragmentParseError('<!DOCTYPE', 'end of input expected at 1:1');
      assertFragmentParseError('<?xml', 'end of input expected at 1:1');
      assertFragmentParseError('<?processing', 'end of input expected at 1:1');
    });
  });
  test('parse deprecated', () {
    // ignore: deprecated_member_use_from_same_package
    final document = parse('<?xml version="1.0"?><schema/>');
    expect(document, isA<XmlDocument>());
  });
}
