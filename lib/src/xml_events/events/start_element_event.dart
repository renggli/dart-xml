library xml_events.events.start_element_event;

import 'package:collection/collection.dart' show ListEquality;

import '../../../xml.dart' show XmlNodeType;
import '../event.dart';
import '../visitor.dart';
import 'event_attribute.dart';
import 'named.dart';

/// Event of an XML start element node.
class XmlStartElementEvent extends XmlEvent with XmlNamed {
  XmlStartElementEvent(this.name, this.attributes, this.isSelfClosing);

  @override
  final String name;

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
