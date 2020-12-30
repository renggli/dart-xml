import 'package:meta/meta.dart';

import '../events/start_element.dart';
import '../streams/with_parent.dart';

/// Mixin with information about the parent event.
mixin XmlParented {
  /// Hold a lazy reference to the parent event.
  XmlStartElementEvent? _parentEvent;

  /// Return the parent event of type [XmlStartElementEvent], or `null`.
  ///
  /// The parent event is not set by default. It is only available if the
  /// event stream is annotated with [XmlWithParentEvents].
  XmlStartElementEvent? get parentEvent => _parentEvent;

  /// Internal helper to attach a parent to this child, do not call directly.
  @internal
  void attachParentEvent(XmlStartElementEvent? parentEvent) {
    if (_parentEvent != null) {
      throw StateError('Parent event already resolved.');
    }
    _parentEvent = parentEvent;
  }
}
