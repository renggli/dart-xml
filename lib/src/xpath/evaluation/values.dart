import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import 'context.dart';
import 'expression.dart';

/// Wrapper of XPath values.
@immutable
sealed class XPathValue implements XPathExpression {
  /// The value.
  dynamic get value;

  /// Returns the node-set of this value.
  Iterable<XmlNode> get nodes;

  /// Returns the string of this value.
  String get string;

  /// Returns the numerical of this value.
  num get number;

  /// Returns the boolean of this value.
  bool get boolean;
}

/// Wrapper around an [Iterable] of [XmlNode]s in XPath.
class XPathNodeSet implements XPathValue {
  /// Creates a new [XPathNodeSet] from the given [nodes].
  factory XPathNodeSet(Iterable<XmlNode> nodes) {
    final set = Set.unmodifiable(nodes);
    if (set.length == 1) {
      return XPathNodeSet._(set.toList(), true);
    }
    return XPathNodeSet._(set, false);
  }

  /// Creates a new [XPathNodeSet] from the given sorted [nodes].
  /// The nodes must be sorted in document order and unique.
  factory XPathNodeSet.fromSortedUniqueNodes(Iterable<XmlNode> nodes) {
    assert(nodes is! Set<XmlNode>, 'Nodes must not be an unordered set');
    return XPathNodeSet._(List.unmodifiable(nodes), true);
  }

  XPathNodeSet._(this.value, this.isSorted);

  static final empty = XPathNodeSet._([], true);

  @override
  final Iterable<XmlNode> value;

  final bool isSorted;

  @override
  Iterable<XmlNode> get nodes => value;

  List<XmlNode> get _list {
    assert(isSorted);
    return value as List<XmlNode>;
  }

  final Map<XmlNode, int> _positions = {};

  XPathNodeSet toSorted() {
    if (isSorted) return this;
    final list = value.sortedBy(getPosition);
    return XPathNodeSet._(list, true);
  }

  int getPosition(XmlNode node, [int? hintPosition]) {
    if (isSorted && hintPosition != null && _list[hintPosition - 1] == node) {
      return hintPosition;
    }
    if (_positions.isEmpty) {
      _computePositions();
      assert(_positions.length == value.length);
    }
    return _positions[node]!;
  }

  /// Compute the position of each node in this set.
  void _computePositions() {
    assert(_positions.isEmpty);

    if (isSorted) {
      final list = _list;
      for (var i = 0; i < list.length; i++) {
        _positions[list.elementAt(i)] = i + 1;
      }
      return;
    }

    var pos = 1;

    void visit(XmlNode node) {
      if (value.contains(node)) {
        _positions[node] = pos++;
      }
      for (final child in node.children) {
        visit(child);
      }
      for (final attribute in node.attributes) {
        visit(attribute);
      }
    }

    final root = _computeLCA();
    visit(root);
  }

  /// Compute the least common ancestor of all nodes in this set.
  /// Time complexity is O(n) where n is the total number of distinct nodes in the paths from the tree root to each node.
  ///
  /// Implementation:
  /// 1. We find the ancestors set (S) of the first node.
  /// 2. For each node, we traverse its ancestors until we find one (x) in S.
  /// 3. For each such x, the one with the largest distance to the first node is the LCA.
  XmlNode _computeLCA() {
    final ancestorToDist = <XmlNode, int>{};
    var lca = value.first;
    XmlNode? p = lca;
    XmlNode? root;
    var dist = 0;
    while (p != null) {
      ancestorToDist[p] = dist++;
      root = p;
      p = p.parent;
    }
    assert(root != null);
    dist = 0;
    final visited = <XmlNode>{lca};
    outer:
    for (final each in value) {
      p = each;
      while (!ancestorToDist.containsKey(p)) {
        if (visited.contains(p)) {
          continue outer;
        }
        visited.add(p!);
        p = p.parent;
        assert(p != null);
      }
      final curDist = ancestorToDist[p]!;
      if (curDist > dist) {
        dist = curDist;
        lca = p!;
        if (lca == root) {
          break;
        }
      }
    }
    return lca;
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
class XPathString implements XPathValue {
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
class XPathNumber implements XPathValue {
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
class XPathBoolean implements XPathValue {
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
