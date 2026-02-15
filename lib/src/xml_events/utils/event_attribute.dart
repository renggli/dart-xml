import '../../xml/enums/attribute_type.dart';
import '../annotations/has_name.dart';
import '../annotations/has_parent.dart';

/// Immutable attributes of XML events.
class XmlEventAttribute with XmlHasName, XmlHasParent {
  XmlEventAttribute(this.name, this.value, this.attributeType);

  @override
  final String name;

  final String value;

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
