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
   * Adds a [XmlElement] node with the provided tag `name` and `contents`.
   *
   * The `contents` is either a function definition child elements or any
   * other object that will be converted to a string an added as text.
   */
  void element(String name, contents) {
    var parent = _current;
    _current = new _XmlElementBuilder(name);
    if (contents is Function) {
      contents();
    } else {
      text(contents.toString());
    }
    parent.children.add(_current.build());
    _current = parent;
  }

  /**
   * Adds a [XmlAttribute] node with the provided `name` and `value`.
   */
  void attribute(String name, String value) {
    _current.attributes.add(new XmlAttribute(new XmlName(name), value));
  }

  /**
   * Returns the resulting [XmlNode].
   */
  XmlNode build() => _current.build();

}

abstract class _XmlNodeBuilder {

  List<XmlAttribute> get attributes;
  List<XmlNode> get children;

  XmlNode build();

}

class _XmlDocumentBuilder extends _XmlNodeBuilder {

  @override
  List<XmlAttribute> get attributes => throw new ArgumentError();

  @override
  final List<XmlNode> children = new List();

  @override
  XmlNode build() => new XmlDocument(children);

}

class _XmlElementBuilder extends _XmlNodeBuilder {

  final String name;
  final List<XmlAttribute> attributes = new List();
  final List<XmlNode> children = new List();

  _XmlElementBuilder(this.name);

  @override
  XmlNode build() => new XmlElement(new XmlName(name), attributes, children);

}