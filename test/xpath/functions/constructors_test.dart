import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

final root = XmlDocument.parse('<root/>');
void expectEval(String expr, Object expected) =>
    expectEvaluate(root, expr, expected);
void main() {
  group('xs:string', () {
    test('string', () {
      expectEval('xs:string("hello")', isXPathSequence(['hello']));
    });
    test('no arguments', () {
      expectEval('xs:string()', isXPathSequence(isEmpty));
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
    test('no arguments', () {
      expectEval('xs:boolean()', isXPathSequence(isEmpty));
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
      check(() => expectEval('xs:integer("12.34")', []))
          .throws<XPathEvaluationException>();
      check(() => expectEval('xs:integer("INF")', []))
          .throws<XPathEvaluationException>();
      check(() => expectEval('xs:integer("- 1")', []))
          .throws<XPathEvaluationException>();
    });

    test('float/decimal cast to integer', () {
      expectEval('xs:integer(12.94)', isXPathSequence([12]));
      expectEval('xs:integer(-12.94)', isXPathSequence([-12]));
    });
  });

  group('xs:decimal', () {
    test('decimal string', () {
      expectEval('xs:decimal("12.34")', isXPathSequence([12.34]));
    });
  });

  group('xs:double', () {
    test('double string', () {
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

  group('xs:byte', () {
    test('cast', () => expectEval('xs:byte("123")', isXPathSequence([123])));
  });

  group('xs:int', () {
    test('cast', () => expectEval('xs:int("123")', isXPathSequence([123])));
  });

  group('xs:long', () {
    test('cast', () => expectEval('xs:long("123")', isXPathSequence([123])));
  });

  group('xs:negativeInteger', () {
    test(
      'cast',
      () => expectEval('xs:negativeInteger("-123")', isXPathSequence([-123])),
    );
  });

  group('xs:nonNegativeInteger', () {
    test(
      'cast',
      () => expectEval('xs:nonNegativeInteger("123")', isXPathSequence([123])),
    );
  });

  group('xs:nonPositiveInteger', () {
    test(
      'cast',
      () =>
          expectEval('xs:nonPositiveInteger("-123")', isXPathSequence([-123])),
    );
  });

  group('xs:positiveInteger', () {
    test(
      'cast',
      () => expectEval('xs:positiveInteger("123")', isXPathSequence([123])),
    );
  });

  group('xs:short', () {
    test('cast', () => expectEval('xs:short("123")', isXPathSequence([123])));
  });

  group('xs:unsignedByte', () {
    test(
      'cast',
      () => expectEval('xs:unsignedByte("123")', isXPathSequence([123])),
    );
  });

  group('xs:unsignedInt', () {
    test(
      'cast',
      () => expectEval('xs:unsignedInt("123")', isXPathSequence([123])),
    );
  });

  group('xs:unsignedLong', () {
    test(
      'cast',
      () => expectEval('xs:unsignedLong("123")', isXPathSequence([123])),
    );
  });

  group('xs:unsignedShort', () {
    test(
      'cast',
      () => expectEval('xs:unsignedShort("123")', isXPathSequence([123])),
    );
  });

  group('xs:date', () {
    test(
      'cast',
      () => expectEval(
        'xs:date("2020-01-01")',
        isXPathSequence([const XPathDateTime.date(2020, 1, 1)]),
      ),
    );
  });

  group('xs:dateTime', () {
    test(
      'cast',
      () => expectEval(
        'xs:dateTime("2020-01-01T12:00:00")',
        isXPathSequence([const XPathDateTime(2020, 1, 1, 12, 0, 0)]),
      ),
    );
  });

  group('xs:duration', () {
    test('cast', () {
      // P1Y2M3DT4H5M6.7S → months=14, dayTime=3D4H5M6.7S
      final d = XPathDuration.tryParse('P1Y2M3DT4H5M6.7S');
      expectEval('xs:duration("P1Y2M3DT4H5M6.7S")', isXPathSequence([d]));
    });
    test('invalid cast throws', () {
      check(() => expectEval('xs:duration("P")', []))
          .throws<XPathEvaluationException>();
      check(() => expectEval('xs:duration("1Y")', []))
          .throws<XPathEvaluationException>();
    });
  });

  group('xs:dayTimeDuration', () {
    test('cast', () {
      expectEval(
        'xs:dayTimeDuration("P3DT4H5M6.7S")',
        isXPathSequence([
          XPathDuration.fromDuration(
            const Duration(
              days: 3,
              hours: 4,
              minutes: 5,
              microseconds: 6700000,
            ),
          ),
        ]),
      );
    });
    test('invalid cast throws', () {
      check(() => expectEval('xs:dayTimeDuration("P1Y2M3D")', []))
          .throws<XPathEvaluationException>();
      check(() => expectEval('xs:dayTimeDuration("P3DT4H5M6.7S1")', []))
          .throws<XPathEvaluationException>();
    });
  });

  group('xs:yearMonthDuration', () {
    test('cast', () {
      expectEval(
        'xs:yearMonthDuration("P1Y2M")',
        isXPathSequence([
          const XPathDuration.yearMonth(14),
        ]), // 1*12 + 2 = 14 months
      );
    });
    test('cast negative', () {
      expectEval(
        'xs:yearMonthDuration("-P1Y2M")',
        isXPathSequence([const XPathDuration.yearMonth(-14)]),
      );
    });
    test('invalid cast throws', () {
      check(() => expectEval('xs:yearMonthDuration("P1Y2M3D")', []))
          .throws<XPathEvaluationException>();
      check(() => expectEval('xs:yearMonthDuration("invalid")', []))
          .throws<XPathEvaluationException>();
    });
  });

  group('xs:hexBinary', () {
    test(
      'cast',
      () => expectEval(
        'xs:hexBinary("FF00")',
        isXPathSequence([
          (Subject<Object?> s) =>
              s.has((o) => o.toString(), 'toString()').equals('[255, 0]'),
        ]),
      ),
    );
  });

  group('xs:base64Binary', () {
    test(
      'cast',
      () => expectEval(
        'xs:base64Binary("AP8=")',
        isXPathSequence([
          (Subject<Object?> s) =>
              s.has((o) => o.toString(), 'toString()').equals('[0, 255]'),
        ]),
      ),
    );
  });

  group('xs:anyURI', () {
    test(
      'cast',
      () => expectEval(
        'xs:anyURI("http://google.com")',
        isXPathSequence(['http://google.com']),
      ),
    );
  });

  group('xs:QName', () {
    test('cast', () {
      expectEval(
        'xs:QName("foo:bar")',
        isXPathSequence([
          (Subject<Object?> s) =>
              s.has((o) => o.toString(), 'toString()').equals('foo:bar'),
        ]),
      );
    });
  });

  group('xs:untypedAtomic', () {
    test('cast', () {
      expectEval(
        'xs:untypedAtomic("test")',
        isXPathSequence([const XPathUntypedAtomic('test')]),
      );
    });
  });

  group('xs:normalizedString', () {
    test('replace whitespace', () {
      expectEval(
        'xs:normalizedString(concat("hello", codepoints-to-string(9), "world", codepoints-to-string(10), "new", codepoints-to-string(13), "line"))',
        isXPathSequence(['hello world new line']),
      );
    });
    test('empty sequence', () {
      expectEval('xs:normalizedString(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:token', () {
    test('collapse whitespace', () {
      expectEval(
        'xs:token(concat(" ", codepoints-to-string(9), " hello ", codepoints-to-string(10), codepoints-to-string(13), " world ", codepoints-to-string(9), " "))',
        isXPathSequence(['hello world']),
      );
    });
    test('empty sequence', () {
      expectEval('xs:token(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:language', () {
    test('valid language', () {
      expectEval('xs:language("en-US")', isXPathSequence(['en-US']));
      expectEval(
        'xs:language(concat("  ", codepoints-to-string(9), " en-US ", codepoints-to-string(10), " "))',
        isXPathSequence(['en-US']),
      );
    });
    test('invalid language', () {
      check(() => expectEval('xs:language("invalid_123")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:language(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:NMTOKEN', () {
    test('valid NMTOKEN', () {
      expectEval(
        'xs:NMTOKEN("some-token.123")',
        isXPathSequence(['some-token.123']),
      );
    });
    test('invalid NMTOKEN', () {
      check(() => expectEval('xs:NMTOKEN("invalid token")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:NMTOKEN(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:Name', () {
    test('valid Name', () {
      expectEval(
        'xs:Name("_valid-Name.123")',
        isXPathSequence(['_valid-Name.123']),
      );
      expectEval('xs:Name("prefix:local")', isXPathSequence(['prefix:local']));
    });
    test('invalid Name', () {
      check(() => expectEval('xs:Name("-invalid")', []))
          .throws<XPathEvaluationException>();
      check(() => expectEval('xs:Name("invalid name")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:Name(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:NCName', () {
    test('valid NCName', () {
      expectEval(
        'xs:NCName("_valid-NCName.123")',
        isXPathSequence(['_valid-NCName.123']),
      );
    });
    test('invalid NCName', () {
      check(() => expectEval('xs:NCName("prefix:local")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:NCName(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:ID', () {
    test('valid ID', () {
      expectEval('xs:ID("my-id")', isXPathSequence(['my-id']));
    });
    test('invalid ID', () {
      check(() => expectEval('xs:ID("invalid:id")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:ID(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:IDREF', () {
    test('valid IDREF', () {
      expectEval('xs:IDREF("my-idref")', isXPathSequence(['my-idref']));
    });
    test('invalid IDREF', () {
      check(() => expectEval('xs:IDREF("invalid:idref")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:IDREF(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:ENTITY', () {
    test('valid ENTITY', () {
      expectEval('xs:ENTITY("my-entity")', isXPathSequence(['my-entity']));
    });
    test('invalid ENTITY', () {
      check(() => expectEval('xs:ENTITY("invalid:entity")', []))
          .throws<XPathEvaluationException>();
    });
    test('empty sequence', () {
      expectEval('xs:ENTITY(())', isXPathSequence(isEmpty));
    });
  });

  group('xs:error', () {
    test('empty sequence returns empty', () {
      expectEval('xs:error(())', isXPathSequence(isEmpty));
    });
    test('invalid arity 0 throws', () {
      check(() => root.xpathEvaluate('xs:error()').toList())
          .throws<XPathEvaluationException>();
    });
    test('invalid arity 2 throws', () {
      check(() => root.xpathEvaluate('xs:error((), ())').toList())
          .throws<XPathEvaluationException>();
    });
    test('non-empty argument throws', () {
      check(() => root.xpathEvaluate('xs:error(1)').toList())
          .throws<XPathEvaluationException>();
      check(() => root.xpathEvaluate('xs:error("test")').toList())
          .throws<XPathEvaluationException>();
    });
    test('cast to xs:error throws', () {
      check(() => root.xpathEvaluate('1 cast as xs:error').toList())
          .throws<XPathEvaluationException>();
    });
    test('castable as xs:error', () {
      expectEval('1 castable as xs:error', isXPathSequence([false]));
      expectEval('() castable as xs:error?', isXPathSequence([true]));
    });
  });

  group('xs:numeric', () {
    test('no arguments', () {
      expectEval('xs:numeric()', isXPathSequence(isEmpty));
    });
    test('numeric', () {
      expectEval('xs:numeric(42)', isXPathSequence([42]));
    });
  });

  group('list constructors', () {
    test('xs:NMTOKENS', () {
      expectEval('xs:NMTOKENS()', isXPathSequence(isEmpty));
      expectEval('xs:NMTOKENS(())', isXPathSequence(isEmpty));
      expectEval('xs:NMTOKENS("   ")', isXPathSequence(isEmpty));
      expectEval('xs:NMTOKENS("a b c")', isXPathSequence(['a', 'b', 'c']));
    });
    test('xs:IDREFS', () {
      expectEval('xs:IDREFS("id1 id2")', isXPathSequence(['id1', 'id2']));
    });
    test('xs:ENTITIES', () {
      expectEval('xs:ENTITIES("e1 e2")', isXPathSequence(['e1', 'e2']));
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
      check(() => root.xpathEvaluate('unknown:func()'))
          .throws<XPathEvaluationException>();
    });
  });
}
