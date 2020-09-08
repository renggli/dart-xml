import '../mixins/has_parent.dart';
import '../nodes/node.dart';
import 'node_type.dart';

/// Abstract exception class.
abstract class XmlException implements Exception {
  /// A message describing the XML error.
  final String message;

  /// Creates a new XmlException with an optional error [message].
  XmlException(this.message);

  @override
  String toString() => '${super.toString}: $message';
}

/// Exception thrown when parsing of an XML document fails.
class XmlParserException extends XmlException implements FormatException {
  /// The source input which caused the error.
  final String? buffer;

  /// The offset in [buffer] where the error was detected.
  final int position;

  /// The line number where the parser error was detected.
  final int line;

  /// The column number where the parser error was detected.
  final int column;

  /// Creates a new XmlParserException.
  XmlParserException(String message,
      {this.buffer, this.position = 0, this.line = 0, this.column = 0})
      : super(message);

  @override
  String? get source => buffer;

  @override
  int? get offset => position;

  @override
  String toString() => '${super.toString()} at $line:$column';
}

/// Exception thrown when an unsupported node type is used.
class XmlNodeTypeException extends XmlException {
  /// Ensure that [node] is of one of the provided [types].
  static void checkValidType(XmlNode node, Iterable<XmlNodeType> types) {
    if (!types.contains(node.nodeType)) {
      throw XmlNodeTypeException('Expected node of type: $types');
    }
  }

  /// Creates a new XmlNodeTypeException.
  XmlNodeTypeException(String message) : super(message);
}

/// Exception thrown when the parent relationship between nodes is invalid.
class XmlParentException extends XmlException {
  /// Ensure that [node] has no parent.
  static void checkNoParent(XmlParentBase node) {
    if (node.parent != null) {
      throw XmlParentException(
          'Node already has a parent, copy or remove it first: $node');
    }
  }

  /// Ensure that [node] has a matching parent.
  static void checkMatchingParent(XmlParentBase node, XmlNode parent) {
    if (node.parent != parent) {
      // If this exception is ever thrown, this is likely a bug in the internal
      // code of the library.
      throw XmlParentException('Node already has a non-matching parent: $node');
    }
  }

  /// Creates a new XmlParentException.
  XmlParentException(String message) : super(message);
}

/// Exception thrown when the end tag does not match the open tag.
class XmlTagException extends XmlException {
  /// Ensure that the [expected] tag matches the [actual] one.
  static void checkClosingTag(String expected, String actual) {
    if (expected != actual) {
      throw XmlTagException.mismatchClosingTag(expected, actual);
    }
  }

  /// Creates a new XmlTagException.
  XmlTagException(String message) : super(message);

  /// Creates a new XmlTagException where [expectedName] was expected, but
  /// instead we found [actualName].
  factory XmlTagException.mismatchClosingTag(
          String expectedName, String actualName) =>
      XmlTagException('Expected closing tag </$expectedName>, '
          'but found </$actualName>.');

  /// Creates a new XmlTagException for an unexpected closing tag.
  factory XmlTagException.unexpectedClosingTag(String name) =>
      XmlTagException('Unexpected closing tag </$name>.');

  /// Creates a new XmlTagException for a missing closing tag.
  factory XmlTagException.missingClosingTag(String name) =>
      XmlTagException('Missing closing tag </$name>.');
}
