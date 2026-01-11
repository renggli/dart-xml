import '../../xml/extensions/ancestors.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/boolean.dart';
import '../types31/node.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
XPathSequence fnBoolean(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.toXPathBoolean());

/// https://www.w3.org/TR/xpath-functions-31/#func-not
XPathSequence fnNot(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(!arg.toXPathBoolean());

/// https://www.w3.org/TR/xpath-functions-31/#func-true
XPathSequence fnTrue(XPathContext context) => XPathSequence.trueSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-false
XPathSequence fnFalse(XPathContext context) => XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-lang
XPathSequence fnLang(
  XPathContext context,
  XPathSequence testLang, [
  XPathSequence? node,
]) {
  final nodeVal = node == null
      ? context.node
      : XPathEvaluationException.checkExactlyOne(node).toXPathNode();
  final lang = [nodeVal, ...nodeVal.ancestors]
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;
  if (lang == null) return XPathSequence.falseSequence;

  final testLangOpt = XPathEvaluationException.checkZeroOrOne(testLang);
  if (testLangOpt == null) return XPathSequence.falseSequence;

  final testLangVal = testLangOpt.toXPathString();
  return XPathSequence.single(
    lang.toLowerCase().startsWith(testLangVal.toLowerCase()),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-equal
XPathSequence opBooleanEqual(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathBoolean();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathBoolean();
  return XPathSequence.single(val1 == val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-less-than
XPathSequence opBooleanLessThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathBoolean();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathBoolean();
  // defined as: boolean($arg1) and not(boolean($arg2)) -> False
  // false < true is True.
  // false < false is False.
  // true < true is False.
  // true < false is False.
  // So: !val1 && val2
  return XPathSequence.single(!val1 && val2);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-greater-than
XPathSequence opBooleanGreaterThan(
  XPathContext context,
  XPathSequence arg1,
  XPathSequence arg2,
) {
  final val1 = XPathEvaluationException.checkExactlyOne(arg1).toXPathBoolean();
  final val2 = XPathEvaluationException.checkExactlyOne(arg2).toXPathBoolean();
  // defined as: boolean($arg1) > boolean($arg2)
  // true > false is True.
  // So: val1 && !val2
  return XPathSequence.single(val1 && !val2);
}
