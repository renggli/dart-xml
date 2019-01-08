library xml.utils.node_type;

/// Enum of the different XML Node types.
enum XmlNodeType {
  /// An element node, e.g. `<item>` or `<item />`.
  ELEMENT,

  /// An attribute node, e.g. `id="123"`.
  ATTRIBUTE,

  /// Text content within a node.
  TEXT,

  /// Raw character data (CDATA), e.g.  `<![CDATA[escaped text]]>`.
  CDATA,

  /// A processing instruction, e.g. `<?pi test?>`.
  PROCESSING,

  /// A comment, e.g. `<!-- comment -->`.
  COMMENT,

  /// A document object.
  DOCUMENT,

  /// A document fragment, e.g. `#document-fragment`.
  DOCUMENT_FRAGMENT,

  /// A document type declaration, e.g. `<!DOCTYPE html>`.
  DOCUMENT_TYPE,
}
