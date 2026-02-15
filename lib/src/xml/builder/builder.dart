import '../dtd/external_id.dart';
import '../entities/entity_mapping.dart';
import '../enums/attribute_type.dart';
import '../exceptions/parser_exception.dart';
import '../nodes/attribute.dart';
import '../nodes/cdata.dart';
import '../nodes/comment.dart';
import '../nodes/data.dart';
import '../nodes/declaration.dart';
import '../nodes/doctype.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';
import '../nodes/processing.dart';
import '../nodes/text.dart';
import '../utils/name.dart';
import '../utils/namespace.dart' as ns;
import '../utils/namespace.dart' show xmlns;
import 'namespace.dart';
import 'node.dart';

/// A builder to create XML trees with code.
///
/// For example, to create a simple XML document:
///
/// ```dart
/// final builder = XmlBuilder();
/// builder.declaration(encoding: 'UTF-8');
/// builder.element('root', nest: () {
///   builder.attribute('lang', 'en');
///   builder.text('Hello World');
/// });
/// final document = builder.buildDocument();
/// ```
class XmlBuilder {
  /// Construct a new [XmlBuilder].
  ///
  /// For the meaning of the [optimizeNamespaces] parameter, read the
  /// documentation of the [optimizeNamespaces] property.
  XmlBuilder({this.optimizeNamespaces = false}) {
    _reset();
  }

  // The stack of node definitions.
  final _nodes = <NodeDefinition>[];

  // The namespace definitions by prefix.
  final _namespacePrefixes = <String?, List<NamespaceDefinition>>{};

  // The namespece definitions by URI.
  final _namespaceUris = <String?, List<NamespaceDefinition>>{};

  /// If [optimizeNamespaces] is true, the builder will perform some
  /// namespace optimization.
  ///
  /// This means that
  ///  - namespaces that are defined in an element but are never used in this
  ///    element or its children will not be included in the document;
  ///  - namespaces that are defined in an element but are already defined in
  ///    one of the ancestors of the element will not be included again.
  final bool optimizeNamespaces;

  /// Adds a [XmlText] node with the provided [text].
  ///
  /// For example, to generate the text `Hello World` one would write:
  ///
  /// ```dart
  /// builder.text('Hello World');
  /// ```
  void text(Object text) {
    final children = _nodes.last.children;
    if (children.isNotEmpty) {
      final lastChild = children.last;
      if (lastChild is XmlText) {
        // Merge consecutive text nodes into one
        lastChild.value += text.toString();
        return;
      }
    }
    children.add(XmlText(text.toString()));
  }

  /// Adds a [XmlCDATA] node with the provided [text].
  ///
  /// For example, to generate an XML CDATA element `<![CDATA[Hello World]]>`
  /// one would write:
  ///
  /// ```dart
  /// builder.cdata('Hello World');
  /// ```
  void cdata(Object text) {
    _nodes.last.children.add(XmlCDATA(text.toString()));
  }

  /// Adds a [XmlDeclaration] node.
  ///
  /// For example, to generate an XML declaration `<?xml version="1.0"
  /// encoding="utf-8"?>` one would write:
  ///
  /// ```dart
  /// builder.declaration(encoding: 'UTF-8');
  /// ```
  void declaration({
    String version = '1.0',
    String? encoding,
    Map<String, String> attributes = const {},
  }) {
    final declaration = XmlDeclaration()
      ..version = version
      ..encoding = encoding;
    attributes.forEach(declaration.setAttribute);
    _nodes.last.children.add(declaration);
  }

