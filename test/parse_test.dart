library xml.test.parse_test;

import 'package:test/test.dart';

import 'assertions.dart';

void main() {
  test('comment', () {
    assertParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
        '<schema><!-- comment --></schema>');
  });
  test('comment with xml', () {
    assertParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
        '<schema><!-- <foo></foo> --></schema>');
  });
  test('doctype (system)', () {
    assertParseInvariants('<!DOCTYPE root-name SYSTEM "uri-reference">'
        '<root />');
  });
  test('doctype (public)', () {
    assertParseInvariants(
        '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">'
        '<root />');
  });
  test('doctype (subset)', () {
    assertParseInvariants('<!DOCTYPE root ['
        '  <!ELEMENT root (child)>'
        '  <!ATTLIST root attribute #IMPLIED>'
        '  <!ENTITY copy "©">'
        ']>'
        '<root />');
  });
  test('doctype (combined)', () {
    assertParseInvariants('<!DOCTYPE root SYSTEM "uri-reference" ['
        '  <!ELEMENT root (child)>'
        '  <!ATTLIST root attribute #IMPLIED>'
        '  <!ENTITY copy "©">'
        ']>'
        '<root />');
  });
  test('empty element', () {
    assertParseInvariants('<root/>');
    assertParseInvariants('<root />');
    assertParseInvariants('<root key="value"/>');
    assertParseInvariants('<root key="value" />');
  });
  test('namespace', () {
    assertParseInvariants('<xs:schema xs:attr="1"></xs:schema>');
  });
  test('simple', () {
    assertParseInvariants('<schema></schema>');
  });
  test('simple double quote attribute', () {
    assertParseInvariants('<schema foo="bar"></schema>');
  });
  test('simple single quote attribute', () {
    assertParseInvariants('<schema foo=\'bar\'></schema>');
  });
  test('short cdata section', () {
    assertParseInvariants('<data><![CDATA[]]></data>');
  });
  test('short cdata section', () {
    assertParseInvariants('<data><![CDATA[<data></data>]]></data>');
  });
  test('short processing instruction', () {
    assertParseInvariants('<?xml?><data />');
  });
  test('long processing instruction', () {
    assertParseInvariants('<?xml version="1.0"?><data />');
  });
  test('whitespace after prolog', () {
    assertParseInvariants('<?xml version="1.0" encoding="UTF-8"?>\n\t'
        '<schema></schema>\t\n');
  });
  test('parse errors', () {
    assertParseError('<foo></bar>', 'Expected </foo>, but found </bar> at 1:6');
    assertParseError('<data key="ab', '">" expected at 1:7');
    assertParseError('<data key', '">" expected at 1:7');
    assertParseError('<data', '">" expected at 1:6');
    assertParseError('<>', 'Expected name at 1:2');
    assertParseError('<!-- comment', 'Expected name at 1:2');
    assertParseError('<![CDATA[ comment', 'Expected name at 1:2');
    assertParseError('<!DOCTYPE data', 'Expected name at 1:2');
    assertParseError('<?processing', 'Expected name at 1:2');
  });
}
