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
   * The optional `contents` can be omitted, if the element has no attributes
   * or children. It can either be a [Function] definition the child elements or
   * a [String] that is added as text.
   */
  void element(String name, {Object contents, String namespace}) {
    var builder = new _XmlElementBuilder(_current);
    _current = builder;
    if (contents != null) {
      if (contents is Function) {
        contents();
      } else {
        text(contents.toString());
      }
    }
    builder.name = _buildName(name, namespace);
    _current = builder.parent;
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