  /// Adds a [XmlDoctype] node.
  ///
  /// For example, to generate an XML doctype element `<!DOCTYPE note SYSTEM
  /// "note.dtd">` one would write:
  ///
  /// ```dart
  /// builder.doctype('note', systemId: 'note.dtd');
  /// ```
  void doctype(
    String name, {
    String? publicId,
    String? systemId,
    String? internalSubset,
  }) {
    if (publicId != null && systemId == null) {
      throw ArgumentError(
        'A system ID is required, if a public ID is provided',
      );
    }
    final externalId = publicId != null && systemId != null
        ? DtdExternalId.public(
            publicId,
            XmlAttributeType.DOUBLE_QUOTE,
            systemId,
            XmlAttributeType.DOUBLE_QUOTE,
          )
        : publicId == null && systemId != null
        ? DtdExternalId.system(systemId, XmlAttributeType.DOUBLE_QUOTE)
        : null;
    _nodes.last.children.add(XmlDoctype(name, externalId, internalSubset));
  }

  /// Adds a [XmlProcessing] node with the provided [target] and [text].
  ///
  /// For example, to generate an XML processing element `<?xml-stylesheet
  /// href="/style.css"?>` one would write:
  ///
  /// ```dart
  /// builder.processing('xml-stylesheet', 'href="/style.css"');
  /// ```
  void processing(String target, Object text) {
    _nodes.last.children.add(XmlProcessing(target, text.toString()));
  }

  /// Adds a [XmlComment] node with the provided [text].
  ///
  /// For example, to generate an XML comment `<!--Hello World-->` one would
  /// write:
  ///
  /// ```dart
  /// builder.comment('Hello World');
  /// ```
  void comment(Object text) {
    _nodes.last.children.add(XmlComment(text.toString()));
  }

  /// Adds a [XmlElement] node with the provided tag [name].
  ///
  /// For the namespace either a [namespacePrefix] or a [namespaceUri] can be
  /// provided, but not both.
  ///
  /// If a map of [namespaceUris] is provided the prefix-uri pairs are added to
  /// the element declaration, see [XmlBuilder.namespaceUri] for details.
  ///
  /// If a map of [attributes] is provided the name-value pairs are added to the
  /// element declaration, see [XmlBuilder.attribute] for details.
  ///
  /// Finally, [nest] is used to further customize the element and to add its
  /// children. Typically this is a [Function] that defines elements using the
  /// same builder object. For convenience `nest` can also be a valid [XmlNode],
  /// a string, or another common object that will be converted to a string and
  /// added as a text node.
  ///
  /// For example, to generate an XML element with the tag _message_ and the
  /// contained text _Hello World_ one would write:
  ///
  /// ```dart
  /// builder.element('message', nest: 'Hello World');
  /// ```
  ///
  /// To add multiple child elements one would use:
  ///
  /// ```dart
  /// builder.element('message', nest: () {
  ///   builder..text('Hello World')
  ///          ..element('break');
  /// });
  /// ```
  void element(
    String name, {
    String? namespaceUri,
    String? namespacePrefix,
    Map<String?, String?> namespaceUris = const {},
    Map<String, String> attributes = const {},
    bool isSelfClosing = true,
    Object? nest,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
    @Deprecated('Use `namespaceUris` instead') Map<String, String?>? namespaces,
  }) {
    final nodeDefinition = NodeDefinition();
    _nodes.add(nodeDefinition);
    try {
      namespaceUris.forEach(this.namespaceUri);
      if (namespaceUris.isEmpty && namespaces != null) {
        // ignore: deprecated_member_use_from_same_package
        namespaces.forEach(this.namespace);
      }
      attributes.forEach(attribute);
      if (nest != null) {
        _insert(nest);
      }
      nodeDefinition.name = _buildName(
        name,
        prefix: namespacePrefix,
        uri: namespaceUri ?? namespace,
      );
      nodeDefinition.isSelfClosing = isSelfClosing;
      for (final namespaceDefinition in nodeDefinition.namespaceDefinitions) {
        // Remove unused namespace definitions.
        if (optimizeNamespaces && !namespaceDefinition.isUsed) {
          nodeDefinition.attributes.remove(
            namespaceDefinition.attribute.name.qualified,
          );
        }
        // Cleanup the namespace lookup caches.
        _namespacePrefixes[namespaceDefinition.prefix]?.removeLast();
        _namespaceUris[namespaceDefinition.uri]?.removeLast();
      }
    } finally {
      _nodes.removeLast();
    }
    _nodes.last.children.add(nodeDefinition.buildElement());
  }

