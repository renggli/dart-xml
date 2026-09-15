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
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../types/node.dart';
import '../types/string.dart';
import '../values/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-name
const fnName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:name'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnName,
);

XPathSequence _fnName(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
  return switch (node) {
    XmlElement() => XPathSequence.single(node.name.toString()),
    XmlAttribute() => XPathSequence.single(node.name.toString()),
    XmlProcessing() => XPathSequence.single(node.target),
    _ => XPathSequence.emptyString,
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-local-name
const fnLocalName = XPathFunctionDefinition(
  name: XmlName.qualified('fn:local-name'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnLocalName,
);

XPathSequence _fnLocalName(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
  return switch (node) {
    XmlElement() => XPathSequence.single(node.name.local),
    XmlAttribute() => XPathSequence.single(node.name.local),
    XmlProcessing() => XPathSequence.single(node.target),
    _ => XPathSequence.emptyString,
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-namespace-uri
const fnNamespaceUri = XPathFunctionDefinition(
  name: XmlName.qualified('fn:namespace-uri'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnNamespaceUri,
);

XPathSequence _fnNamespaceUri(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
  return switch (node) {
    XmlElement() => XPathSequence.single(node.name.namespaceUri ?? ''),
    XmlAttribute() => XPathSequence.single(node.name.namespaceUri ?? ''),
    _ => XPathSequence.emptyString,
  };
}

/// https://www.w3.org/TR/xpath-functions-31/#func-id
const fnId = XPathFunctionDefinition(
  name: XmlName.qualified('fn:id'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnId,
);

XPathSequence _fnId(XPathContext context, XPathSequence arg, [XmlNode? node]) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = node?.root;
  if (root == null || root is! XmlDocument) return XPathSequence.empty;
  final dtdIds = _getIdAttributes(root);
  return XPathSequence(
    root.descendantElements.where(
      (element) => element.attributes.any(
        (attribute) =>
            _isId(element, attribute, dtdIds) &&
            ids.contains(attribute.value.trim()),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-element-with-id
const fnElementWithId = XPathFunctionDefinition(
  name: XmlName.qualified('fn:element-with-id'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnElementWithId,
);

XPathSequence _fnElementWithId(
  XPathContext context,
  XPathSequence arg, [
  XmlNode? node,
]) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = node?.root;
  if (root == null || root is! XmlDocument) return XPathSequence.empty;
  final dtdIds = _getIdAttributes(root);
  final seen = <String>{};
  return XPathSequence(
    root.descendantElements.where(
      (element) => element.attributes
          .where((attribute) => _isId(element, attribute, dtdIds))
          .any((attribute) {
            final value = attribute.value.trim();
            return ids.contains(value) && seen.add(value);
          }),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-idref
const fnIdref = XPathFunctionDefinition(
  name: XmlName.qualified('fn:idref'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsString,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnIdref,
);

XPathSequence _fnIdref(
  XPathContext context,
  XPathSequence arg, [
  XmlNode? node,
]) {
  final ids = _parseIdStrings(arg);
  if (ids.isEmpty) return XPathSequence.empty;
  final root = node?.root;
  if (root == null || root is! XmlDocument) return XPathSequence.empty;
  final dtdIdrefs = _getIdrefAttributes(root);
  return XPathSequence(
    root.descendantElements.expand(
      (element) => element.attributes.where(
        (attribute) =>
            _isIdref(element, attribute, dtdIdrefs) &&
            attribute.value.trim().split(_whitespace).any(ids.contains),
      ),
    ),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-generate-id
const fnGenerateId = XPathFunctionDefinition(
  name: XmlName.qualified('fn:generate-id'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnGenerateId,
);

XPathSequence _fnGenerateId(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.emptyString;
  final id = identityHashCode(node)
      .toRadixString(16)
      .toUpperCase()
      .padLeft(8, '0');
  return XPathSequence.single('autoId$id');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-root
const fnRoot = XPathFunctionDefinition(
  name: XmlName.qualified('fn:root'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnRoot,
);

XPathSequence _fnRoot(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.empty;
  return XPathSequence.single(node.root);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-has-children
const fnHasChildren = XPathFunctionDefinition(
  name: XmlName.qualified('fn:has-children'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'node',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnHasChildren,
);

XPathSequence _fnHasChildren(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.falseSequence;
  return XPathSequence.single(node.children.isNotEmpty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-innermost
const fnInnermost = XPathFunctionDefinition(
  name: XmlName.qualified('fn:innermost'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnInnermost,
);

XPathSequence _fnInnermost(XPathContext context, XPathSequence nodes) {
  final list = nodes.cast<XmlNode>().toList();
  final result = <XmlNode>[];
  for (final node in list) {
    if (!list.any(
      (other) => node != other && node.descendants.any((desc) => desc == other),
    )) {
      result.add(node);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-outermost
const fnOutermost = XPathFunctionDefinition(
  name: XmlName.qualified('fn:outermost'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'nodes',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrMore,
    ),
  ],
  function: _fnOutermost,
);

XPathSequence _fnOutermost(XPathContext context, XPathSequence nodes) {
  final list = nodes.cast<XmlNode>().toList();
  final result = <XmlNode>[];
  for (final node in list) {
    if (!list.any(
      (other) => node != other && node.ancestors.any((anc) => anc == other),
    )) {
      result.add(node);
    }
  }
  return XPathSequence(result);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-path
const fnPath = XPathFunctionDefinition(
  name: XmlName.qualified('fn:path'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'arg',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
      defaultValue: _defaultToContextItem,
    ),
  ],
  function: _fnPath,
);

XPathSequence _fnPath(XPathContext context, [XmlNode? node]) {
  if (node == null) return XPathSequence.empty;
  if (node is XmlDocument) return const XPathSequence.single('/');
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
  return XPathSequence.single(isDocRoot ? '/$path' : path);
}

final _whitespace = RegExp(r'\s+');

XmlNode _defaultToContextItem(XPathContext context) =>
    xsNode.cast(context.item);

Set<String> _parseIdStrings(XPathSequence arg) => arg
    .map(xsString.cast)
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
