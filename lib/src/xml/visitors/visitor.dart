import '../mixins/has_visitor.dart';
import '../nodes/attribute.dart';
import '../nodes/cdata.dart';
import '../nodes/comment.dart';
import '../nodes/declaration.dart';
import '../nodes/doctype.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/namespace.dart';
import '../nodes/processing.dart';
import '../nodes/text.dart';
import '../utils/name.dart';

/// Basic visitor over [XmlHasVisitor] nodes.
mixin XmlVisitor {
  /// Dispatches the provided [node] onto this visitor.
  void visit(XmlHasVisitor node) => node.accept(this);

  /// Visits an [XmlName].
  void visitName(XmlName name) {}

  /// Visits an [XmlAttribute] node.
  void visitAttribute(XmlAttribute node) {}

  /// Visits an [XmlDeclaration] node.
  void visitDeclaration(XmlDeclaration node) {}

  /// Visits an [XmlDocument] node.
  void visitDocument(XmlDocument node) {}

  /// Visits an [XmlDocumentFragment] node.
  void visitDocumentFragment(XmlDocumentFragment node) {}

  /// Visits an [XmlElement] node.
  void visitElement(XmlElement node) {}

  /// Visits an [XmlCDATA] node.
  void visitCDATA(XmlCDATA node) {}

  /// Visits an [XmlComment] node.
  void visitComment(XmlComment node) {}

  /// Visits an [XmlDoctype] node.
  void visitDoctype(XmlDoctype node) {}

  /// Visits an [XmlProcessing] node.
  void visitProcessing(XmlProcessing node) {}

  /// Visits an [XmlText] node.
  void visitText(XmlText node) {}

  /// Visits an [XmlNamespace] node.
  void visitNamespace(XmlNamespace node) {}
}
