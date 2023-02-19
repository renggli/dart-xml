import '../mixins/has_parent.dart';
import 'node.dart';

/// Abstract XML data node.
abstract class XmlData extends XmlNode with XmlHasParent<XmlNode> {
  /// Create a data section with `value`.
  XmlData(this.value);

  // The textual value of this node.
  @override
  String value;

  @Deprecated('Use `XmlData.value` getter instead')
  @override
  String get text => value;

  @Deprecated('Use `XmlData.value` setter instead')
  set text(String text) => value = text;
}
