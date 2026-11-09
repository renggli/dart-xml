import 'package:meta/meta.dart';

import '../mixins/has_attributes.dart';
import '../nodes/attribute.dart';
import '../nodes/document.dart';
import '../nodes/document_fragment.dart';
import '../nodes/element.dart';
import '../nodes/node.dart';
import '../nodes/text.dart';
import '../utils/token.dart';
import 'writer.dart';

/// A visitor that writes XML nodes correctly indented and with whitespaces
/// adapted.
class XmlPrettyWriter extends XmlWriter {
  /// Creates an [XmlPrettyWriter] writing to [buffer].
  new(
    super.buffer, {
    super.entityMapping,
    super.repairNamespaces,
    int? level,
    String? indent,
    String? newLine,
    this.preserveWhitespace,
    this.indentAttribute,
    this.sortAttributes,
    this.spaceBeforeSelfClose,
  }) : level = level ?? 0,
       indent = indent ?? '  ',
       newLine = newLine ?? '\n';

  int level;
  bool pretty = true;
  final String indent;
  final String newLine;
  final bool Function(XmlNode)? preserveWhitespace;
  final bool Function(XmlAttribute)? indentAttribute;
  final Comparator<XmlAttribute>? sortAttributes;
  final bool Function(XmlNode)? spaceBeforeSelfClose;

  @override
  void visitDocument(XmlDocument node) {
    buffer.write(indent * level);
    writeIterable(normalizeText(node.children), newLine + indent * level);
  }

  @override
  void visitDocumentFragment(XmlDocumentFragment node) {
    buffer.write(indent * level);
    writeIterable(normalizeText(node.children), newLine + indent * level);
  }

  @override
  void visitElement(XmlElement node) {
    withNamespaceScope(node, () {
      buffer.write(XmlToken.openElement);
      visit(node.name);
      writeAttributes(node);
      if (node.children.isEmpty && node.isSelfClosing) {
        if (spaceBeforeSelfClose != null && spaceBeforeSelfClose!(node)) {
          buffer.write(' ');
        }
        buffer.write(XmlToken.closeEndElement);
      } else {
        buffer.write(XmlToken.closeElement);
        if (node.children.isNotEmpty) {
          final xmlSpace =
              node.getAttribute('xml:space') ??
              node.getAttribute(
                'space',
                namespaceUri: 'http://www.w3.org/XML/1998/namespace',
              );
          final shouldPreserve =
              (preserveWhitespace != null && preserveWhitespace!(node)) ||
              xmlSpace == 'preserve';
          final shouldDefault = xmlSpace == 'default';
          if (shouldPreserve) {
            final wasPretty = pretty;
            pretty = false;
            try {
              writeIterable(node.children);
            } finally {
              pretty = wasPretty;
            }
          } else if (shouldDefault && !pretty) {
            final wasPretty = pretty;
            pretty = true;
            try {
              _writePrettyChildren(node);
            } finally {
              pretty = wasPretty;
            }
          } else if (pretty) {
            _writePrettyChildren(node);
          } else {
            writeIterable(node.children);
          }
        }
        buffer.write(XmlToken.openEndElement);
        visit(node.name);
        buffer.write(XmlToken.closeElement);
      }
    });
  }

  void _writePrettyChildren(XmlElement node) {
    if (node.children.every((each) => each is XmlText)) {
      writeIterable(normalizeText(node.children));
    } else {
      level++;
      buffer.write(newLine);
      buffer.write(indent * level);
      writeIterable(normalizeText(node.children), newLine + indent * level);
      level--;
      buffer.write(newLine);
      buffer.write(indent * level);
    }
  }

  @override
  void writeAttributes(XmlHasAttributes node) {
    for (final attribute in normalizeAttributes(attributesFor(node))) {
      if (pretty && indentAttribute != null && indentAttribute!(attribute)) {
        buffer.write(newLine);
        buffer.write(indent * (level + 1));
      } else {
        buffer.write(XmlToken.whitespace);
      }
      visit(attribute);
    }
  }

  @protected
  List<XmlAttribute> normalizeAttributes(List<XmlAttribute> attributes) {
    if (sortAttributes != null) {
      final result = attributes.toList();
      result.sort(sortAttributes);
      return result;
    }
    return attributes;
  }

  // Normalizes the text nodes within a sequence of nodes. Trims leading and
  // trailing whitespaces, replaces all whitespaces with a clean space, removes
  // duplicated whitespaces, drops empty nodes, and combines consecutive nodes.
  @protected
  List<XmlNode> normalizeText(List<XmlNode> nodes) {
    // XML without text nodes is already normalized. Avoid allocating a
    // replacement list and StringBuffer for element-only documents.
    List<XmlNode>? result;
    StringBuffer? textBuffer;
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node is XmlText) {
        final normalized = result ??= nodes.sublist(0, i);
        final buffer = textBuffer ??= StringBuffer();
        buffer.write(node.value);
        if (i + 1 < nodes.length && nodes[i + 1] is XmlText) {
          continue;
        }
        final raw = buffer.toString();
        buffer.clear();
        // Dart's String.trim and RegExp \\s also consume NBSP and other
        // Unicode spacing characters that XML does not define as whitespace.
        final collapsed = raw.replaceAll(_xmlWhitespace, ' ');
        final start = collapsed.startsWith(' ') ? 1 : 0;
        final end = collapsed.endsWith(' ')
            ? collapsed.length - 1
            : collapsed.length;
        final text = start == 0 && end == collapsed.length
            ? collapsed
            : start >= end
            ? ''
            : collapsed.substring(start, end);
        if (text.isNotEmpty) {
          normalized.add(XmlText(text));
        }
      } else {
        result?.add(node);
      }
    }
    return result ?? nodes;
  }
}

final _xmlWhitespace = RegExp(r'[ \t\r\n]+');
