import '../nodes/attribute.dart';
import '../nodes/node.dart';

// XML namespace declarations.
const String xml = 'xml';
const String xmlUri = 'http://www.w3.org/XML/1998/namespace';
const String xmlns = 'xmlns';

/// Lookup [XmlAttribute] with the given `prefix` and `local` name by walking up
/// the XML DOM from the provided `start`. Return `null`, if the attribute
/// cannot be found.
XmlAttribute? lookupAttribute(XmlNode? start, String? prefix, String local) {
  for (var node = start; node != null; node = node.parent) {
    for (final attribute in node.attributes) {
      if (attribute.name.prefix == prefix && attribute.name.local == local) {
        return attribute;
      }
    }
  }
  return null;
}

/// Lookup the namespace prefix (possibly an empty string), for the given
/// namespace `uri` by walking up the XML DOM from the provided `start`.
/// Return `null`, if the prefix cannot be found.
String? lookupNamespacePrefix(XmlNode? start, String uri) {
  for (var node = start; node != null; node = node.parent) {
    for (final attribute in node.attributes) {
      if (attribute.value == uri) {
        if (attribute.name.prefix == xmlns) {
          return attribute.name.local;
        } else if (attribute.name.prefix == null &&
            attribute.name.local == xmlns) {
          return '';
        }
      }
    }
  }
  return null;
}
