library xml.nodes.node;

import '../mixins/has_attributes.dart';
import '../mixins/has_children.dart';
import '../mixins/has_parent.dart';
import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';
import '../navigation/descendants.dart';
import '../utils/node_type.dart';
import 'cdata.dart';
import 'text.dart';

/// Immutable abstract XML node.
abstract class XmlNode extends Object
    with
        XmlParentBase,
        XmlAttributesBase,
        XmlChildrenBase,
        XmlHasVisitor,
        XmlHasWriter {
  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Return the text contents of this node and all its descendants.
  String get text => descendants
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.text)
      .join();
}
