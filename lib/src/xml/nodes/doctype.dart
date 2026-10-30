import '../dtd/external_id.dart';
import '../enums/node_type.dart';
import '../mixins/has_parent.dart';
import '../visitors/visitor.dart';
import 'node.dart';

/// XML doctype node (`<!DOCTYPE ...>`).
///
/// Represents an XML Document Type Declaration containing a root element [name],
/// an optional [externalId] referencing an external DTD subset, and an optional
/// [internalSubset] string containing markup declarations.
///
/// For example:
///
/// ```dart
/// final doc = XmlDocument.parse('<!DOCTYPE note SYSTEM "note.dtd"><note/>');
/// final doctype = doc.doctypeElement!;
/// print(doctype.name); // note
/// print(doctype.externalId?.systemId); // note.dtd
/// ```
class XmlDoctype extends XmlNode with XmlHasParent<XmlNode> {
  /// Creates a doctype node with [name], optional [externalId], and [internalSubset].
  new(this.name, [this.externalId, this.internalSubset]);

  /// The root element name declared by this document type declaration.
  final String name;

  /// The external ID of the declaration referencing a DTD, or `null`.
  final DtdExternalId? externalId;

  /// The complete internal subset of declarations as a [String], or `null`.
  final String? internalSubset;

  @override
  XmlNodeType get nodeType => XmlNodeType.DOCUMENT_TYPE;

  @override
  XmlDoctype copy() => XmlDoctype(name, externalId, internalSubset);

  @override
  void accept(XmlVisitor visitor) => visitor.visitDoctype(this);
}
