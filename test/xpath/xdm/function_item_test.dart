import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/xdm/function_item.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

final document = XmlDocument.parse('<r/>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('XPathFunctionItem', () {
    test('fn0', () {
      final f = XPathFunctionItem.fn0(
        const XmlName.qualified('my:zero'),
        (ctx) => XPathSequence.single(XPathInteger.fromInt(1)),
      );
      check(f.name).equals(const XmlName.qualified('my:zero'));
      check(f.arity).equals(0);
      check(f.isVariadic).isFalse();
      check(f.type).equals(xsFunction);
      check(f.toString()).equals('my:zero#0');
      check(f(context, [])).isXPathSequence([1]);
      check(() => f(context, [XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('fn1', () {
      final f = XPathFunctionItem.fn1(
        const XmlName.qualified('my:one'),
        (ctx, a1) => a1,
      );
      check(f.name).equals(const XmlName.qualified('my:one'));
      check(f.arity).equals(1);
      check(f.isVariadic).isFalse();
      check(f.toString()).equals('my:one#1');
      check(f(context, [const XPathSequence.single(XPathString('hello'))]))
          .isXPathSequence(['hello']);
      check(() => f(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => f(context, [XPathSequence.empty, XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('fn2', () {
      final f = XPathFunctionItem.fn2(
        const XmlName.qualified('my:two'),
        (ctx, a1, a2) => XPathSequence([...a1, ...a2]),
      );
      check(f.name).equals(const XmlName.qualified('my:two'));
      check(f.arity).equals(2);
      check(f.isVariadic).isFalse();
      check(f.toString()).equals('my:two#2');
      check(
        f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ]),
      ).isXPathSequence([1, 2]);
      check(() => f(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => f(context, [XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('fn3', () {
      final f = XPathFunctionItem.fn3(
        const XmlName.qualified('my:three'),
        (ctx, a1, a2, a3) => XPathSequence([...a1, ...a2, ...a3]),
      );
      check(f.name).equals(const XmlName.qualified('my:three'));
      check(f.arity).equals(3);
      check(f.isVariadic).isFalse();
      check(f.toString()).equals('my:three#3');
      check(
        f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
          XPathSequence.single(XPathInteger.fromInt(0)),
        ]),
      ).isXPathSequence([1, 2, 0]);
      check(() => f(context, [XPathSequence.empty, XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('fnN and function factory', () {
      final f = XPathFunctionItem.fnN(
        const XmlName.qualified('my:four'),
        4,
        (ctx, args) => XPathSequence(args.expand((s) => s)),
      );
      check(f.name).equals(const XmlName.qualified('my:four'));
      check(f.arity).equals(4);
      check(f.isVariadic).isFalse();
      check(f.toString()).equals('my:four#4');
      check(
        f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
          XPathSequence.single(XPathInteger.fromInt(0)),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ]),
      ).isXPathSequence([1, 2, 0, 1]);
      check(() => f(context, [XPathSequence.empty]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());

      final fNamed = XPathFunctionItem.function(
        name: const XmlName.qualified('my:custom'),
        arity: 1,
        function: (ctx, args) => args.first,
      );
      check(fNamed.arity).equals(1);
      check(fNamed(context, [const XPathSequence.single(XPathString('ok'))]))
          .isXPathSequence(['ok']);
    });

    test('variadic', () {
      final f = XPathFunctionItem.variadic(
        const XmlName.qualified('my:concat'),
        2,
        (ctx, args) => XPathSequence(args.expand((s) => s)),
      );
      check(f.name).equals(const XmlName.qualified('my:concat'));
      check(f.arity).equals(2);
      check(f.isVariadic).isTrue();
      check(f.toString()).equals('my:concat#2');
      check(
        f(context, [
          const XPathSequence.single(XPathString('a')),
          const XPathSequence.single(XPathString('b')),
          const XPathSequence.single(XPathString('c')),
        ]),
      ).isXPathSequence(['a', 'b', 'c']);
      check(() => f(context, [const XPathSequence.single(XPathString('a'))]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
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
      check(f.name).equals(const XmlName.qualified('my:overloaded'));
      check(f.arity).equals(0);
      check(f.isVariadic).isFalse();
      if (f is XPathOverloadedFunction) {
        check(f.getForArity(0)).isNotNull();
        check(f.getForArity(1)).isNotNull();
        check(f.getForArity(2)).isNull();
      }
      check(f(context, [])).isXPathSequence(['zero']);
      check(f(context, [XPathSequence.single(XPathInteger.fromInt(1))]))
          .isXPathSequence(['one']);
      check(
        () => f(context, [
          XPathSequence.single(XPathInteger.fromInt(1)),
          XPathSequence.single(XPathInteger.fromInt(2)),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('item methods and toValue', () {
      final f = XPathFunctionItem.fn0(
        anonymousFunctionName,
        (ctx) => XPathSequence.empty,
      );
      check(f.toString()).equals('(anonymous)#0');
      check(f.toValue()).identicalTo(f);
      check(f.returnType).isNull();
      check(f.atomize)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => f.stringValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
      check(() => f.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('typed function and overloaded signatures', () {
      final typedFn = XPathFunctionItem.fn1(
        const XmlName.qualified('typed'),
        (ctx, a) => a,
        parameterTypes: [xsInteger],
        returnType: xsInteger,
      );
      check(typedFn.returnType).equals(xsInteger);
      check(typedFn.parameterTypes).isNotNull().deepEquals([xsInteger]);
      check(typedFn.type).isA<XPathFunctionType>();

      final overloadedTyped = XPathOverloadedFunction(
        const XmlName.qualified('overloaded-typed'),
        {1: typedFn},
      );
      check(overloadedTyped.parameterTypes).isNotNull().deepEquals([xsInteger]);
      check(overloadedTyped.returnType).equals(xsInteger);
    });

    test('default returnType on base XPathFunctionItem', () {
      final custom = _CustomFunctionItem();
      check(custom.returnType).isNull();
    });
  });
}

class _CustomFunctionItem extends XPathFunctionItem {
  @override
  int get arity => 0;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) =>
      XPathSequence.empty;
}
