import '../../xml/extensions/ancestors.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/boolean.dart';
import '../types/node.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
const fnBoolean = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'boolean',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnBoolean,
);

XPathSequence _fnBoolean(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(arg.toXPathBoolean());

/// https://www.w3.org/TR/xpath-functions-31/#func-not
const fnNot = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'not',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequenceType(
        xsAny,
        cardinality: XPathArgumentCardinality.zeroOrMore,
      ),
    ),
  ],
  function: _fnNot,
);

XPathSequence _fnNot(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(!arg.toXPathBoolean());

/// https://www.w3.org/TR/xpath-functions-31/#func-true
const fnTrue = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'true',
  function: _fnTrue,
);

XPathSequence _fnTrue(XPathContext context) => XPathSequence.trueSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-false
const fnFalse = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'false',
  function: _fnFalse,
);

XPathSequence _fnFalse(XPathContext context) => XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-lang
const fnLang = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'lang',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'testlang',
      type: XPathSequenceType(
        xsString,
        cardinality: XPathArgumentCardinality.zeroOrOne,
      ),
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'node', type: xsNode)],
  function: _fnLang,
);

XPathSequence _fnLang(XPathContext context, String? testlang, [XmlNode? node]) {
  final item = node ?? context.item.toXPathNode();
  final lang = [item, ...item.ancestors]
      .whereType<XmlElement>()
      .map((node) => node.getAttribute('xml:lang'))
      .where((lang) => lang != null)
      .firstOrNull;
  if (lang == null) return XPathSequence.falseSequence;
  if (testlang == null) return XPathSequence.falseSequence;
  return XPathSequence.single(
    lang.toLowerCase().startsWith(testlang.toLowerCase()),
  );
}
