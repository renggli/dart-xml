import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an notation within a DTD.
class XmlNotationEvent extends XmlEvent {
  XmlNotationEvent();

  @override
  XmlNodeType get nodeType => XmlNodeType.ENTITY;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitNotationEvent(this);

  @override
  int get hashCode => nodeType.hashCode;

  @override
  bool operator ==(Object other) => other is XmlNotationEvent;
}
