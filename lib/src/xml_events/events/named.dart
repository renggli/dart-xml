library xml_events.events.named;

import 'package:xml/xml.dart' show XmlToken;

/// Mixin with additional accessors for named objects.
mixin XmlNamed {
  /// The fully qualified name.
  String get name;

  /// The namespace prefix, or `null`.
  String get namespacePrefix {
    final index = name.indexOf(XmlToken.namespace);
    return index > 0 ? name.substring(0, index) : null;
  }

  /// The local name, excluding the namespace prefix.
  String get localName {
    final index = name.indexOf(XmlToken.namespace);
    return index > 0 ? name.substring(index + 1) : name;
  }
}
