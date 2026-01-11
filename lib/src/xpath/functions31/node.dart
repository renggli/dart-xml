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
XPathSequence fnName(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node.toXPathNode()
      : XPathEvaluationException.checkZeroOrOne(node)?.toXPathNode();
  if (nodeOpt is XmlHasName) {
    return XPathSequence.single((nodeOpt as XmlHasName).qualifiedName);
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
XPathSequence fnLocalName(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node.toXPathNode()
      : XPathEvaluationException.checkZeroOrOne(node)?.toXPathNode();
  if (nodeOpt is XmlHasName) {
    return XPathSequence.single(XPathString((nodeOpt as XmlHasName).localName));
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
XPathSequence fnNamespaceUri(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node.toXPathNode()
      : XPathEvaluationException.checkZeroOrOne(node)?.toXPathNode();
  if (nodeOpt is XmlHasName) {
    return XPathSequence.single(
      XPathString((nodeOpt as XmlHasName).namespaceUri ?? ''),
    );
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
XPathSequence fnRoot(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node.toXPathNode()
      : XPathEvaluationException.checkZeroOrOne(node)?.toXPathNode();
  if (nodeOpt != null) {
    // nodeOpt is XPathNode (implements XmlNode)
    return XPathSequence.single((nodeOpt as XmlNode).root);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
XPathSequence fnHasChildren(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node.toXPathNode()
      : XPathEvaluationException.checkZeroOrOne(node)?.toXPathNode();
  if (nodeOpt is XmlHasChildren) {
    return XPathSequence.single(
      (nodeOpt as XmlHasChildren).children.isNotEmpty,
    );
  }
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
XPathSequence fnInnermost(XPathContext context, XPathSequence nodes) {
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
XPathSequence fnOutermost(XPathContext context, XPathSequence nodes) {
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
XPathSequence fnPath(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node.toXPathNode()
      : XPathEvaluationException.checkZeroOrOne(node)?.toXPathNode();
  if (nodeOpt != null) {
    return XPathSequence.single(
      XPathString((nodeOpt as XmlNode).xpathGenerate()),
    );
  }
  return XPathSequence.empty;
}
