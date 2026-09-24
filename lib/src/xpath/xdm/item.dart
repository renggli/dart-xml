import '../../xml/extensions/string.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/comment.dart';
import '../../xml/nodes/data.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/document_fragment.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/nodes/text.dart';
import 'atomic.dart';
import 'types.dart';

/// Base interface for all items in the XDM 3.1 data model.
abstract interface class XPathItem {
  /// The XDM type of this item.
  XPathType get type;

  /// Atomizes this item into an [XPathAtomic] value.
  XPathAtomic atomize();

  /// Canonical string representation of this item.
  String get stringValue;

  /// Effective boolean value (EBV) of this item.
  bool get effectiveBooleanValue;

  /// Converts this item to a native Dart value.
  Object? toValue();
}

/// Represents an XML node item in the XDM 3.1 data model.
final class XPathNode implements XPathItem {
  const new(this.node);

  /// The underlying XML DOM node.
  final XmlNode node;

  @override
  XPathType get type => switch (node) {
    XmlElement() => xsElement,
    XmlAttribute() => xsAttribute,
    XmlText() => xsText,
    XmlComment() => xsComment,
    XmlProcessing() => xsProcessingInstruction,
    XmlNamespace() => xsNamespace,
    XmlDocument() || XmlDocumentFragment() => xsDocument,
    _ => xsNode,
  };

  @override
  XPathAtomic atomize() => XPathUntypedAtomic(stringValue);

  @override
  String get stringValue => switch (node) {
    XmlAttribute(:final value) => value,
    XmlData(:final value) => value,
    XmlProcessing(:final text) => text,
    XmlNamespace(:final value) => value,
    _ => node.innerText,
  };

  @override
  bool get effectiveBooleanValue => true;

  @override
  XmlNode toValue() => node;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is XPathNode && other.node == node);

  @override
  int get hashCode => node.hashCode;

  @override
  String toString() => node.toString();
}
