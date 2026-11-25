import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'utils/assertions.dart';
import 'utils/checks.dart';

const nameStartChars = {
  'A',
  'Z',
  '_',
  'a',
  'z',
  '\u{c0}',
  '\u{d6}',
  '\u{d8}',
  '\u{f6}',
  '\u{f8}',
  '\u{2ff}',
  '\u{370}',
  '\u{37d}',
  '\u{37f}',
  '\u{1fff}',
  '\u{200c}',
  '\u{200d}',
  '\u{2070}',
  '\u{218f}',
  '\u{2c00}',
  '\u{2fef}',
  '\u{3001}',
  '\u{d7ff}',
  '\u{f900}',
  '\u{fdcf}',
  '\u{fdf0}',
  '\u{fffd}',
  '\u{10000}',
  '\u{effff}',
};
const nameChars = {
  ...nameStartChars,
  '-',
  '.',
  '0',
  '9',
  '\u{B7}',
  '\u{300}',
  '\u{36F}',
  '\u{203F}',
  '\u{2040}',
};

void main() {
  group('document', () {
    test('cdata', () {
      assertDocumentParseInvariants('<data><![CDATA[]]></data>');
    });
    test('cdata with xml', () {
      assertDocumentParseInvariants('<data><![CDATA[<data></data>]]></data>');
    });
    test('comment', () {
      assertDocumentParseInvariants(
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<schema><!-- comment --></schema>',
      );
    });
    test('comment with xml', () {
      assertDocumentParseInvariants(
        '<?xml version="1.0" encoding="UTF-8"?>'
        '<schema><!-- <foo></foo> --></schema>',
      );
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
        '<root />',
      );
    });
    test('doctype (public)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">'
        '<root />',
      );
    });
    test('doctype (empty)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root []>\n'
        '<root />',
      );
    });
    test('doctype (comment)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!-- comment -->\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (processing)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <?processing?>\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (element type declarations)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ELEMENT br EMPTY>\n'
        '  <!ELEMENT p (#PCDATA|emph)* >\n'
        '  <!ELEMENT %name.para; %content.para; >\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (element content models)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ELEMENT spec (front, body, back?)>\n'
        '  <!ELEMENT div1 (head, (p | list | note)*, div2*)>\n'
        '  <!ELEMENT dictionary-body (%div.mix; | %dict.mix;)*>\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (element mixed content)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ELEMENT p (#PCDATA|a|ul|b|i|em)*>\n'
        '  <!ELEMENT p (#PCDATA | %font; | %phrase; | %special; | %form;)* >\n'
        '  <!ELEMENT b (#PCDATA)>\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (attribute-list)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ATTLIST termdef\n'
        '    id      ID      #REQUIRED\n'
        '    name    CDATA   #IMPLIED>\n'
        '  <!ATTLIST list\n'
        '    type    (bullets|ordered|glossary)  "ordered">\n'
        '  <!ATTLIST form\n'
        '    method  CDATA   #FIXED "POST">\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (internal entity)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ENTITY Pub-Status "This is a pre-release.">\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (internal entity, included)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ENTITY % YN "Yes" >\n'
        '  <!ENTITY WhatHeSaid "He said %YN;" >\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (internal entity, replacement text)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ENTITY % pub    "&#xc9;ditions Gallimard" >\n'
        '  <!ENTITY   rights "All rights reserved" >\n'
        '  <!ENTITY   book   "La Peste: Albert Camus,\n'
        '    &#xA9; 1947 %pub;. &rights;" >\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (entity reference)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ENTITY % ISOLat2\n'
        '    SYSTEM "http://www.xml.com/iso/isolat2-xml.entities" >\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (external entities )', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!ENTITY open-hatch\n'
        '    SYSTEM "http://www.textuality.com/boilerplate/OpenHatch.xml">\n'
        '  <!ENTITY open-hatch\n'
        '    PUBLIC "-//Textuality//TEXT Standard open-hatch boilerplate//EN"\n'
        '    "http://www.textuality.com/boilerplate/OpenHatch.xml">\n'
        '  <!ENTITY hatch-pic\n'
        '    SYSTEM "../grafix/OpenHatch.gif"\n'
        '    NDATA gif >\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (notation)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE root [\n'
        '  <!NOTATION open-hatch\n'
        '    SYSTEM "http://www.textuality.com/boilerplate/OpenHatch.xml">\n'
        '  <!NOTATION open-hatch\n'
        '    PUBLIC "-//Textuality//TEXT Standard open-hatch boilerplate//EN">\n'
        '  <!NOTATION open-hatch\n'
        '    PUBLIC "-//Textuality//TEXT Standard open-hatch boilerplate//EN"\n'
        '    "http://www.textuality.com/boilerplate/OpenHatch.xml">\n'
        ']>\n'
        '<root />',
      );
    });
    test('doctype (ambiguous)', () {
      assertDocumentParseInvariants(
        '<!DOCTYPE ambiguous [\n'
        '  <!-- comment [<brackets>] -->\n'
        '  <?pi processing="[<brackets>]" ?>\n'
        '  <!NOTATION not PUBLIC "[<brackets>]" \'[<brackets>]\'>\n'
        '  <!ENTITY entity1 "[<brackets>]">\n'
        '  <!ENTITY entity2 \'[<brackets>]\'>\n'
        '  <!ENTITY % entity3 "[<brackets>]">\n'
        '  <!ENTITY % entity4 \'[<brackets>]\'>\n'
        '  <!ELEMENT element1 (#PCDATA)>\n'
        '  <!ELEMENT element2 (element1 | element2)+>\n'
        '  <!ELEMENT element3 (#PCDATA , element3)*>\n'
        '  <!ATTLIST attlist1 entity1 (foo | bar)>\n'
        '  <!ATTLIST attlist2 entity2 "[<brackets>]" #REQUIRED>\n'
        '  <!ATTLIST attlist2 entity3 \'[<brackets>]\' #IMPLIED>\n'
        ']>\n'
        '<root />',
      );
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
      assertDocumentParseInvariants('<schema foo="bar" take="drop"></schema>');
    });
    test('element with single quote attribute', () {
      assertDocumentParseInvariants("<schema foo='bar'></schema>");
      assertDocumentParseInvariants("<schema foo='bar' take='drop'></schema>");
    });
    test('element with attribute without quotes', () {
      assertDocumentParseInvariants('<schema foo=bar></schema>');
      assertDocumentParseInvariants('<schema foo=bar take=drop></schema>');
    });
    test('element with attribute without value', () {
      assertDocumentParseInvariants('<schema foo></schema>');
      assertDocumentParseInvariants('<schema foo bar></schema>');
    });
    test('element with special initial char', () {
      for (final char in nameStartChars) {
        final qualified = char;
        final closed = XmlDocument.parse('<$qualified />');
        check(closed.rootElement.name.qualified).equals(qualified);
        final openClosed = XmlDocument.parse('<$qualified></$qualified>');
        check(openClosed.rootElement.name.qualified).equals(qualified);
      }
    });
    test('element with special continuation char', () {
      for (final char in nameChars) {
        final qualified = 'x$char';
        final closed = XmlDocument.parse('<$qualified />');
        check(closed.rootElement.name.qualified).equals(qualified);
        final openClosed = XmlDocument.parse('<$qualified></$qualified>');
        check(openClosed.rootElement.name.qualified).equals(qualified);
      }
    });
    test('element with attribute with special initial char', () {
      for (final char in nameStartChars) {
        final qualified = char;
        final root = XmlDocument.parse('<root $qualified="ok" />');
        check(root.rootElement.attributes.first.name.qualified)
            .equals(qualified);
        check(root.rootElement.getAttribute(qualified)).equals('ok');
      }
    });
    test('element with attribute with with special continuation char', () {
      for (final char in nameChars) {
        final qualified = 'x$char';
        final root = XmlDocument.parse('<root $qualified="ok" />');
        check(root.rootElement.attributes.first.name.qualified)
            .equals(qualified);
        check(root.rootElement.getAttribute(qualified)).equals('ok');
      }
    });
    test('processing instruction', () {
      assertDocumentParseInvariants('<?pi?><data />');
    });
    test('processing instruction with attribute', () {
      assertDocumentParseInvariants('<?pi foo="bar"?><data />');
    });
    test('document with comments', () {
      assertDocumentParseInvariants(
        '<?xml version="1.0"?>'
        '<!--comment-->'
        '<!DOCTYPE root-name SYSTEM "uri-reference">'
        '<data />',
      );
      assertDocumentParseInvariants(
        '<?xml version="1.0"?>'
        '<!DOCTYPE root-name SYSTEM "uri-reference">'
        '<!--comment-->'
        '<data />',
      );
      assertDocumentParseInvariants(
        '<?xml version="1.0"?>'
        '<!DOCTYPE root-name SYSTEM "uri-reference">'
        '<data />'
        '<!--comment-->',
      );
    });
    group('validation errors', () {
      test('empty', () {
        check(() => XmlDocument.parse('')).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Expected a single root element',
            position: 0,
          ),
        );
      });
      test('whitespace', () {
        check(() => XmlDocument.parse('  ')).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Expected a single root element',
            position: 2,
          ),
        );
      });
      test('repeated declaration', () {
        check(
          () => XmlDocument.parse(
            '<?xml version="1.0"?>'
            '<?xml version="1.1"?>'
            '<root />',
          ),
        ).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Expected at most one XML declaration',
            position: 21,
          ),
        );
      });
      test('repeated doctype', () {
        check(
          () => XmlDocument.parse(
            '<!DOCTYPE root-name SYSTEM "uri-ref">'
            '<!DOCTYPE root-name PUBLIC "pub-id" "uri-ref">'
            '<root />',
          ),
        ).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Expected at most one doctype declaration',
            position: 37,
          ),
        );
      });
      test('unexpected declaration', () {
        check(
          () => XmlDocument.parse(
            '<!DOCTYPE root-name SYSTEM "uri-ref">'
            '<?xml version="1.1"?>',
          ),
        ).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Unexpected XML declaration',
            position: 37,
          ),
        );
        check(
          () => XmlDocument.parse(
            '<root />'
            '<?xml version="1.1"?>',
          ),
        ).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Unexpected XML declaration',
            position: 8,
          ),
        );
      });
      test('unexpected doctype', () {
        check(
          () => XmlDocument.parse(
            '<root />'
            '<!DOCTYPE root-name SYSTEM "uri-ref">',
          ),
        ).throws<XmlParserException>().which(
          isXmlParserException(
            message: 'Unexpected doctype declaration',
            position: 8,
          ),
        );
      });
      test('unexpected root element', () {
        check(
          () => XmlDocument.parse('<root1 /><root2 />'),
        ).throws<XmlParserException>().which(
          isXmlParserException(message: 'Unexpected root element', position: 9),
        );
      });
    });
    group('parse errors', () {
      test('nesting', () {
        check(() => XmlDocument.parse('<foo></bar>'))
            .throws<XmlTagException>()
            .which(
              isXmlTagException(
                message: 'Expected </foo>, but found </bar>',
                position: 5,
              ),
            );
        check(() => XmlDocument.parse('<bar>')).throws<XmlTagException>().which(
          isXmlTagException(message: 'Missing closing tag </bar>', position: 5),
        );
        check(() => XmlDocument.parse('</bar>'))
            .throws<XmlTagException>()
            .which(
              isXmlTagException(
                message: 'Unexpected closing tag </bar>',
                position: 0,
              ),
            );
      });
      test('element', () {
        check(() => XmlDocument.parse('<'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: 'name expected', position: 1));
        check(() => XmlDocument.parse('<data'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 5));
        check(() => XmlDocument.parse('<data key'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 9));
        check(() => XmlDocument.parse('<data key="ab'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 9));
      });
      test('comment', () {
        check(() => XmlDocument.parse('<!--'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"-->" expected', position: 4),
            );
        check(() => XmlDocument.parse('<!-- comment'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"-->" expected', position: 4),
            );
      });
      test('cdata', () {
        check(() => XmlDocument.parse('<![CDATA['))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"]]>" expected', position: 9),
            );
        check(() => XmlDocument.parse('<![CDATA[ cdata'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"]]>" expected', position: 9),
            );
      });
      test('doctype', () {
        check(() => XmlDocument.parse('<!DOCTYPE'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: 'whitespace expected', position: 9),
            );
        check(() => XmlDocument.parse('<!DOCTYPE data'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 14));
        check(() => XmlDocument.parse('<!DOCTYPE data ['))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 15));
      });
      test('declaration', () {
        check(() => XmlDocument.parse('<?'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: 'name expected', position: 2));
        check(() => XmlDocument.parse('<?xml'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '"?>" expected', position: 5));
        check(() => XmlDocument.parse('<?xml version'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 13),
            );
        check(() => XmlDocument.parse('<?xml version='))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 13),
            );
        check(() => XmlDocument.parse('<?xml version="1.0'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 13),
            );
      });
      test('processing', () {
        check(() => XmlDocument.parse('<?'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: 'name expected', position: 2));
        check(() => XmlDocument.parse('<?processing'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 12),
            );
        check(() => XmlDocument.parse('<?processing whatever'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 12),
            );
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
        '<!DOCTYPE root-name SYSTEM "uri-reference">',
      );
    });
    test('doctype (public)', () {
      assertFragmentParseInvariants(
        '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">',
      );
    });
    test('doctype (subset)', () {
      assertFragmentParseInvariants(
        '<!DOCTYPE root ['
        '  <!ELEMENT root (child)>'
        '  <!ATTLIST root attribute #IMPLIED>'
        '  <!ENTITY copy "©">'
        ']>',
      );
    });
    test('doctype (combined)', () {
      assertFragmentParseInvariants(
        '<!DOCTYPE root SYSTEM "uri-reference" ['
        '  <!ELEMENT root (child)>'
        '  <!ATTLIST root attribute #IMPLIED>'
        '  <!ENTITY copy "©">'
        ']>',
      );
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
      assertFragmentParseInvariants(
        'I have a heart I swear I do, '
        'Just not baby when it comes to you.',
      );
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
        check(() => XmlDocumentFragment.parse('<foo></bar>'))
            .throws<XmlTagException>()
            .which(
              isXmlTagException(
                message: 'Expected </foo>, but found </bar>',
                position: 5,
              ),
            );
        check(
          () => XmlDocumentFragment.parse('<bar>'),
        ).throws<XmlTagException>().which(
          isXmlTagException(message: 'Missing closing tag </bar>', position: 5),
        );
        check(() => XmlDocumentFragment.parse('</bar>'))
            .throws<XmlTagException>()
            .which(
              isXmlTagException(
                message: 'Unexpected closing tag </bar>',
                position: 0,
              ),
            );
      });
      test('element', () {
        check(() => XmlDocumentFragment.parse('<'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: 'name expected', position: 1));
        check(() => XmlDocumentFragment.parse('<data'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 5));
        check(() => XmlDocumentFragment.parse('<data key'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 9));
        check(() => XmlDocumentFragment.parse('<data key="ab'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 9));
      });
      test('comment', () {
        check(() => XmlDocumentFragment.parse('<!--'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"-->" expected', position: 4),
            );
        check(() => XmlDocumentFragment.parse('<!-- comment'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"-->" expected', position: 4),
            );
      });
      test('cdata', () {
        check(() => XmlDocumentFragment.parse('<![CDATA['))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"]]>" expected', position: 9),
            );
        check(() => XmlDocumentFragment.parse('<![CDATA[ cdata'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"]]>" expected', position: 9),
            );
      });
      test('doctype', () {
        check(() => XmlDocumentFragment.parse('<!DOCTYPE'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: 'whitespace expected', position: 9),
            );
        check(() => XmlDocumentFragment.parse('<!DOCTYPE data'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 14));
        check(() => XmlDocumentFragment.parse('<!DOCTYPE data ['))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '">" expected', position: 15));
      });
      test('declaration', () {
        check(() => XmlDocumentFragment.parse('<?'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: 'name expected', position: 2));
        check(() => XmlDocumentFragment.parse('<?xml'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: '"?>" expected', position: 5));
        check(() => XmlDocumentFragment.parse('<?xml version'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 13),
            );
        check(() => XmlDocumentFragment.parse('<?xml version='))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 13),
            );
        check(() => XmlDocumentFragment.parse('<?xml version="1.0'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 13),
            );
      });
      test('processing', () {
        check(() => XmlDocumentFragment.parse('<?'))
            .throws<XmlParserException>()
            .which(isXmlParserException(message: 'name expected', position: 2));
        check(() => XmlDocumentFragment.parse('<?processing'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 12),
            );
        check(() => XmlDocumentFragment.parse('<?processing whatever'))
            .throws<XmlParserException>()
            .which(
              isXmlParserException(message: '"?>" expected', position: 12),
            );
      });
    });
  });
  group('end-of-line normalization', () {
    test('text', () {
      final doc = XmlDocument.parse('<root>a\r\nb\rc\nd\r\n&#xD;&#13;</root>');
      check(doc.rootElement.innerText).equals('a\nb\nc\nd\n\r\r');
    });
    test('attributes', () {
      final doc = XmlDocument.parse(
        '<root a="1\r\n2\r3&#xD;" b=\'4\r\n5\r6&#13;\'/>',
      );
      check(doc.rootElement.getAttribute('a')).equals('1 2 3\r');
      check(doc.rootElement.getAttribute('b')).equals('4 5 6\r');
    });
    test('comment, cdata, processing, doctype', () {
      final doc = XmlDocument.parse(
        '<!DOCTYPE root [\r\n<!ELEMENT root (#PCDATA)>\r]>\r\n'
        '<root><!--c1\r\nc2\rc3--><![CDATA[d1\r\nd2\rd3]]><?pi p1\r\np2\rp3?></root>',
      );
      check(doc.doctypeElement?.internalSubset)
          .equals('\n<!ELEMENT root (#PCDATA)>\n');
      final children = doc.rootElement.children;
      check((children[0] as XmlComment).value).equals('c1\nc2\nc3');
      check((children[1] as XmlCDATA).value).equals('d1\nd2\nd3');
      check((children[2] as XmlProcessing).value).equals('p1\np2\np3');
    });
    test('preserves source offsets and positions', () {
      const input = '<root>\r\n  <child>a\r\nb</child>\r\n</root>';
      final events = parseEvents(input, withLocation: true).toList();
      check(events[0].start).equals(0);
      check(events[0].stop).equals(6);
      check(events[1].start).equals(6);
      check(events[1].stop).equals(10);
      check(events[2].start).equals(10);
      check(events[2].stop).equals(17);
      check((events[3] as XmlTextEvent).value).equals('a\nb');
      check(events[3].start).equals(17);
      check(events[3].stop).equals(21);
      check(events[4].start).equals(21);
      check(events[4].stop).equals(29);
    });
  });
  group('attribute-value normalization', () {
    test('whitespace characters', () {
      final doc = XmlDocument.parse('<r a="x\ty\nz" b=\'x\ty\nz\'/>');
      check(doc.rootElement.getAttribute('a')).equals('x y z');
      check(doc.rootElement.getAttribute('b')).equals('x y z');
    });
    test('end-of-line sequences', () {
      final doc = XmlDocument.parse('<r a="1\r\n2\r3\n\r4" b=\'1\r\n2\'/>');
      check(doc.rootElement.getAttribute('a')).equals('1 2 3  4');
      check(doc.rootElement.getAttribute('b')).equals('1 2');
    });
    test('spaces', () {
      final doc = XmlDocument.parse('<r a="  x  y  " b=\'  x  y  \'/>');
      check(doc.rootElement.getAttribute('a')).equals('  x  y  ');
      check(doc.rootElement.getAttribute('b')).equals('  x  y  ');
    });
    test('character references', () {
      final doc = XmlDocument.parse(
        '<r a="x&#9;y&#10;z&#13;" b=\'x&#x9;y&#xA;z&#xD;\'/>',
      );
      check(doc.rootElement.getAttribute('a')).equals('x\ty\nz\r');
      check(doc.rootElement.getAttribute('b')).equals('x\ty\nz\r');
    });
    test('events', () {
      final events = parseEvents('<r a="x\ty\r\nz" b=\'x&#9;y&#xA;z\'/>');
      final attributes = (events.single as XmlStartElementEvent).attributes;
      check(attributes[0].value).equals('x y z');
      check(attributes[1].value).equals('x\ty\nz');
    });
    test('round-trip', () {
      const value = '\tx\r\ny\nz\r ';
      for (final type in XmlAttributeType.values) {
        final element = XmlElement.tag(
          'r',
          attributes: [XmlAttribute(XmlName('a'), value, type)],
        );
        final doc = XmlDocument.parse(element.toXmlString());
        check(doc.rootElement.getAttribute('a')).equals(value);
      }
    });
  });
}
