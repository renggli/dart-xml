/// Enum of the different XML Node types.
enum XmlNodeType {
  /// An attribute node, e.g. `id="123"`.
  ATTRIBUTE,

  /// Raw character data (CDATA), e.g.  `<![CDATA[escaped text]]>`.
  CDATA,

  /// A comment, e.g. `<!-- comment -->`.
  COMMENT,

  /// A xml declaration, e.g. `<?xml version='1.0'?>`.
  DECLARATION,

  /// A document type declaration, e.g. `<!DOCTYPE html>`.
  DOCUMENT_TYPE,

  /// A document object.
  DOCUMENT,

  /// A document fragment, e.g. `#document-fragment`.
  DOCUMENT_FRAGMENT,

  /// An element node, e.g. `<item>` or `<item />`.
  ELEMENT,

  /// A processing instruction, e.g. `<?pi test?>`.
  PROCESSING,

  /// Text content within a node.
  TEXT,
}
