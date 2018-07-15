library xml.utils.named;

import 'package:xml/xml/nodes/attribute.dart';
import 'package:xml/xml/nodes/element.dart';
import 'package:xml/xml/utils/name.dart';

/// A named XML node, such as an [XmlElement] or [XmlAttribute].
abstract class XmlNamed {
  /// Return the name of the node.
  XmlName get name;
}
