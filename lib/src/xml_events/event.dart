import 'package:meta/meta.dart';

import '../../xml.dart' show XmlNodeType;
import 'converters/event_encoder.dart';
import 'visitor.dart';

/// Immutable base class for all events.
@immutable
abstract class XmlEvent {
  const XmlEvent();

  /// Return the node type of this node.
  XmlNodeType get nodeType;

  /// Dispatch to the [visitor] based on event type.
  void accept(XmlEventVisitor visitor);

  @override
  String toString() => const XmlEventEncoder().convert([this]);
}
