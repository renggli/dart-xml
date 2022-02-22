import 'exception.dart';
import 'format_exception.dart';

/// Exception thrown when parsing of an XML document fails.
class XmlParserException extends XmlException with XmlFormatException {
  /// Creates a new XmlParserException.
  XmlParserException(String message, {this.buffer, this.position})
      : super(message);

  @override
  String? buffer;

  @override
  int? position;

  @override
  String toString() => 'XmlParserException: $message at $line:$column';
}
