import '../mixins/has_visitor.dart';
import '../nodes/attribute.dart';
import '../nodes/cdata.dart';
import '../nodes/comment.dart';
import '../nodes/declaration.dart';
import '../nodes/doctype.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/processing.dart';
import '../nodes/text.dart';
import '../utils/name.dart';

/// Basic visitor over [XmlHasVisitor] nodes.
mixin XmlVisitor {
  /// Helper to visit an [XmlHasVisitor] using this visitor by dispatching
  /// through the provided [visitable].
  T visit<T>(XmlHasVisitor visitable) => visitable.accept(this);

  /// Visit an [XmlName].
  dynamic visitName(XmlName name) => null;

  /// Visit an [XmlAttribute] node.
  dynamic visitAttribute(XmlAttribute node) => null;

  /// Visit an [XmlDeclaration] node.
  dynamic visitDeclaration(XmlDeclaration node) => null;

  /// Visit an [XmlDocument] node.
  dynamic visitDocument(XmlDocument node) => null;

  /// Visit an [XmlDocumentFragment] node.
  dynamic visitDocumentFragment(XmlDocumentFragment node) => null;

  /// Visit an [XmlElement] node.
  dynamic visitElement(XmlElement node) => null;

  /// Visit an [XmlCDATA] node.
  dynamic visitCDATA(XmlCDATA node) => null;

  /// Visit an [XmlComment] node.
  dynamic visitComment(XmlComment node) => null;

  /// Visit an [XmlDoctype] node.
  dynamic visitDoctype(XmlDoctype node) => null;

  /// Visit an [XmlProcessing] node.
  dynamic visitProcessing(XmlProcessing node) => null;

  /// Visit an [XmlText] node.
  dynamic visitText(XmlText node) => null;
}
