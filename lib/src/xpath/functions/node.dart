import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/cdata.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/name.dart';
import '../../xml/utils/namespace.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
final fnName = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:name'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:name'),
      (context) => _evalName(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:name'),
      (context, arg) => _evalName(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalName(XPathNode? nodeItem) {
  if (nodeItem == null) return const XPathSequence.single(XPathString.empty);
  final node = nodeItem.node;
  return switch (node) {
    XmlElement() => XPathSequence.single(XPathString(node.name.toString())),
    XmlAttribute() => XPathSequence.single(XPathString(node.name.toString())),
    XmlProcessing() => XPathSequence.single(XPathString(node.target)),
    _ => const XPathSequence.single(XPathString.empty),
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
final fnLocalName = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:local-name'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:local-name'),
      (context) => _evalLocalName(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:local-name'),
      (context, arg) => _evalLocalName(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalLocalName(XPathNode? nodeItem) {
  if (nodeItem == null) return const XPathSequence.single(XPathString.empty);
  final node = nodeItem.node;
  return switch (node) {
    XmlElement() => XPathSequence.single(XPathString(node.name.local)),
    XmlAttribute() => XPathSequence.single(XPathString(node.name.local)),
    XmlProcessing() => XPathSequence.single(XPathString(node.target)),
    _ => const XPathSequence.single(XPathString.empty),
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
final fnNamespaceUri = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:namespace-uri'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:namespace-uri'),
      (context) => _evalNamespaceUri(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:namespace-uri'),
      (context, arg) => _evalNamespaceUri(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalNamespaceUri(XPathNode? nodeItem) {
  if (nodeItem == null) return const XPathSequence.single(XPathString.empty);
  final node = nodeItem.node;
  return switch (node) {
    XmlElement() => XPathSequence.single(
      XPathString(node.name.namespaceUri ?? ''),
    ),
    XmlAttribute() => XPathSequence.single(
      XPathString(node.name.namespaceUri ?? ''),
    ),
    _ => const XPathSequence.single(XPathString.empty),
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-id
final fnId = XPathFunctionItem.overloaded(const XmlName.qualified('fn:id'), {
  1: XPathFunctionItem.fn1(
    const XmlName.qualified('fn:id'),
    (context, arg) => _evalId(arg, context.item as XPathNode?),
  ),
  2: XPathFunctionItem.fn2(const XmlName.qualified('fn:id'), (
    context,
    arg,
    node,
  ) {
    final nodeItem = node.firstOrNull;
    if (nodeItem is! XPathNode) {
      throw XPathEvaluationException(
        'Expected a node for the second argument of fn:id',
      );
    }
    return _evalId(arg, nodeItem);
  }),
});

XPathSequence _evalId(XPathSequence arg, XPathNode? nodeItem) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = nodeItem?.node.root;
  if (root == null || root is! XmlDocument) return XPathSequence.empty;
  final dtdIds = _getIdAttributes(root);
  return XPathSequence(
    root.descendantElements
        .where(
          (element) => element.attributes.any(
            (attribute) =>
                _isId(element, attribute, dtdIds) &&
                ids.contains(attribute.value.trim()),
          ),
        )
        .map(XPathNode.new),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
final fnElementWithId = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:element-with-id'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:element-with-id'),
      (context, arg) => _evalElementWithId(arg, context.item as XPathNode?),
    ),
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:element-with-id'), (
      context,
      arg,
      node,
    ) {
      final nodeItem = node.firstOrNull;
      if (nodeItem is! XPathNode) {
        throw XPathEvaluationException(
          'Expected a node for the second argument of fn:element-with-id',
        );
      }
      return _evalElementWithId(arg, nodeItem);
    }),
  },
);

XPathSequence _evalElementWithId(XPathSequence arg, XPathNode? nodeItem) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = nodeItem?.node.root;
  if (root == null || root is! XmlDocument) return XPathSequence.empty;
  final dtdIds = _getIdAttributes(root);
  final seen = <String>{};
  return XPathSequence(
    root.descendantElements
        .where(
          (element) => element.attributes
              .where((attribute) => _isId(element, attribute, dtdIds))
              .any((attribute) {
                final value = attribute.value.trim();
                return ids.contains(value) && seen.add(value);
              }),
        )
        .map(XPathNode.new),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
final fnIdref = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:idref'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:idref'),
      (context, arg) => _evalIdref(arg, context.item as XPathNode?),
    ),
    2: XPathFunctionItem.fn2(const XmlName.qualified('fn:idref'), (
      context,
      arg,
      node,
    ) {
      final nodeItem = node.firstOrNull;
      if (nodeItem is! XPathNode) {
        throw XPathEvaluationException(
          'Expected a node for the second argument of fn:idref',
        );
      }
      return _evalIdref(arg, nodeItem);
    }),
  },
);

XPathSequence _evalIdref(XPathSequence arg, XPathNode? nodeItem) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = nodeItem?.node.root;
  if (root == null || root is! XmlDocument) return XPathSequence.empty;
  final dtdIdrefs = _getIdrefAttributes(root);
  return XPathSequence(
    root.descendantElements
        .expand(
          (element) => element.attributes.where(
            (attribute) =>
                _isIdref(element, attribute, dtdIdrefs) &&
                attribute.value.trim().split(_whitespace).any(ids.contains),
          ),
        )
        .map(XPathNode.new),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
final fnGenerateId = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:generate-id'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:generate-id'),
      (context) => _evalGenerateId(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:generate-id'),
      (context, arg) => _evalGenerateId(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalGenerateId(XPathNode? nodeItem) {
  if (nodeItem == null) return const XPathSequence.single(XPathString.empty);
  final id = identityHashCode(nodeItem.node)
      .toRadixString(16)
      .toUpperCase()
      .padLeft(8, '0');
  return XPathSequence.single(XPathString('autoId$id'));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
final fnRoot = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:root'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:root'),
      (context) => _evalRoot(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:root'),
      (context, arg) => _evalRoot(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalRoot(XPathNode? nodeItem) {
  if (nodeItem == null) return XPathSequence.empty;
  return XPathSequence.single(XPathNode(nodeItem.node.root));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
final fnHasChildren = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:has-children'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:has-children'),
      (context) => _evalHasChildren(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:has-children'),
      (context, arg) => _evalHasChildren(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalHasChildren(XPathNode? nodeItem) {
  if (nodeItem == null) {
    return XPathSequence.falseSequence;
  }
  return nodeItem.node.children.isNotEmpty
      ? XPathSequence.trueSequence
      : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
final fnInnermost = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:innermost'),
  (context, nodes) {
    final list = nodes.whereType<XPathNode>().toList();
    final result = <XPathNode>[];
    for (final nodeItem in list) {
      final node = nodeItem.node;
      if (!list.any(
        (other) =>
            node != other.node &&
            node.descendants.any((desc) => desc == other.node),
      )) {
        result.add(nodeItem);
      }
    }
    return XPathSequence(result);
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
final fnOutermost = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:outermost'),
  (context, nodes) {
    final list = nodes.whereType<XPathNode>().toList();
    final result = <XPathNode>[];
    for (final nodeItem in list) {
      final node = nodeItem.node;
      if (!list.any(
        (other) =>
            node != other.node &&
            node.ancestors.any((anc) => anc == other.node),
      )) {
        result.add(nodeItem);
      }
    }
    return XPathSequence(result);
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-path
final fnPath = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:path'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:path'),
      (context) => _evalPath(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:path'),
      (context, arg) => _evalPath(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalPath(XPathNode? nodeItem) {
  if (nodeItem == null) return XPathSequence.empty;
  final node = nodeItem.node;
  if (node is XmlDocument) return const XPathSequence.single(XPathString('/'));
  final components = <String>[];
  XmlNode? current = node;
  while (current != null && current is! XmlDocument) {
    switch (current) {
      case XmlElement():
        final local = current.name.local;
        final uri = current.name.namespaceUri ?? '';
        final siblings =
            current.parent?.children.whereType<XmlElement>() ?? const [];
        var index = 1;
        for (final sibling in siblings) {
          if (identical(sibling, current)) break;
          if (sibling.name.local == local &&
              (sibling.name.namespaceUri ?? '') == uri) {
            index++;
          }
        }
        components.add('Q{$uri}$local[$index]');
      case XmlAttribute():
        final local = current.name.local;
        final uri = current.name.namespaceUri;
        if (uri != null && uri.isNotEmpty) {
          components.add('@Q{$uri}$local');
        } else {
          components.add('@$local');
        }
      case XmlText() || XmlCDATA():
        final siblings =
            current.parent?.children.where(
              (e) => e is XmlText || e is XmlCDATA,
            ) ??
            const [];
        var index = 1;
        for (final sibling in siblings) {
          if (identical(sibling, current)) break;
          index++;
        }
        components.add('text()[$index]');
      case XmlComment():
        final siblings =
            current.parent?.children.whereType<XmlComment>() ?? const [];
        var index = 1;
        for (final sibling in siblings) {
          if (identical(sibling, current)) break;
          index++;
        }
        components.add('comment()[$index]');
      case XmlProcessing():
        final target = current.target;
        final siblings =
            current.parent?.children.whereType<XmlProcessing>() ?? const [];
        var index = 1;
        for (final sibling in siblings) {
          if (identical(sibling, current)) break;
          if (sibling.target == target) index++;
        }
        components.add('processing-instruction($target)[$index]');
      case _:
        break;
    }
    current = current.parent;
  }
  final isDocRoot = node.root is XmlDocument;
  final path = components.reversed.join('/');
  return XPathSequence.single(XPathString(isDocRoot ? '/$path' : path));
}

final _whitespace = RegExp(r'\s+');

Set<String> _parseIdStrings(XPathSequence arg) => arg
    .atomize()
    .map((each) => each.stringValue)
    .expand((each) => each.split(_whitespace))
    .where((each) => each.isNotEmpty)
    .toSet();

final _attlistIdRegex = RegExp(
  r'<!ATTLIST\s+([^\s>]+)\s+([^\s>]+)\s+ID\b',
  caseSensitive: false,
);

final _attlistIdrefRegex = RegExp(
  r'<!ATTLIST\s+([^\s>]+)\s+([^\s>]+)\s+(?:IDREF|IDREFS)\b',
  caseSensitive: false,
);

Map<String, Set<String>> _getIdAttributes(XmlNode root) {
  final result = <String, Set<String>>{};
  if (root is XmlDocument) {
    final subset = root.doctypeElement?.internalSubset;
    if (subset != null) {
      for (final m in _attlistIdRegex.allMatches(subset)) {
        result.putIfAbsent(m.group(1)!, () => {}).add(m.group(2)!);
      }
    }
  }
  return result;
}

Map<String, Set<String>> _getIdrefAttributes(XmlNode root) {
  final result = <String, Set<String>>{};
  if (root is XmlDocument) {
    final subset = root.doctypeElement?.internalSubset;
    if (subset != null) {
      for (final m in _attlistIdrefRegex.allMatches(subset)) {
        result.putIfAbsent(m.group(1)!, () => {}).add(m.group(2)!);
      }
    }
  }
  return result;
}

bool _isId(
  XmlElement element,
  XmlAttribute attr,
  Map<String, Set<String>> dtdIds,
) =>
    attr.name.qualified == 'id' ||
    attr.name.qualified == '$xml:id' ||
    (dtdIds[element.name.local]?.contains(attr.name.local) ?? false);

bool _isIdref(
  XmlElement element,
  XmlAttribute attr,
  Map<String, Set<String>> dtdIdrefs,
) {
  final qualified = attr.name.qualified;
  return qualified == 'idref' ||
      qualified == 'idrefs' ||
      qualified == '$xml:idref' ||
      qualified == '$xml:idrefs' ||
      (dtdIdrefs[element.name.local]?.contains(attr.name.local) ?? false);
}
