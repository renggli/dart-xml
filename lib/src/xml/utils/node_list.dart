import 'package:collection/collection.dart' show DelegatingList;
import 'package:meta/meta.dart';

import '../enums/node_type.dart';
import '../exceptions/type_exception.dart';
import '../nodes/attribute.dart';
import '../nodes/document_fragment.dart';
import '../nodes/node.dart';

/// Mutable list of [XmlNode]s that manages parent relationships according to
/// DOM semantics:
///
/// - Nodes added to this list are automatically detached from their previous
///   parent (whether in this list or another), rather than throwing.
/// - [XmlDocumentFragment] nodes are transparently expanded into their
///   children before insertion.
/// - Each mutating operation is atomic: the entire input is validated before
///   any structural change is made.
class XmlNodeList<E extends XmlNode> extends DelegatingList<E> {
  final List<E> _inner;
  late final XmlNode _parent;
  late final Set<XmlNodeType> _nodeTypes;

  // Construction

  factory XmlNodeList() => XmlNodeList._(<E>[]);
  XmlNodeList._(this._inner) : super(_inner);

  @internal
  void initialize(XmlNode parent, Set<XmlNodeType> nodeTypes) {
    _parent = parent;
    _nodeTypes = nodeTypes;
  }

  // Unsupported operations

  @override
  set length(int length) =>
      throw UnsupportedError('Unsupported length change of node list');

  @override
  void fillRange(int start, int end, [E? fillValue]) =>
      throw UnsupportedError('Unsupported range filling of node list');

  @override
  void setAll(int index, Iterable<E> iterable) =>
      throw UnsupportedError('Unsupported setAll on node list');

  // Insertion operations

  @override
  void add(E value) {
    final operation = _XmlNodeListOperation<E>(this);
    operation.expand(value);
    operation.commitAppend();
  }

  @override
  void addAll(Iterable<E> iterable) {
    final operation = _XmlNodeListOperation<E>(this);
    operation.expandAll(iterable);
    operation.commitAppend();
  }

  @override
  void insert(int index, E element) {
    RangeError.checkValueInInterval(index, 0, length, 'index');
    final operation = _XmlNodeListOperation<E>(this);
    operation.expand(element);
    operation.commitInsert(index);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    RangeError.checkValueInInterval(index, 0, length, 'index');
    final operation = _XmlNodeListOperation<E>(this);
    operation.expandAll(iterable);
    operation.commitInsert(index);
  }

  @override
  void operator []=(int index, E value) {
    RangeError.checkValidIndex(index, this);
    final operation = _XmlNodeListOperation<E>(this);
    operation.expand(value);
    operation.commitReplaceRange(index, index + 1);
  }

  // Replacement operations

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    RangeError.checkValidRange(start, end, length);
    final operation = _XmlNodeListOperation<E>(this);
    operation.expandAll(iterable);
    operation.commitReplaceRange(start, end);
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final operation = _XmlNodeListOperation<E>(this);
    operation.expandAll(iterable.skip(skipCount));
    operation.commitReplaceRange(start, end);
  }

  // Removal operations

  @override
  bool remove(Object? value) {
    final index = value is E ? indexOf(value) : -1;
    if (index < 0) return false;
    removeAt(index);
    return true;
  }

  @override
  E removeAt(int index) {
    RangeError.checkValidIndex(index, this);
    final node = _inner[index];
    node.detachParent(_parent);
    _inner.removeAt(index);
    return node;
  }

  @override
  E removeLast() {
    if (isEmpty) throw RangeError.index(0, this, 'index', null, 0);
    return removeAt(length - 1);
  }

  @override
  void removeRange(int start, int end) {
    RangeError.checkValidRange(start, end, length);
    for (var i = start; i < end; i++) {
      _inner[i].detachParent(_parent);
    }
    _inner.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(E element) test) {
    _inner.removeWhere((node) {
      if (!test(node)) return false;
      node.detachParent(_parent);
      return true;
    });
  }

  @override
  void retainWhere(bool Function(E node) test) {
    _inner.removeWhere((node) {
      if (test(node)) return false;
      node.detachParent(_parent);
      return true;
    });
  }

  @override
  void clear() => removeRange(0, length);
}

/// Collects, validates, and atomically commits a set of changes to an
/// [XmlNodeList].
///
/// Workflow:
/// 1. Call [expand] or [expandAll] with the input nodes (resolves
///    [XmlDocumentFragment]s and deduplicates nodes).
/// 2. Call one of the `commit*` methods to validate, detach from old parents,
///    apply the structural change, and re-attach to the new parent — all or
///    nothing.
class _XmlNodeListOperation<E extends XmlNode> {
  /// Creates an operation for the given [target].
  _XmlNodeListOperation(this.target);

