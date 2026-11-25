import 'package:checks/checks.dart';
import 'package:petitparser/petitparser.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/utils/name_token_parser.dart';
import 'package:xml/src/xml/utils/token.dart';

final parser = XmlNameTokenParser('name expected');

/// The generic definition that [XmlNameTokenParser] replaces.
final reference = seq2(
  pattern(XmlToken.nameStartChars, unicode: true),
  pattern(XmlToken.nameChars, unicode: true).star(),
).flatten(message: 'name expected');

void verify(String input, [int position = 0]) {
  final expected = reference.parseOn(Context(input, position));
  final actual = parser.parseOn(Context(input, position));
  check(
    because: 'parseOn(${input.runes.toList()}, $position)',
    actual.position,
  ).equals(expected.position);
  check(actual is Failure).equals(expected is Failure);
  if (expected is Failure) {
    check(actual.message).equals(expected.message);
  } else {
    check(actual.value).equals(expected.value);
  }
  check(
    because: 'fastParseOn(${input.runes.toList()}, $position)',
    parser.fastParseOn(input, position),
  ).equals(reference.fastParseOn(input, position));
}

void main() {
  group('ascii', () {
    test('accepts names', () {
      for (final name in ['a', 'Z', '_', 'abc', 'a-b.c_d1', 'A9', 'html']) {
        check(parser.parse(name).value).equals(name);
      }
    });
    test('accepts names with colons', () {
      for (final name in [':', 'a:b', 'xml:lang', 'epub:type', ':a', 'a:']) {
        check(parser.parse(name).value).equals(name);
      }
      check(parser.parse('a:b:c').value).equals('a:b:c');
    });
    test('rejects invalid start characters', () {
      for (final input in ['', ' ', '0', '9a', '-a', '.a', '<a', '=', '"']) {
        final result = parser.parse(input);
        check(result is Failure).isTrue;
        check(result.position).equals(0);
        check(result.message).equals('name expected');
      }
    });
    test('stops at non-name characters', () {
      for (final (input, name) in [
        ('a b', 'a'),
        ('a=b', 'a'),
        ('a>', 'a'),
        ('a/>', 'a'),
        ('a\tb', 'a'),
        ('ab"', 'ab'),
        ('a\u{7f}', 'a'),
      ]) {
        final result = parser.parse(input);
        check(result.value).equals(name);
        check(result.position).equals(name.length);
      }
    });
    test('all ascii characters', () {
      for (var code = 0; code < 0x80; code++) {
        final char = String.fromCharCode(code);
        verify(char);
        verify('a$char');
        verify('a${char}b');
      }
    });
  });
  group('unicode', () {
    test('accepts non-ascii names', () {
      for (final name in [
        'élan',
        'naïve',
        'Ελληνικά',
        'имя',
        '日本語',
        'ルビ',
        'a\u{b7}b',
        'a\u{300}',
        'a\u{203f}b',
        '\u{10000}',
        'a\u{10000}b',
        '\u{effff}',
      ]) {
        check(parser.parse(name).value).equals(name);
      }
    });
    test('rejects non-ascii non-name characters', () {
      for (final input in ['\u{80}', '\u{b7}', '\u{d7}', '\u{f7}', '\u{300}']) {
        check(parser.parse(input) is Failure).isTrue;
      }
      check(parser.parse('a\u{d7}').value).equals('a');
      check(parser.parse('a\u{f0000}').value).equals('a');
    });
    test('rejects unpaired surrogates', () {
      check(parser.parse('\u{d800}') is Failure).isTrue;
      check(parser.parse('\u{dc00}a') is Failure).isTrue;
      check(parser.parse('a\u{d800}').value).equals('a');
      check(parser.parse('a\u{dc00}b').value).equals('a');
    });
    test('all basic multilingual plane characters', () {
      for (var code = 0x80; code < 0x10000; code++) {
        final char = String.fromCharCode(code);
        verify(char);
        verify('a${char}b');
      }
    });
    test('supplementary characters', () {
      for (final code in [0x10000, 0x1f600, 0xeffff, 0xf0000, 0x10ffff]) {
        final char = String.fromCharCode(code);
        verify(char);
        verify('a${char}b');
      }
    });
  });
  group('position', () {
    test('parses from an offset', () {
      verify('<a:b c="d"/>', 1);
      verify('<a:b c="d"/>', 5);
      check(parser.parseOn(const Context('<abc>', 1)).value).equals('abc');
      check(parser.parseOn(const Context('<abc>', 1)).position).equals(4);
    });
    test('fails at the end of input', () {
      verify('abc', 3);
      check(parser.fastParseOn('abc', 3)).equals(-1);
    });
  });
  group('parser', () {
    test('copy and equality', () {
      check(parser.copy().isEqualTo(parser)).isTrue;
      check(XmlNameTokenParser('other').isEqualTo(parser)).isFalse;
    });
  });
}
