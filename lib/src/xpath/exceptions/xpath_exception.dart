import '../../xml/exceptions/exception.dart';
import '../../xml/exceptions/format_exception.dart';

/// Exception thrown when parsing of an XPath expression fails.
class XPathException extends XmlException with XmlFormatException {
  XPathException(super.message, {this.buffer, this.position});

  @override
  final String? buffer;

  @override
  final int? position;

  @override
  String toString() => 'XPathException: $message at $locationString';
}
