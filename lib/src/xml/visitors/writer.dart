import 'package:meta/meta.dart';

import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../enums/attribute_type.dart';
import '../mixins/has_attributes.dart';
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
import '../utils/namespace.dart' as ns;
import '../utils/token.dart';
import 'visitor.dart';

/// A visitor that writes XML nodes exactly as they were parsed.
class XmlWriter with XmlVisitor {
  /// Creates an [XmlWriter] writing to [buffer].
  new(
    this.buffer, {
    XmlEntityMapping? entityMapping,
    this.repairNamespaces = false,
  }) : entityMapping = entityMapping ?? defaultEntityMapping;

  final StringSink buffer;
  final XmlEntityMapping entityMapping;
  final bool repairNamespaces;

  Map<String, String>? _namespaceScope;
  List<XmlAttribute> _currentRepairs = const [];
  static const _initialScope = {ns.xml: ns.xmlUri};

  @override
  void visitAttribute(XmlAttribute node) {
    visit(node.name);
    buffer.write(XmlToken.equals);
    buffer.write(
      entityMapping.encodeAttributeValueWithQuotes(
        node.value,
        node.attributeType,
      ),
    );
  }

  @override
  void visitCDATA(XmlCDATA node) {
    buffer.write(XmlToken.openCDATA);
    buffer.write(node.value);
    buffer.write(XmlToken.closeCDATA);
  }

  @override
  void visitComment(XmlComment node) {
    buffer.write(XmlToken.openComment);
    buffer.write(node.value);
    buffer.write(XmlToken.closeComment);
  }

  @override
  void visitDeclaration(XmlDeclaration node) {
    buffer.write(XmlToken.openDeclaration);
    writeAttributes(node);
    buffer.write(XmlToken.closeDeclaration);
  }

  @override
  void visitDoctype(XmlDoctype node) {
    buffer.write(XmlToken.openDoctype);
    buffer.write(XmlToken.whitespace);
    buffer.write(node.name);
    if (node.externalId != null) {
      buffer.write(XmlToken.whitespace);
      buffer.write(node.externalId);
    }
    if (node.internalSubset != null) {
      buffer.write(XmlToken.whitespace);
      buffer.write(XmlToken.openDoctypeIntSubset);
      buffer.write(node.internalSubset);
      buffer.write(XmlToken.closeDoctypeIntSubset);
    }
    buffer.write(XmlToken.closeDoctype);
  }

  @override
  void visitDocument(XmlDocument node) {
    writeIterable(node.children);
  }

  @override
  void visitDocumentFragment(XmlDocumentFragment node) {
    writeIterable(node.children);
  }

  @override
  void visitElement(XmlElement node) {
    withNamespaceScope(node, () {
      buffer.write(XmlToken.openElement);
      visit(node.name);
      writeAttributes(node);
      if (node.children.isEmpty && node.isSelfClosing) {
        buffer.write(XmlToken.closeEndElement);
      } else {
        buffer.write(XmlToken.closeElement);
        writeIterable(node.children);
        buffer.write(XmlToken.openEndElement);
        visit(node.name);
        buffer.write(XmlToken.closeElement);
      }
    });
  }

  @override
  void visitName(XmlName name) {
    buffer.write(name.qualified);
  }

  @override
  void visitNamespace(XmlNamespace node) {
    buffer.write(ns.xmlns);
    if (node.prefix.isNotEmpty) {
      buffer.write(XmlToken.namespace);
      buffer.write(node.prefix);
    }
    buffer.write(XmlToken.equals);
    buffer.write(
      entityMapping.encodeAttributeValueWithQuotes(
        node.uri,
        XmlAttributeType.DOUBLE_QUOTE,
      ),
    );
  }

  @override
  void visitProcessing(XmlProcessing node) {
    buffer.write(XmlToken.openProcessing);
    buffer.write(node.target);
    if (node.value.isNotEmpty) {
      buffer.write(XmlToken.whitespace);
      buffer.write(node.value);
    }
    buffer.write(XmlToken.closeProcessing);
  }

  @override
  void visitText(XmlText node) {
    buffer.write(entityMapping.encodeText(node.value));
  }

  void writeAttributes(XmlHasAttributes node) {
    final attributes = attributesFor(node);
    if (attributes.isNotEmpty) {
      buffer.write(XmlToken.whitespace);
      writeIterable(attributes, XmlToken.whitespace);
    }
  }

  @protected
  void withNamespaceScope(XmlElement node, void Function() callback) {
    if (!repairNamespaces) {
      callback();
      return;
    }
    final previousScope = _namespaceScope;
    final previousRepairs = _currentRepairs;
    _pushNamespaceScope(node);
    try {
      callback();
    } finally {
      _namespaceScope = previousScope;
      _currentRepairs = previousRepairs;
    }
  }

  List<XmlAttribute> attributesFor(XmlHasAttributes node) {
    if (!repairNamespaces || _currentRepairs.isEmpty) {
      return node.attributes;
    }
    return [...node.attributes, ..._currentRepairs];
  }

  void _pushNamespaceScope(XmlElement node) {
    final currentScope = Map<String, String>.of(
      _namespaceScope ?? _initialScope,
    );
    for (final attribute in node.attributes) {
      if (attribute.name.prefix == ns.xmlns) {
        currentScope[attribute.name.local] = attribute.value;
      } else if (attribute.name.local == ns.xmlns &&
          attribute.name.prefix == null) {
        currentScope[''] = attribute.value;
      }
    }

    final repairs = <XmlAttribute>[];

    final elementUri = node.name.namespaceUri;
    final elementPrefix = node.name.prefix ?? '';
    if (elementUri != null && elementUri.isNotEmpty) {
      if (currentScope[elementPrefix] != elementUri) {
        final targetName = elementPrefix.isEmpty
            ? ns.xmlns
            : '${ns.xmlns}:$elementPrefix';
        if (!node.attributes.any((attr) => attr.name.qualified == targetName)) {
          currentScope[elementPrefix] = elementUri;
          repairs.add(
            XmlAttribute(
              elementPrefix.isEmpty
                  ? const XmlName.parts(ns.xmlns)
                  : XmlName.parts(elementPrefix, prefix: ns.xmlns),
              elementUri,
            ),
          );
        }
      }
    }

    for (final attribute in node.attributes) {
      final attrUri = attribute.name.namespaceUri;
      final attrPrefix = attribute.name.prefix;
      if (attrUri != null &&
          attrUri.isNotEmpty &&
          attrPrefix != null &&
          attrPrefix.isNotEmpty) {
        if (attrPrefix == ns.xml || attrPrefix == ns.xmlns) continue;
        if (currentScope[attrPrefix] != attrUri) {
          final targetName = '${ns.xmlns}:$attrPrefix';
          if (!node.attributes.any((a) => a.name.qualified == targetName) &&
              !repairs.any((a) => a.name.qualified == targetName)) {
            currentScope[attrPrefix] = attrUri;
            repairs.add(
              XmlAttribute(
                XmlName.parts(attrPrefix, prefix: ns.xmlns),
                attrUri,
              ),
            );
          }
        }
      }
    }

    _namespaceScope = currentScope;
    _currentRepairs = repairs;
  }

  void writeIterable(Iterable<XmlHasVisitor> nodes, [String? separator]) {
    final iterator = nodes.iterator;
    if (iterator.moveNext()) {
      if (separator == null || separator.isEmpty) {
        do {
          visit(iterator.current);
        } while (iterator.moveNext());
      } else {
        visit(iterator.current);
        while (iterator.moveNext()) {
          buffer.write(separator);
          visit(iterator.current);
        }
      }
    }
  }
}
