import '../xml/extensions/parent.dart';
import '../xml/nodes/attribute.dart';
import '../xml/nodes/cdata.dart';
import '../xml/nodes/comment.dart';
import '../xml/nodes/document.dart';
import '../xml/nodes/element.dart';
import '../xml/nodes/namespace.dart';
import '../xml/nodes/node.dart';
import '../xml/nodes/processing.dart';
import '../xml/nodes/text.dart';

extension XPathGenerator on XmlNode {
  /// Generates an XPath expression that selects this node.
  String xpathGenerate() => xpathNodePath(this);
}

/// Generates the canonical XPath 3.1 path for [node] per W3C `fn:path`.
String xpathNodePath(XmlNode node) {
  if (node is XmlDocument) return '/';
  final components = <String>[];
  XmlNode? current = node;
  while (current != null && current is! XmlDocument) {
    switch (current) {
      case XmlElement():
        final local = current.name.local;
        final prefix = current.name.prefix;
        final uri = current.name.namespaceUri;
        final siblings =
            current.parent?.children.whereType<XmlElement>() ?? const [];
        var index = 1;
        for (final sibling in siblings) {
          if (identical(sibling, current)) break;
          if (uri != null && uri.isNotEmpty) {
            if (sibling.name.local == local &&
                sibling.name.namespaceUri == uri) {
              index++;
            }
          } else {
            if (sibling.name.qualified == current.name.qualified) {
              index++;
            }
          }
        }
        if (uri != null && uri.isNotEmpty) {
          components.add('Q{$uri}$local[$index]');
        } else if (prefix != null && prefix.isNotEmpty) {
          components.add('$prefix:$local[$index]');
        } else {
          components.add('Q{}$local[$index]');
        }
      case XmlAttribute():
        final local = current.name.local;
        final prefix = current.name.prefix;
        final uri = prefix != null ? current.name.namespaceUri : null;
        if (uri != null && uri.isNotEmpty) {
          components.add('@Q{$uri}$local');
        } else if (prefix != null && prefix.isNotEmpty) {
          components.add('@$prefix:$local');
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
        components.add(
          target.isEmpty
              ? 'processing-instruction()[$index]'
              : 'processing-instruction($target)[$index]',
        );
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
  return isDocRoot ? '/$path' : path;
}
