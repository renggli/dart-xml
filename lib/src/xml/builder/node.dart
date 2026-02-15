import '../../../xml.dart' show XmlDocumentFragment, XmlElement;
import '../nodes/attribute.dart';
import '../nodes/document.dart';
import '../nodes/node.dart';
import '../utils/name.dart';
import 'namespace.dart';

// Internal class to define a node.
class NodeDefinition {
  // The name of the element.
  XmlName? name;

  // Whether the element is self-closing.
  bool? isSelfClosing;

  // The namespace definitions on this element.
  final List<NamespaceDefinition> namespaceDefinitions = [];

  // The attributes of the element, indexed by qualified name.
  final Map<String, XmlAttribute> attributes = {};

  // The children of the node.
  final List<XmlNode> children = [];

  // Builds an [XmlElement] from this definition.
  XmlElement buildElement() {
    assert(name != null, 'An element must have a name');
    assert(isSelfClosing != null, 'An element must be self-closing or not');
    return XmlElement(name!, attributes.values, children, isSelfClosing!);
  }

  // Builds an [XmlDocument] from this definition.
  XmlDocument buildDocument() {
    assert(name == null, 'A document cannot have a name');
    assert(isSelfClosing == null, 'A document cannot be self-closing');
    assert(attributes.isEmpty, 'A document cannot have attributes');
    return XmlDocument(children);
  }

  // Builds an [XmlDocumentFragment] from this definition.
  XmlDocumentFragment buildFragment() {
    assert(name == null, 'A fragment cannot have a name');
    assert(isSelfClosing == null, 'A fragment cannot be self-closing');
    assert(attributes.isEmpty, 'A fragment cannot have attributes');
    return XmlDocumentFragment(children);
  }
}
