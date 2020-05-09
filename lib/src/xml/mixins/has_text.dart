library xml.mixins.has_text;

import '../navigation/descendants.dart';
import '../nodes/cdata.dart';
import '../nodes/data.dart';
import '../nodes/text.dart';
import 'has_children.dart';

/// Mixin for nodes with text.
mixin XmlHasText implements XmlChildrenBase {
  /// Return the text contents of this node and all its descendants.
  @Deprecated('Use `innerText` instead')
  String get text => innerText;

  /// Return the text contents of this node and all its descendants.
  String get innerText => XmlDescendantsIterable(this)
      .whereType<XmlData>()
      .where((node) => node is XmlText || node is XmlCDATA)
      .map((node) => node.text)
      .join();

  /// Replaces the children of this node with text contents.
  set innerText(String value) {
    children.clear();
    if (value != null && value.isNotEmpty) {
      children.add(XmlText(value));
    }
  }
}
