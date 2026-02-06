import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/matchers.dart';

enum AxisDirection { none, forward, reverse }

void expectXPath(
  XmlNode? node,
  String expression,
  Iterable<dynamic> matchers, {
  AxisDirection axisDirection = AxisDirection.none,
  Map<String, Object> variables = const {},
  Map<String, XPathFunction> functions = const {},
}) {
  expect(
    node!.xpath(expression, variables: variables, functions: functions),
    orderedEquals(matchers.map(isXmlNode)),
    reason: expression,
  );
  // Indexed access works correctly across axis directions.
  if (axisDirection != AxisDirection.none) {
    for (var i = 0; i < matchers.length; i++) {
      final indexedExpression = '$expression[${i + 1}]';
      final indexedMatcher = axisDirection == AxisDirection.forward
          ? matchers.elementAt(i)
          : matchers.elementAt(matchers.length - i - 1);
      expect(
        node.xpath(
          indexedExpression,
          variables: variables,
          functions: functions,
        ),
        orderedEquals([isXmlNode(indexedMatcher)]),
        reason: indexedExpression,
      );
    }
  }
}

void expectEvaluate(
  XmlNode? node,
  String expression,
  dynamic matcher, {
  Map<String, Object> variables = const {},
  Map<String, XPathFunction> functions = const {},
}) => expect(
  node!.xpathEvaluate(expression, variables: variables, functions: functions),
  matcher,
  reason: expression,
);
