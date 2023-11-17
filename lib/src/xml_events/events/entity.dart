import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an entity element within a DTD.
class XmlEntityEvent extends XmlEvent {
  XmlEntityEvent();

  @override
  XmlNodeType get nodeType => XmlNodeType.ENTITY;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitEntityEvent(this);

  @override
  int get hashCode => nodeType.hashCode;

  @override
  bool operator ==(Object other) => other is XmlEntityEvent;
}
