import 'package:checks/checks.dart';
import 'package:petitparser/reflection.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/entities/null_mapping.dart';
import 'package:xml/src/xml/utils/cache.dart';
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
  group('parser', () {
    test('linter', () {
      final parser = const XmlEventParser(XmlNullEntityMapping()).build();
      check(linter(parser)).isEmpty();
    });
  });
}
