library xml_events.event;

import 'package:xml/xml.dart' show XmlNodeType;

import 'converters/event_encoder.dart';
import 'visitor.dart';

/// Base class for all events.
abstract class XmlEvent {
  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Dispatch to the [visitor] based on event type.
  void accept(XmlEventVisitor visitor);

  @override
  String toString() => const XmlEventEncoder().convert([this]);
}
