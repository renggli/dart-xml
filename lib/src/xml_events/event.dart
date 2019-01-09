library xml_events.events.event;

import 'package:xml/xml/utils/node_type.dart';

abstract class XmlEvent {
  /// Return the node type of this node.
  XmlNodeType get nodeType;
}
