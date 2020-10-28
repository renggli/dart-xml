import '../xml/utils/node_type.dart';
import 'converters/event_encoder.dart';
import 'utils/parented.dart';
import 'visitor.dart';

/// Immutable base class for all events.
abstract class XmlEvent with XmlParented {
  XmlEvent();

  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Dispatch to the [visitor] based on event type.
  void accept(XmlEventVisitor visitor);

  @override
  String toString() => XmlEventEncoder().convert([this]);
}
