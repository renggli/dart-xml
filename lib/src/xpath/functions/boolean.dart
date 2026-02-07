import '../../xml/extensions/ancestors.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/any.dart';
import '../types/boolean.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-boolean
const fnBoolean = XPathFunctionDefinition(
  name: 'fn:boolean',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnBoolean,
);

XPathSequence _fnBoolean(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(xsBoolean.cast(arg));

/// https://www.w3.org/TR/xpath-functions-31/#func-not
const fnNot = XPathFunctionDefinition(
  name: 'fn:not',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsAny,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnNot,
);

XPathSequence _fnNot(XPathContext context, XPathSequence arg) =>
    XPathSequence.single(!xsBoolean.cast(arg));

/// https://www.w3.org/TR/xpath-functions-31/#func-true
const fnTrue = XPathFunctionDefinition(name: 'fn:true', function: _fnTrue);

XPathSequence _fnTrue(XPathContext context) => XPathSequence.trueSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-false
const fnFalse = XPathFunctionDefinition(name: 'fn:false', function: _fnFalse);

XPathSequence _fnFalse(XPathContext context) => XPathSequence.falseSequence;

/// https://www.w3.org/TR/xpath-functions-31/#func-lang
const fnLang = XPathFunctionDefinition(
  name: 'fn:lang',
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'testlang',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'node', type: xsNode)],
  function: _fnLang,
);

XPathSequence _fnLang(XPathContext context, String? testlang, [XmlNode? node]) {
  final item = node ?? xsNode.cast(context.item);
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
