import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/declaration.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'json_escape.dart';
import 'serialization_parameters.dart';

/// Serializes [sequence] according to [params].
String serializeSequence(
  XPathSequence sequence,
  SerializationParameters params,
) {
  final method = params.method.toLowerCase();
  var rawOutput = switch (method) {
    'xml' => _serializeXml(sequence, params),
    'html' => _serializeHtml(sequence, params),
    'xhtml' => _serializeXml(sequence, params),
    'text' => _serializeText(sequence, params),
    'json' => _serializeJson(sequence, params),
    'adaptive' => _serializeAdaptive(sequence, params),
    _ => _serializeXml(sequence, params),
  };

  if (params.useCharacterMaps.isNotEmpty) {
    params.useCharacterMaps.forEach((char, rep) {
      rawOutput = rawOutput.replaceAll(char, rep);
    });
  }

  return rawOutput;
}

String _serializeXml(XPathSequence sequence, SerializationParameters params) {
  if (sequence.isEmpty) return '';

  final sb = StringBuffer();
  if (!params.omitXmlDeclaration) {
    sb.write('<?xml version="${params.version}" encoding="${params.encoding}"');
    if (params.standalone != null) {
      sb.write(' standalone="${params.standalone! ? 'yes' : 'no'}"');
    }
    sb.write('?>');
    if (params.indent) {
      sb.write('\n');
    } else {
      sb.write(' ');
    }
  }

  final items = sequence.toList();
  final itemSeparator = params.itemSeparator;

  for (var i = 0; i < items.length; i++) {
    final item = items[i];
    if (i > 0) {
      if (itemSeparator != null) {
        sb.write(itemSeparator);
      } else {
        final prev = items[i - 1];
        if (prev is XPathAtomic && item is XPathAtomic) {
          sb.write(' ');
        }
      }
    }

    if (item is XPathNode) {
      final node = item.node;
      if (node is XmlAttribute || node is XmlNamespace) {
        throw XPathEvaluationException(
          XPathErrorCode.SENR0001,
          'Cannot serialize free-standing attribute or namespace in XML method',
        );
      }
      _writeXmlItemNode(sb, node, params);
    } else {
      sb.write(item.stringValue);
    }
  }

  return sb.toString();
}

void _writeXmlItemNode(
  StringBuffer sb,
  XmlNode node,
  SerializationParameters params,
) {
  if (params.cdataSectionElements.isNotEmpty) {
    _writeNodeWithCdata(sb, node, params.cdataSectionElements);
    return;
  }
  if (node is XmlDocument) {
    for (final child in node.children) {
      if (child is XmlDeclaration) continue;
      _writeXmlItemNode(sb, child, params);
    }
    return;
  }
  if (params.indent) {
    sb.write(
      node.toXmlString(
        pretty: true,
        preserveWhitespace: (n) {
          if (n is XmlElement && params.suppressIndentation.isNotEmpty) {
            return params.suppressIndentation.any((name) {
              if (name.namespaceUri != null && name.namespaceUri!.isNotEmpty) {
                return n.name.local == name.local &&
                    n.name.namespaceUri == name.namespaceUri;
              }
              return n.name.local == name.local;
            });
          }
          return false;
        },
      ),
    );
  } else {
    sb.write(node.toXmlString());
  }
}

void _writeNodeWithCdata(
  StringBuffer sb,
  XmlNode node,
  List<XmlName> cdataElements,
) {
  if (node is XmlDeclaration) return;
  if (node is XmlElement) {
    final isCdata = cdataElements.any((name) {
      if (name.namespaceUri != null && name.namespaceUri!.isNotEmpty) {
        return node.name.local == name.local &&
            node.name.namespaceUri == name.namespaceUri;
      }
      return node.name.local == name.local;
    });

    sb.write('<${node.name.qualified}');
    for (final attr in node.attributes) {
      sb.write(' ${attr.name.qualified}="${attr.value}"');
    }
    if (node.children.isEmpty && node.isSelfClosing) {
      sb.write('/>');
      return;
    }
    sb.write('>');
    for (final child in node.children) {
      if (isCdata && child is XmlText) {
        sb.write('<![CDATA[${child.value}]]>');
      } else {
        _writeNodeWithCdata(sb, child, cdataElements);
      }
    }
    sb.write('</${node.name.qualified}>');
  } else if (node is XmlDocument) {
    for (final child in node.children) {
      if (child is XmlDeclaration) continue;
      _writeNodeWithCdata(sb, child, cdataElements);
    }
  } else {
    sb.write(node.toXmlString());
  }
}

String _serializeHtml(XPathSequence sequence, SerializationParameters params) {
  final sb = StringBuffer();
  final hasDocOrRoot = sequence.any(
    (item) =>
        item is XPathNode &&
        (item.node is XmlDocument ||
            (item.node is XmlElement &&
                (item.node as XmlElement).name.local.toLowerCase() == 'html')),
  );
  if (hasDocOrRoot) {
    sb.write('<!DOCTYPE html>\n');
  }
  for (final item in sequence) {
    if (item is XPathNode) {
      final node = item.node;
      _writeHtmlNode(sb, node, params);
    } else {
      sb.write(item.stringValue);
    }
  }
  return sb.toString();
}

