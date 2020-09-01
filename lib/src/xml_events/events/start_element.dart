import 'package:collection/collection.dart' show ListEquality;

import '../../../xml.dart' show XmlNodeType;
import '../event.dart';
import '../utils/event_attribute.dart';
import '../utils/named.dart';
import '../visitor.dart';

/// Event of an XML start element node.
class XmlStartElementEvent extends XmlEvent with XmlNamed {
  const XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing,
      [this.namespaceUri]);

  @override
  final String name;

  @override
  final String namespaceUri;

  final List<XmlEventAttribute> attributes;

  final bool isSelfClosing;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitStartElementEvent(this);

  @override
  int get hashCode =>
      nodeType.hashCode ^
      name.hashCode ^
      isSelfClosing.hashCode ^
      const ListEquality().hash(attributes);

  @override
  bool operator ==(Object other) =>
      other is XmlStartElementEvent &&
      other.name == name &&
      other.isSelfClosing == isSelfClosing &&
      const ListEquality().equals(other.attributes, attributes);
}
