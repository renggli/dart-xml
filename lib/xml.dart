/// Dart XML is a lightweight library for parsing, traversing, querying and
/// building XML documents.
import 'src/xml/entities/entity_mapping.dart';
import 'src/xml/nodes/document.dart';
import 'src/xml/utils/exceptions.dart';

export 'src/xml/builder.dart' show XmlBuilder;
export 'src/xml/entities/default_mapping.dart'
    show defaultEntityMapping, XmlDefaultEntityMapping;
export 'src/xml/entities/entity_mapping.dart' show XmlEntityMapping;
export 'src/xml/entities/null_mapping.dart' show XmlNullEntityMapping;
export 'src/xml/grammar.dart' show XmlGrammarDefinition;
export 'src/xml/mixins/has_attributes.dart' show XmlHasAttributes;
export 'src/xml/mixins/has_children.dart' show XmlHasChildren;
export 'src/xml/mixins/has_name.dart' show XmlHasName;
export 'src/xml/mixins/has_parent.dart' show XmlHasParent;
export 'src/xml/mixins/has_text.dart' show XmlHasText;
export 'src/xml/mixins/has_visitor.dart' show XmlHasVisitor;
export 'src/xml/mixins/has_writer.dart' show XmlHasWriter;
export 'src/xml/mixins/has_xml.dart' show XmlHasXml;
export 'src/xml/navigation/ancestors.dart' show XmlAncestorsExtension;
export 'src/xml/navigation/descendants.dart' show XmlDescendantsExtension;
export 'src/xml/navigation/find.dart' show XmlFindExtension;
export 'src/xml/navigation/following.dart' show XmlFollowingExtension;
export 'src/xml/navigation/nodes.dart' show XmlNodesExtension;
export 'src/xml/navigation/parent.dart' show XmlParentExtension;
export 'src/xml/navigation/preceding.dart' show XmlPrecedingExtension;
export 'src/xml/navigation/sibling.dart' show XmlSiblingExtension;
export 'src/xml/nodes/attribute.dart' show XmlAttribute;
export 'src/xml/nodes/cdata.dart' show XmlCDATA;
export 'src/xml/nodes/comment.dart' show XmlComment;
export 'src/xml/nodes/declaration.dart' show XmlDeclaration;
export 'src/xml/nodes/doctype.dart' show XmlDoctype;
export 'src/xml/nodes/document.dart' show XmlDocument;
export 'src/xml/nodes/document_fragment.dart' show XmlDocumentFragment;
export 'src/xml/nodes/element.dart' show XmlElement;
export 'src/xml/nodes/node.dart' show XmlNode;
export 'src/xml/nodes/processing.dart' show XmlProcessing;
export 'src/xml/nodes/text.dart' show XmlText;
export 'src/xml/parser.dart' show XmlParserDefinition;
export 'src/xml/production.dart' show XmlProductionDefinition;
export 'src/xml/utils/attribute_type.dart' show XmlAttributeType;
export 'src/xml/utils/exceptions.dart'
    show
        XmlException,
        XmlParserException,
        XmlNodeTypeException,
        XmlParentException,
        XmlTagException;
export 'src/xml/utils/flatten.dart' show XmlFlattenIterableExtension;
export 'src/xml/utils/name.dart' show XmlName;
export 'src/xml/utils/node_type.dart' show XmlNodeType;
export 'src/xml/utils/token.dart' show XmlToken;
export 'src/xml/visitors/normalizer.dart' show XmlNormalizerExtension;
export 'src/xml/visitors/pretty_writer.dart' show XmlPrettyWriter;
export 'src/xml/visitors/transformer.dart' show XmlTransformer;
export 'src/xml/visitors/visitor.dart' show XmlVisitor;
export 'src/xml/visitors/writer.dart' show XmlWriter;

/// Return an [XmlDocument] for the given [input] string, or throws an
/// [XmlParserException] if the input is invalid.
///
/// For example, the following code prints `Hello World`:
///
///    final document = parse('<?xml?><root message="Hello World" />');
///    print(document.rootElement.getAttribute('message'));
///
/// Note: It is the responsibility of the caller to provide a standard Dart
/// [String] using the default UTF-16 encoding.
@Deprecated('Use `XmlDocument.parse` instead')
XmlDocument parse(String input, {XmlEntityMapping? entityMapping}) =>
    XmlDocument.parse(input, entityMapping: entityMapping);
