library xml.nodes.node;

import 'package:xml/xml/iterators/ancestors.dart' show XmlAncestorsIterable;
import 'package:xml/xml/iterators/descendants.dart' show XmlDescendantsIterable;
import 'package:xml/xml/iterators/following.dart' show XmlFollowingIterable;
import 'package:xml/xml/iterators/preceding.dart' show XmlPrecedingIterable;
import 'package:xml/xml/nodes/attribute.dart' show XmlAttribute;
import 'package:xml/xml/nodes/cdata.dart' show XmlCDATA;
import 'package:xml/xml/nodes/document.dart' show XmlDocument;
import 'package:xml/xml/nodes/text.dart' show XmlText;
import 'package:xml/xml/utils/child.dart' show XmlOwned;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/utils/writable.dart' show XmlWritable;
import 'package:xml/xml/visitors/visitable.dart' show XmlVisitable;

/// Abstract XML node.
abstract class XmlNode extends Object with XmlVisitable, XmlWritable, XmlOwned {
  /// Return the attribute nodes of this node.
  List<XmlAttribute> get attributes => const [];

  /// Return the direct children of this node.
  List<XmlNode> get children => const [];

  /// Return an iterable of the nodes preceding the opening tag of this node
  /// in document order.
  Iterable<XmlNode> get preceding => new XmlPrecedingIterable(this);

  /// Return an iterable over the descendants of this node (children, grandchildren,
  /// ...) in document order.
  Iterable<XmlNode> get descendants => new XmlDescendantsIterable(this);

  /// Return an iterable of the nodes following the closing tag of this node
  /// in document order.
  Iterable<XmlNode> get following => new XmlFollowingIterable(this);

  /// Return an iterable over the ancestors of this node (parent, grandparent,
  /// ...) in reverse document order.
  Iterable<XmlNode> get ancestors => new XmlAncestorsIterable(this);

  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Return the document that contains this node, or `null` if the node is
  /// not library a document.
  XmlDocument get document => parent == null ? null : parent.document;

  /// Return the first child of this node, or `null` if there are no children.
  XmlNode get firstChild => children.isEmpty ? null : children.first;

  /// Return the last child of this node, or `null` if there are no children.
  XmlNode get lastChild => children.isEmpty ? null : children.last;

  /// Return the text contents of this node and all its descendants.
  String get text => descendants
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.text)
      .join();

  /// Return the next sibling of this node or `null`.
  XmlNode get nextSibling {
    if (parent != null) {
      var siblings = parent.children;
      for (var i = 0; i < siblings.length - 1; i++) {
        if (siblings[i] == this) {
          return siblings[i + 1];
        }
      }
    }
    return null;
  }

  /// Return the previous sibling of this node or `null`.
  XmlNode get previousSibling {
    if (parent != null) {
      var siblings = parent.children;
      for (var i = siblings.length - 1; i > 0; i--) {
        if (siblings[i] == this) {
          return siblings[i - 1];
        }
      }
    }
    return null;
  }
}
