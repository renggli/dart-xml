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

/// Abstract visitor over [XmlVisitable] nodes.
abstract class XmlVisitor<E> {
  const XmlVisitor();

  /// Helper to visit an [XmlVisitable] using this visitor by dispatching
  /// through the provided [visitable].
  E visit(XmlVisitable visitable) => visitable.accept(this);

  /// Helper to visit an [Iterable] of [XmlVisitable]s using this visitor
  /// by dispatching through the provided [visitables].
  Iterable<E> visitAll(Iterable<XmlVisitable> visitables) => visitables.map(visit);

  /// Visit an [XmlName].
  E visitName(XmlName name) {}

  /// Visit an [XmlAttribute] node.
  E visitAttribute(XmlAttribute node) {}

  /// Visit an [XmlDocument] node.
  E visitDocument(XmlDocument node) {}

  /// Visit an [XmlDocumentFragment] node.
  E visitDocumentFragment(XmlDocumentFragment node) {}

  /// Visit an [XmlElement] node.
  E visitElement(XmlElement node) {}

  /// Visit an [XmlCDATA] node.
  E visitCDATA(XmlCDATA node) {}

  /// Visit an [XmlComment] node.
  E visitComment(XmlComment node) {}

  /// Visit an [XmlDoctype] node.
  E visitDoctype(XmlDoctype node) {}

  /// Visit an [XmlProcessing] node.
  E visitProcessing(XmlProcessing node) {}

  /// Visit an [XmlText] node.
  E visitText(XmlText node) {}
}
