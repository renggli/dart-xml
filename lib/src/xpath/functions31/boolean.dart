import '../../xml/extensions/ancestors.dart';
import '../../xml/nodes/element.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/boolean.dart';
import '../types31/node.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
XPathSequence fnBoolean(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:boolean', arguments, 1);
  return XPathSequence.single(arguments[0].toXPathBoolean());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-not
XPathSequence fnNot(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:not', arguments, 1);
  return XPathSequence.single(!arguments[0].toXPathBoolean());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-true
XPathSequence fnTrue(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:true', arguments, 0);
  return XPathSequence.trueSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-false
XPathSequence fnFalse(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:false', arguments, 0);
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-lang
XPathSequence fnLang(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:lang', arguments, 1, 2);
  final node = arguments.length > 1
      ? XPathEvaluationException.extractExactlyOne(
          'fn:lang',
          'node',
          arguments[1],
        ).toXPathNode()
      : context.node;
  final lang = [node, ...node.ancestors]
      .whereType<XmlElement>()
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;
  if (lang == null) return XPathSequence.falseSequence;
  final testlang = XPathEvaluationException.extractZeroOrOne(
    'fn:lang',
    'testlang',
    arguments[0],
  )?.toXPathString();
  if (testlang == null) return XPathSequence.falseSequence;
  return XPathSequence.single(
    lang.toLowerCase().startsWith(testlang.toLowerCase()),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-equal
XPathSequence opBooleanEqual(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(_compareBoolean('op:boolean-equal', arguments) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-less-than
XPathSequence opBooleanLessThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareBoolean('op:boolean-less-than', arguments) < 0,
);

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-greater-than
XPathSequence opBooleanGreaterThan(
  XPathContext context,
  List<XPathSequence> arguments,
) => XPathSequence.single(
  _compareBoolean('op:boolean-greater-than', arguments) > 0,
);

int _compareBoolean(String name, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final value1 = XPathEvaluationException.extractExactlyOne(
    name,
    'arg1',
    arguments[0],
  ).toXPathBoolean();
  final value2 = XPathEvaluationException.extractExactlyOne(
    name,
    'arg2',
    arguments[1],
  ).toXPathBoolean();
  return (value1 ? 1 : 0).compareTo(value2 ? 1 : 0);
}
