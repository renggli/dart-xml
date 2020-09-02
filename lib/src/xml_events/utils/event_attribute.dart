import '../../xml/utils/attribute_type.dart';
import 'named.dart';
import 'parented.dart';

/// Immutable attributes of XML events.
class XmlEventAttribute with XmlNamed, XmlParented {
  XmlEventAttribute(this.name, this.value, this.attributeType);

  @override
  final String name;

  final String value;

  final XmlAttributeType attributeType;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;

  @override
  bool operator ==(Object other) =>
      other is XmlEventAttribute &&
      other.name == name &&
      other.value == value &&
      other.attributeType == attributeType;
}
