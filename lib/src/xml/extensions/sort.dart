import '../nodes/node.dart';

extension XmlSortExtension on Iterable<XmlNode> {
  /// Returns a [List] of the nodes sorted in document order.
  List<XmlNode> sortedInDocumentOrder() {
    /// Overview of the algorithm:
    /// 1. Build the minimal unordered tree that contains all nodes in the list.
    /// 2. Count each node in the list.
    /// 3. Convert the unordered tree to an ordered tree.
    /// 4. Traverse the ordered tree in pre-order to produce the final sorted list.
    /// Check https://github.com/renggli/dart-xml/issues/196 for more details.
    final list = this is List<XmlNode> ? this as List<XmlNode> : toList();
    if (list.length < 2) return list;
    final first = list.first;
    final unorderedTree = <XmlNode, Set<XmlNode>>{first: {}};
    // Build the minimal unordered tree that contains all nodes in the list.
    var itr = first;
    var root = first;
    while (itr.parent != null) {
      final p = itr.parent!;
      unorderedTree[p] = {itr};
      itr = p;
      root = p;
    }
    for (var i = 1; i < list.length; i++) {
      final node = list[i];
      if (unorderedTree.containsKey(node)) {
        continue;
      }
      unorderedTree[node] = {};
      itr = node;
      while (itr.parent != null) {
        final p = itr.parent!;
        if (unorderedTree.containsKey(p)) {
          unorderedTree[p]!.add(itr);
          break;
        }
        unorderedTree[p] = {itr};
        itr = p;
      }
      if (itr.parent == null) {
        // From the `node` to its root, nothing was found in the existing tree.
        // It means this `node` shares no common ancestor with the first node at least.
        throw StateError('Nodes do not share the same root');
      }
    }
    // Count each node in the list.
    final counts = <XmlNode, int>{};
    for (final node in list) {
      if (!counts.containsKey(node)) {
        counts[node] = 1;
      } else {
        counts[node] = counts[node]! + 1;
      }
    }
    // Two operations at a time:
    // - Convert the unordered tree to an ordered tree.
    // - Traverse the ordered tree in pre-order to produce the final sorted list.
    final stack = <XmlNode>[root];
    final result = <XmlNode>[];
    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (counts.containsKey(node)) {
        final count = counts[node]!;
        for (var i = 0; i < count; i++) {
          result.add(node);
        }
      }
      final set = unorderedTree[node]!;
      if (set.isEmpty) {
        continue;
      }
      if (set.length == 1) {
        stack.add(set.first);
        continue;
      }
      var cnt = 0;
      done:
      for (final children in [node.children, node.attributes]) {
        for (var i = children.length - 1; i >= 0; i--) {
          final child = children[i];
          if (set.contains(child)) {
            stack.add(child);
            if (++cnt == set.length) {
              break done;
            }
          }
        }
      }
      assert(cnt == set.length);
    }
    assert(result.length == list.length);
    return result;
  }
}
