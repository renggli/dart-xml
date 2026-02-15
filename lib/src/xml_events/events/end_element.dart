import '../../xml/enums/node_type.dart';
import '../annotations/has_name.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an closing XML element node.
class XmlEndElementEvent extends XmlEvent with XmlHasName {
  XmlEndElementEvent(this.name);

  @override
  final String name;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitEndElementEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, name);

  @override
  bool operator ==(Object other) =>
      other is XmlEndElementEvent && other.name == name;
}
