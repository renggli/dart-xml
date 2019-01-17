library xml_events.event.processing_event;

import 'package:xml/xml.dart';

import '../event.dart';

class XmlProcessingEvent extends XmlEvent {
  XmlProcessingEvent(this.target, this.text);

  final String target;

  final String text;

  @override
  XmlNodeType get nodeType => XmlNodeType.PROCESSING;

  @override
  void encode(StringBuffer buffer) {
    buffer.write(XmlToken.openProcessing);
    buffer.write(target);
    if (text.isNotEmpty) {
      buffer.write(XmlToken.whitespace);
      buffer.write(text);
    }
    buffer.write(XmlToken.closeProcessing);
  }
}
