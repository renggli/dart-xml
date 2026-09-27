import 'package:collection/collection.dart' show ListEquality;

import '../../xml/enums/node_type.dart';
import '../annotations/has_name.dart';
import '../event.dart';
import '../utils/event_attribute.dart';
import '../visitor.dart';

/// Event of an XML start element node.
class XmlStartElementEvent extends XmlEvent with XmlHasName {
  /// Creates a start element event with [name], [attributes], and [isSelfClosing].
  new(this.name, this.attributes, this.isSelfClosing);

  @override
  final String name;

  /// The attributes of this start element.
  final List<XmlEventAttribute> attributes;

  /// Whether the start element is self-closing.
  final bool isSelfClosing;

  @override
  XmlNodeType get nodeType => XmlNodeType.ELEMENT;

  @override
  void accept(XmlEventVisitor visitor) => visitor.visitStartElementEvent(this);

  @override
  int get hashCode => Object.hash(
    nodeType,
    name,
    isSelfClosing,
    const ListEquality<XmlEventAttribute>().hash(attributes),
  );

  @override
  bool operator ==(Object other) =>
      other is XmlStartElementEvent &&
      other.name == name &&
      other.isSelfClosing == isSelfClosing &&
      const ListEquality<XmlEventAttribute>().equals(
        other.attributes,
        attributes,
      );
}
