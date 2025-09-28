import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../xml/extensions/comparison.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import 'context.dart';
import 'expression.dart';

/// Wrapper of XPath values.
@immutable
sealed class XPathValue implements XPathExpression {
  const XPathValue();

  /// The value.
  dynamic get value;

  /// Returns the **unordered** node-set of this value.
  /// Use [sortedNodes] to get the node-set in document order.
  Iterable<XmlNode> get nodes;

  /// Returns the node-set in document order of this value.
  /// Be aware that this can be an expensive operation.
  Iterable<XmlNode> get sortedNodes => nodes;

  /// Returns the string of this value.
  String get string;

  /// Returns the numerical of this value.
  num get number;

  /// Returns the boolean of this value.
  bool get boolean;
}

/// An unordered collection of nodes without duplicates
class XPathNodeSet implements XPathValue {
  factory XPathNodeSet(
    Iterable<XmlNode> nodes, {
    bool isSortedAndUnique = false,
  }) {
    if (isSortedAndUnique || nodes.length <= 1) {
      return XPathNodeSet._(nodes.toList(growable: false), true);
    }
    final set = nodes is Set<XmlNode> ? nodes : nodes.toSet();
    final list = set.toList(growable: false);
    return XPathNodeSet._(list, false);
  }

  const XPathNodeSet._(this.value, this.isSorted);

  /// The empty node-set as a reusable object
  static const empty = XPathNodeSet._([], true);

  @override
  final List<XmlNode> value;

  final bool isSorted;

  @override
  List<XmlNode> get nodes => value;

  /// Return the nodes in document order without duplicates.
  /// It can be an expensive operation, so call it only when necessary.
  @override
  List<XmlNode> get sortedNodes {
    if (isSorted) {
      return value;
    }
    return value.sorted((a, b) => a.compareNodePosition(b));
  }

  /// Returns itself if already sorted, otherwise returns a sorted copy.
  XPathNodeSet toSorted() {
    if (isSorted) {
      return this;
    }
    return XPathNodeSet._(sortedNodes, true);
  }

  @override
  String get string {
    if (nodes.isEmpty) return '';
    final buffer = StringBuffer();
    _stringForNodeOn(nodes.first, buffer);
    return buffer.toString();
  }

  void _stringForNodeOn(XmlNode node, StringBuffer buffer) {
    if (node is XmlDocument) {
      node = node.rootElement;
    }
    if (node is XmlElement) {
      _stringForElementOn(node, buffer);
    } else {
      buffer.write(node.value ?? '');
    }
  }

  void _stringForElementOn(XmlElement element, StringBuffer buffer) {
    for (final child in element.children) {
      if (child is XmlText) {
        buffer.write(child.value);
      } else if (child is XmlElement) {
        _stringForElementOn(child, buffer);
      }
    }
  }

  @override
  num get number => num.tryParse(string) ?? double.nan;

  @override
  bool get boolean => value.isNotEmpty;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() {
    final buffer = StringBuffer('[');
    final iterator = value.iterator;
    var i = 0;
    while (iterator.moveNext() && i < 3) {
      if (i > 0) buffer.write(', ');
      final inner = StringBuffer();
      _stringForNodeOn(iterator.current, inner);
      if (inner.length > 20) {
        buffer.write(inner.toString().substring(0, 20));
        buffer.write('...');
      } else {
        buffer.write(inner.toString());
      }
      i++;
    }
    if (i >= 3) buffer.write(', ...');
    buffer.write(']');
    return buffer.toString();
  }
}

/// Wrapper around a [String] in XPath.
class XPathString extends XPathValue {
  const XPathString(this.value);

  /// The empty string as a reusable object.
  static const empty = XPathString('');

  @override
  final String value;

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert string "$value" to node-set');

  @override
  String get string => value;

  @override
  num get number => num.tryParse(string) ?? double.nan;

  @override
  bool get boolean => value.isNotEmpty;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => '"$value"';
}

/// Wrapper around a [num] in XPath.
class XPathNumber extends XPathValue {
  const XPathNumber(this.value);

  @override
  final num value;

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert number $value to node-set');

  @override
  String get string => value == 0 ? '0' : value.toString();

  @override
  num get number => value;

  @override
  bool get boolean => value == 0;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => value.toString();
}

/// Wrapper around a [bool] in XPath.
class XPathBoolean extends XPathValue {
  const XPathBoolean(this.value);

  @override
  final bool value;

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert boolean $value to node-set');

  @override
  String get string => value ? 'true' : 'false';

  @override
  num get number => value ? 1 : 0;

  @override
  bool get boolean => value;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => '$value()';
}
