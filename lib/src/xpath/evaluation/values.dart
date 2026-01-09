import 'package:meta/meta.dart';

import '../../xml/extensions/comparison.dart';
import '../../xml/extensions/descendants.dart';
import '../../xml/extensions/parent.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../exceptions/evaluation_exception.dart';
import 'context.dart';
import 'expression.dart';

/// Wrapper of XPath values.
@immutable
sealed class XPathValue implements XPathExpression {
  /// Returns the node-set (unique and in document-order) of this value.
  List<XmlNode> get nodes;

  /// Returns the string of this value.
  String get string;

  /// Returns the numerical of this value.
  num get number;

  /// Returns the boolean of this value.
  bool get boolean;
}

/// Wrapper around an [Iterable] of unique [XmlNode]s in document-order.
class XPathNodeSet implements XPathValue {
  /// Constructs a node-set from a list of unique `nodes` in document-order.
  XPathNodeSet(this.nodes) {
    assert(() {
      for (var i = 1; i < nodes.length; i++) {
        if (nodes[i - 1].compareNodePosition(nodes[i]) >= 0) {
          return false;
        }
      }
      return true;
    }(), 'Nodes are required to be unique and in document-order');
  }

  /// Constructs a node-set from a single `node`.
  XPathNodeSet.single(XmlNode node) : nodes = [node];

  /// Constructs a node-set from an iterable of `nodes`. Unless told oltherwise,
  /// removes duplicates and orders the nodes in document-order.
  ///
  /// The implementaiton tries to avoid unnecessary allocation and copying of
  /// nodes. If a lot of nodes need to be sorted, the document-order nodes are
  /// extracted from a full traversal of the node tree.
  factory XPathNodeSet.fromIterable(
    Iterable<XmlNode> nodes, {
    bool isUnique = false,
    bool isSorted = false,
  }) {
    // Short path, if this is a trivial case.
    switch (nodes.length) {
      case 0:
        return XPathNodeSet.empty;
      case 1:
        return XPathNodeSet(nodes is List<XmlNode> ? nodes : nodes.toList());
    }
    // Compute the unique nodes, if required.
    if (!isUnique && nodes is! Set<XmlNode>) {
      nodes = nodes.toSet();
    }
    // Sort the nodes, if required.
    if (!isSorted) {
      // https://github.com/renggli/dart-xml/issues/196
      if (nodes.length < 50) {
        final list = nodes is List<XmlNode> ? nodes : nodes.toList();
        list.sort((a, b) => a.compareNodePosition(b));
        return XPathNodeSet(list);
      } else {
        final selected = nodes is Set<XmlNode> ? nodes : nodes.toSet();
        return XPathNodeSet(
          nodes.first.root.descendants.where(selected.contains).toList(),
        );
      }
    }
    return XPathNodeSet(nodes is List<XmlNode> ? nodes : nodes.toList());
  }

  /// The empty node-set as a reusable object.
  static const empty = XPathNodeSet._([]);

  const XPathNodeSet._(this.nodes);

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
  List<XmlNode> get nodes =>
      throw XPathEvaluationException('$this cannot be converted to a node-set');

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

  XPathNumber.fromString(String input) : this(num.parse(input));

  @override
  List<XmlNode> get nodes =>
      throw XPathEvaluationException('$this cannot be converted to a node-set');

  @override
  String get string => number == 0 ? '0' : number.toString();

  @override
  final num number;

  @override
  bool get boolean => !(number == 0 || number.isNaN);

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => number.toString();
}

/// Wrapper around a [bool] in XPath.
class XPathBoolean implements XPathValue {
  const XPathBoolean(this.boolean);

  @override
  List<XmlNode> get nodes =>
      throw XPathEvaluationException('$this cannot be converted to a node-set');

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

/// Wrapper around a [List] in XPath.
class XPathArray<T> implements XPathValue {
  const XPathArray(this.members);

  final List<XPathValue> members;

  @override
  List<XmlNode> get nodes =>
      throw XPathEvaluationException('$this cannot be converted to a node-set');

  @override
  String get string =>
      throw XPathEvaluationException('$this cannot be converted to a string');

  @override
  num get number => double.nan;

  @override
  bool get boolean => members.isNotEmpty;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() => 'array { ${members.join(', ')} }';
}

/// Wrapper around a [Map] in XPath.
class XPathMap<K, V> implements XPathValue {
  const XPathMap(this.members);

  final Map<K, V> members;

  @override
  List<XmlNode> get nodes =>
      throw XPathEvaluationException('$this cannot be converted to a node-set');

  @override
  String get string =>
      throw XPathEvaluationException('$this cannot be converted to a string');

  @override
  num get number => double.nan;

  @override
  bool get boolean => members.isNotEmpty;

  @override
  XPathValue call(XPathContext context) => this;

  @override
  String toString() {
    final entries = members.entries.map(
      (entry) => '${entry.key}: ${entry.value}',
    );
    return 'map { ${entries.join(', ')} }';
  }
}
