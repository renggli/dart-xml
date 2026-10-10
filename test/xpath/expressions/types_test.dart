import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/expressions/types.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');

  group('instance of', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 instance of xs:integer', [true]);
      expectEvaluate(xml, '1 instance of xs:string', [false]);
      expectEvaluate(xml, "'foo' instance of xs:string", [true]);
      expectEvaluate(xml, "'foo' instance of xs:integer", [false]);
    });

    test('sequence types', () {
      expectEvaluate(xml, '(1, 2) instance of xs:integer+', [true]);
      expectEvaluate(xml, '() instance of xs:integer*', [true]);
      expectEvaluate(xml, '() instance of empty-sequence()', [true]);
    });
  });

  group('castable as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' castable as xs:integer", [true]);
      expectEvaluate(xml, "'foo' castable as xs:integer", [false]);
    });

    test('duration to numeric is disallowed', () {
      expectEvaluate(xml, "xs:dayTimeDuration('PT1H') castable as xs:numeric", [
        false,
      ]);
      expectEvaluate(xml, "xs:dayTimeDuration('PT1S') castable as xs:integer", [
        false,
      ]);
      expectEvaluate(
        xml,
        "xs:yearMonthDuration('P1Y') castable as xs:integer",
        [false],
      );
      expectEvaluate(
        xml,
        "xs:yearMonthDuration('P1Y') castable as xs:dayTimeDuration",
        [true],
      );
    });

    test('date with timezone to dateTime', () {
      expectEvaluate(xml, "xs:date('1970-01-01Z') castable as xs:dateTime", [
        true,
      ]);
      expectEvaluate(
        xml,
        "xs:date('2002-03-07-05:00') castable as xs:dateTime",
        [true],
      );
    });

    test('time with timezone to dateTime', () {
      expectEvaluate(xml, "xs:time('00:00:00Z') castable as xs:dateTime", [
        false,
      ]);
      expectEvaluate(xml, "xs:time('13:20:00+05:00') castable as xs:dateTime", [
        false,
      ]);
    });

    test('function item and map raise FOTY0013, arrays are atomized', () {
      check(
        () => xml.xpathEvaluate('(function() { 2 }) castable as xs:integer'),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
      check(() => xml.xpathEvaluate('map { 1: 2 } castable as xs:integer'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      expectEvaluate(xml, '[1, 2] castable as xs:integer', [false]);
      expectEvaluate(xml, '[5] castable as xs:integer', [true]);
      expectEvaluate(xml, '[] castable as xs:integer?', [true]);
      expectEvaluate(xml, '[] castable as xs:integer', [false]);
      check(() => xml.xpathEvaluate('[map { 1: 2 }] castable as xs:integer'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('abstract target types raise XPST0080', () {
      check(() => xml.xpathEvaluate('1 castable as xs:anyAtomicType'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('cast as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' cast as xs:integer", [1]);
      expectEvaluate(xml, '1 cast as xs:string', ['1']);
    });

    test('abstract target types raise XPST0080', () {
      check(() => xml.xpathEvaluate('1 cast as xs:anyAtomicType'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('array operand is atomized', () {
      expectEvaluate(xml, '[5] cast as xs:integer', [5]);
      check(() => xml.xpathEvaluate('[1, 2] cast as xs:integer'))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('duration to numeric is disallowed', () {
      check(() => xml.xpathEvaluate("xs:numeric(xs:dayTimeDuration('PT1S'))"))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => xml.xpathEvaluate("xs:integer(xs:dayTimeDuration('PT1S'))"))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => xml.xpathEvaluate("xs:double(xs:dayTimeDuration('PT1S'))"))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('xs:date with timezone to xs:dateTime', () {
      // Date with Z timezone
      check(xml.xpathEvaluate("xs:dateTime(xs:date('1970-01-01Z'))"))
          .isNotEmpty();
      // Date with timezone offset
      check(xml.xpathEvaluate("xs:dateTime(xs:date('2002-03-07-05:00'))"))
          .isNotEmpty();
    });

    test('xs:time with timezone to xs:dateTime', () {
      check(() => xml.xpathEvaluate("xs:dateTime(xs:time('00:00:00Z'))"))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => xml.xpathEvaluate("xs:dateTime(xs:time('13:20:00+05:00'))"))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });
  });

  group('treat as', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 treat as xs:integer', [1]);
    });
    test('failure', () {
      check(() => xml.xpathEvaluate("'foo' treat as xs:integer"))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Expected'));
    });
  });

  group('inline function typed parameters', () {
    test('XPTY0004: parameter type mismatch at runtime', () {
      check(
            () => xml.xpathEvaluate(
              '(function(\$x as xs:integer) { \$x })(\'hello\')',
            ),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XPTY0004'));
    });

    test('no error when declared type matches', () {
      expectEvaluate(xml, '(function(\$x as xs:integer) { \$x })(42)', [42]);
    });

    test('no error when parameter is untyped', () {
      expectEvaluate(xml, "(function(\$x) { \$x })('hello')", ['hello']);
    });

    test('instance of typed function type', () {
      // Typed inline function satisfies the declared signature.
      expectEvaluate(
        xml,
        'function(\$x as xs:integer) as xs:integer { \$x } '
        'instance of function(xs:integer) as xs:integer',
        [true],
      );
      // Wrong declared return type is not a match.
      expectEvaluate(
        xml,
        'function(\$x as xs:integer) as xs:integer { \$x } '
        'instance of function(xs:integer) as xs:string',
        [false],
      );
    });
  });

  group('XPST0051', () {
    test('unknown type in instance of raises parser error', () {
      check(() => xml.xpathEvaluate('1 instance of xs:unknownType'))
          .throws<XPathParserException>();
    });

    test('bare NCName in instance of raises parser error', () {
      check(() => xml.xpathEvaluate('1 instance of integer'))
          .throws<XPathParserException>();
    });
  });

  group('cast empty sequence', () {
    test('optional sequence type returns empty', () {
      expectEvaluate(xml, '() cast as xs:integer?', isEmpty);
    });

    test('required sequence type throws XPTY0004', () {
      check(() => xml.xpathEvaluate('() cast as xs:integer'))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
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
      check(expr(context)).isXPathSequence([42]);

      final multiExpr = CastExpression(
        LiteralExpression(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        xsInteger,
      );
      check(() => multiExpr(context)).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });

    test('CastableExpression with atomic type', () {
      const expr = CastableExpression(
        LiteralExpression(XPathSequence.single(XPathString('42'))),
        xsInteger,
      );
      check(expr(context)).isXPathSequence([true]);

      final multiExpr = CastableExpression(
        LiteralExpression(
          XPathSequence([XPathInteger.fromInt(1), XPathInteger.fromInt(2)]),
        ),
        xsInteger,
      );
      check(multiExpr(context)).isXPathSequence([false]);
    });
  });
}
