// ignore_for_file: constant_identifier_names

/// Enum of the different XML node types.
enum XmlNodeType {
  /// An attribute like `id="123"`.
  ATTRIBUTE,

  /// A CDATA section like `<![CDATA[...]]>`.
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

  /// A namespace node.
  NAMESPACE,

  /// A notation declaration like `<!NOTATION...>`.
  NOTATION,

  /// A processing instruction like `<?pi test?>`.
  PROCESSING,

  /// The text contents of a node.
  TEXT,
}

/// Supported child node types for document and document fragment nodes.
const Set<XmlNodeType> documentChildrenNodeTypes = {
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.DECLARATION,
  XmlNodeType.DOCUMENT_TYPE,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
};

/// Supported child node types for element nodes.
const Set<XmlNodeType> elementChildrenNodeTypes = {
  XmlNodeType.CDATA,
  XmlNodeType.COMMENT,
  XmlNodeType.ELEMENT,
  XmlNodeType.PROCESSING,
  XmlNodeType.TEXT,
};

/// Supported attribute node types.
const Set<XmlNodeType> attributeNodeTypes = {XmlNodeType.ATTRIBUTE};