  /// Adds a [XmlAttribute] node with the provided [name] and [value].
  ///
  /// For the namespace either a previously defined [namespacePrefix] or
  /// [namespaceUri] can be provided, but not both.
  ///
  /// To generate an element with the tag _message_ and the
  /// attribute _lang="en"_ one would write:
  ///
  /// ```dart
  /// builder.element('message', nest: () {
  ///    builder.attribute('lang', 'en');
  /// });
  /// ```
  void attribute(
    String name,
    Object? value, {
    String? namespaceUri,
    String? namespacePrefix,
    XmlAttributeType? attributeType,
    @Deprecated('Use `namespaceUri` instead') String? namespace,
  }) {
    final attributeName = _buildName(
      name,
      prefix: namespacePrefix,
      uri: namespaceUri ?? namespace,
    );
    final attributeNode = XmlAttribute(
      attributeName,
      value.toString(),
      attributeType ?? XmlAttributeType.DOUBLE_QUOTE,
    );
    final attributes = _nodes.last.attributes;
    if (value != null) {
      attributes[attributeName.qualified] = attributeNode;
    } else {
      attributes.remove(attributeName.qualified);
    }
  }

  /// Adds a raw XML string. The string will be parsed as [XmlDocumentFragment]
  /// and throws an [XmlParserException] if the input is invalid.
  ///
  /// To generate a bookshelf element with two predefined book elements, one
  /// would write:
  ///
  /// ```dart
  /// builder.element('bookshelf', nest: () {
  ///   builder.xml('<book><title>Growing a Language</title></book>');
  ///   builder.xml('<book><title>Learning XML</title></book>');
  /// });
  /// ```
  void xml(String input, {XmlEntityMapping? entityMapping}) {
    final fragment = XmlDocumentFragment.parse(
      input,
      entityMapping: entityMapping,
    );
    _nodes.last.children.add(fragment);
  }

  /// Binds a namespace [prefix] to the provided [uri].
  ///
  /// The [prefix] can be `null` to declare a default namespace. The [uri]
  /// can be `null` to undeclare a namespace. Throws an [ArgumentError] if
  /// the [prefix] is invalid or conflicts with an existing declaration.
  ///
  /// For example, to bind the `xsd` prefix:
  ///
  /// ```dart
  /// builder.element('schema', nest: () {
  ///   builder.namespaceUri('xsd', 'http://www.w3.org/2001/XMLSchema');
  /// });
  /// ```
  void namespaceUri(String? prefix, String? uri) {
    assert(
      prefix == null || !prefix.contains('://'),
      '$prefix contains a URL, which is most likely a bug',
    );
    if (prefix == ns.xmlns || prefix == ns.xml) {
      throw ArgumentError('The "$prefix" prefix cannot be bound.');
    }
    if (optimizeNamespaces &&
        _namespacePrefixes[prefix]?.lastOrNull?.uri == uri) {
      return;
    }
    final attribute = XmlAttribute(
      XmlName(
        prefix != null ? '$xmlns:$prefix' : ns.xmlns,
        namespaceUri: ns.xmlnsUri,
      ),
      uri ?? '',
    );
    final nodeDefinition = _nodes.last;
    if (nodeDefinition.attributes.containsKey(attribute.qualifiedName)) {
      throw ArgumentError('The namespace "${prefix ?? uri}" is already bound.');
    }
    nodeDefinition.attributes[attribute.qualifiedName] = attribute;
    final definition = NamespaceDefinition(
      attribute: attribute,
      prefix: prefix,
      uri: uri,
    );
    nodeDefinition.namespaceDefinitions.add(definition);
    _namespacePrefixes.putIfAbsent(prefix, () => []).add(definition);
    _namespaceUris.putIfAbsent(uri, () => []).add(definition);
  }

