import '../../xml/extensions/ancestors.dart';
import '../evaluation/context.dart';
import '../types31/boolean.dart';
import '../types31/sequence.dart';

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
XPathSequence fnLang(XPathContext context, [XPathSequence? testLang]) {
  final node = context.node;
  final lang = [node, ...node.ancestors]
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;

  if (lang == null) return XPathSequence.falseSequence;

  final argSequence = testLang ?? context.value.toXPathSequence();
  if (argSequence.isEmpty) return XPathSequence.falseSequence;

  final argument = argSequence.first.toString().toLowerCase();
  return XPathSequence.single(lang.toLowerCase().startsWith(argument));
}
