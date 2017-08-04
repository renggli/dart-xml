library xml.utils.named;

import 'package:xml/xml/utils/name.dart' show XmlName;

/// A named XML node, such as an [XmlElement] or [XmlAttribute].
abstract class XmlNamed {
  /// Return the name of the node.
  XmlName get name;
}
