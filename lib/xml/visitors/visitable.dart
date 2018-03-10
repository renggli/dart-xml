library xml.visitors.visitable;

import 'package:xml/xml/visitors/visitor.dart' show XmlVisitor;

/// Interface for classes that can be visited using an [XmlVisitor].
abstract class XmlVisitable {
  /// Dispatch the invocation depending on this type to the [visitor].
  dynamic accept(XmlVisitor visitor);
}
