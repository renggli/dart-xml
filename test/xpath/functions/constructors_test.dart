import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  final root = XmlDocument.parse('<root/>');
  void expectEval(String expr, Object expected) =>
      expectEvaluate(root, expr, expected);

  group('constructors', () {
    group('xs:string', () {
      test('string', () {
        expectEval('xs:string("hello")', ['hello']);
      });
      test('boolean', () {
        expectEval('xs:string(true())', ['true']);
        expectEval('xs:string(false())', ['false']);
      });
      test('number', () {
        expectEval('xs:string(123)', ['123']);
        expectEval('xs:string(1.5)', ['1.5']);
      });
    });

    group('xs:boolean', () {
      test('true', () {
        expectEval('xs:boolean("true")', [true]);
        expectEval('xs:boolean(1)', [true]);
      });
      test('false', () {
        expectEval('xs:boolean("false")', [false]);
        expectEval('xs:boolean(0)', [false]);
      });
    });

    group('xs:integer', () {
      test('integer', () {
        expectEval('xs:integer("123")', [123]);
      });
      test('decimal', () {
        expectEval('xs:decimal("12.34")', [12.34]);
      });
      test('double', () {
        expectEval('xs:double("1.23e2")', [123.0]);
      });
      test('INF', () {
        expectEval('xs:double("INF")', [double.infinity]);
      });
      test('minus INF', () {
        expectEval('xs:double("-INF")', [double.negativeInfinity]);
      });
    });

    group('namespace resolution', () {
      test('fn prefix', () {
        expectEval('fn:string("test")', ['test']);
      });
      test('xs prefix', () {
        expectEval('xs:string("test")', ['test']);
      });
      test('no prefix (default fn)', () {
        expectEval('string("test")', ['test']);
      });
      test('unknown prefix', () {
        expect(() => root.xpathEvaluate('unknown:func()'), throwsA(anything));
      });
    });
  });
}
