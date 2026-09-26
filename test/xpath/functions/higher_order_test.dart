import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/accessor.dart';
import 'package:xml/src/xpath/functions/higher_order.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathConfiguration().context(document);

void main() {
  group('fn:sort', () {
    test('sorts numbers', () {
      expect(
        fnSort(context, [
          seq([3, 1, 2]),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });

    test('sorts strings', () {
      expect(
        fnSort(context, [
          seq(['b', 'a', 'c']),
        ]),
        isXPathSequence(['a', 'b', 'c']),
      );
    });

    test('sorts with key function', () {
      expect(
        fnSort(context, [
          seq(['apple', 'be', 'cat']),
          XPathSequence.empty, // collation
          seq((XPathContext context, List<XPathSequence> args) {
            final arg = args[0].first.stringValue;
            return seq(arg.length);
          }),
        ]),
        isXPathSequence(['be', 'cat', 'apple']),
      );
    });

    test('sorts with 2 arguments (collation)', () {
      expect(
        fnSort(context, [
          seq(['b', 'a']),
          const XPathSequence.single(
            XPathString(
              'http://www.w3.org/2005/xpath-functions/collation/codepoint',
            ),
          ),
        ]),
        isXPathSequence(['a', 'b']),
      );
    });

    test('sorts with key function returning empty', () {
      expect(
        fnSort(context, [
          seq([2, 1]),
          XPathSequence.empty,
          seq((XPathContext context, List<XPathSequence> args) {
            final arg = (args[0].first as XPathInteger).asInt;
            return arg == 2 ? XPathSequence.empty : seq(arg);
          }),
        ]),
        isXPathSequence([2, 1]),
      );
      expect(
        fnSort(context, [
          seq([1, 2, 3]),
          XPathSequence.empty,
          seq((XPathContext context, List<XPathSequence> args) {
            final arg = (args[0].first as XPathInteger).asInt;
            return arg == 2 ? XPathSequence.empty : seq(arg);
          }),
        ]),
        isXPathSequence([2, 1, 3]),
      );
    });
  });

  group('fn:apply', () {
    test('applies function', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) {
        final a = (args[0].first as XPathInteger).asInt;
        final b = (args[1].first as XPathInteger).asInt;
        return seq(a + b);
      }

      expect(
        fnApply(context, [
          seq(add),
          XPathSequence.single(toXPathItem([1, 2])),
        ]),
        isXPathSequence([3]),
      );
    });

    test('apply with nested array and data#1 (fn-apply-11)', () {
      expect(
        fnApply(context, [
          XPathSequence.single(fnData),
          XPathSequence.single(
            toXPathItem([
              [1, 2, 3],
            ]),
          ),
        ]),
        isXPathSequence([1, 2, 3]),
      );
    });
  });

  group('fn:for-each', () {
    test('applies function to each item', () {
      XPathSequence double(XPathContext context, List<XPathSequence> args) {
        final arg = (args[0].first as XPathInteger).asInt;
        return seq(arg * 2);
      }

      expect(
        fnForEach(context, [
          seq([1, 2, 3]),
          seq(double),
        ]),
        isXPathSequence([2, 4, 6]),
      );
    });
  });

  group('fn:filter', () {
    test('filters items', () {
      XPathSequence isEven(XPathContext context, List<XPathSequence> args) {
        final arg = (args[0].first as XPathInteger).asInt;
        return seq(arg % 2 == 0);
      }

      expect(
        fnFilter(context, [
          seq([1, 2, 3, 4]),
          seq(isEven),
        ]),
        isXPathSequence([2, 4]),
      );
    });
  });

  group('fn:fold-left', () {
    test('processes list from left', () {
      XPathSequence add(XPathContext context, List<XPathSequence> args) {
        final acc = (args[0].single as XPathInteger).asInt;
        final item = (args[1].single as XPathInteger).asInt;
        return seq(acc + item);
      }

      expect(
        fnFoldLeft(context, [
          seq([1, 2, 3, 4, 5]),
          seq(0),
          seq(add),
        ]),
        isXPathSequence([15]),
      );
    });
  });

  group('fn:fold-right', () {
    test('processes list from right', () {
      XPathSequence sub(XPathContext context, List<XPathSequence> args) {
        final item = (args[0].single as XPathInteger).asInt;
        final acc = (args[1].single as XPathInteger).asInt;
        return seq(item - acc);
      }

      expect(
        fnFoldRight(context, [
          seq([1, 2, 3, 4, 5]),
          seq(0),
          seq(sub),
        ]),
        isXPathSequence([3]),
      );
    });
  });

  group('fn:for-each-pair', () {
    test('applies function to pairs', () {
      XPathSequence concat(XPathContext context, List<XPathSequence> args) {
        final a = args[0].first.stringValue;
        final b = args[1].first.stringValue;
        return seq('$a$b');
      }

      expect(
        fnForEachPair(context, [
          seq(['a', 'b', 'c']),
          seq(['1', '2', '3']),
          seq(concat),
        ]),
        isXPathSequence(['a1', 'b2', 'c3']),
      );
    });
  });

  group('fn:function-lookup', () {
    test('known function by prefixed name', () {
      final result = fnFunctionLookup(context, [
        seq(const XmlName.qualified('fn:abs')),
        seq(1),
      ]);
      expect(result, isXPathSequence([isA<XPathFunctionItem>()]));
    });
    test('known function by short name', () {
      final result = fnFunctionLookup(context, [
        seq(const XmlName.qualified('abs')),
        seq(1),
      ]);
      expect(result, isXPathSequence([isA<XPathFunctionItem>()]));
    });

    test('unknown function returns empty', () {
      final result = fnFunctionLookup(context, [
        seq(const XmlName.qualified('nonexistent')),
        seq(1),
      ]);
      expect(result, isEmpty);
    });

    test('absent namespace does not match standard function', () {
      expect(
        document.xpathEvaluate('function-lookup(QName("", "round"), 2)'),
        isEmpty,
      );
    });

    test('negative arity returns empty', () {
      expect(
        document.xpathEvaluate('function-lookup(xs:QName("fn:abs"), -1)'),
        isEmpty,
      );
    });

    test('invalid argument cardinality throws XPTY0004', () {
      expect(
        () => document.xpathEvaluate(
          'function-lookup((xs:QName("fn:abs"), xs:QName("fn:abs")), 1)',
        ),
        throwsA(isXPathEvaluationException(message: contains('XPTY0004'))),
      );
      expect(
        () => document.xpathEvaluate('function-lookup(xs:QName("fn:abs"), ())'),
        throwsA(isXPathEvaluationException(message: contains('XPTY0004'))),
      );
    });

    test('invalid argument types throw XPTY0004', () {
      expect(
        () => fnFunctionLookup(context, [
          const XPathSequence.single(XPathString('fn:abs')),
          XPathSequence.single(XPathInteger.fromInt(1)),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => fnFunctionLookup(context, [
          const XPathSequence.single(XPathQName(XmlName('abs', 'fn'))),
          const XPathSequence.single(XPathString('1')),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('lookup and call arity 0 function', () {
      expect(
        document.xpathEvaluate('function-lookup(xs:QName("fn:true"), 0)()'),
        isXPathSequence([true]),
      );
    });

    test('integration via xpathEvaluate', () {
      expect(
        document.xpathEvaluate('function-lookup(xs:QName("fn:abs"), 1)(-42)'),
        isXPathSequence([42]),
      );
    });
  });

  group('fn:function-name', () {
    test('returns empty for anonymous function', () {
      expect(
        fnFunctionName(context, [
          seq(
            (XPathContext context, List<XPathSequence> args) =>
                XPathSequence.empty,
          ),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns empty for inline function', () {
      expect(
        document.xpathEvaluate('function-name(function(\$x) { \$x })'),
        isEmpty,
      );
    });

    test('returns QName with namespace for named function ref', () {
      final result = document.xpathEvaluate('function-name(fn:abs#1)');
      expect(result.length, equals(1));
      final qname = result.first as XPathQName;
      expect(qname.value.local, equals('abs'));
      expect(
        qname.value.namespaceUri,
        equals('http://www.w3.org/2005/xpath-functions'),
      );
    });
  });

  group('fn:function-arity', () {
    test('returns arity', () {
      expect(
        fnFunctionArity(context, [
          seq(
            (XPathContext context, List<XPathSequence> args) =>
                XPathSequence.empty,
          ),
        ]),
        isXPathSequence([0]),
      );
    });
  });

  group('fn:load-xquery-module', () {
    test('unimplemented without options', () {
      expect(
        () => fnLoadXqueryModule(context, [seq('uri')]),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('unimplemented with options', () {
      expect(
        () => fnLoadXqueryModule(context, [
          seq('uri'),
          const XPathSequence.single(XPathMap.empty),
        ]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('fn:transform', () {
    test('unimplemented', () {
      expect(
        () =>
            fnTransform(context, [const XPathSequence.single(XPathMap.empty)]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
