library xml.visitors.visitable;

import 'visitor.dart';

/// Interface for classes that can be visited using an [XmlVisitor].
mixin XmlVisitable {
  /// Dispatch the invocation depending on this type to the [visitor].
  dynamic accept(XmlVisitor visitor);
}
