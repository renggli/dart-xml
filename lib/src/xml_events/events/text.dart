import '../../xml/entities/entity_mapping.dart';
import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an XML text node.
class XmlTextEvent extends XmlEvent {
  XmlTextEvent(this.value);

  final String value;

  @Deprecated('Use `XmlTextEvent.value` instead.')
  String get text => value;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitTextEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, value);

  @override
  bool operator ==(Object other) =>
      other is XmlTextEvent && other.value == value;
}

/// Internal event of an XML text node that is lazily decoded.
class XmlRawTextEvent extends XmlEvent implements XmlTextEvent {
  XmlRawTextEvent(this.raw, this.entityMapping);

  final String raw;

  final XmlEntityMapping entityMapping;

  @override
  late final String value = entityMapping.decode(raw);

  @override
  String get text => value;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitTextEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, value);

  @override
  bool operator ==(Object other) =>
      other is XmlTextEvent && other.value == value;
}
