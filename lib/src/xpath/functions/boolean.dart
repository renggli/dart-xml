import '../../xml/extensions/ancestors.dart';
import '../../xml/nodes/element.dart';
import '../evaluation/context.dart';
import '../evaluation/definition.dart';
import '../types/boolean.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
const fnBoolean = XPathFunctionDefinition(
  namespace: 'fn',
  name: 'boolean',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
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
      type: XPathSequence,
      cardinality: XPathArgumentCardinality.zeroOrMore,
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
      type: XPathString,
      cardinality: XPathArgumentCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'node', type: XPathNode)],
  function: _fnLang,
);

XPathSequence _fnLang(
  XPathContext context,
  XPathString? testlang, [
  XPathNode? node,
]) {
  final item = node ?? XPathNode(context.node);
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

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-equal
const opBooleanEqual = XPathFunctionDefinition(
  namespace: 'op',
  name: 'boolean-equal',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathBoolean),
    XPathArgumentDefinition(name: 'arg2', type: XPathBoolean),
  ],
  function: _opBooleanEqual,
);

XPathSequence _opBooleanEqual(
  XPathContext context,
  XPathBoolean value1,
  XPathBoolean value2,
) => XPathSequence.single((value1 ? 1 : 0).compareTo(value2 ? 1 : 0) == 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-less-than
const opBooleanLessThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'boolean-less-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathBoolean),
    XPathArgumentDefinition(name: 'arg2', type: XPathBoolean),
  ],
  function: _opBooleanLessThan,
);

XPathSequence _opBooleanLessThan(
  XPathContext context,
  XPathBoolean value1,
  XPathBoolean value2,
) => XPathSequence.single((value1 ? 1 : 0).compareTo(value2 ? 1 : 0) < 0);

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean-greater-than
const opBooleanGreaterThan = XPathFunctionDefinition(
  namespace: 'op',
  name: 'boolean-greater-than',
  requiredArguments: [
    XPathArgumentDefinition(name: 'arg1', type: XPathBoolean),
    XPathArgumentDefinition(name: 'arg2', type: XPathBoolean),
  ],
  function: _opBooleanGreaterThan,
);

XPathSequence _opBooleanGreaterThan(
  XPathContext context,
  XPathBoolean value1,
  XPathBoolean value2,
) => XPathSequence.single((value1 ? 1 : 0).compareTo(value2 ? 1 : 0) > 0);
