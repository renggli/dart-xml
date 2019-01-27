library xml_events.event;

import 'package:xml/src/xml_events/converters/event_encoder.dart';
import 'package:xml/src/xml_events/visitor.dart';
import 'package:xml/xml.dart' show XmlNodeType;

/// Immutable base class for all events.
abstract class XmlEvent {
  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Dispatch to the [visitor] based on event type.
  void accept(XmlEventVisitor visitor);

  @override
  String toString() => const XmlEventEncoder().convert([this]);
}
