import 'package:checks/checks.dart';
import 'package:petitparser/core.dart';
import 'package:petitparser/matcher.dart' show AcceptParser;
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/utils/character_data_parser.dart';
import 'package:xml/xml.dart';

void testDefaultMapping(XmlEntityMapping entityMapping) {
  group('decode', () {
    test('&#xHHHH;', () {
      check(entityMapping.decode('&#X41;')).equals('A');
      check(entityMapping.decode('&#x61;')).equals('a');
      check(entityMapping.decode('&#x7A;')).equals('z');
    });
    test('&#dddd;', () {
      check(entityMapping.decode('&#65;')).equals('A');
      check(entityMapping.decode('&#97;')).equals('a');
      check(entityMapping.decode('&#122;')).equals('z');
    });
    test('&named;', () {
      check(entityMapping.decode('&lt;')).equals('<');
      check(entityMapping.decode('&gt;')).equals('>');
      check(entityMapping.decode('&amp;')).equals('&');
      check(entityMapping.decode('&apos;')).equals('\'');
      check(entityMapping.decode('&quot;')).equals('"');
    });
    test('invalid', () {
      check(entityMapping.decode('&Invalid;')).equals('&Invalid;');
      check(entityMapping.decode('&#Invalid;')).equals('&#Invalid;');
      check(entityMapping.decode('&#xInvalid;')).equals('&#xInvalid;');
      check(entityMapping.decode('&#XInvalid;')).equals('&#XInvalid;');
    });
    test('unicode', () {
      // https://www.compart.com/en/unicode/U+0000
      check(entityMapping.decode('&#0;')).equals('\u0000');
      check(entityMapping.decode('&#x0000;')).equals('\u0000');
      // https://www.compart.com/en/unicode/U+10FFFF
      check(entityMapping.decode('&#1114111;')).equals('\uDBFF\uDFFF');
      check(entityMapping.decode('&#x10FFFF;')).equals('\uDBFF\uDFFF');
    });
    test('unicode invalid', () {
      check(entityMapping.decode('&#-1;')).equals('&#-1;');
      check(entityMapping.decode('&#x-1;')).equals('&#x-1;');
      check(entityMapping.decode('&#1114112;')).equals('&#1114112;');
      check(entityMapping.decode('&#x110000;')).equals('&#x110000;');
    });
    test('incomplete', () {
      check(entityMapping.decode('&')).equals('&');
      check(entityMapping.decode('&amp')).equals('&amp');
      check(entityMapping.decode('a&b')).equals('a&b');
      check(entityMapping.decode('&&gt;')).equals('&>');
    });
    test('empty', () {
      check(entityMapping.decode('&;')).equals('&;');
    });
    test('none', () {
      check(entityMapping.decode('')).equals('');
      check(entityMapping.decode('Hello')).equals('Hello');
      check(entityMapping.decode('Hello World')).equals('Hello World');
    });
    test('surrounded', () {
      check(entityMapping.decode('a&amp;b')).equals('a&b');
      check(entityMapping.decode('&amp;a&amp;')).equals('&a&');
      check(entityMapping.decode('a&amp;b&amp;c')).equals('a&b&c');
      check(entityMapping.decode('&amp;a&amp;b&amp;')).equals('&a&b&');
      check(entityMapping.decode('a&amp;b&amp;c&amp;d')).equals('a&b&c&d');
    });
    test('sequence', () {
      check(entityMapping.decode('&amp;&amp;')).equals('&&');
      check(entityMapping.decode('&lt;&amp;&gt;')).equals('<&>');
    });
    test('document', () {
      final document = XmlDocument.parse(
        '<xml>a&amp;b</xml>',
        entityMapping: entityMapping,
      );
      check(document.rootElement.innerText).equals('a&b');
    });
    test('fragment', () {
      final fragment = XmlDocumentFragment.parse(
        'a&amp;b',
        entityMapping: entityMapping,
      );
      check(fragment.innerText).equals('a&b');
    });
  });
  group('encode', () {
    test('text', () {
      check(entityMapping.encodeText('<')).equals('&lt;');
      check(entityMapping.encodeText('&')).equals('&amp;');
      check(entityMapping.encodeText('\u0000\u0008\u0009\u0084\u0085\u0086'))
          .equals('\u0000&#x8;\u0009&#x84;\u0085&#x86;');
      check(entityMapping.encodeText('hello')).equals('hello');
      check(entityMapping.encodeText('<foo &amp;>'))
          .equals('&lt;foo &amp;amp;>');
    });
    test('attribute (single quote)', () {
      check(
        entityMapping.encodeAttributeValue("'", XmlAttributeType.SINGLE_QUOTE),
      ).equals('&apos;');
      check(
        entityMapping.encodeAttributeValue('"', XmlAttributeType.SINGLE_QUOTE),
      ).equals('"');
      check(
        entityMapping.encodeAttributeValue('\t', XmlAttributeType.SINGLE_QUOTE),
      ).equals('&#x9;');
      check(
        entityMapping.encodeAttributeValue('\n', XmlAttributeType.SINGLE_QUOTE),
      ).equals('&#xA;');
      check(
        entityMapping.encodeAttributeValue('\r', XmlAttributeType.SINGLE_QUOTE),
      ).equals('&#xD;');
      check(
        entityMapping.encodeAttributeValue(
          '\u0000\u0008\u0009\u0084\u0085\u0086',
          XmlAttributeType.SINGLE_QUOTE,
        ),
      ).equals('\u0000&#x8;&#x9;&#x84;\u0085&#x86;');
      check(
        entityMapping.encodeAttributeValue(
          'hello',
          XmlAttributeType.SINGLE_QUOTE,
        ),
      ).equals('hello');
      check(
        entityMapping.encodeAttributeValue(
          "'hello'",
          XmlAttributeType.SINGLE_QUOTE,
        ),
      ).equals('&apos;hello&apos;');
      check(
        entityMapping.encodeAttributeValue(
          '"hello"',
          XmlAttributeType.SINGLE_QUOTE,
        ),
      ).equals('"hello"');
    });
    test('encode attribute (double quote)', () {
      check(
        entityMapping.encodeAttributeValue("'", XmlAttributeType.DOUBLE_QUOTE),
      ).equals("'");
      check(
        entityMapping.encodeAttributeValue('"', XmlAttributeType.DOUBLE_QUOTE),
      ).equals('&quot;');
      check(
        entityMapping.encodeAttributeValue('\t', XmlAttributeType.DOUBLE_QUOTE),
      ).equals('&#x9;');
      check(
        entityMapping.encodeAttributeValue('\n', XmlAttributeType.DOUBLE_QUOTE),
      ).equals('&#xA;');
      check(
        entityMapping.encodeAttributeValue('\r', XmlAttributeType.DOUBLE_QUOTE),
      ).equals('&#xD;');
      check(
        entityMapping.encodeAttributeValue(
          '\u0000\u0008\u0009\u0084\u0085\u0086',
          XmlAttributeType.DOUBLE_QUOTE,
        ),
      ).equals('\u0000&#x8;&#x9;&#x84;\u0085&#x86;');
      check(
        entityMapping.encodeAttributeValue(
          'hello',
          XmlAttributeType.DOUBLE_QUOTE,
        ),
      ).equals('hello');
      check(
        entityMapping.encodeAttributeValue(
          "'hello'",
          XmlAttributeType.DOUBLE_QUOTE,
        ),
      ).equals("'hello'");
      check(
        entityMapping.encodeAttributeValue(
          '"hello"',
          XmlAttributeType.DOUBLE_QUOTE,
        ),
      ).equals('&quot;hello&quot;');
    });
  });
}

