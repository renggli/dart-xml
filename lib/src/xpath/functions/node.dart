import '../../xml/extensions/ancestors.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/cdata.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/name.dart';
import '../../xml/utils/namespace.dart';
import '../evaluation/cardinality.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import '../xdm/types.dart';

XPathNode? _optionalNodeArg(
  XPathContext context,
  XPathSequence? arg,
  String fnName,
) {
  if (arg == null) {
    final item = context.item;
    if (item is XPathSequence && item.isEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.XPDY0002,
        'The context item is absent [err:XPDY0002]',
      );
    }
    if (item is! XPathNode) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Context item for $fnName must be a node, got ${item.runtimeType}',
      );
    }
    return item;
  }
  if (arg.isEmpty) return null;
  final item = arg.single;
  if (item is! XPathNode) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Argument to $fnName must be a node, got ${item.type}',
    );
  }
  return item;
}

XPathNode _requiredNodeArg(XPathSequence arg, String fnName) {
  if (arg.isEmpty) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected a node for the argument of $fnName',
    );
  }
  final item = arg.single;
  if (item is! XPathNode) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Expected a node for the argument of $fnName, got ${item.type}',
    );
  }
  return item;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-name
final fnName = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:name'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:name'),
      (context) => _evalName(_optionalNodeArg(context, null, 'fn:name')),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:name'),
      (context, arg) => _evalName(_optionalNodeArg(context, arg, 'fn:name')),
      parameterTypes: const [
        XPathSequenceType(
          itemType: xsNode,
          cardinality: XPathCardinality.zeroOrOne,
        ),
      ],
      returnType: const XPathSequenceType(
        itemType: xsString,
        cardinality: XPathCardinality.exactlyOne,
      ),
    ),
  },
);

XPathSequence _evalName(XPathNode? nodeItem) {
  if (nodeItem == null) return const XPathSequence.single(XPathString.empty);
  final node = nodeItem.node;
  return switch (node) {
    XmlElement() => XPathSequence.single(XPathString(node.name.toString())),
    XmlAttribute() => XPathSequence.single(
      XPathString(
        node.name.prefix != null
            ? '${node.name.prefix}:${node.name.local}'
            : node.name.local,
      ),
    ),
    XmlProcessing() => XPathSequence.single(XPathString(node.target)),
    XmlNamespace(:final prefix) => XPathSequence.single(XPathString(prefix)),
    _ => const XPathSequence.single(XPathString.empty),
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
final fnLocalName = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:local-name'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:local-name'),
      (context) =>
          _evalLocalName(_optionalNodeArg(context, null, 'fn:local-name')),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:local-name'),
      (context, arg) =>
          _evalLocalName(_optionalNodeArg(context, arg, 'fn:local-name')),
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
    XmlNamespace(:final prefix) => XPathSequence.single(XPathString(prefix)),
    _ => const XPathSequence.single(XPathString.empty),
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
final fnNamespaceUri = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:namespace-uri'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:namespace-uri'),
      (context) => _evalNamespaceUri(
        _optionalNodeArg(context, null, 'fn:namespace-uri'),
      ),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:namespace-uri'),
      (context, arg) =>
          _evalNamespaceUri(_optionalNodeArg(context, arg, 'fn:namespace-uri')),
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
    (context, arg) => _evalId(arg, _optionalNodeArg(context, null, 'fn:id')),
  ),
  2: XPathFunctionItem.fn2(
    const XmlName.qualified('fn:id'),
    (context, arg, node) => _evalId(arg, _requiredNodeArg(node, 'fn:id')),
  ),
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
      (context, arg) => _evalElementWithId(
        arg,
        _optionalNodeArg(context, null, 'fn:element-with-id'),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:element-with-id'),
      (context, arg, node) =>
          _evalElementWithId(arg, _requiredNodeArg(node, 'fn:element-with-id')),
    ),
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
      (context, arg) =>
          _evalIdref(arg, _optionalNodeArg(context, null, 'fn:idref')),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:idref'),
      (context, arg, node) =>
          _evalIdref(arg, _requiredNodeArg(node, 'fn:idref')),
    ),
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
      (context) =>
          _evalGenerateId(_optionalNodeArg(context, null, 'fn:generate-id')),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:generate-id'),
      (context, arg) =>
          _evalGenerateId(_optionalNodeArg(context, arg, 'fn:generate-id')),
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
      (context) => _evalRoot(_optionalNodeArg(context, null, 'fn:root')),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:root'),
      (context, arg) => _evalRoot(_optionalNodeArg(context, arg, 'fn:root')),
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
      (context) =>
          _evalHasChildren(_optionalNodeArg(context, null, 'fn:has-children')),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:has-children'),
      (context, arg) =>
          _evalHasChildren(_optionalNodeArg(context, arg, 'fn:has-children')),
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
    final list = <XPathNode>[];
    for (final item in nodes) {
      if (item is! XPathNode) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Argument to fn:innermost must be a sequence of nodes, but got ${item.runtimeType}',
        );
      }
      list.add(item);
    }
    final result = <XPathNode>[];
    for (final nodeItem in list) {
      final node = nodeItem.node;
      if (!list.any(
        (other) =>
            node != other.node &&
            node.descendants.any((desc) => desc == other.node),
      )) {
        if (!result.any((existing) => existing.node == node)) {
          result.add(nodeItem);
        }
      }
    }
    return XPathSequence(result);
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
final fnOutermost = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:outermost'),
  (context, nodes) {
    final list = <XPathNode>[];
    for (final item in nodes) {
      if (item is! XPathNode) {
        throw XPathEvaluationException(
          XPathErrorCode.XPTY0004,
          'Argument to fn:outermost must be a sequence of nodes, but got ${item.runtimeType}',
        );
      }
      list.add(item);
    }
    final result = <XPathNode>[];
    for (final nodeItem in list) {
      final node = nodeItem.node;
      if (!list.any(
        (other) =>
            node != other.node &&
            node.ancestors.any((anc) => anc == other.node),
      )) {
        if (!result.any((existing) => existing.node == node)) {
          result.add(nodeItem);
        }
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
      (context) => _evalPath(_optionalNodeArg(context, null, 'fn:path')),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:path'),
      (context, arg) => _evalPath(_optionalNodeArg(context, arg, 'fn:path')),
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
        final prefix = current.name.prefix;
        final uri = prefix != null ? current.name.namespaceUri : null;
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
      case XmlNamespace():
        final prefix = current.prefix;
        if (prefix.isNotEmpty) {
          components.add('namespace::$prefix');
        } else {
          components.add(
            'namespace::*[Q{http://www.w3.org/2005/xpath-functions}local-name()=""]',
          );
        }
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
