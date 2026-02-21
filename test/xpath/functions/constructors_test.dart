import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final root = XmlDocument.parse('<root/>');
void expectEval(String expr, Object expected) =>
    expectEvaluate(root, expr, expected);
void main() {
  group('xs:string', () {
    test('string', () {
      expectEval('xs:string("hello")', isXPathSequence(['hello']));
    });
    test('boolean', () {
      expectEval('xs:string(true())', isXPathSequence(['true']));
      expectEval('xs:string(false())', isXPathSequence(['false']));
    });
    test('number', () {
      expectEval('xs:string(123)', isXPathSequence(['123']));
      expectEval('xs:string(1.5)', isXPathSequence(['1.5']));
    });
  });

  group('xs:boolean', () {
    test('true', () {
      expectEval('xs:boolean("true")', isXPathSequence([true]));
      expectEval('xs:boolean(1)', isXPathSequence([true]));
    });
    test('false', () {
      expectEval('xs:boolean("false")', isXPathSequence([false]));
      expectEval('xs:boolean(0)', isXPathSequence([false]));
    });
  });

  group('xs:integer', () {
    test('integer string', () {
      expectEval('xs:integer("123")', isXPathSequence([123]));
      expectEval('xs:integer("  -456  ")', isXPathSequence([-456]));
    });
    test('invalid integer lexical value', () {
      expect(
        () => expectEval('xs:integer("12.34")', []),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => expectEval('xs:integer("INF")', []),
        throwsA(isA<XPathEvaluationException>()),
      );
      expect(
        () => expectEval('xs:integer("- 1")', []),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
    test('float/decimal cast to integer', () {
      expectEval('xs:integer(12.94)', isXPathSequence([12]));
      expectEval('xs:integer(-12.94)', isXPathSequence([-12]));
    });
    test('decimal', () {
      expectEval('xs:decimal("12.34")', isXPathSequence([12.34]));
    });
    test('double', () {
      expectEval('xs:double("1.23e2")', isXPathSequence([123.0]));
    });
    test('INF', () {
      expectEval('xs:double("INF")', isXPathSequence([double.infinity]));
    });
    test('minus INF', () {
      expectEval(
        'xs:double("-INF")',
        isXPathSequence([double.negativeInfinity]),
      );
    });
  });

  group('xs:integer aliases', () {
    test('xs:byte', () => expectEval('xs:byte("123")', isXPathSequence([123])));
    test('xs:int', () => expectEval('xs:int("123")', isXPathSequence([123])));
    test('xs:long', () => expectEval('xs:long("123")', isXPathSequence([123])));
    test(
      'xs:negativeInteger',
      () => expectEval('xs:negativeInteger("-123")', isXPathSequence([-123])),
    );
    test(
      'xs:nonNegativeInteger',
      () => expectEval('xs:nonNegativeInteger("123")', isXPathSequence([123])),
    );
    test(
      'xs:nonPositiveInteger',
      () =>
          expectEval('xs:nonPositiveInteger("-123")', isXPathSequence([-123])),
    );
    test(
      'xs:positiveInteger',
      () => expectEval('xs:positiveInteger("123")', isXPathSequence([123])),
    );
    test(
      'xs:short',
      () => expectEval('xs:short("123")', isXPathSequence([123])),
    );
    test(
      'xs:unsignedByte',
      () => expectEval('xs:unsignedByte("123")', isXPathSequence([123])),
    );
    test(
      'xs:unsignedInt',
      () => expectEval('xs:unsignedInt("123")', isXPathSequence([123])),
    );
    test(
      'xs:unsignedLong',
      () => expectEval('xs:unsignedLong("123")', isXPathSequence([123])),
    );
    test(
      'xs:unsignedShort',
      () => expectEval('xs:unsignedShort("123")', isXPathSequence([123])),
    );
  });

  group('xs:dateTime and friends', () {
    test(
      'xs:date',
      () => expectEval(
        'xs:date("2020-01-01")',
        isXPathSequence([DateTime(2020, 1, 1)]),
      ),
    );
    test(
      'xs:dateTime',
      () => expectEval(
        'xs:dateTime("2020-01-01T12:00:00")',
        isXPathSequence([DateTime(2020, 1, 1, 12, 0, 0)]),
      ),
    );
  });

  group('xs:duration and friends', () {
    test(
      'xs:duration',
      () => expectEval(
        'xs:duration("P1Y2M3DT4H5M6.7S")',
        isXPathSequence([
          const Duration(
            days: 365 + 60 + 3,
            hours: 4,
            minutes: 5,
            microseconds: 6700000,
          ),
        ]),
      ),
    );
    test(
      'xs:dayTimeDuration',
      () => expectEval(
        'xs:dayTimeDuration("P3DT4H5M6.7S")',
        isXPathSequence([
          const Duration(days: 3, hours: 4, minutes: 5, microseconds: 6700000),
        ]),
      ),
    );
    test(
      'xs:yearMonthDuration',
      () => expectEval(
        'xs:yearMonthDuration("P1Y2M")',
        isXPathSequence([const Duration(days: 365 + 60)]),
      ),
    );
  });

  group('xs:hexBinary and xs:base64Binary', () {
    test(
      'xs:hexBinary',
      () => expectEval(
        'xs:hexBinary("FF00")',
        isXPathSequence([
          predicate((object) => object.toString() == '[255, 0]'),
        ]),
      ),
    );
    test(
      'xs:base64Binary',
      () => expectEval(
        'xs:base64Binary("AP8=")',
        isXPathSequence([
          predicate((object) => object.toString() == '[0, 255]'),
        ]),
      ),
    );
  });

  group('other constructors', () {
    test(
      'xs:anyURI',
      () => expectEval(
        'xs:anyURI("http://google.com")',
        isXPathSequence(['http://google.com']),
      ),
    );
    test('xs:QName', () {
      expectEval(
        'xs:QName("foo:bar")',
        isXPathSequence([
          predicate((object) => object.toString() == 'foo:bar'),
        ]),
      );
    });
    test('xs:untypedAtomic', () {
      expectEval('xs:untypedAtomic("test")', isXPathSequence(['test']));
    });
  });

  group('namespace resolution', () {
    test('fn prefix', () {
      expectEval('fn:string("test")', isXPathSequence(['test']));
    });
    test('xs prefix', () {
      expectEval('xs:string("test")', isXPathSequence(['test']));
    });
    test('no prefix (default fn)', () {
      expectEval('string("test")', isXPathSequence(['test']));
    });
    test('unknown prefix', () {
      expect(() => root.xpathEvaluate('unknown:func()'), throwsA(anything));
    });
  });
}
