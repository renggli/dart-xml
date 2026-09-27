import '../../xml/exceptions/exception.dart';
import '../../xml/exceptions/format_exception.dart';

/// Exception thrown when parsing of an XPath expression fails.
class XPathParserException extends XmlException with XmlFormatException {
  /// Creates a parser exception with [message], [buffer], and [position].
  new(super.message, {this.buffer, this.position});

  @override
  final String? buffer;

  @override
  final int? position;

  @override
  String toString() => 'XPathParserException: $message$locationString';
}
