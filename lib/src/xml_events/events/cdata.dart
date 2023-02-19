import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an XML CDATA node.
class XmlCDATAEvent extends XmlEvent {
  XmlCDATAEvent(this.value);

  final String value;

  @Deprecated('Use `XmlCDATAEvent.value` instead.')
  String get text => value;

  @override
  XmlNodeType get nodeType => XmlNodeType.CDATA;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitCDATAEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, value);

  @override
  bool operator ==(Object other) =>
      other is XmlCDATAEvent && other.value == value;
}
