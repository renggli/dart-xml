library xml.utils.exceptions;

import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/utils/owned.dart';

/// Abstract exception class.
abstract class XmlException implements Exception {
  final String message;

  XmlException([this.message]);

  @override
  String toString() => message ?? super.toString();
}

/// Exception thrown when parsing of an XML document fails.
class XmlParserException extends XmlException {
  final int line;
  final int column;

  XmlParserException(String message, this.line, this.column) : super(message);

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

  XmlParentException(String message) : super(message);
}

/// Exception thrown when the end tag does not match the open tag.
class XmlTagException extends XmlException {
  XmlTagException(String message) : super(message);
}
