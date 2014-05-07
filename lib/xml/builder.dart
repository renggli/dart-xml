part of xml;

/**
 * A builder to create XML trees.
 *
 * API is not finalized yet, do not use.
 */
class XmlBuilder {

  _XmlNodeBuilder _current = new _XmlDocumentBuilder();

  /**
   * Adds a [XmlText] node with the provided `text`.
   */
  void text(String text) {
    _current.children.add(new XmlText(text));
  }

  /**
   * Adds a [XmlCDATA] node with the provided `text`.
   */
  void cdata(String text) {
    _current.children.add(new XmlCDATA(text));
  }

  /**
   * Adds a [XmlProcessing] node with the provided `target` and `text`.
   */
  void processing(String target, String text) {
    _current.children.add(new XmlProcessing(target, text));
  }

  /**
   * Adds a [XmlComment] node with the provided `text`.
   */
  void comment(String text) {
    _current.children.add(new XmlComment(text));
  }

  /**
   * Adds a [XmlElement] node with the provided tag `name`.
   *
   * If a `namespace` URI is provided, the prefix is looked up, verified and
   * combined with the given tag `name`.
   *
   * If a map of `attributes` is provided the name-value pairs are added to the
   * element declaration, see also [XmlBuilder#attribute].
   *
   * If a map of `namespaces` is provided the uri-prefix pairs are added to the
   * element declaration, see also [XmlBuilder#namespace].
   *
   * Finally, `insert` is used to customize the element and to define children.
   * Typically `insert` is a [Function] that defines elements using the same
   * builder object. For convenience `contents` can be a string or an arbitrary
   * other object that will be added as a text node.
   */
  void element(String name, {
      String namespace: null,
      Map<String, String> attributes: const {},
      Map<String, String> namespaces: const {},
      Object insert: null}) {
    var builder = new _XmlElementBuilder(_current);
    _current = builder;
    attributes.forEach(this.attribute);
    namespaces.forEach(this.namespace);
    if (insert != null) {
      _insert(insert);
    }
    builder.name = _buildName(name, namespace);
    _current = builder.parent;
    _current.children.add(builder.build());
  }

  /**
   * Adds a [XmlAttribute] node with the provided `name` and `value`.
   */
  void attribute(String name, String value, {String namespace}) {
    _current.attributes.add(new XmlAttribute(_buildName(name, namespace), value));
  }

  /**
   * Binds a namespace `prefix` to the provided `uri`. The `prefix` can be
   * omitted to declare a default namespace. Throws an [ArgumentError] if
   * the `prefix` conflicts with an existing delcaration.
   */
  void namespace(String uri, [String prefix]) {
    if (prefix == _XMLNS || prefix == _XML) {
      throw new ArgumentError('The "$prefix" prefix cannot be bound.');
    }
    if (_current.namespaces.containsValue(prefix)) {
      throw new ArgumentError('The "$prefix" prefix conflicts with existing binding.');
    }
    var name = prefix == null || prefix.isEmpty
        ? new XmlName(_XMLNS)
        : new XmlName(prefix, _XMLNS);
    _current.attributes.add(new XmlAttribute(name, uri));
    _current.namespaces[uri] = prefix;
  }

  /**
   * Returns the resulting [XmlNode].
   */
  XmlNode build() => _current.build();

  /**
   * Internal method to build a name.
   */
  XmlName _buildName(String name, String uri) {
    return uri == null || uri.isEmpty
        ? new XmlName.fromString(name)
        : new XmlName(name, _current.lookupPrefix(uri));
  }

  /**
   * Internal method to add something to the current element.
   */
  void _insert(value) {
    if (value is Function) {
      value();
    } if (value is Iterable) {
      value.forEach((each) => _insert(value));
    } else {
      text(value.toString());
    }
  }

}

abstract class _XmlNodeBuilder {
  Map<String, String> get namespaces;
  List<XmlAttribute> get attributes;
  List<XmlNode> get children;
  XmlNode build();
  String lookupPrefix(String uri);
}

class _XmlDocumentBuilder extends _XmlNodeBuilder {

  @override
  Map<String, String> get namespaces {
    throw new ArgumentError('Unable to define namespaces at the document level.');
  }

  @override
  List<XmlAttribute> get attributes {
    throw new ArgumentError('Unable to define attributes at the document level.');
  }

  @override
  final List<XmlNode> children = new List();

  @override
  XmlNode build() => new XmlDocument(children);

  @override
  String lookupPrefix(String uri) {
    return uri == _XML_URI ? _XML : throw new ArgumentError('Undefined namespace: $uri');
  }

}

class _XmlElementBuilder extends _XmlNodeBuilder {

  @override
  final Map<String, String> namespaces = new Map();

  @override
  final List<XmlAttribute> attributes = new List();

  @override
  final List<XmlNode> children = new List();

  final _XmlNodeBuilder parent;

  XmlName name;

  _XmlElementBuilder(this.parent);

  @override
  XmlNode build() => new XmlElement(name, attributes, children);

  @override
  String lookupPrefix(String uri) {
    return namespaces.containsKey(uri) ? namespaces[uri] : parent.lookupPrefix(uri);
  }

}