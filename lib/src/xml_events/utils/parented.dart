import '../events/start_element.dart';
import '../streams/with_parent.dart';

/// Mixin with information about the parent event.
mixin XmlParented {
  /// Return the parent event of type [XmlStartElementEvent], or `null`.
  ///
  /// The parent event is not set by default. It is only available if the
  /// event stream is annotated with [XmlWithParentEvents].
  ///
  /// Do not write this field! It will become a `late final` field once
  /// dart.dev/null-safety is fully launched.
  XmlStartElementEvent parentEvent;
}
