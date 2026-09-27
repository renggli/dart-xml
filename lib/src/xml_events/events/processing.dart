import '../../xml/enums/node_type.dart';
import '../event.dart';
import '../visitor.dart';

/// Event of an XML processing node.
class XmlProcessingEvent extends XmlEvent {
  /// Creates a processing event with [target] and [value].
  new(this.target, this.value);

  /// The processing target.
  final String target;

  /// The processing value.
  final String value;

  @Deprecated('Use `XmlProcessingEvent.value` instead.')
  String get text => value;

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitProcessingEvent(this);

  @override
  int get hashCode => Object.hash(nodeType, value, target);

  @override
  bool operator ==(Object other) =>
      other is XmlProcessingEvent &&
      other.target == target &&
      other.value == value;
}
