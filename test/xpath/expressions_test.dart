import 'package:test/test.dart';
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
  });
}
