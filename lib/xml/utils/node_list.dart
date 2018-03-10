library xml.utils.node_list;

import 'package:collection/collection.dart' show DelegatingList;

import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/owned.dart' show XmlOwned;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/utils/errors.dart'
    show XmlNodeTypeError, XmlParentError;

/// Mutable list of XmlNodes, manages the parenting of the nodes.
class XmlNodeList<E extends XmlNode> extends DelegatingList<E> with XmlOwned {
  /// The shared list of supported node types.
  final Set<XmlNodeType> _validNodeTypes;

  XmlNodeList(this._validNodeTypes) : super(<E>[]);

  @override
  void operator []=(int index, E node) {
    XmlNodeTypeError.checkNotNull(node);
    RangeError.checkValidIndex(index, this);
    XmlNodeTypeError.checkValidType(node, _validNodeTypes);
    XmlParentError.checkNoParent(node);
    this[index].detachParent(parent);
    super[index] = node;
    node.attachParent(parent);
  }

  @override
  set length(int length) =>
      throw new UnsupportedError('Unsupported length change of node list.');

  @override
  void add(E node) {
    XmlNodeTypeError.checkNotNull(node);
    if (node.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
      addAll(_expandFragment(node));
    } else {
      XmlNodeTypeError.checkValidType(node, _validNodeTypes);
      XmlParentError.checkNoParent(node);
      super.add(node);
      node.attachParent(parent);
    }
  }

  @override
  void addAll(Iterable<E> nodes) {
    var expanded = _expandNodes(nodes);
    super.addAll(expanded);
    for (var node in expanded) {
      node.attachParent(parent);
    }
  }

  @override
  bool remove(Object node) {
    bool removed = super.remove(node);
    if (removed) {
      (node as E).detachParent(parent);
    }
    return removed;
  }

  @override
  void removeWhere(bool test(E element)) {
    super.removeWhere((node) {
      var remove = test(node);
      if (remove) {
        node.detachParent(parent);
      }
      return remove;
    });
  }

  @override
  void retainWhere(bool test(E node)) {
    super.retainWhere((node) {
      var retain = test(node);
      if (!retain) {
        node.detachParent(parent);
      }
      return retain;
    });
  }

  @override
  void clear() {
    for (var node in this) {
      node.detachParent(parent);
    }
    super.clear();
  }

  @override
  E removeLast() {
    var node = super.removeLast();
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
  void fillRange(int start, int end, [E fill]) =>
      throw new UnsupportedError('Unsupported range filling of node list.');

  @override
  void setRange(int start, int end, Iterable<E> nodes, [int skipCount = 0]) {
    RangeError.checkValidRange(start, end, length);
    var expanded = _expandNodes(nodes);
    for (var i = start; i < end; i++) {
      this[i].detachParent(parent);
    }
    super.setRange(start, end, expanded, skipCount);
    for (var i = start; i < end; i++) {
      this[i].attachParent(parent);
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<E> nodes) {
    RangeError.checkValidRange(start, end, length);
    var expanded = _expandNodes(nodes);
    for (var i = start; i < end; i++) {
      this[i].detachParent(parent);
    }
    super.replaceRange(start, end, expanded);
    for (var node in expanded) {
      node.attachParent(parent);
    }
  }

  @override
  void setAll(int index, Iterable<E> iterable) =>
      throw new UnimplementedError();

  @override
  void insert(int index, E node) {
    XmlNodeTypeError.checkNotNull(node);
    if (node.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
      insertAll(index, _expandFragment(node));
    } else {
      XmlNodeTypeError.checkValidType(node, _validNodeTypes);
      XmlParentError.checkNoParent(node);
      super.insert(index, node);
      node.attachParent(parent);
    }
  }

  @override
  void insertAll(int index, Iterable<E> nodes) {
    var expanded = _expandNodes(nodes);
    super.insertAll(index, expanded);
    for (var node in expanded) {
      node.attachParent(parent);
    }
  }

  @override
  E removeAt(int index) {
    RangeError.checkValidIndex(index, this);
    this[index].detachParent(parent);
    return super.removeAt(index);
  }

  Iterable<E> _expandFragment(E fragment) {
    return fragment.children.map((node) {
      XmlNodeTypeError.checkValidType(node, _validNodeTypes);
      return node.copy();
    });
  }

  Iterable<E> _expandNodes(Iterable<E> nodes) {
    var expanded = <E>[];
    for (var node in nodes) {
      XmlNodeTypeError.checkNotNull(node);
      if (node.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
        expanded.addAll(_expandFragment(node));
      } else {
        XmlNodeTypeError.checkValidType(node, _validNodeTypes);
        XmlParentError.checkNoParent(node);
        expanded.add(node);
      }
    }
    return expanded;
  }
}
