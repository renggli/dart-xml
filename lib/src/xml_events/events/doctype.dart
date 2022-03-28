import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an XML doctype node.
class XmlDoctypeEvent extends XmlEvent {
  XmlDoctypeEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitDoctypeEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, text);

  @override
  bool operator ==(Object other) =>
      other is XmlDoctypeEvent && other.text == text;
}
