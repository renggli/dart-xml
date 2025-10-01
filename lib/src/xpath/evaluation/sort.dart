import 'dart:collection';

import '../../xml/nodes/node.dart';

extension NodeSetSortExtension on Iterable<XmlNode> {
  List<XmlNode> sortedInDocumentOrder({required bool isUnique}) =>
      isUnique ? _sorted(this) : _sortedWithDuplicates(this);
}

class _Item {
  int childCount;
  XmlNode? lastChild;

  _Item(this.childCount, [this.lastChild]);
}

/// Returns a [List] of the nodes sorted in document order.
/// There must be no duplicate nodes in the input.
List<XmlNode> _sorted(Iterable<XmlNode> input) {
  /// Overview of the algorithm:
  /// - Collect all the nodes of a minimal subtree that contains all the target nodes.
  /// - Traverse the minimal subtree nodes in document order to collect the target nodes.
  /// Check https://github.com/renggli/dart-xml/issues/196 for more details.
  final list = input is List<XmlNode> ? input : input.toList();
  if (list.length < 2) return list;
  final set = HashSet<XmlNode>.identity()..addAll(list);
  assert(set.length == list.length, 'Input contains duplicate nodes');
  final first = list.first;
  final nodeItems = HashMap<XmlNode, _Item>.identity();
  nodeItems[first] = _Item(0);
  var current = first;
  var root = first;
  while (current.parent != null) {
    final p = current.parent!;
    nodeItems[p] = _Item(1, current);
    current = p;
    root = p;
  }
  nodeLoop:
  for (var i = 1; i < list.length; i++) {
    final node = list[i];
    if (nodeItems.containsKey(node)) continue;
    nodeItems[node] = _Item(0);
    current = node;
    while (current.parent != null) {
      final p = current.parent!;
      if (nodeItems.containsKey(p)) {
        final item = nodeItems[p]!;
        item.childCount++;
        item.lastChild = current;
        continue nodeLoop;
      }
      nodeItems[p] = _Item(1, current);
      current = p;
    }
    // From the `node` to its root, nothing was found in the existing tree.
    // It means this `node` shares no common ancestor with the first node at least.
    throw StateError('Nodes do not share the same root');
  }
  final stack = <XmlNode>[root];
  final result = <XmlNode>[];
  while (stack.isNotEmpty) {
    final node = stack.removeLast();
    final item = nodeItems[node]!;
    if (set.contains(node)) {
      result.add(node);
      if (item.childCount == 0) continue;
    }
    if (item.childCount == 1) {
      stack.add(item.lastChild!);
      continue;
    }
    var count = 0;
    done:
    for (final children in [node.children, node.attributes]) {
      for (var i = children.length - 1; i >= 0; i--) {
        final child = children[i];
        if (nodeItems.containsKey(child)) {
          stack.add(child);
          if (++count == item.childCount) break done;
        }
      }
    }
  }
  assert(result.length == list.length);
  return result;
}

List<XmlNode> _sortedWithDuplicates(Iterable<XmlNode> input) {
  final counts = HashMap<XmlNode, int>.identity();
  for (final node in input) {
    counts[node] = (counts[node] ?? 0) + 1;
  }
  final sorted = _sorted(counts.keys);
  final result = <XmlNode>[];
  for (final node in sorted) {
    final count = counts[node]!;
    for (var i = 0; i < count; i++) {
      result.add(node);
    }
  }
  return result;
}
