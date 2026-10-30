import '../enums/attribute_type.dart';
import '../utils/token.dart';

/// Immutable DTD external identifier.
///
/// An external identifier can be a `SYSTEM` identifier (specifying a system URI)
/// or a `PUBLIC` identifier (specifying a public identifier along with a system URI).
///
/// For example:
///
/// ```dart
/// // SYSTEM "note.dtd"
/// final systemId = DtdExternalId.system('note.dtd', XmlAttributeType.DOUBLE_QUOTE);
///
/// // PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
/// final publicId = DtdExternalId.public(
///   '-//W3C//DTD XHTML 1.0 Strict//EN',
///   XmlAttributeType.DOUBLE_QUOTE,
///   'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd',
///   XmlAttributeType.DOUBLE_QUOTE,
/// );
/// ```
class DtdExternalId {
  /// Creates an external ID with a public identifier and a system identifier.
  new public(
    String this.publicId,
    XmlAttributeType this.publicIdType,
    this.systemId,
    this.systemIdType,
  );

  /// Creates an external ID with a system identifier.
  new system(this.systemId, this.systemIdType)
    : publicId = null,
      publicIdType = null;

  /// The public identifier for the external subset, or `null` if this is a `SYSTEM` ID.
  final String? publicId;

  /// The quote type used for the [publicId], or `null`.
  final XmlAttributeType? publicIdType;

  /// The system identifier (URI) for the external subset.
  final String systemId;

  /// The quote type used for the [systemId].
  final XmlAttributeType systemIdType;

  @override
  String toString() {
    final buffer = StringBuffer();
    if (publicId != null) {
      buffer.write(XmlToken.doctypePublicId);
      buffer.write(XmlToken.whitespace);
      buffer.write(publicIdType!.token);
      buffer.write(publicId);
      buffer.write(publicIdType!.token);
    } else {
      buffer.write(XmlToken.doctypeSystemId);
    }
    buffer.write(XmlToken.whitespace);
    buffer.write(systemIdType.token);
    buffer.write(systemId);
    buffer.write(systemIdType.token);
    return buffer.toString();
  }

  @override
  int get hashCode => Object.hash(systemId, publicId);

  @override
  bool operator ==(Object other) =>
      other is DtdExternalId &&
      publicId == other.publicId &&
      systemId == other.systemId;
}
