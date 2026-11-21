import 'package:checks/checks.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/entities/null_mapping.dart';
import 'package:xml/src/xml/utils/cache.dart';
import 'package:xml/src/xml/utils/end_of_line.dart';
import 'package:xml/src/xml_events/parser.dart';

void main() {
  group('cache', () {
    test('simple', () {
      var counter = 0;
      final cache = XmlCache<int, String>((key) {
        check(key).equals(counter);
        return '${counter++}';
      }, 10);
      check(cache[0]).equals('0');
      check(cache[1]).equals('1');
      check(cache[0]).equals('0');
      check(cache[1]).equals('1');
    });
    test('expiry', () {
      var counter = 0;
      final cache = XmlCache<int, String>((key) => '${counter++}', 1);
      check(cache[0]).equals('0');
      check(cache[1]).equals('1');
      check(cache[0]).equals('2');
      check(cache[1]).equals('3');
    });
  });
  group('end-of-line', () {
    test('no carriage return returns identical string', () {
      const input = 'hello\nworld';
      check(identical(normalizeEndOfLine(input), input)).isTrue;
      check(normalizeEndOfLine('')).equals('');
    });
    test('normalizes CRLF and standalone CR', () {
      check(normalizeEndOfLine('\r')).equals('\n');
      check(normalizeEndOfLine('\r\n')).equals('\n');
      check(normalizeEndOfLine('\r\r\n')).equals('\n\n');
      check(normalizeEndOfLine('a\r\nb\rc\nd\r')).equals('a\nb\nc\nd\n');
      check(normalizeEndOfLine('a\n\r')).equals('a\n\n');
    });
  });
  group('parser', () {
    test('linter', () {
      final parser = const XmlEventParser(XmlNullEntityMapping()).build();
      check(linter(parser)).isEmpty;
    });
  });
}
