library xml.utils.node_list;

import 'package:collection/collection.dart' show DelegatingList;
import 'package:xml/src/xml/nodes/node.dart';
import 'package:xml/src/xml/utils/exceptions.dart';
import 'package:xml/src/xml/utils/node_type.dart';
import 'package:xml/src/xml/utils/owned.dart';

/// Mutable list of XmlNodes, manages the parenting of the nodes.
class XmlNodeList<E extends XmlNode> extends DelegatingList<E> with XmlOwned {
  XmlNodeList(this.validNodeTypes) : super(<E>[]);

  /// Return the shared list of supported node types.
  final Set<XmlNodeType> validNodeTypes;

  @override
  void operator []=(int index, E value) {
    XmlNodeTypeException.checkNotNull(value);
    RangeError.checkValidIndex(index, this);
    XmlNodeTypeException.checkValidType(value, validNodeTypes);
    XmlParentException.checkNoParent(value);
    this[index].detachParent(parent);
    super[index] = value;
    value.attachParent(parent);
  }

  @override
  set length(int length) =>
      throw UnsupportedError('Unsupported length change of node list.');

  @override
  void add(E value) {
    XmlNodeTypeException.checkNotNull(value);
    if (value.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
      addAll(_expandFragment(value));
    } else {
      XmlNodeTypeException.checkValidType(value, validNodeTypes);
      XmlParentException.checkNoParent(value);
      super.add(value);
      value.attachParent(parent);
    }
  }

  @override
  void addAll(Iterable<E> iterable) {
    final expanded = _expandNodes(iterable);
    super.addAll(expanded);
    for (final node in expanded) {
      node.attachParent(parent);
    }
  }

  @override
  bool remove(Object value) {
    final removed = super.remove(value);
    if (removed) {
      final E node = value;
      node.detachParent(parent);
    }
    return removed;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    super.removeWhere((node) {
      final remove = test(node);
      if (remove) {
        node.detachParent(parent);
      }
      return remove;
    });
  }

  @override
  void retainWhere(bool Function(E node) test) {
    super.retainWhere((node) {
      final retain = test(node);
      if (!retain) {
        node.detachParent(parent);
      }
      return retain;
    });
  }

  @override
  void clear() {
    for (final node in this) {
      node.detachParent(parent);
    }
    super.clear();
  }

  @override
  E removeLast() {
    final node = super.removeLast();
    node.detachParent(parent);
    return node;
  }

  @override
  void removeRange(int start, int end) {
    RangeError.checkValidRange(start, end, length);
    for (var i = start; i < end; i++) {
      this[i].detachParent(parent);
    }
    super.removeRange(start, end);
  }

  @override
  void fillRange(int start, int end, [E fillValue]) =>
      throw UnsupportedError('Unsupported range filling of node list.');

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    final expanded = _expandNodes(iterable);
    for (var i = start; i < end; i++) {
      this[i].detachParent(parent);
    }
    super.setRange(start, end, expanded, skipCount);
    for (var i = start; i < end; i++) {
      this[i].attachParent(parent);
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<E> iterable) {
    RangeError.checkValidRange(start, end, length);
    final expanded = _expandNodes(iterable);
    for (var i = start; i < end; i++) {
      this[i].detachParent(parent);
    }
    super.replaceRange(start, end, expanded);
    for (final node in expanded) {
      node.attachParent(parent);
    }
  }

  @override
  void setAll(int index, Iterable<E> iterable) => throw UnimplementedError();

  @override
  void insert(int index, E element) {
    XmlNodeTypeException.checkNotNull(element);
    if (element.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
      insertAll(index, _expandFragment(element));
    } else {
      XmlNodeTypeException.checkValidType(element, validNodeTypes);
      XmlParentException.checkNoParent(element);
      super.insert(index, element);
      element.attachParent(parent);
    }
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    final expanded = _expandNodes(iterable);
    super.insertAll(index, expanded);
    for (final node in expanded) {
      node.attachParent(parent);
    }
  }

  @override
  E removeAt(int index) {
    RangeError.checkValidIndex(index, this);
    this[index].detachParent(parent);
    return super.removeAt(index);
  }

  Iterable<E> _expandFragment(E fragment) => fragment.children.map((node) {
        XmlNodeTypeException.checkValidType(node, validNodeTypes);
        return node.copy();
      });

  Iterable<E> _expandNodes(Iterable<E> iterable) {
    final expanded = <E>[];
    for (final node in iterable) {
      XmlNodeTypeException.checkNotNull(node);
      if (node.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
        expanded.addAll(_expandFragment(node));
      } else {
        XmlNodeTypeException.checkValidType(node, validNodeTypes);
        XmlParentException.checkNoParent(node);
        expanded.add(node);
      }
    }
    return expanded;
  }
}
