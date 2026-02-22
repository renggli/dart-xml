import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/math.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import '../../utils/matchers.dart';

final context = XPathContext.empty(XmlDocument());
void main() {
  test('math:pi', () {
    expect(mathPi(context, []), isXPathSequence([math.pi]));
  });
  test('math:sqrt', () {
    expect(
      mathSqrt(context, [const XPathSequence.single(4)]),
      isXPathSequence([2.0]),
    );
  });
  test('math:exp', () {
    expect(
      mathExp(context, [const XPathSequence.single(0)]),
      isXPathSequence([1.0]),
    );
  });
  test('math:exp10', () {
    expect(
      mathExp10(context, [const XPathSequence.single(0)]),
      isXPathSequence([1.0]),
    );
  });
  test('math:log', () {
    expect(
      mathLog(context, [const XPathSequence.single(math.e)]),
      isXPathSequence([1.0]),
    );
  });
  test('math:log10', () {
    expect(
      mathLog10(context, [const XPathSequence.single(10)]),
      isXPathSequence([1.0]),
    );
  });
  test('math:pow', () {
    expect(
      mathPow(context, [
        const XPathSequence.single(2),
        const XPathSequence.single(3),
      ]),
      isXPathSequence([8.0]),
    );
  });
  test('math:sin', () {
    expect(
      mathSin(context, [const XPathSequence.single(0)]),
      isXPathSequence([0.0]),
    );
  });
  test('math:cos', () {
    expect(
      mathCos(context, [const XPathSequence.single(0)]),
      isXPathSequence([1.0]),
    );
  });
  test('math:tan', () {
    expect(
      mathTan(context, [const XPathSequence.single(0)]),
      isXPathSequence([0.0]),
    );
  });
  test('math:asin', () {
    expect(
      mathAsin(context, [const XPathSequence.single(0)]),
      isXPathSequence([0.0]),
    );
  });
  test('math:acos', () {
    expect(
      mathAcos(context, [const XPathSequence.single(1)]),
      isXPathSequence([0.0]),
    );
  });
  test('math:atan', () {
    expect(
      mathAtan(context, [const XPathSequence.single(0)]),
      isXPathSequence([0.0]),
    );
  });
  test('math:atan2', () {
    expect(
      mathAtan2(context, [
        const XPathSequence.single(0),
        const XPathSequence.single(1),
      ]),
      isXPathSequence([0.0]),
    );
  });
}
