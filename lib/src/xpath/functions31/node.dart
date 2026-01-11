import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/mixins/has_children.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../generator.dart';
import '../types31/node.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
XPathSequence fnName(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:name', arguments, 0, 1);
  final arg = arguments.isEmpty
      ? context.node.toXPathNode()
      : XPathEvaluationException.extractZeroOrOne(
          'fn:name',
          'arg',
          arguments[0],
        )?.toXPathNode();
  if (arg is XmlHasName) {
    return XPathSequence.single((arg as XmlHasName).qualifiedName);
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
XPathSequence fnLocalName(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:local-name', arguments, 0, 1);
  final arg = arguments.isEmpty
      ? context.node.toXPathNode()
      : XPathEvaluationException.extractZeroOrOne(
          'fn:local-name',
          'arg',
          arguments[0],
        )?.toXPathNode();
  if (arg is XmlHasName) {
    return XPathSequence.single(XPathString((arg as XmlHasName).localName));
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
XPathSequence fnNamespaceUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:namespace-uri',
    arguments,
    0,
    1,
  );
  final arg = arguments.isEmpty
      ? context.node.toXPathNode()
      : XPathEvaluationException.extractZeroOrOne(
          'fn:namespace-uri',
          'arg',
          arguments[0],
        )?.toXPathNode();
  if (arg is XmlHasName) {
    return XPathSequence.single(
      XPathString((arg as XmlHasName).namespaceUri ?? ''),
    );
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
XPathSequence fnRoot(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:root', arguments, 0, 1);
  final arg = arguments.isEmpty
      ? context.node.toXPathNode()
      : XPathEvaluationException.extractZeroOrOne(
          'fn:root',
          'arg',
          arguments[0],
        )?.toXPathNode();
  if (arg != null) {
    // arg is XPathNode (implements XmlNode)
    return XPathSequence.single((arg as XmlNode).root);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
XPathSequence fnHasChildren(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(
    'fn:has-children',
    arguments,
    0,
    1,
  );
  final node = arguments.isEmpty
      ? context.node.toXPathNode()
      : XPathEvaluationException.extractZeroOrOne(
          'fn:has-children',
          'node',
          arguments[0],
        )?.toXPathNode();
  if (node is XmlHasChildren) {
    return XPathSequence.single((node as XmlHasChildren).children.isNotEmpty);
  }
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
XPathSequence fnInnermost(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:innermost', arguments, 1);
  final nodes = arguments[0];
  final nodeList = nodes
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toList();
  if (nodeList.isEmpty) return XPathSequence.empty;
  return XPathSequence(
    nodeList.where(
      (node) => !nodeList.any(
        (other) => other != node && other.ancestors.contains(node),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
XPathSequence fnOutermost(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:outermost', arguments, 1);
  final nodes = arguments[0];
  final nodeList = nodes
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toList();
  if (nodeList.isEmpty) return XPathSequence.empty;
  return XPathSequence(
    nodeList.where(
      (node) => !nodeList.any(
        (other) => other != node && node.ancestors.contains(other),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-path
XPathSequence fnPath(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:path', arguments, 0, 1);
  final arg = arguments.isEmpty
      ? context.node.toXPathNode()
      : XPathEvaluationException.extractZeroOrOne(
          'fn:path',
          'arg',
          arguments[0],
        )?.toXPathNode();
  if (arg != null) {
    return XPathSequence.single(XPathString((arg as XmlNode).xpathGenerate()));
  }
  return XPathSequence.empty;
}
