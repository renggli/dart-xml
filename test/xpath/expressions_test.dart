import 'package:test/test.dart';
import 'package:xml/src/xpath/types31/array.dart';
import 'package:xml/src/xpath/types31/map.dart';
import 'package:xml/src/xpath/types31/number.dart';
import 'package:xml/src/xpath/types31/sequence.dart';
import 'package:xml/xml.dart';

import '../xpath_test.dart';

void main() {
  group('expressions', () {
    final xml = XmlDocument.parse('<root/>');

    group('if', () {
      test('true branch', () {
        expectEvaluate(xml, 'if (true()) then 1 else 0', isNumber(1));
      });
      test('false branch', () {
        expectEvaluate(xml, 'if (false()) then 1 else 0', isNumber(0));
      });
      test('ebv true', () {
        expectEvaluate(xml, 'if (1) then "yes" else "no"', isString('yes'));
      });
      test('ebv false', () {
        expectEvaluate(xml, 'if (0) then "yes" else "no"', isString('no'));
      });
    });

    group('let', () {
      test('single variable', () {
        expectEvaluate(xml, 'let \$x := 1 return \$x + 1', isNumber(2));
      });
      test('variable shadowing', () {
        expectEvaluate(
          xml,
          'let \$x := 1 return let \$x := 2 return \$x',
          isNumber(2),
        );
      });
      test('multiple bindings', () {
        expectEvaluate(
          xml,
          'let \$x := 1, \$y := 2 return \$x + \$y',
          isNumber(3),
        );
      });
      test('binding dependency', () {
        expectEvaluate(
          xml,
          'let \$x := 1, \$y := \$x + 1 return \$y',
          isNumber(2),
        );
      });
    });

    group('for', () {
      test('single variable', () {
        expectEvaluate(
          xml,
          'for \$x in (1, 2, 3) return \$x * 2',
          isA<XPathSequence>().having(
            (seq) => seq.map((item) => item.toXPathNumber()),
            'values',
            orderedEquals([2, 4, 6]),
          ),
        );
      });
      test('multiple variables', () {
        expectEvaluate(
          xml,
          'for \$x in (1, 2), \$y in (3, 4) return \$x + \$y',
          isA<XPathSequence>().having(
            (seq) => seq.map((item) => item.toXPathNumber()),
            'values',
            orderedEquals([4, 5, 5, 6]),
          ),
        );
      });
      test('variable dependency', () {
        expectEvaluate(
          xml,
          'for \$x in (1, 2), \$y in (\$x, \$x * 10) return \$y',
          isA<XPathSequence>().having(
            (seq) => seq.map((item) => item.toXPathNumber()),
            'values',
            orderedEquals([1, 10, 2, 20]),
          ),
        );
      });
    });

    group('some', () {
      test('matches one', () {
        expectEvaluate(
          xml,
          'some \$x in (1, 2, 3) satisfies \$x = 2',
          isBoolean(true),
        );
      });
      test('matches none', () {
        expectEvaluate(
          xml,
          'some \$x in (1, 2, 3) satisfies \$x = 4',
          isBoolean(false),
        );
      });
      test('multiple variables', () {
        expectEvaluate(
          xml,
          'some \$x in (1, 2), \$y in (2, 3) satisfies \$x = \$y',
          isBoolean(true),
        );
      });
    });

    group('every', () {
      test('matches all', () {
        expectEvaluate(
          xml,
          'every \$x in (1, 2, 3) satisfies \$x > 0',
          isBoolean(true),
        );
      });
      test('fails one', () {
        expectEvaluate(
          xml,
          'every \$x in (1, 2, 3) satisfies \$x = 1',
          isBoolean(false),
        );
      });
      test('multiple variables', () {
        expectEvaluate(
          xml,
          'every \$x in (1, 2), \$y in (3, 4) satisfies \$x < \$y',
          isBoolean(true),
        );
      });
    });

    group('range', () {
      test('1 to 3', () {
        expectEvaluate(
          xml,
          '1 to 3',
          isA<XPathSequence>().having(
            (seq) => seq.map((item) => item.toXPathNumber()),
            'values',
            orderedEquals([1, 2, 3]),
          ),
        );
      });
      test('1 to 1', () {
        expectEvaluate(xml, '1 to 1', isNumber(1));
      });
      test('3 to 1', () {
        expectEvaluate(xml, '3 to 1', isEmpty);
      });
      test('empty operand', () {
        expectEvaluate(xml, '() to 1', isEmpty);
        expectEvaluate(xml, '1 to ()', isEmpty);
      });
      test('double operand', () {
        expectEvaluate(
          xml,
          '1.0 to 3.0',
          isA<XPathSequence>().having(
            (seq) => seq.map((item) => item.toXPathNumber()),
            'values',
            orderedEquals([1, 2, 3]),
          ),
        );
      });
    });

    group('concat', () {
      test('strings', () {
        expectEvaluate(xml, '"a" || "b"', isString('ab'));
      });
      test('numbers', () {
        expectEvaluate(xml, '1 || 2', isString('12'));
      });
      test('mixed', () {
        expectEvaluate(xml, '"a" || 1 || "b"', isString('a1b'));
      });
      test('empty', () {
        expectEvaluate(xml, '"a" || () || "b"', isString('ab'));
      });
    });

    group('constructors', () {
      group('map', () {
        test('empty', () {
          expectEvaluate(
            xml,
            'map {}',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathMap>().having((m) => m, 'map', isEmpty),
            ),
          );
        });
        test('simple', () {
          expectEvaluate(
            xml,
            'map { "a": 1, "b": 2 }',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathMap>().having(
                (m) => m,
                'map',
                allOf(
                  containsPair('a', isNumber(1)),
                  containsPair('b', isNumber(2)),
                ),
              ),
            ),
          );
        });
      });
      group('array', () {
        test('square empty', () {
          expectEvaluate(
            xml,
            '[]',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathArray>().having((a) => a, 'array', isEmpty),
            ),
          );
        });
        test('square simple', () {
          expectEvaluate(
            xml,
            '[1, 2]',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathArray>().having(
                (a) => a,
                'array',
                orderedEquals([isNumber(1), isNumber(2)]),
              ),
            ),
          );
        });
        test('square nested', () {
          expectEvaluate(
            xml,
            '[(1, 2), 3]',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathArray>().having(
                (a) => a,
                'array',
                orderedEquals([
                  isA<XPathSequence>().having(
                    (s) => s.map((i) => i.toXPathNumber()),
                    'values',
                    orderedEquals([1, 2]),
                  ),
                  isNumber(3),
                ]),
              ),
            ),
          );
        });
        test('curly empty', () {
          expectEvaluate(
            xml,
            'array {}',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathArray>().having((a) => a, 'array', isEmpty),
            ),
          );
        });
        test('curly flatten', () {
          expectEvaluate(
            xml,
            'array { (1, 2), 3 }',
            isA<XPathSequence>().having(
              (seq) => seq.single,
              'single',
              isA<XPathArray>().having(
                (a) => a,
                'array',
                orderedEquals([isNumber(1), isNumber(2), isNumber(3)]),
              ),
            ),
          );
        });
      });
    });
  });
}
