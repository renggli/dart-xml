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

/// Extension providing XPath generator capabilities on [XmlNode].
extension XPathGenerator on XmlNode {
  /// Generates a canonical XPath 3.1 path expression that selects this node.
  ///
  /// The generated path conforms to the W3C XPath 3.1 `fn:path` specification.
  /// Paths starting from an [XmlDocument] root begin with `/`. Elements without
  /// an explicit namespace URI use `Q{}` notation, while elements with a
  /// namespace URI use `Q{uri}` notation followed by a 1-based positional index
  /// among matching sibling elements.
  ///
  /// For example:
  ///
  /// ```dart
  /// final document = XmlDocument.parse('<root><item>first</item><item>second</item></root>');
  /// final secondItem = document.findAllElements('item').last;
  /// print(secondItem.xpathGenerate()); // /Q{}root[1]/Q{}item[2]
  /// ```
  String xpathGenerate() => xpathNodePath(this);
}

/// Generates the canonical XPath 3.1 path for [node] per W3C `fn:path`.
///
/// Returns `/` for an [XmlDocument]. For elements, attributes, text nodes,
/// comments, processing instructions, and namespaces, produces an absolute
/// path if the root is an [XmlDocument], or a relative path otherwise.
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
