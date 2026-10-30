import '../enums/node_type.dart';
import '../mixins/has_attributes.dart';
import '../mixins/has_parent.dart';
import '../utils/token.dart';
import '../visitors/visitor.dart';
import 'attribute.dart';
import 'node.dart';

/// XML document declaration (`<?xml ...?>`).
///
/// Provides metadata about the XML document, including the XML [version],
/// character [encoding], and [standalone] document status.
///
/// For example:
///
/// ```dart
/// final doc = XmlDocument.parse('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><root/>');
/// final decl = doc.declaration!;
/// print(decl.version); // 1.0
/// print(decl.encoding); // UTF-8
/// print(decl.standalone); // true
/// ```
class XmlDeclaration extends XmlNode
    with XmlHasParent<XmlNode>, XmlHasAttributes {
  /// Creates a document declaration with optional [attributes].
  new([Iterable<XmlAttribute> attributes = const []]) {
    this.attributes.initialize(this, attributeNodeTypes);
    this.attributes.addAll(attributes);
  }

  /// The XML version of the document (e.g. `'1.0'`), or `null`.
  String? get version => getAttribute(versionAttribute);

  set version(String? value) => setAttribute(versionAttribute, value);

  /// The character encoding of the document (e.g. `'UTF-8'`), or `null`.
  String? get encoding => getAttribute(encodingAttribute);

  set encoding(String? value) => setAttribute(encodingAttribute, value);

  /// Whether the document is declared standalone (`standalone="yes"`).
  ///
  /// Returns `true` if `standalone="yes"`, and `false` otherwise.
  bool get standalone => getAttribute(standaloneAttribute) == 'yes';

  set standalone(bool? value) => setAttribute(
    standaloneAttribute,
    value == null
        ? null
        : value
        ? 'yes'
        : 'no',
  );

  @override
  String get value {
    if (attributes.isEmpty) return '';
    final result = toXmlString();
    return result.substring(
      XmlToken.openDeclaration.length + 1,
      result.length - XmlToken.closeDeclaration.length,
    );
  }

  @override
  XmlNodeType get nodeType => XmlNodeType.DECLARATION;

  @override
  XmlDeclaration copy() =>
      XmlDeclaration(attributes.map((each) => each.copy()));

  @override
  void accept(XmlVisitor visitor) => visitor.visitDeclaration(this);
}

/// Supported attribute node types.
const Set<XmlNodeType> attributeNodeTypes = {XmlNodeType.ATTRIBUTE};

/// Known attribute names.
const versionAttribute = 'version';
const encodingAttribute = 'encoding';
const standaloneAttribute = 'standalone';
