import 'exception.dart';
import 'format_exception.dart';

/// Exception thrown when there is an error with a namespace.
class XmlNamespaceException extends XmlException with XmlFormatException {
  /// Creates a new [XmlNamespaceException].
  XmlNamespaceException(super.message, {this.buffer, this.position});

  /// Creates a new XmlTagException where [namespacePrefix] could not be
  /// resolved.
  factory XmlNamespaceException.unknownNamespacePrefix(
    String namespacePrefix, {
    String? buffer,
    int? position,
  }) => XmlNamespaceException(
    'Unknown namespace prefix: $namespacePrefix',
    buffer: buffer,
    position: position,
  );

  @override
  String? buffer;

  @override
  int? position;

  @override
  String toString() => 'XmlNamespaceException: $message$locationString';
}
