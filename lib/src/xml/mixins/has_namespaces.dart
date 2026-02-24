import '../nodes/element.dart';
import '../nodes/namespace.dart';
import '../nodes/node.dart';
import '../utils/namespace.dart' as ns;

/// Namespace interface for nodes.
mixin XmlNamespacesBase {
  /// Return the in-scope namespaces of this node.
  Iterable<XmlNamespace> get namespaces => const [];
}

/// Mixin for nodes with namespaces.
mixin XmlHasNamespaces implements XmlNamespacesBase, XmlNode {
  @override
  Iterable<XmlNamespace> get namespaces sync* {
    final prefixes = <String>{};
    for (XmlNode? current = this; current != null; current = current.parent) {
      if (current is XmlElement) {
        for (final attribute in current.attributes) {
          if (attribute.name.prefix == ns.xmlns) {
            if (prefixes.add(attribute.name.local) &&
                attribute.value.isNotEmpty) {
              yield XmlNamespace(attribute.name.local, attribute.value);
            }
          } else if (attribute.name.local == ns.xmlns &&
              attribute.name.prefix == null) {
            if (prefixes.add('') && attribute.value.isNotEmpty) {
              yield XmlNamespace('', attribute.value);
            }
          }
        }
      }
    }
    if (prefixes.add(ns.xml)) {
      yield XmlNamespace(ns.xml, ns.xmlUri);
    }
  }
}
