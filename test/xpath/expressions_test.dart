import 'package:test/test.dart';
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
  });
}