  /// Binds a namespace [prefix] to the provided [uri]. The [prefix] can be
  /// omitted to declare a default namespace. Throws an [ArgumentError] if
  /// the [prefix] is invalid or conflicts with an existing declaration.
  ///
  /// For example, to bind the `xsd` prefix:
  ///
  /// ```dart
  /// builder.element('schema', nest: () {
  ///   builder.namespace('http://www.w3.org/2001/XMLSchema', 'xsd');
  /// });
  /// ```
  @Deprecated('Use `namespaceUri` instead')
  void namespace(String uri, [String? prefix]) {
    namespaceUri(prefix, uri);
  }

  /// Builds and returns the resulting [XmlDocument]; resets the builder to its
  /// initial empty state.
  ///
  /// For example:
  ///
  /// ```dart
  /// final document = builder.buildDocument();
  /// ```
  XmlDocument buildDocument() => _build((builder) => builder.buildDocument());

  /// Builds and returns the resulting [XmlDocumentFragment]; resets the builder
  /// to its initial empty state.
  ///
  /// For example:
  ///
  /// ```dart
  /// final fragment = builder.buildFragment();
  /// ```
  XmlDocumentFragment buildFragment() =>
      _build((builder) => builder.buildFragment());

  // Internal method to build the final result and reset the builder.
  T _build<T extends XmlNode>(T Function(NodeDefinition definition) callback) {
    if (_nodes.length != 1) {
      throw StateError('Unable to build an incomplete DOM element.');
    }
    try {
      return callback(_nodes.last);
    } finally {
      _reset();
    }
  }

  // Internal method to reset the node stack.
  void _reset() {
    _nodes.clear();
    _namespacePrefixes.clear();
    _namespaceUris.clear();
    _nodes.add(NodeDefinition());
  }

  // Internal method to build a name.
  XmlName _buildName(String name, {String? prefix, String? uri}) {
    if (prefix != null && uri != null) {
      throw ArgumentError(
        'Both prefix and uri were specified: $prefix and $uri',
      );
    }
    NamespaceDefinition? definition;
    if (prefix != null) {
      definition = _namespacePrefixes[prefix]?.lastOrNull;
      if (definition == null) {
        throw ArgumentError('Undefined namespace prefix: $prefix');
      }
    } else if (uri != null) {
      definition = _namespaceUris[uri]?.lastOrNull;
      if (definition == null) {
        throw ArgumentError('Undefined namespace URI: $uri');
      }
    } else {
      definition = _namespacePrefixes[null]?.lastOrNull;
    }
    if (definition != null) {
      definition.isUsed = true;
      return XmlName(
        definition.prefix == null ? name : '${definition.prefix}:$name',
        namespaceUri: definition.uri,
      );
    }
    return XmlName(name);
  }

  // Internal method to add children to the current element.
  void _insert(Object? value) {
    switch (value) {
      case Callback():
        value();
      case CallbackWithBuilder():
        value(this);
      case Iterable():
        value.forEach(_insert);
      case XmlNode():
        switch (value) {
          // Text nodes need to be unwrapped for merging.
          case XmlText():
            text(value.value);
          // Attributes must be copied and added to the attributes list.
          case XmlAttribute():
            _nodes.last.attributes[value.qualifiedName] = value.copy();
          // Children nodes must be copied and added to the children list.
          case XmlElement() || XmlData() || XmlDeclaration():
            _nodes.last.children.add(value.copy());
          // Document fragments must be copied and unwrapped.
          case XmlDocumentFragment():
            value.children.map((element) => element.copy()).forEach(_insert);
          default:
            throw ArgumentError(
              'Unable to add element of type ${value.nodeType}',
            );
        }
      default:
        text(value.toString());
    }
  }
}

typedef Callback = void Function();
typedef CallbackWithBuilder = void Function(XmlBuilder builder);
