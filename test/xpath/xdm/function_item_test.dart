import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/xdm/atomic.dart';
import 'package:xml/src/xpath/xdm/function_item.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/src/xpath/xdm/types.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathFunctionItem', () {
    test('fn0', () {
      final f = XPathFunctionItem.fn0(
        const XmlName.qualified('my:zero'),
        (ctx) => XPathSequence.single(XPathInteger.fromInt(1)),
      );
      expect(f.name, const XmlName.qualified('my:zero'));
      expect(f.arity, 0);
      expect(f.isVariadic, isFalse);
      expect(f.type, xsFunction);
      expect(f.toString(), 'my:zero#0');
      expect(f(context, []), isXPathSequence([1]));
      expect(
        () => f(context, [XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('fn1', () {
      final f = XPathFunctionItem.fn1(
        const XmlName.qualified('my:one'),
        (ctx, a1) => a1,
      );
      expect(f.name, const XmlName.qualified('my:one'));
      expect(f.arity, 1);
      expect(f.isVariadic, isFalse);
      expect(f.toString(), 'my:one#1');
      expect(
        f(context, [const XPathSequence.single(XPathString('hello'))]),
        isXPathSequence(['hello']),
      );
      expect(() => f(context, []), throwsA(isXPathEvaluationException()));
      expect(
        () => f(context, [XPathSequence.empty, XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('fn2', () {
      final f = XPathFunctionItem.fn2(
        const XmlName.qualified('my:two'),
        (ctx, a1, a2) => XPathSequence([...a1, ...a2]),
      );
      expect(f.name, const XmlName.qualified('my:two'));
      expect(f.arity, 2);
      expect(f.isVariadic, isFalse);
      expect(f.toString(), 'my:two#2');
      expect(
        f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ]),
        isXPathSequence([1, 2]),
      );
      expect(() => f(context, []), throwsA(isXPathEvaluationException()));
      expect(
        () => f(context, [XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('fn3', () {
      final f = XPathFunctionItem.fn3(
        const XmlName.qualified('my:three'),
        (ctx, a1, a2, a3) => XPathSequence([...a1, ...a2, ...a3]),
      );
      expect(f.name, const XmlName.qualified('my:three'));
      expect(f.arity, 3);
      expect(f.isVariadic, isFalse);
      expect(f.toString(), 'my:three#3');
      expect(
        f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
          XPathSequence.single(XPathInteger.fromInt(0)),
        ]),
        isXPathSequence([1, 2, 0]),
      );
      expect(
        () => f(context, [XPathSequence.empty, XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('fnN and function factory', () {
      final f = XPathFunctionItem.fnN(
        const XmlName.qualified('my:four'),
        4,
        (ctx, args) => XPathSequence(args.expand((s) => s)),
      );
      expect(f.name, const XmlName.qualified('my:four'));
      expect(f.arity, 4);
      expect(f.isVariadic, isFalse);
      expect(f.toString(), 'my:four#4');
      expect(
        f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
          XPathSequence.single(XPathInteger.fromInt(0)),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ]),
        isXPathSequence([1, 2, 0, 1]),
      );
      expect(
        () => f(context, [XPathSequence.empty]),
        throwsA(isXPathEvaluationException()),
      );

      final fNamed = XPathFunctionItem.function(
        name: const XmlName.qualified('my:custom'),
        arity: 1,
        function: (ctx, args) => args.first,
      );
      expect(fNamed.arity, 1);
      expect(
        fNamed(context, [const XPathSequence.single(XPathString('ok'))]),
        isXPathSequence(['ok']),
      );
    });

    test('variadic', () {
      final f = XPathFunctionItem.variadic(
        const XmlName.qualified('my:concat'),
        2,
        (ctx, args) => XPathSequence(args.expand((s) => s)),
      );
      expect(f.name, const XmlName.qualified('my:concat'));
      expect(f.arity, 2);
      expect(f.isVariadic, isTrue);
      expect(f.toString(), 'my:concat#2');
      expect(
        f(context, [
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
          const XPathSequence.single(XPathString('c')),
        ]),
        isXPathSequence(['a', 'b', 'c']),
      );
      expect(
        () => f(context, [const XPathSequence.single(XPathString('a'))]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('overloaded', () {
      final f = XPathFunctionItem.overloaded(
        const XmlName.qualified('my:overloaded'),
        {
          0: XPathFunctionItem.fn0(
            const XmlName.qualified('my:overloaded'),
            (ctx) => const XPathSequence.single(XPathString('zero')),
          ),
          1: XPathFunctionItem.fn1(
            const XmlName.qualified('my:overloaded'),
            (ctx, a1) => const XPathSequence.single(XPathString('one')),
          ),
        },
      );
      expect(f.name, const XmlName.qualified('my:overloaded'));
      expect(f.arity, 0);
      expect(f.isVariadic, isFalse);
      if (f is XPathOverloadedFunction) {
        expect(f.getForArity(0), isNotNull);
        expect(f.getForArity(1), isNotNull);
        expect(f.getForArity(2), isNull);
      }
      expect(f(context, []), isXPathSequence(['zero']));
      expect(
        f(context, [XPathSequence.single(XPathInteger.fromInt(1))]),
        isXPathSequence(['one']),
      );
      expect(
        () => f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('item methods throw', () {
      final f = XPathFunctionItem.fn0(
        anonymousFunctionName,
        (ctx) => XPathSequence.empty,
      );
      expect(f.toString(), '(anonymous)#0');
      expect(f.atomize, throwsA(isXPathEvaluationException()));
      expect(() => f.stringValue, throwsA(isXPathEvaluationException()));
      expect(
        () => f.effectiveBooleanValue,
        throwsA(isXPathEvaluationException()),
      );
    });
  });
}
