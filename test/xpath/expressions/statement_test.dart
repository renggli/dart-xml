import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../xpath_test.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');
  group('if', () {
    test('true branch', () {
      expectEvaluate(xml, 'if (true()) then 1 else 0', [1]);
    });
    test('false branch', () {
      expectEvaluate(xml, 'if (false()) then 1 else 0', [0]);
    });
    test('ebv true', () {
      expectEvaluate(xml, 'if (1) then "yes" else "no"', ['yes']);
    });
    test('ebv false', () {
      expectEvaluate(xml, 'if (0) then "yes" else "no"', ['no']);
    });
  });
  group('let', () {
    test('single variable', () {
      expectEvaluate(xml, r'let $x := 1 return $x + 1', [2]);
    });
    test('variable shadowing', () {
      expectEvaluate(xml, r'let $x := 1 return let $x := 2 return $x', [2]);
    });
    test('multiple bindings', () {
      expectEvaluate(xml, r'let $x := 1, $y := 2 return $x + $y', [3]);
    });
    test('binding dependency', () {
      expectEvaluate(xml, r'let $x := 1, $y := $x + 1 return $y', [2]);
    });
  });
  group('for', () {
    test('single variable', () {
      expectEvaluate(xml, r'for $x in (1, 2, 3) return $x * 2', [2, 4, 6]);
    });
    test('multiple variables', () {
      expectEvaluate(xml, r'for $x in (1, 2), $y in (3, 4) return $x + $y', [
        4,
        5,
        5,
        6,
      ]);
    });
    test('variable dependency', () {
      expectEvaluate(xml, r'for $x in (1, 2), $y in ($x, $x * 10) return $y', [
        1,
        10,
        2,
        20,
      ]);
    });
  });
  group('some', () {
    test('matches one', () {
      expectEvaluate(xml, r'some $x in (1, 2, 3) satisfies $x = 2', [true]);
    });
    test('matches none', () {
      expectEvaluate(xml, r'some $x in (1, 2, 3) satisfies $x = 4', [false]);
    });
    test('multiple variables', () {
      expectEvaluate(
        xml,
        'some \$x in (1, 2), \$y in (2, 3) satisfies \$x = \$y',
        [true],
      );
    });
  });
  group('every', () {
    test('matches all', () {
      expectEvaluate(xml, r'every $x in (1, 2, 3) satisfies $x > 0', [true]);
    });
    test('fails one', () {
      expectEvaluate(xml, r'every $x in (1, 2, 3) satisfies $x = 1', [false]);
    });
    test('multiple variables', () {
      expectEvaluate(
        xml,
        r'every $x in (1, 2), $y in (3, 4) satisfies $x < $y',
        [true],
      );
    });
  });
}