  /// The set of seen nodes during expansion to deduplicate them.
  final seen = <XmlNode>{};

  /// The sequence of expanded and deduplicated nodes to be inserted.
  final List<E> source = [];

  /// The target list to insert the nodes into.
  final XmlNodeList<E> target;

  /// Maps every node currently in [target] to its original index.
  /// Built lazily only if same-list moves are detected.
  late final Map<E, int> originalIndex = {
    for (var i = 0; i < target._inner.length; i++) target._inner[i]: i,
  };

  /// Expands [node] into [source], resolving [XmlDocumentFragment]s and
  /// deduplicating: each unique node is recorded only on first encounter.
  void expand(E node) {
    if (node is XmlDocumentFragment) {
      for (final child in node.children) {
        expand(child as E);
      }
    } else {
      if (seen.add(node)) source.add(node);
    }
  }

  /// Expands [nodes] into [source], resolving [XmlDocumentFragment]s and
  /// deduplicating: each unique node is recorded only on first encounter.
  void expandAll(Iterable<E> nodes) {
    for (final node in nodes) {
      expand(node);
    }
  }

  /// Validates every node in [source] against [XmlNodeList._nodeTypes].
  void _validate() {
    for (final node in source) {
      XmlNodeTypeException.checkValidType(node, target._nodeTypes);
    }
  }

  /// Removes all nodes in [source] that currently live in [target], processing
  /// them in descending index order so earlier removals do not invalidate later
  /// indices.
  ///
  /// Returns the count of removed nodes whose original index was strictly less
  /// than [beforeIndex]; the caller uses this to adjust its target position.
  int _removeSameListNodes({int beforeIndex = -1}) {
    if (!source.any((node) => node.parent == target._parent)) return 0;

    var adjustment = 0;
    final indices = <int>[];
    for (final node in source) {
      if (node.parent == target._parent) {
        indices.add(originalIndex[node]!);
      }
    }
    indices.sort((a, b) => b.compareTo(a));
    for (final i in indices) {
      if (i < beforeIndex) adjustment++;
      target._inner[i].detachParent(target._parent);
      target._inner.removeAt(i);
    }
    return adjustment;
  }

  /// Removes nodes in [source] that currently live in a different list.
  void _removeOtherParentNodes() {
    for (final node in source) {
      if (node.parent != target._parent) {
        final parent = node.parent;
        if (parent != null) {
          _detachFromCurrentParent(parent, node);
        }
      }
    }
  }

  /// Removes [node] from whichever [XmlNodeList] currently owns it via the
  /// public API, keeping parent relationships consistent.
  static void _detachFromCurrentParent(XmlNode parent, XmlNode node) {
    if (node is XmlAttribute) {
      parent.attributes.remove(node);
    } else {
      parent.children.remove(node);
    }
  }

  /// Attaches all expanded nodes to the owning parent node.
  void _attachAll() {
    for (final node in source) {
      node.attachParent(target._parent);
    }
  }

  /// Validates and appends all nodes to the end of [target].
  void commitAppend() {
    _validate();
    _removeSameListNodes();
    _removeOtherParentNodes();
    target._inner.addAll(source);
    _attachAll();
  }

  /// Validates and inserts all nodes at [index].
  void commitInsert(int index) {
    _validate();
    final adjustment = _removeSameListNodes(beforeIndex: index);
    _removeOtherParentNodes();
    target._inner.insertAll(index - adjustment, source);
    _attachAll();
  }

  /// Validates and replaces [target]`[start..end]` with [source].
  ///
  /// Same-list nodes **outside** `[start, end)` are removed first and adjust
  /// the range bounds. Same-list nodes **inside** the range are treated as
  /// part of the replaced content: they are detached by the range-clear step
  /// and then re-attached if they are also in [source].
  void commitReplaceRange(int start, int end) {
    _validate();
    var startAdjust = 0;
    final outsideIndices = <int>[];
    if (source.any((node) => node.parent == target._parent)) {
      for (final node in source) {
        if (node.parent == target._parent) {
          if (originalIndex[node] case final i? when i < start || i >= end) {
            outsideIndices.add(i);
            if (i < start) startAdjust++;
          }
        }
      }
    }
    outsideIndices.sort((a, b) => b.compareTo(a));
    for (final i in outsideIndices) {
      target._inner[i].detachParent(target._parent);
      target._inner.removeAt(i);
    }
    _removeOtherParentNodes();
    final adjStart = start - startAdjust;
    final adjEnd = end - startAdjust;
    for (var i = adjStart; i < adjEnd; i++) {
      target._inner[i].detachParent(target._parent);
    }
    target._inner.replaceRange(adjStart, adjEnd, source);
    _attachAll();
  }
}
