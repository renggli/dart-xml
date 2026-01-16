import 'package:test/test.dart';

import 'package:xml/xml.dart';

import '../xpath_test.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');
  group('expressions', () {
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
        expectEvaluate(
          xml,
          r'for $x in (1, 2), $y in ($x, $x * 10) return $y',
          [1, 10, 2, 20],
        );
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
    group('range', () {
      test('1 to 3', () {
        expectEvaluate(xml, '1 to 3', [1, 2, 3]);
      });
      test('1 to 1', () {
        expectEvaluate(xml, '1 to 1', [1]);
      });
      test('3 to 1', () {
        expectEvaluate(xml, '3 to 1', isEmpty);
      });
      test('empty operand', () {
        expectEvaluate(xml, '() to 1', isEmpty);
        expectEvaluate(xml, '1 to ()', isEmpty);
      });
      test('double operand', () {
        expectEvaluate(xml, '1.0 to 3.0', [1, 2, 3]);
      });
    });
    group('concat', () {
      test('strings', () {
        expectEvaluate(xml, '"a" || "b"', ['ab']);
      });
      test('numbers', () {
        expectEvaluate(xml, '1 || 2', ['12']);
      });
      test('mixed', () {
        expectEvaluate(xml, '"a" || 1 || "b"', ['a1b']);
      });
      test('empty', () {
        expectEvaluate(xml, '"a" || () || "b"', ['ab']);
      });
    });
    group('map', () {
      test('empty', () {
        expectEvaluate(xml, 'map {}', [<Object, Object>{}]);
      });
      test('simple', () {
        expectEvaluate(xml, 'map { "a": 1, "b": 2 }', [
          {'a': 1, 'b': 2},
        ]);
      });
    });
    group('array', () {
      test('square empty', () {
        expectEvaluate(xml, '[]', [<Object>[]]);
      });
      test('square simple', () {
        expectEvaluate(xml, '[1, 2]', [
          [1, 2],
        ]);
      });
      test('square nested', () {
        expectEvaluate(xml, '[(1, 2), 3]', [
          [
            [1, 2],
            3,
          ],
        ]);
      });
      test('curly empty', () {
        expectEvaluate(xml, 'array {}', [<Object>[]]);
      });
      test('curly flatten', () {
        expectEvaluate(xml, 'array { (1, 2), 3 }', [
          [1, 2, 3],
        ]);
      });
    });
  });
}
