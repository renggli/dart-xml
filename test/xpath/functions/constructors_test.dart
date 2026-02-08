import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final root = XmlDocument.parse('<root/>');
void expectEval(String expr, Object expected) =>
    expectEvaluate(root, expr, expected);
void main() {
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

  group('xs:integer aliases', () {
    test('xs:byte', () => expectEval('xs:byte("123")', [123]));
    test('xs:int', () => expectEval('xs:int("123")', [123]));
    test('xs:long', () => expectEval('xs:long("123")', [123]));
    test(
      'xs:negativeInteger',
      () => expectEval('xs:negativeInteger("-123")', [-123]),
    );
    test(
      'xs:nonNegativeInteger',
      () => expectEval('xs:nonNegativeInteger("123")', [123]),
    );
    test(
      'xs:nonPositiveInteger',
      () => expectEval('xs:nonPositiveInteger("-123")', [-123]),
    );
    test(
      'xs:positiveInteger',
      () => expectEval('xs:positiveInteger("123")', [123]),
    );
    test('xs:short', () => expectEval('xs:short("123")', [123]));
    test('xs:unsignedByte', () => expectEval('xs:unsignedByte("123")', [123]));
    test('xs:unsignedInt', () => expectEval('xs:unsignedInt("123")', [123]));
    test('xs:unsignedLong', () => expectEval('xs:unsignedLong("123")', [123]));
    test(
      'xs:unsignedShort',
      () => expectEval('xs:unsignedShort("123")', [123]),
    );
  });

  group('xs:dateTime and friends', () {
    test(
      'xs:date',
      () => expectEval('xs:date("2020-01-01")', [DateTime(2020, 1, 1)]),
    );
    test(
      'xs:dateTime',
      () => expectEval('xs:dateTime("2020-01-01T12:00:00")', [
        DateTime(2020, 1, 1, 12, 0, 0),
      ]),
    );
  });

  group('xs:duration and friends', () {
    test(
      'xs:duration',
      () => expectEval('xs:duration("P1Y2M3DT4H5M6.7S")', [
        const Duration(
          days: 365 + 60 + 3,
          hours: 4,
          minutes: 5,
          microseconds: 6700000,
        ),
      ]),
    );
    test(
      'xs:dayTimeDuration',
      () => expectEval('xs:dayTimeDuration("P3DT4H5M6.7S")', [
        const Duration(days: 3, hours: 4, minutes: 5, microseconds: 6700000),
      ]),
    );
    test(
      'xs:yearMonthDuration',
      () => expectEval('xs:yearMonthDuration("P1Y2M")', [
        const Duration(days: 365 + 60),
      ]),
    );
  });

  group('xs:hexBinary and xs:base64Binary', () {
    test(
      'xs:hexBinary',
      () => expectEval('xs:hexBinary("FF00")', [
        predicate((object) => object.toString() == '[255, 0]'),
      ]),
    );
    test(
      'xs:base64Binary',
      () => expectEval('xs:base64Binary("AP8=")', [
        predicate((object) => object.toString() == '[0, 255]'),
      ]),
    );
  });

  group('other constructors', () {
    test(
      'xs:anyURI',
      () => expectEval('xs:anyURI("http://google.com")', ['http://google.com']),
    );
    test('xs:QName', () {
      expectEval('xs:QName("foo:bar")', [
        predicate((object) => object.toString() == 'foo:bar'),
      ]);
    });
    test('xs:untypedAtomic', () {
      expectEval('xs:untypedAtomic("test")', ['test']);
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
}
