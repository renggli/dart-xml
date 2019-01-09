library xml.utils.named;

import '../nodes/attribute.dart';
import '../nodes/element.dart';
import 'name.dart';

/// A named XML node, such as an [XmlElement] or [XmlAttribute].
abstract class XmlNamed {
  /// Return the name of the node.
  XmlName get name;
}
