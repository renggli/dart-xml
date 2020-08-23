import '../../../xml.dart' show XmlNodeType;
import '../event.dart';
import '../visitor.dart';

/// Event of an XML text node.
class XmlTextEvent extends XmlEvent {
  const XmlTextEvent(this.text);

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.TEXT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitTextEvent(this);

  @override
  int get hashCode => nodeType.hashCode ^ text.hashCode;

  @override
  bool operator ==(Object other) => other is XmlTextEvent && other.text == text;
}
