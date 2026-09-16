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
  Map<XmlName, XPathFunction> functions = const {},
}) {
  final configuration = XPathConfiguration(
    variables: variables,
    functions: functions,
  );
  expect(
    node!.xpath(expression, configuration: configuration),
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
        node.xpath(indexedExpression, configuration: configuration),
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
  Map<XmlName, XPathFunction> functions = const {},
}) {
  final configuration = XPathConfiguration(
    variables: variables,
    functions: functions,
  );
  expect(
    node!.xpathEvaluate(expression, configuration: configuration),
    isXPathSequence(matcher),
    reason: expression,
  );
}

XPathSequence seq(Object? value) {
  if (value == null) return XPathSequence.empty;
  if (value is XPathSequence) return value;
  if (value is XPathItem) return XPathSequence.single(value);
  if (value is Iterable) return XPathSequence(value.map(toXPathItem));
  return XPathSequence.single(toXPathItem(value));
}

XPathItem toXPathItem(Object? value) => switch (value) {
  final XPathItem item => item,
  final XmlNode node => XPathNode(node),
  final XmlName name => XPathQName(name),
  final bool b => XPathBoolean(b),
  final int i => XPathInteger.fromInt(i),
  final BigInt bi => XPathInteger(bi),
  final double d => XPathDouble(d),
  final String s => XPathString(s),
  final DateTime dt => XPathDateTime.fromDateTime(dt, 0),
  final Function fn => fn.toXPathFunction(),
  final Map<XPathAtomic, XPathSequence> m => XPathMap(m),
  final Map<dynamic, dynamic> m => XPathMap({
    for (final e in m.entries) toXPathItem(e.key) as XPathAtomic: seq(e.value),
  }),
  final List<dynamic> l => XPathArray([for (final e in l) seq(e)]),
  _ => throw ArgumentError.value(value),
};
