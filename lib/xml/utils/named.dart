part of xml;

/**
 * A named XML node, such as an [XmlElement] or [XmlAttribute].
 */
abstract class XmlNamed {

  /**
   * Return the name of the node.
   */
  XmlName get name;

}

/**
 * Returns a function that matches [XmlNamed].
 */
Function _createMatcher(String name, String namespace) {

  // matches the name part
  var name_matcher = null;
  if (name != '*') {
    name_matcher = (XmlName name) => name.local == name;
  }

  // matches the namespace part
  var namespace_matcher = null;
  if (namespace == null) {
    namespace_matcher = (XmlName name) => name.prefix == null;
  } else if (name != '*') {
    namespace_matcher = (XmlName name) => name.namespaceUri == namespace;
  }

  // figure out the right combination of matchers
  if (name_matcher != null && namespace_matcher != null) {
    return (XmlNamed named) => name_matcher(named.name) && namespace_matcher(named.name);
  } else if (name_matcher != null) {
    return (XmlNamed named) => name_matcher(named.name);
  } else if (namespace_matcher != null) {
    return (XmlNamed named) => namespace_matcher(named.name);
  } else {
    return (XmlNamed named) => true;
  }

}