void main() {
  group('xml', () {
    testDefaultMapping(defaultEntityMapping);
  });
  group('html', () {
    const entityMapping = XmlDefaultEntityMapping.html();
    testDefaultMapping(entityMapping);
    test('special', () {
      check(entityMapping.decode('&eacute;')).equals('é');
      check(entityMapping.decode('&Eacute;')).equals('É');
    });
  });
  group('html5', () {
    const entityMapping = XmlDefaultEntityMapping.html5();
    testDefaultMapping(entityMapping);
    test('special', () {
      check(entityMapping.decode('&bigstar;')).equals('★');
      check(entityMapping.decode('&block;')).equals('█');
    });
  });
  group('custom', () {
    const entityMapping = XmlDefaultEntityMapping({'joy': '😂', 'tears': '😢'});
    test('basic', () {
      check(entityMapping.decodeEntity('joy')).equals('😂');
      check(entityMapping.decodeEntity('tears')).equals('😢');
    });
    test('entities', () {
      check(entityMapping.decode('&joy;')).equals('😂');
      check(entityMapping.decode('&tears;')).equals('😢');
    });
    test('document', () {
      final document = XmlDocument.parse(
        '<xml>&joy; and &tears;</xml>',
        entityMapping: entityMapping,
      );
      check(document.rootElement.innerText).equals('😂 and 😢');
    });
    test('fragment', () {
      final fragment = XmlDocumentFragment.parse(
        '&joy; and &tears;',
        entityMapping: entityMapping,
      );
      check(fragment.innerText).equals('😂 and 😢');
    });
  });
  group('null', () {
    const entityMapping = XmlNullEntityMapping();
    group('decode', () {
      test('basic', () {
        check(entityMapping.decodeEntity('')).isNull();
        check(entityMapping.decodeEntity('amp')).isNull();
        check(entityMapping.decodeEntity('#X41')).isNull();
        check(entityMapping.decodeEntity('#65')).isNull();
      });
      test('entities', () {
        check(entityMapping.decode('&#X41;')).equals('&#X41;');
        check(entityMapping.decode('&#65;')).equals('&#65;');
        check(entityMapping.decode('&amp;')).equals('&amp;');
      });
      test('invalid entities', () {
        check(entityMapping.decode('&;')).equals('&;');
        check(entityMapping.decode('&invalid;')).equals('&invalid;');
        check(entityMapping.decode('&incomplete')).equals('&incomplete');
      });
      test('combinations', () {
        check(entityMapping.decode('a&amp;b')).equals('a&amp;b');
        check(entityMapping.decode('&amp;x&amp;')).equals('&amp;x&amp;');
        check(entityMapping.decode('&amp;&amp;')).equals('&amp;&amp;');
      });
    });
    group('encode', () {
      test('text', () {
        check(entityMapping.encodeText('<')).equals('<');
        check(entityMapping.encodeText('&')).equals('&');
        check(entityMapping.encodeText('hello')).equals('hello');
        check(entityMapping.encodeText('<foo &amp;>')).equals('<foo &amp;>');
      });
      test('attribute', () {
        check(
          entityMapping.encodeAttributeValue(
            '<>&\'"',
            XmlAttributeType.SINGLE_QUOTE,
          ),
        ).equals('<>&\'"');
        check(
          entityMapping.encodeAttributeValue(
            '<>&\'"',
            XmlAttributeType.DOUBLE_QUOTE,
          ),
        ).equals('<>&\'"');
      });
    });
  });
  group('character parser', () {
    final parser = XmlCharacterDataParser('*', 1);
    test('parse without stopper', () {
      final result1 = parser.parse('');
      check(result1 is Failure).isTrue();
      check(result1.position).equals(0);

      final result2 = parser.parse('a');
      check(result2 is Success).isTrue();
      check(result2.position).equals(1);
      check(result2.value).equals('a');

      final result3 = parser.parse('ab');
      check(result3 is Success).isTrue();
      check(result3.position).equals(2);
      check(result3.value).equals('ab');
    });
    test('parse with stopper', () {
      final result1 = parser.parse('*');
      check(result1 is Failure).isTrue();
      check(result1.position).equals(0);

      final result2 = parser.parse('a*');
      check(result2 is Success).isTrue();
      check(result2.position).equals(1);
      check(result2.value).equals('a');

      final result3 = parser.parse('ab*');
      check(result3 is Success).isTrue();
      check(result3.position).equals(2);
      check(result3.value).equals('ab');
    });
    test('fast parse without stopper', () {
      check(parser.accept('')).isFalse();
      check(parser.accept('a')).isTrue();
      check(parser.accept('ab')).isTrue();
    });
    test('fast parse with stopper', () {
      check(parser.accept('*')).isFalse();
      check(parser.accept('a*')).isTrue();
      check(parser.accept('ab*')).isTrue();
    });
    test('copy and equality', () {
      check(parser.isEqualTo(parser)).isTrue();
      check(parser.isEqualTo(parser.copy())).isTrue();
      check(parser.isEqualTo(XmlCharacterDataParser('%', 1))).isFalse();
      check(parser.isEqualTo(XmlCharacterDataParser('*', 2))).isFalse();
    });
  });
}
