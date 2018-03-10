library xml.visitors.visitor;

import 'package:xml/xml/nodes/attribute.dart' show XmlAttribute;
import 'package:xml/xml/nodes/cdata.dart' show XmlCDATA;
import 'package:xml/xml/nodes/comment.dart' show XmlComment;
import 'package:xml/xml/nodes/doctype.dart' show XmlDoctype;
import 'package:xml/xml/nodes/document.dart' show XmlDocument;
import 'package:xml/xml/nodes/document_fragment.dart' show XmlDocumentFragment;
import 'package:xml/xml/nodes/element.dart' show XmlElement;
import 'package:xml/xml/nodes/processing.dart' show XmlProcessing;
import 'package:xml/xml/nodes/text.dart' show XmlText;
import 'package:xml/xml/utils/name.dart' show XmlName;
import 'package:xml/xml/visitors/visitable.dart' show XmlVisitable;

/// Basic visitor over [XmlVisitable] nodes.
class XmlVisitor {
  const XmlVisitor();

  /// Helper to visit an [XmlVisitable] using this visitor by dispatching
  /// through the provided [visitable].
  T visit<T>(XmlVisitable visitable) => visitable.accept(this);

  /// Visit an [XmlName].
  dynamic visitName(XmlName name) => null;

  /// Visit an [XmlAttribute] node.
  dynamic visitAttribute(XmlAttribute node) => null;

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
