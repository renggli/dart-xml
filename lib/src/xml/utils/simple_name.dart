library xml.utils.simple_name;

import 'package:xml/src/xml/utils/name.dart';

/// An XML entity name without a prefix.
class XmlSimpleName extends XmlName {
  @override
  String get prefix => null;

  @override
  final String local;

  @override
  String get qualified => local;

  @override
  String get namespaceUri {
    for (var node = parent; node != null; node = node.parent) {
      for (final attribute in node.attributes) {
        if (attribute.name.prefix == null && attribute.name.local == xmlns) {
          return attribute.value;
        }
      }
    }
    return null;
  }

  XmlSimpleName(this.local) : super.internal();
}
