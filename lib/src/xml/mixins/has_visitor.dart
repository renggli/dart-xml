import '../visitors/visitor.dart';

/// Mixin for classes that can be visited using an [XmlVisitor].
mixin XmlHasVisitor {
  /// Dispatch the invocation depending on this type to the [visitor].
  dynamic accept(XmlVisitor visitor);
}
