library xml.utils.exceptions;

import '../nodes/node.dart';
import 'node_type.dart';
import 'owned.dart';

/// Abstract exception class.
abstract class XmlException implements Exception {
  /// A message describing the XML error.
  final String message;

  /// Creates a new XmlException with an optional error [message].
  XmlException([this.message]);

  @override
  String toString() => message ?? super.toString();
}

/// Exception thrown when parsing of an XML document fails.
class XmlParserException extends XmlException implements FormatException {
  /// The source input which caused the error.
  final String buffer;

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
  String get source => buffer;

  @override
  int get offset => position;

  @override
  String toString() => '${super.toString()} at $line:$column';
}

/// Exception thrown when an unsupported node type is used.
class XmlNodeTypeException extends XmlException {
  /// Ensure that [node] is not null.
  static void checkNotNull(XmlNode node) {
    if (node == null) {
      throw XmlNodeTypeException('Node must not be null.');
    }
  }

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
  /// Ensure that [owned] has no parent.
  static void checkNoParent(XmlOwned owned) {
    if (owned.hasParent) {
      throw XmlParentException(
          'Node already has a parent, copy or remove it first: $owned');
    }
  }

  /// Creates a new XmlParentException.
  XmlParentException(String message) : super(message);
}

/// Exception thrown when the end tag does not match the open tag.
class XmlTagException extends XmlException {
  /// Creates a new XmlTagException.
  XmlTagException(String message) : super(message);
}
