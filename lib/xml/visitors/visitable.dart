part of xml;

/// Interface for classes that can be visited using an [XmlVisitor].
abstract class XmlVisitable {

  /// Dispatch the invocation depending on this type to the [visitor].
  E accept<E>(XmlVisitor<E> visitor);

}
