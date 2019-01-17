library xml_events.event;

import 'package:xml/xml.dart' show XmlNodeType;

import 'codec.dart';
import 'visitor.dart';

/// Base class for all XML events.
abstract class XmlEvent {
  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Dispatch to the [visitor] based on event type.
  dynamic accept(XmlEventVisitor visitor);

  @override
  String toString() => '$runtimeType: ${const XmlCodec().encode([this])}';
}
