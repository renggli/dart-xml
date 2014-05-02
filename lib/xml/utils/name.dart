part of xml;

/**
 * XML entity name.
 */
class XmlName extends Object with XmlWritable, XmlParent {

  static const _SEPARATOR = ':';
  static const _WILDCARD = '*';

  /**
   * Return the namespace prefix, or `null`.
   */
  final String prefix;

  /**
   * Return the local name, excluding the namespace prefix.
   */
  final String local;

  /**
   * Return the fully qualified name, including the namespace if defined.
   */
  final String qualified;

  /**
   * Create a qualified [XmlName] from a given `name`.
   */
  factory XmlName(String name) {
    var index = name.indexOf(_SEPARATOR);
    if (index < 0) {
      return new XmlName._(name, null, name);
    } else {
      var prefix = name.substring(0, index);
      var local = name.substring(index + 1, name.length);
      return new XmlName._(name, prefix, local);
    }
  }

  /**
   * Create a qualified [XmlName] with a `name` and a possible `namespace`.
   */
  factory XmlName._forQuery(String name, [String namespace]) {
    if (namespace == null) {
      if (name.indexOf(_SEPARATOR) < 0) {
        return new XmlName._('$_WILDCARD$_SEPARATOR$name', _WILDCARD, name);
      } else {
        return new XmlName(name);
      }
    } else {
      return new XmlName._('$namespace$_SEPARATOR$name', namespace, name);
    }
  }

  XmlName._(this.qualified, this.prefix, this.local);

  @override
  void writeTo(StringBuffer buffer) => buffer.write(qualified);

  @override
  int get hashCode => qualified.hashCode;

  @override
  bool operator ==(other) {
    return other is XmlName && other.qualified == qualified;
  }

  bool matches(XmlName other) {
    return (prefix == _WILDCARD || prefix == other.prefix)
        && (local == _WILDCARD || local == other.local);
  }

}
