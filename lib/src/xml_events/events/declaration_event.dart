library xml_events.events.declaration_event;

import 'package:collection/collection.dart';

import '../../../xml.dart' show XmlNodeType;
import '../event.dart';
import '../visitor.dart';
import 'event_attribute.dart';

/// Event of an XML declaration.
class XmlDeclarationEvent extends XmlEvent {
  XmlDeclarationEvent(this.attributes);

  final List<XmlEventAttribute> attributes;

  @override
  XmlNodeType get nodeType => XmlNodeType.DECLARATION;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitDeclarationEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ const ListEquality().hash(attributes);

  @override
  bool operator ==(Object other) =>
      other is XmlDeclarationEvent &&
      const ListEquality().equals(other.attributes, attributes);
}
