library xml_events.event;

import 'package:xml/xml.dart';

/// Base class for all XML events.
abstract class XmlEvent {
  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Encodes this event onto a buffer.
  void encode(StringBuffer buffer);

  @override
  String toString() {
    final buffer = StringBuffer('$runtimeType: ');
    encode(buffer);
    return buffer.toString();
  }
}
