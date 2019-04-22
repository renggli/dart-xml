library xml.visitors.visitor;

import 'package:xml/src/xml/nodes/attribute.dart';
import 'package:xml/src/xml/nodes/cdata.dart';
import 'package:xml/src/xml/nodes/comment.dart';
import 'package:xml/src/xml/nodes/doctype.dart';
import 'package:xml/src/xml/nodes/document.dart';
import 'package:xml/src/xml/nodes/document_fragment.dart';
import 'package:xml/src/xml/nodes/element.dart';
import 'package:xml/src/xml/nodes/processing.dart';
import 'package:xml/src/xml/nodes/text.dart';
import 'package:xml/src/xml/utils/name.dart';
import 'package:xml/src/xml/visitors/visitable.dart';

/// Basic visitor over [XmlVisitable] nodes.
mixin XmlVisitor {
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
