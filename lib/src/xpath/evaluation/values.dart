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
  /// Returns the node-set (unique and in document-order) of this value.
  Iterable<XmlNode> get nodes;

  /// Returns the string of this value.
  String get string;

  /// Returns the numerical of this value.
  num get number;

  /// Returns the boolean of this value.
  bool get boolean;
}

/// Wrapper around an [Iterable] of unique [XmlNode]s in document-order.
class XPathNodeSet implements XPathValue {
  /// Constructs a new node-set from `nodes`. By default we assume that the
  /// input require sorting (`isSorted = false`) and deduplication (`isUnique
  /// = false`).
  factory XPathNodeSet(
    Iterable<XmlNode> nodes, {
    bool isUnique = false,
    bool isSorted = false,
  }) {
    final hasMultipleNodes = nodes.length > 1;
    if (hasMultipleNodes && !isUnique) {
      isSorted = false;
      nodes = nodes.toSet();
    }
    final list = nodes.toList(growable: false);
    if (hasMultipleNodes && !isSorted) {
      list.sort((a, b) => a.compareNodePosition(b));
    }
    return XPathNodeSet._(list);
  }

  /// Constructs a new node-set from a single `node`.
  factory XPathNodeSet.single(XmlNode node) => XPathNodeSet._([node]);

  /// Constructs a node node-set from a list of unique nodes in document-order.
  const XPathNodeSet._(this.nodes);

  /// The empty node-set as a reusable object.
  static const empty = XPathNodeSet._([]);

  @override
  final List<XmlNode> nodes;

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
class XPathString implements XPathValue {
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
class XPathNumber implements XPathValue {
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
class XPathBoolean implements XPathValue {
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
