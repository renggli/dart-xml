import '../../xml/enums/attribute_type.dart';
import '../annotations/has_name.dart';
import '../annotations/has_parent.dart';

/// Immutable attribute of an XML event.
class XmlEventAttribute with XmlHasName, XmlHasParent {
  /// Creates an attribute with [name], [value], and [attributeType].
  new(this.name, this.value, this.attributeType);

  @override
  final String name;

  /// The attribute value.
  final String value;

  /// The attribute quote type.
  final XmlAttributeType attributeType;

  @override
  int get hashCode => Object.hash(name, value, attributeType);

  @override
  bool operator ==(Object other) =>
      other is XmlEventAttribute &&
      other.name == name &&
      other.value == value &&
      other.attributeType == attributeType;
}
