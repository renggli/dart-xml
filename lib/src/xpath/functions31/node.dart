import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/mixins/has_children.dart';
import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../evaluation/context.dart';
// unused import removed
import '../types31/sequence.dart';
import '../types31/string.dart';
import 'utils.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
XPathSequence fnName(XPathContext context, [XPathSequence? node]) {
  final nodeSequence = node ?? contextNode(context);
  if (nodeSequence.isEmpty) return XPathSequence.single(XPathString.empty);
  final item = nodeSequence.first;
  if (item is XmlHasName) {
    return XPathSequence.single(XPathString(item.qualifiedName));
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
XPathSequence fnLocalName(XPathContext context, [XPathSequence? node]) {
  final nodeSequence = node ?? contextNode(context);
  if (nodeSequence.isEmpty) return XPathSequence.single(XPathString.empty);
  final item = nodeSequence.first;
  if (item is XmlHasName) {
    return XPathSequence.single(XPathString(item.localName));
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
XPathSequence fnNamespaceUri(XPathContext context, [XPathSequence? node]) {
  final nodeSequence = node ?? contextNode(context);
  if (nodeSequence.isEmpty) return XPathSequence.single(XPathString.empty);
  final item = nodeSequence.first;
  if (item is XmlHasName) {
    return XPathSequence.single(XPathString(item.namespaceUri ?? ''));
  }
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
XPathSequence fnRoot(XPathContext context, [XPathSequence? node]) {
  final nodeSequence = node ?? contextNode(context);
  if (nodeSequence.isEmpty) return XPathSequence.empty;
  final item = nodeSequence.first;
  if (item is XmlNode) {
    return XPathSequence.single(item.root);
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
XPathSequence fnHasChildren(XPathContext context, [XPathSequence? node]) {
  final nodeSequence = node ?? contextNode(context);
  if (nodeSequence.isEmpty) return XPathSequence.falseSequence;
  final item = nodeSequence.first;
  if (item is XmlHasChildren) {
    return XPathSequence.single(item.children.isNotEmpty);
  }
  return XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
XPathSequence fnInnermost(XPathContext context, XPathSequence nodes) {
  final nodeList = nodes.whereType<XmlNode>().toList();
  if (nodeList.isEmpty) return XPathSequence.empty;
  final result = nodeList
      .where(
        (node) => !nodeList.any(
          (other) => other != node && other.ancestors.contains(node),
        ),
      )
      .toList();
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
XPathSequence fnOutermost(XPathContext context, XPathSequence nodes) {
  final nodeList = nodes.whereType<XmlNode>().toList();
  if (nodeList.isEmpty) return XPathSequence.empty;
  final result = nodeList
      .where(
        (node) => !nodeList.any(
          (other) => other != node && node.ancestors.contains(other),
        ),
      )
      .toList();
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-path
XPathSequence fnPath(XPathContext context, [XPathSequence? node]) {
  final nodeSequence = node ?? contextNode(context);
  if (nodeSequence.isEmpty) return XPathSequence.empty;
  final item = nodeSequence.first;
  if (item is XmlNode) {
    final path = [item, ...item.ancestors].reversed
        .map((node) {
          if (node is XmlDocument) return '';
          if (node is XmlElement) {
            final sameTagAncestors =
                node.parent?.children
                    .where((c) => c is XmlElement && c.name == node.name)
                    .toList() ??
                [];
            if (sameTagAncestors.length > 1) {
              return '${node.name}[${sameTagAncestors.indexOf(node) + 1}]';
            }
            return node.name;
          }
          if (node is XmlAttribute) return '@${node.name}';
          return node.toString();
        })
        .join('/');
    return XPathSequence.single(
      XPathString(
        path.isEmpty
            ? '/'
            : path.startsWith('/')
            ? path
            : '/$path',
      ),
    );
  }
  return XPathSequence.empty;
}

// Replaced by contextNode in utils.dart
