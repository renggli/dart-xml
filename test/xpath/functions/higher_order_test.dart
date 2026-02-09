import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/higher_order.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:sort', () {
    expect(
      fnSort(context, [
        const XPathSequence([3, 1, 2]),
      ]),
      isXPathSequence(const XPathSequence([1, 2, 3])),
    );
    expect(
      fnSort(context, [
        const XPathSequence(['b', 'a', 'c']),
      ]),
      isXPathSequence(const XPathSequence(['a', 'b', 'c'])),
    );
    // Sort with key
    expect(
      fnSort(context, [
        const XPathSequence(['apple', 'be', 'cat']),
        XPathSequence.empty, // collation
        XPathSequence.single((XPathContext context, List<XPathSequence> args) {
          final arg = args[0];
          return XPathSequence.single(xsString.cast(arg).length);
        }),
      ]),
      isXPathSequence(const XPathSequence(['be', 'cat', 'apple'])),
    );
  });
  test('fn:apply', () {
    XPathSequence add(XPathContext context, List<XPathSequence> args) {
      final a = args[0];
      final b = args[1];
      return XPathSequence.single((a.first as num) + (b.first as num));
    }

    expect(
      fnApply(context, [
        XPathSequence.single(add),
        const XPathSequence.single([1, 2]),
      ]),
      isXPathSequence([3]),
    );
  });
  test('fn:for-each', () {
    XPathSequence double(XPathContext context, List<XPathSequence> args) {
      final arg = args[0];
      return XPathSequence.single((arg.first as num) * 2);
    }

    expect(
      fnForEach(context, [
        const XPathSequence([1, 2, 3]),
        XPathSequence.single(double),
      ]),
      isXPathSequence([2, 4, 6]),
    );
  });
  test('fn:filter', () {
    XPathSequence isEven(XPathContext context, List<XPathSequence> args) {
      final arg = args[0];
      return XPathSequence.single((arg.first as num) % 2 == 0);
    }

    expect(
      fnFilter(context, [
        const XPathSequence([1, 2, 3, 4]),
        XPathSequence.single(isEven),
      ]),
      isXPathSequence([2, 4]),
    );
  });
  test('fn:fold-left', () {
    XPathSequence add(XPathContext context, List<XPathSequence> args) {
      final acc = args[0];
      final item = args[1];
      return XPathSequence.single((acc.single as num) + (item.single as num));
    }

    expect(
      fnFoldLeft(context, [
        const XPathSequence([1, 2, 3, 4, 5]),
        const XPathSequence.single(0),
        XPathSequence.single(add),
      ]),
      isXPathSequence([15]),
    );
  });
  test('fn:fold-right', () {
    XPathSequence sub(XPathContext context, List<XPathSequence> args) {
      final item = args[0];
      final acc = args[1];
      return XPathSequence.single((item.single as num) - (acc.single as num));
    }

    expect(
      fnFoldRight(context, [
        const XPathSequence([1, 2, 3, 4, 5]),
        const XPathSequence.single(0),
        XPathSequence.single(sub),
      ]),
      isXPathSequence([3]),
    );
  });
  test('fn:for-each-pair', () {
    XPathSequence concat(XPathContext context, List<XPathSequence> args) {
      final a = args[0];
      final b = args[1];
      return XPathSequence.single(xsString.cast(a) + xsString.cast(b));
    }

    expect(
      fnForEachPair(context, [
        const XPathSequence(['a', 'b', 'c']),
        const XPathSequence(['1', '2', '3']),
        XPathSequence.single(concat),
      ]),
      isXPathSequence(['a1', 'b2', 'c3']),
    );
  });
  test('fn:function-lookup', () {
    expect(
      () => fnFunctionLookup(context, [
        const XPathSequence.single('name'),
        const XPathSequence.single(1),
      ]),
      throwsA(isA<UnimplementedError>()),
    );
  });
  test('fn:function-name', () {
    expect(
      fnFunctionName(context, [
        XPathSequence.single(
          (XPathContext context, List<XPathSequence> args) =>
              XPathSequence.empty,
        ),
      ]),
      isXPathSequence(isEmpty),
    );
  });
  test('fn:function-arity', () {
    expect(
      fnFunctionArity(context, [
        XPathSequence.single(
          (XPathContext context, List<XPathSequence> args) =>
              XPathSequence.empty,
        ),
      ]),
      isXPathSequence([0]),
    );
  });
  test('fn:load-xquery-module', () {
    expect(
      () => fnLoadXqueryModule(context, [const XPathSequence.single('uri')]),
      throwsA(isA<UnimplementedError>()),
    );
  });
  test('fn:transform', () {
    expect(
      () => fnTransform(context, [XPathSequence.emptyMap]),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