void _writeHtmlNode(
  StringBuffer sb,
  XmlNode node,
  SerializationParameters params,
) {
  if (node is XmlDocument) {
    for (final child in node.children) {
      if (child is XmlDeclaration) continue;
      _writeHtmlNode(sb, child, params);
    }
    return;
  }
  if (node is XmlElement) {
    final nameLower = node.name.local.toLowerCase();
    sb.write('<${node.name.qualified}');
    for (final attr in node.attributes) {
      sb.write(' ${attr.name.qualified}="${attr.value}"');
    }
    if (node.children.isEmpty && node.isSelfClosing && nameLower != 'head') {
      sb.write('/>');
      return;
    }
    sb.write('>');
    if (nameLower == 'head') {
      sb.write(
        '<meta http-equiv="Content-Type" content="text/html; charset=${params.encoding}">',
      );
    }
    for (final child in node.children) {
      _writeHtmlNode(sb, child, params);
    }
    sb.write('</${node.name.qualified}>');
  } else {
    sb.write(node.toXmlString());
  }
}

String _serializeText(XPathSequence sequence, SerializationParameters params) {
  final sb = StringBuffer();
  final itemSeparator = params.itemSeparator;
  var first = true;
  for (final item in sequence) {
    if (!first && itemSeparator != null) {
      sb.write(itemSeparator);
    }
    first = false;
    sb.write(item.stringValue);
  }
  return sb.toString();
}

String _serializeJson(XPathSequence sequence, SerializationParameters params) {
  if (sequence.isEmpty) return 'null';
  if (sequence.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.SERE0023,
      'JSON output method cannot serialize sequence of length > 1',
    );
  }
  final item = sequence.single;
  return _serializeJsonItem(item, params, isRoot: true);
}

String _serializeJsonItem(
  XPathItem item,
  SerializationParameters params, {
  bool isRoot = false,
}) {
  if (item is XPathMap) {
    final sb = StringBuffer();
    sb.write('{');
    final seen = <String>{};
    var i = 0;
    for (final entry in item.entries.entries) {
      if (i > 0) sb.write(params.indent ? ', ' : ',');
      i++;
      final k = entry.key;
      final keyStr = k.stringValue;
      if (!params.allowDuplicateNames && seen.contains(keyStr)) {
        throw XPathEvaluationException(
          XPathErrorCode.SERE0022,
          'Duplicate key in JSON serialization: $keyStr',
        );
      }
      seen.add(keyStr);
      sb.write(escapeJsonString(keyStr, params.encoding));
      sb.write(':');
      final valSeq = entry.value;
      if (valSeq.isEmpty) {
        sb.write('null');
      } else if (valSeq.length > 1) {
        throw XPathEvaluationException(
          XPathErrorCode.SERE0023,
          'Cannot serialize sequence with length > 1 inside JSON map',
        );
      } else {
        sb.write(_serializeJsonItem(valSeq.single, params));
      }
    }
    sb.write('}');
    return sb.toString();
  } else if (item is XPathArray) {
    final sb = StringBuffer();
    sb.write('[');
    for (var i = 0; i < item.length; i++) {
      if (i > 0) sb.write(params.indent ? ', ' : ',');
      final memberSeq = item[i];
      if (memberSeq.isEmpty) {
        sb.write('null');
      } else if (memberSeq.length > 1) {
        throw XPathEvaluationException(
          XPathErrorCode.SERE0023,
          'Cannot serialize sequence with length > 1 inside JSON array',
        );
      } else {
        sb.write(_serializeJsonItem(memberSeq.single, params));
      }
    }
    sb.write(']');
    return sb.toString();
  } else if (item is XPathNode) {
    final node = item.node;
    final String nodeXml;
    if (node is XmlDocument) {
      // Serialize children without XML declaration
      final sb = StringBuffer();
      for (final child in node.children) {
        if (child is! XmlDeclaration) {
          sb.write(child.toXmlString());
        }
      }
      nodeXml = sb.toString();
    } else if (node is XmlText) {
      nodeXml = node.value;
    } else {
      nodeXml = node.toXmlString();
    }
    return escapeJsonString(nodeXml, params.encoding);
  } else if (item is XPathBoolean) {
    return item.value ? 'true' : 'false';
  } else if (item is XPathNumeric) {
    final d = item.toDouble();
    if (d.isNaN || d.isInfinite) {
      throw XPathEvaluationException(
        XPathErrorCode.SERE0020,
        'Cannot serialize NaN or Infinity with JSON method',
      );
    }
    return item.stringValue;
  } else {
    return escapeJsonString(item.stringValue, params.encoding);
  }
}

String _serializeAdaptive(
  XPathSequence sequence,
  SerializationParameters params,
) {
  final sep = params.itemSeparator ?? '\n';
  final parts = <String>[];
  for (final item in sequence) {
    parts.add(_serializeAdaptiveItem(item, params));
  }
  return parts.join(sep);
}

String _serializeAdaptiveItem(XPathItem item, SerializationParameters params) {
  if (item is XPathMap) {
    final entries = item.entries.entries
        .map((e) => '${e.key}:${_serializeAdaptive(e.value, params)}')
        .join(',');
    return 'map{$entries}';
  } else if (item is XPathArray) {
    final members = item.members
        .map((m) => _serializeAdaptive(m, params))
        .join(',');
    return '[$members]';
  } else if (item is XPathNode) {
    final node = item.node;
    if (node is XmlAttribute) {
      return '${node.name.qualified}="${node.value}"';
    }
    return node.toXmlString(pretty: params.indent);
  } else if (item is XPathBoolean) {
    return item.value ? 'true()' : 'false()';
  } else {
    return item.stringValue;
  }
}
