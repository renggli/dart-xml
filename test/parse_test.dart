library xml.test.parse_test;

import 'package:test/test.dart';

import 'assertions.dart';

void main() {
  test('comment', () {
    assetParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
        '<schema><!-- comment --></schema>');
  });
  test('comment with xml', () {
    assetParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
        '<schema><!-- <foo></foo> --></schema>');
  });
  test('complicated', () {
    assetParseInvariants('<?xml foo?>\n'
        '<!DOCTYPE name [ something ]>\n'
        '<ns:foo attr="not namespaced" n1:ans="namespaced 1" n2:ans="namespace 2" >\n'
        '  <element/>\n'
        '  <ns:element/>\n'
        '  <!-- comment -->\n'
        '  <![CDATA[cdata]]>\n'
        '  <?processing instruction?>\n'
        '</ns:foo>');
  });
  test('doctype (system)', () {
    assetParseInvariants('<!DOCTYPE root-name SYSTEM "uri-reference">'
        '<root />');
  });
  test('doctype (public)', () {
    assetParseInvariants(
        '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">'
        '<root />');
  });
  test('doctype (subset)', () {
    assetParseInvariants('<!DOCTYPE root ['
        '  <!ELEMENT root (child)>'
        '  <!ATTLIST root attribute #IMPLIED>'
        '  <!ENTITY copy "©">'
        ']>'
        '<root />');
  });
  test('doctype (combined)', () {
    assetParseInvariants('<!DOCTYPE root SYSTEM "uri-reference" ['
        '  <!ELEMENT root (child)>'
        '  <!ATTLIST root attribute #IMPLIED>'
        '  <!ENTITY copy "©">'
        ']>'
        '<root />');
  });
  test('empty element', () {
    assetParseInvariants('<root/>');
    assetParseInvariants('<root />');
    assetParseInvariants('<root key="value"/>');
    assetParseInvariants('<root key="value" />');
  });
  test('namespace', () {
    assetParseInvariants('<xs:schema xs:attr="1"></xs:schema>');
  });
  test('simple', () {
    assetParseInvariants('<schema></schema>');
  });
  test('simple double quote attribute', () {
    assetParseInvariants('<schema foo="bar"></schema>');
  });
  test('simple single quote attribute', () {
    assetParseInvariants('<schema foo=\'bar\'></schema>');
  });
  test('short cdata section', () {
    assetParseInvariants('<data><![CDATA[]]></data>');
  });
  test('short cdata section', () {
    assetParseInvariants('<data><![CDATA[<data></data>]]></data>');
  });
  test('short processing instruction', () {
    assetParseInvariants('<?xml?><data />');
  });
  test('long processing instruction', () {
    assetParseInvariants('<?xml version="1.0"?><data />');
  });
  test('whitespace after prolog', () {
    assetParseInvariants('<?xml version="1.0" encoding="UTF-8"?>\n\t'
        '<schema></schema>\t\n');
  });
  test('parse errors', () {
    assertParseError('<data></tada>', 'Expected </data>, but found </tada>');
    assertParseError('<data key="ab', '">" expected at 1:7');
    assertParseError('<data key', '">" expected at 1:7');
    assertParseError('<data', '">" expected at 1:6');
    assertParseError('<>', 'Expected name at 1:2');
  });
}
