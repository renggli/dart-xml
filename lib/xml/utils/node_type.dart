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

  /// A document fragment.
  DOCUMENT_FRAGMENT,

  /// A document type declaration, e.g. `<!DOCTYPE...>`.
  DOCUMENT_TYPE,
}

/// Enum of the different XML Node types that [xml.reader.XmlPushReader] emits.
///
/// This is a subset of [XmlNodeType], as [xml.reader.XmlPushReader] does not
/// emit [XmlNodeType.DOCUMENT] or [XmlNodeType.DOCUMENT_FRAGMENT] node types.
/// It also does not emit [XmlNodeType.ATTRIBUTE]s, instead providing accessors
/// for them when parsing an [XmlPushReaderNodeType.ELEMENT].
enum XmlPushReaderNodeType {
  /// An element start or self-closed tag, e.g. `<item>` or `<item />`.
  ELEMENT,

  /// An element closing tag, e.g. `</item>`.
  END_ELEMENT,

  /// Text content within a node.
  TEXT,

  /// Raw character data (CDATA), e.g.  `<![CDATA[escaped text]]>`.
  CDATA,

  /// A processing instruction, e.g. `<?pi test?>`.
  PROCESSING,

  /// A comment, e.g. `<!-- comment -->`.
  COMMENT,

  /// A document type declaration, e.g. `<!DOCTYPE...>`.
  DOCUMENT_TYPE,
}
