import '../extensions/parent.dart';
import '../nodes/element.dart';
import '../nodes/namespace.dart';
import '../nodes/node.dart';
import '../utils/namespace.dart' as ns;

/// Namespace interface for nodes.
mixin XmlNamespacesBase {
  /// The in-scope namespaces of this node.
  Iterable<XmlNamespace> get namespaces => const [];

  /// Looks up the namespace URI associated with [prefix] in-scope for this node, or `null`.
  ///
  /// Passing `null` or `''` looks up the default element namespace URI.
  String? lookupNamespaceUri(String? prefix) => null;

  /// Looks up the prefix associated with [namespaceUri] in-scope for this node, or `null`.
  String? lookupPrefix(String namespaceUri) => null;
}

/// Mixin for nodes with namespaces.
mixin XmlHasNamespaces implements XmlNamespacesBase, XmlNode {
  @override
  String? lookupNamespaceUri(String? prefix) {
    final searchPrefix = prefix ?? '';
    for (final ns in namespaces) {
      if (ns.prefix == searchPrefix) return ns.uri;
    }
    return null;
  }

  @override
  String? lookupPrefix(String namespaceUri) {
    for (final ns in namespaces) {
      if (ns.uri == namespaceUri) return ns.prefix;
    }
    return null;
  }

  @override
  Iterable<XmlNamespace> get namespaces sync* {
    final prefixes = <String>{};
    for (XmlNode? current = this; current != null; current = current.parent) {
      if (current is XmlElement) {
        for (final attribute in current.attributes) {
          if (attribute.name.prefix == ns.xmlns) {
            if (prefixes.add(attribute.name.local) &&
                attribute.value.isNotEmpty) {
              yield XmlNamespace(attribute.name.local, attribute.value)
                ..attachParent(current);
            }
          } else if (attribute.name.local == ns.xmlns &&
              attribute.name.prefix == null) {
            if (prefixes.add('') && attribute.value.isNotEmpty) {
              yield XmlNamespace('', attribute.value)..attachParent(current);
            }
          }
        }
      }
    }
    if (prefixes.add(ns.xml)) {
      yield XmlNamespace(ns.xml, ns.xmlUri)..attachParent(root);
    }
  }
}
