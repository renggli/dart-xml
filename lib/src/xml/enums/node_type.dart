// ignore_for_file: constant_identifier_names

/// Enum of the different XML node types.
enum XmlNodeType {
  /// An attribute like `id="123"`.
  ATTRIBUTE,

  /// A CDATA section like `<!CDATA[[...]]>`.
  CDATA,

  /// A comment like `<!-- comment -->`.
  COMMENT,

  /// An XML declaration like `<?xml version='1.0'?>`.
  DECLARATION,

  /// A document type declaration like `<!DOCTYPE html>`.
  DOCUMENT_TYPE,

  /// A document object at the root of a document tree.
  DOCUMENT,

  /// A document fragment.
  DOCUMENT_FRAGMENT,

  /// An element node like `<item>`.
  ELEMENT,

  /// An entity declaration like ` <!ENTITY...>`.
  ENTITY,

  /// A notation declaration like `<!NOTATION...>`.
  NOTATION,

  /// A processing instruction like `<?pi test?>`.
  PROCESSING,

  /// The text contents of a node.
  TEXT,
}
