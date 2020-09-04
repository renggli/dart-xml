import '../events/start_element.dart';
import '../streams/with_parent.dart';

/// Mixin with information about the parent event.
mixin XmlParented {
  /// Hold a lazy reference to the parent event.
  /* final late */ XmlStartElementEvent _parentEvent;

  /// Return the parent event of type [XmlStartElementEvent], or `null`.
  ///
  /// The parent event is not set by default. It is only available if the
  /// event stream is annotated with [XmlWithParentEvents].
  XmlStartElementEvent get parentEvent => _parentEvent;

  /// Internal helper to attach a parent to this child, do not call directly.
  void attachParentEvent(XmlStartElementEvent parentEvent) {
    if (_parentEvent != null) {
      // '_parentEvent' will become 'final late' which throws if the field is
      // already assigned, simulate this behavior until Dart supports it.
      throw StateError('Parent event already resolved.');
    }
    if (parentEvent != null) {
      // '_parentEvent' will become 'final late' which only allows a single
      // assignment, so do not perform an unnecessary assignment.
      _parentEvent = parentEvent;
    }
  }
}
