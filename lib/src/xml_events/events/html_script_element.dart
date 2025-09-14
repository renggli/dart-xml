import '../visitor.dart';
import 'start_element.dart';
import 'text.dart';

/// Event of an html script element node.
class HtmlScriptElementEvent extends XmlStartElementEvent {
  HtmlScriptElementEvent(XmlStartElementEvent startEvent, this.codeEvent)
    : super(startEvent.name, startEvent.attributes, startEvent.isSelfClosing);

  final XmlTextEvent codeEvent;

  @override
  void accept(XmlEventVisitor visitor) => visitor
    ..visitStartElementEvent(this)
    ..visitTextEvent(codeEvent);

  @override
  int get hashCode => Object.hash(super.hashCode, codeEvent);

  @override
  bool operator ==(Object other) =>
      other is HtmlScriptElementEvent &&
      super == other &&
      codeEvent == other.codeEvent;
}
