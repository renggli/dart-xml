library xml.utils.prefix_name;

import 'package:xml/src/xml/utils/name.dart';

/// An XML entity name with a prefix.
class XmlPrefixName extends XmlName {
  @override
  final String prefix;

  @override
  final String local;

  @override
  final String qualified;

  @override
  String get namespaceUri {
    for (var node = parent; node != null; node = node.parent) {
      for (final attribute in node.attributes) {
        if (attribute.name.prefix == xmlns && attribute.name.local == prefix) {
          return attribute.value;
        }
      }
    }
    return null;
  }

  XmlPrefixName(this.prefix, this.local, this.qualified) : super.internal();
}
