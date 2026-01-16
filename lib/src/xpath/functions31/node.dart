import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/comparison.dart';
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
  final arg = _nodeOrContext('fn:name', context, arguments);
  if (arg is XmlHasName) {
    return XPathSequence.single((arg as XmlHasName).qualifiedName);
  }
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
XPathSequence fnLocalName(XPathContext context, List<XPathSequence> arguments) {
  final arg = _nodeOrContext('fn:local-name', context, arguments);
  if (arg is XmlHasName) {
    return XPathSequence.single(XPathString((arg as XmlHasName).localName));
  }
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
XPathSequence fnNamespaceUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  final arg = _nodeOrContext('fn:namespace-uri', context, arguments);
  if (arg is XmlHasName) {
    return XPathSequence.single(
      XPathString((arg as XmlHasName).namespaceUri ?? ''),
    );
  }
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
XPathSequence fnRoot(XPathContext context, List<XPathSequence> arguments) {
  final arg = _nodeOrContext('fn:root', context, arguments);
  if (arg != null) {
    // arg is XPathNode (implements XmlNode)
    return XPathSequence.single(arg.root);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
XPathSequence fnHasChildren(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  final node = _nodeOrContext('fn:has-children', context, arguments);
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
  final arg = _nodeOrContext('fn:path', context, arguments);
  if (arg != null) {
    return XPathSequence.single(XPathString(arg.xpathGenerate()));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-31/#combining_seq
XPathSequence opUnion(XPathContext context, List<XPathSequence> arguments) =>
    _nodeSetOperation('op:union', arguments, (a, b) => a.union(b));

/// https://www.w3.org/TR/xpath-31/#combining_seq
XPathSequence opIntersect(
  XPathContext context,
  List<XPathSequence> arguments,
) => _nodeSetOperation('op:intersect', arguments, (a, b) => a.intersection(b));

/// https://www.w3.org/TR/xpath-31/#combining_seq
XPathSequence opExcept(XPathContext context, List<XPathSequence> arguments) =>
    _nodeSetOperation('op:except', arguments, (a, b) => a.difference(b));

XmlNode? _nodeOrContext(
  String name,
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 0, 1);
  return arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          name,
          'node',
          arguments[0],
        )?.toXPathNode()
      : context.node.toXPathNode();
}

XPathSequence _nodeSetOperation(
  String name,
  List<XPathSequence> arguments,
  Set<XmlNode> Function(Set<XmlNode>, Set<XmlNode>) operation,
) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 2);
  final arg1 = arguments[0]
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toSet();
  final arg2 = arguments[1]
      .map((item) => item.toXPathNode())
      .whereType<XmlNode>()
      .toSet();
  final result = operation(arg1, arg2).toList();
  result.sort((a, b) => a.compareNodePosition(b));
  return XPathSequence(result);
}
