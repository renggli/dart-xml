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

  const XPathNodeSet._(this.nodes, this.isSorted);

  /// The empty node-set as a reusable object
  static const empty = XPathNodeSet._([], true);

  final bool isSorted;

  @override
  final List<XmlNode> nodes;

  /// Return the nodes in document order without duplicates.
  /// It can be an expensive operation, so call it only when necessary.
  @override
  List<XmlNode> get sortedNodes =>
      isSorted ? nodes : nodes.sorted((a, b) => a.compareNodePosition(b));

  /// Returns itself if already sorted, otherwise returns a sorted copy.
  XPathNodeSet toSorted() =>
      isSorted ? this : XPathNodeSet._(sortedNodes, true);

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
  bool get boolean => nodes.isNotEmpty;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() {
    final buffer = StringBuffer('[');
    final iterator = nodes.iterator;
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
  const XPathString(this.string);

  /// The empty string as a reusable object.
  static const empty = XPathString('');

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert string "$string" to node-set');

  @override
  final String string;

  @override
  num get number => num.tryParse(string) ?? double.nan;

  @override
  bool get boolean => string.isNotEmpty;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => '"$string"';
}

/// Wrapper around a [num] in XPath.
class XPathNumber extends XPathValue {
  const XPathNumber(this.number);

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert number $number to node-set');

  @override
  String get string => number == 0 ? '0' : number.toString();

  @override
  final num number;

  @override
  bool get boolean => number == 0;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => number.toString();
}

/// Wrapper around a [bool] in XPath.
class XPathBoolean extends XPathValue {
  const XPathBoolean(this.boolean);

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert boolean $boolean to node-set');

  @override
  String get string => boolean ? 'true' : 'false';

  @override
  num get number => boolean ? 1 : 0;

  @override
  final bool boolean;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => '$boolean()';
}
