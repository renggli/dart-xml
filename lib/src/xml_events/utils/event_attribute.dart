library xml_events.events.event_attribute;

import 'package:meta/meta.dart';

import '../../xml/utils/attribute_type.dart';
import 'named.dart';

/// Attributes of XML event.
@immutable
class XmlEventAttribute with XmlNamed {
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
