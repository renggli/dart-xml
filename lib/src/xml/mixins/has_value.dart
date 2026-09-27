import '../extensions/string.dart';
import '../nodes/node.dart';

/// Value interface for nodes.
mixin XmlValueBase {
  /// The value of the node, or `null`.
  ///
  /// The returned value depends on the type of the node:
  /// - attributes return their attribute value;
  /// - text, CDATA, and comment nodes return their textual content; and
  /// - processing and declaration nodes return their contents.
  /// All other nodes return `null`.
  String? get value => null;

  /// The concatenated text of this node or its descendants.
  /// text, CDATA, and comment nodes return the textual value of the node.
  @Deprecated(
    'Use [value] to access the textual content of this node, or '
    '[innerText] to access the textual content of its descendants.',
  )
  String get text => XmlStringExtension(this as XmlNode).innerText;
}
