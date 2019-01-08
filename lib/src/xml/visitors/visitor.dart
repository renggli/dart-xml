library xml.visitors.visitor;

import '../nodes/attribute.dart';
import '../nodes/cdata.dart';
import '../nodes/comment.dart';
import '../nodes/doctype.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/processing.dart';
import '../nodes/text.dart';
import '../utils/name.dart';
import 'visitable.dart';

/// Basic visitor over [XmlVisitable] nodes.
class XmlVisitor {
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

  /// Visit an [XmlStartElement] node.
  dynamic visitStartElement(XmlStartElement node) => null;

  /// Visit an [XmlEndElement] node.
  dynamic visitEndElement(XmlEndElement node) => null;

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
