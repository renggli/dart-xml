import 'package:test/test.dart';
import 'package:xml/src/xpath/expressions/types.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');

  group('instance of', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 instance of xs:integer', orderedEquals([true]));
      expectEvaluate(xml, '1 instance of xs:string', orderedEquals([false]));
      expectEvaluate(xml, "'foo' instance of xs:string", orderedEquals([true]));
      expectEvaluate(
        xml,
        "'foo' instance of xs:integer",
        orderedEquals([false]),
      );
    });

    test('sequence types', () {
      expectEvaluate(
        xml,
        '(1, 2) instance of xs:integer+',
        orderedEquals([true]),
      );
      expectEvaluate(xml, '() instance of xs:integer*', orderedEquals([true]));
      expectEvaluate(
        xml,
        '() instance of empty-sequence()',
        orderedEquals([true]),
      );
    });
  });

  group('castable as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' castable as xs:integer", orderedEquals([true]));
      expectEvaluate(
        xml,
        "'foo' castable as xs:integer",
        orderedEquals([false]),
      );
    });

    test('duration to numeric is disallowed', () {
      expectEvaluate(
        xml,
        "xs:dayTimeDuration('PT1H') castable as xs:numeric",
        orderedEquals([false]),
      );
      expectEvaluate(
        xml,
        "xs:dayTimeDuration('PT1S') castable as xs:integer",
        orderedEquals([false]),
      );
      expectEvaluate(
        xml,
        "xs:yearMonthDuration('P1Y') castable as xs:integer",
        orderedEquals([false]),
      );
      expectEvaluate(
        xml,
        "xs:yearMonthDuration('P1Y') castable as xs:dayTimeDuration",
        orderedEquals([true]),
      );
    });

    test('date with timezone to dateTime', () {
      expectEvaluate(
        xml,
        "xs:date('1970-01-01Z') castable as xs:dateTime",
        orderedEquals([true]),
      );
      expectEvaluate(
        xml,
        "xs:date('2002-03-07-05:00') castable as xs:dateTime",
        orderedEquals([true]),
      );
    });

    test('time with timezone to dateTime', () {
      expectEvaluate(
        xml,
        "xs:time('00:00:00Z') castable as xs:dateTime",
        orderedEquals([false]),
      );
      expectEvaluate(
        xml,
        "xs:time('13:20:00+05:00') castable as xs:dateTime",
        orderedEquals([false]),
      );
    });

    test('function item and map raise FOTY0013, arrays are atomized', () {
      expect(
        () => xml.xpathEvaluate('(function() { 2 }) castable as xs:integer'),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xml.xpathEvaluate('map { 1: 2 } castable as xs:integer'),
        throwsA(isXPathEvaluationException()),
      );
      expectEvaluate(
        xml,
        '[1, 2] castable as xs:integer',
        orderedEquals([false]),
      );
      expectEvaluate(xml, '[5] castable as xs:integer', orderedEquals([true]));
      expectEvaluate(xml, '[] castable as xs:integer?', orderedEquals([true]));
      expectEvaluate(xml, '[] castable as xs:integer', orderedEquals([false]));
      expect(
        () => xml.xpathEvaluate('[map { 1: 2 }] castable as xs:integer'),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('abstract target types raise XPST0080', () {
      expect(
        () => xml.xpathEvaluate('1 castable as xs:anyAtomicType'),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('cast as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' cast as xs:integer", orderedEquals([1]));
      expectEvaluate(xml, '1 cast as xs:string', orderedEquals(['1']));
    });

    test('abstract target types raise XPST0080', () {
      expect(
        () => xml.xpathEvaluate('1 cast as xs:anyAtomicType'),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('array operand is atomized', () {
      expectEvaluate(xml, '[5] cast as xs:integer', orderedEquals([5]));
      expect(
        () => xml.xpathEvaluate('[1, 2] cast as xs:integer'),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('duration to numeric is disallowed', () {
      expect(
        () => xml.xpathEvaluate("xs:numeric(xs:dayTimeDuration('PT1S'))"),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xml.xpathEvaluate("xs:integer(xs:dayTimeDuration('PT1S'))"),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xml.xpathEvaluate("xs:double(xs:dayTimeDuration('PT1S'))"),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('xs:date with timezone to xs:dateTime', () {
      // Date with Z timezone
      expectEvaluate(xml, "xs:dateTime(xs:date('1970-01-01Z'))", isNotEmpty);
      // Date with timezone offset
      expectEvaluate(
        xml,
        "xs:dateTime(xs:date('2002-03-07-05:00'))",
        isNotEmpty,
      );
    });

    test('xs:time with timezone to xs:dateTime', () {
      expect(
        () => xml.xpathEvaluate("xs:dateTime(xs:time('00:00:00Z'))"),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xml.xpathEvaluate("xs:dateTime(xs:time('13:20:00+05:00'))"),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('treat as', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 treat as xs:integer', orderedEquals([1]));
    });
    test('failure', () {
      expect(
        () => xml.xpathEvaluate("'foo' treat as xs:integer"),
        throwsA(isXPathEvaluationException(message: contains('Expected'))),
      );
    });
  });

  group('inline function typed parameters', () {
    test('XPTY0004: parameter type mismatch at runtime', () {
      expect(
        () => xml.xpathEvaluate(
          '(function(\$x as xs:integer) { \$x })(\'hello\')',
        ),
        throwsA(isXPathEvaluationException(message: contains('XPTY0004'))),
      );
    });

    test('no error when declared type matches', () {
      expectEvaluate(
        xml,
        '(function(\$x as xs:integer) { \$x })(42)',
        orderedEquals([42]),
      );
    });

    test('no error when parameter is untyped', () {
      expectEvaluate(
        xml,
        "(function(\$x) { \$x })('hello')",
        orderedEquals(['hello']),
      );
    });

    test('instance of typed function type', () {
      // Typed inline function satisfies the declared signature.
      expectEvaluate(
        xml,
        'function(\$x as xs:integer) as xs:integer { \$x } '
        'instance of function(xs:integer) as xs:integer',
        orderedEquals([true]),
      );
      // Wrong declared return type is not a match.
      expectEvaluate(
        xml,
        'function(\$x as xs:integer) as xs:integer { \$x } '
        'instance of function(xs:integer) as xs:string',
        orderedEquals([false]),
      );
    });
  });

  group('XPST0051', () {
    test('unknown type in instance of raises parser error', () {
      expect(
        () => xml.xpathEvaluate('1 instance of xs:unknownType'),
        throwsA(isA<XPathParserException>()),
      );
    });

    test('bare NCName in instance of raises parser error', () {
      expect(
        () => xml.xpathEvaluate('1 instance of integer'),
        throwsA(isA<XPathParserException>()),
      );
    });
  });

  group('cast empty sequence', () {
    test('optional sequence type returns empty', () {
      expectEvaluate(xml, '() cast as xs:integer?', isEmpty);
    });

    test('required sequence type throws XPTY0004', () {
      expect(
        () => xml.xpathEvaluate('() cast as xs:integer'),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });
  });

  group('direct CastExpression and CastableExpression', () {
    final context = XPathConfiguration.standard().context();
    test('CastExpression with atomic type', () {
      const expr = CastExpression(
        LiteralExpression(XPathSequence.single(XPathString('42'))),
        xsInteger,
      );
      expect(expr(context), isXPathSequence([42]));

      final multiExpr = CastExpression(
        LiteralExpression(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        xsInteger,
      );
      expect(
        () => multiExpr(context),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('CastableExpression with atomic type', () {
      const expr = CastableExpression(
        LiteralExpression(XPathSequence.single(XPathString('42'))),
        xsInteger,
      );
      expect(expr(context), isXPathSequence([true]));

      final multiExpr = CastableExpression(
        LiteralExpression(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        xsInteger,
      );
      expect(multiExpr(context), isXPathSequence([false]));
    });
  });
}
