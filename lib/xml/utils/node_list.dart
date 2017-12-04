library xml.utils.node_list;

import 'dart:collection';

import 'package:xml/xml/nodes/node.dart' show XmlNode;
import 'package:xml/xml/utils/owned.dart' show XmlOwned;
import 'package:xml/xml/utils/node_type.dart' show XmlNodeType;
import 'package:xml/xml/utils/errors.dart' show XmlNodeTypeError;

/// Mutable list of XmlNodes, manages the parenting of the nodes.
class XmlNodeList<E extends XmlNode> extends ListBase<E> with XmlOwned {
  /// The list of nodes.
  final List<XmlNode> _nodes = [];

  /// The shared list of supported node types.
  final Set<XmlNodeType> _validNodeTypes;

  XmlNodeList(this._validNodeTypes);

  @override
  int get length => _nodes.length;

  @override
  set length(int length) => _nodes.length = length;

  @override
  E operator [](int index) => _nodes[index];

  @override
  void operator []=(int index, E childNode) {
    RangeError.checkValidIndex(index, _nodes);
    XmlNodeTypeError.checkValidType(childNode, _validNodeTypes);
    if (childNode.hasParent) {
      if (childNode.parent == parent) {
        var oldIndex = _nodes.indexOf(childNode);
        if (oldIndex != index) {
          _nodes[index] = childNode;
          _nodes.removeAt(oldIndex);
        }
        return;
      }
      _removeNode(childNode);
    }
    _nodes[index].detachParent(parent);
    _nodes[index] = childNode;
    childNode.attachParent(parent);
  }

  @override
  void add(E childNode) {
    if (childNode.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
      addAll(childNode.children as Iterable<E>);
      return;
    }
    XmlNodeTypeError.checkValidType(childNode, _validNodeTypes);
    _removeNode(childNode);
    _nodes.add(childNode);
    childNode.attachParent(parent);
  }

  @override
  void addAll(Iterable<E> childNodes) {
    var copiedNodes = new List<E>.from(childNodes);
    for (var childNode in copiedNodes) {
      XmlNodeTypeError.checkValidType(childNode, _validNodeTypes);
    }
    for (var childNode in copiedNodes) {
      _removeNode(childNode);
      _nodes.add(childNode);
      childNode.attachParent(parent);
    }
  }

  @override
  bool remove(Object childNode) {
    bool removed = _nodes.remove(childNode);
    if (removed) {
      (childNode as E).detachParent(parent);
    }
    return removed;
  }

  @override
  void removeWhere(bool test(E node)) => throw new UnimplementedError();

  @override
  void retainWhere(bool test(E node)) => throw new UnimplementedError();

  @override
  void clear() {
    for (var node in _nodes) {
      node.detachParent(parent);
    }
    _nodes.clear();
  }

  @override
  E removeLast() {
    _nodes.last.detachParent(parent);
    return _nodes.removeLast();
  }

  @override
  void removeRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);
    for (var i = start; i < end; i++) {
      _nodes[i].detachParent(parent);
    }
    _nodes.removeRange(start, end);
  }

  @override
  void fillRange(int start, int end, [E fill]) => throw new UnimplementedError();

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) =>
      throw new UnimplementedError();

  @override
  void replaceRange(int start, int end, Iterable<E> newContents) => throw new UnimplementedError();

  @override
  void setAll(int index, Iterable<E> iterable) => throw new UnimplementedError();

  @override
  void insert(int index, E childNode) {
    if (childNode.nodeType == XmlNodeType.DOCUMENT_FRAGMENT) {
      insertAll(index, childNode.children as Iterable<E>);
      return;
    }
    XmlNodeTypeError.checkValidType(childNode, _validNodeTypes);
    if (childNode.hasParent) {
      if (childNode.parent == parent) {
        var oldIndex = _nodes.indexOf(childNode);
        if (oldIndex != index) {
          _nodes[index] = childNode;
          _nodes.removeAt(oldIndex < index ? oldIndex : oldIndex + 1);
        }
        return;
      }
      _removeNode(childNode);
    }
    _nodes.insert(index, childNode);
    childNode.attachParent(parent);
  }

  @override
  void insertAll(int index, Iterable<E> childNodes) {
    RangeError.checkValueInInterval(index, 0, length, 'index');
    var copiedNodes = new List<E>.from(childNodes);
    for (var childNode in copiedNodes) {
      XmlNodeTypeError.checkValidType(childNode, _validNodeTypes);
    }
    for (var childNode in copiedNodes) {
      if (childNode.hasParent) {
        if (childNode.parent == parent) {
          var oldIndex = _nodes.indexOf(childNode);
          if (oldIndex < index) {
            index--;
          }
        }
        _removeNode(childNode);
      }
      childNode.attachParent(parent);
    }
    _nodes.insertAll(index, childNodes);
  }

  @override
  E removeAt(int index) {
    RangeError.checkValueInInterval(index, 0, length, 'index');
    _nodes[index].detachParent(parent);
    return removeAt(index);
  }

  static void _removeNode(XmlNode node) {
    if (node.hasParent) {
      if (node.nodeType == XmlNodeType.ATTRIBUTE) {
        node.parent.attributes.remove(node);
      } else {
        node.parent.children.remove(node);
      }
    }
  }
}
