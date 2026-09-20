import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/declaration.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/namespace.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/name.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

const _outputNamespace = 'http://www.w3.org/2010/xslt-xquery-serialization';

/// Serialization parameters defined in W3C XSLT and XQuery Serialization 3.1.
class SerializationParameters {
  new({
    this.method = 'xml',
    this.byteOrderMark,
    this.cdataSectionElements = const [],
    this.doctypePublic,
    this.doctypeSystem,
    this.encoding = 'utf-8',
    this.escapeUriAttributes = true,
    this.htmlVersion = 5.0,
    this.includeContentType = true,
    this.indent = false,
    this.itemSeparator,
    this.jsonNodeOutputMethod = 'xml',
    this.mediaType,
    this.normalizationForm,
    this.omitXmlDeclaration = true,
    this.standalone,
    this.suppressIndentation = const [],
    this.undeclarePrefixes = false,
    this.useCharacterMaps = const {},
    this.version = '1.0',
    this.allowDuplicateNames = false,
  });

  String method;
  bool? byteOrderMark;
  List<XmlName> cdataSectionElements;
  String? doctypePublic;
  String? doctypeSystem;
  String encoding;
  bool escapeUriAttributes;
  double htmlVersion;
  bool includeContentType;
  bool indent;
  String? itemSeparator;
  String jsonNodeOutputMethod;
  String? mediaType;
  String? normalizationForm;
  bool omitXmlDeclaration;
  bool? standalone;
  List<XmlName> suppressIndentation;
  bool undeclarePrefixes;
  Map<String, String> useCharacterMaps;
  String version;
  bool allowDuplicateNames;

  static SerializationParameters fromSequence(XPathSequence paramsSeq) {
    if (paramsSeq.isEmpty) {
      return SerializationParameters();
    }
    final item = paramsSeq.first;
    if (item is XPathMap) {
      return fromMap(item);
    } else if (item is XPathNode && item.node is XmlElement) {
      return fromElement(item.node as XmlElement);
    }
    throw XPathEvaluationException(
      'Serialization parameters must be a map or an element [err:XPTY0004]',
    );
  }

  static SerializationParameters fromMap(XPathMap map) {
    final params = SerializationParameters();
    var hasItemSeparator = false;

    for (final entry in map.entries.entries) {
      final key = entry.key;
      final valSeq = entry.value;

      String paramName;
      if (key is XPathString || key is XPathUntypedAtomic) {
        paramName = key.stringValue;
      } else if (key is XPathQName) {
        // Option parameter conventions: unrecognized parameters (or QNames
        // with empty or vendor namespace not recognized) are ignored.
        continue;
      } else {
        throw XPathEvaluationException(
          'Serialization parameter key must be xs:string or xs:QName [err:XPTY0004]',
        );
      }

      switch (paramName) {
        case 'method':
          final v = _getStringOption(valSeq, 'method');
          if (v != 'xml' &&
              v != 'html' &&
              v != 'xhtml' &&
              v != 'text' &&
              v != 'json' &&
              v != 'adaptive') {
            throw XPathEvaluationException('Unknown method: $v [err:SEPM0016]');
          }
          params.method = v;

        case 'indent':
          params.indent = _getBooleanOption(valSeq, 'indent');

        case 'omit-xml-declaration':
          params.omitXmlDeclaration = _getBooleanOption(
            valSeq,
            'omit-xml-declaration',
          );

        case 'standalone':
          if (valSeq.isEmpty) {
            params.standalone = null;
          } else {
            final atom = valSeq.atomize().toList();
            if (atom.length == 1) {
              final first = atom.first;
              if (first is XPathBoolean) {
                params.standalone = first.value;
              } else if (first is XPathString &&
                  (first.value == 'yes' ||
                      first.value == 'no' ||
                      first.value == 'omit')) {
                params.standalone = first.value == 'yes'
                    ? true
                    : (first.value == 'no' ? false : null);
              } else {
                throw XPathEvaluationException(
                  'Invalid standalone value [err:XPTY0004]',
                );
              }
            } else {
              throw XPathEvaluationException(
                'Invalid standalone sequence [err:XPTY0004]',
              );
            }
          }

        case 'item-separator':
          params.itemSeparator = _getStringOption(valSeq, 'item-separator');
          hasItemSeparator = true;

        case 'version':
          params.version = _getStringOption(valSeq, 'version');

        case 'html-version':
          params.htmlVersion = _getNumberOption(valSeq, 'html-version');

        case 'encoding':
          params.encoding = _getStringOption(valSeq, 'encoding');

        case 'json-node-output-method':
          params.jsonNodeOutputMethod = _getStringOption(
            valSeq,
            'json-node-output-method',
          );

        case 'allow-duplicate-names':
          params.allowDuplicateNames = _getBooleanOption(
            valSeq,
            'allow-duplicate-names',
          );

        case 'undeclare-prefixes':
          params.undeclarePrefixes = _getBooleanOption(
            valSeq,
            'undeclare-prefixes',
          );

        case 'cdata-section-elements':
          final list = <XmlName>[];
          final rawItems = <XPathItem>[];
          for (final it in valSeq) {
            if (it is XPathArray) {
              for (final member in it.members) {
                rawItems.addAll(member);
              }
            } else {
              rawItems.add(it);
            }
          }
          for (final it in rawItems) {
            if (it is XPathQName) {
              list.add(it.value);
            } else if (it is XPathString || it is XPathUntypedAtomic) {
              list.add(XmlName.parse(it.stringValue));
            } else {
              throw XPathEvaluationException(
                'cdata-section-elements items must be QNames [err:XPTY0004]',
              );
            }
          }
          params.cdataSectionElements = list;

        case 'suppress-indentation':
          final list = <XmlName>[];
          final rawItems = <XPathItem>[];
          for (final it in valSeq) {
            if (it is XPathArray) {
              for (final member in it.members) {
                rawItems.addAll(member);
              }
            } else {
              rawItems.add(it);
            }
          }
          for (final it in rawItems) {
            if (it is XPathQName) {
              list.add(it.value);
            } else if (it is XPathString || it is XPathUntypedAtomic) {
              list.add(XmlName.parse(it.stringValue));
            } else {
              throw XPathEvaluationException(
                'suppress-indentation items must be QNames [err:XPTY0004]',
              );
            }
          }
          params.suppressIndentation = list;

        case 'use-character-maps':
          if (valSeq.length != 1 || valSeq.first is! XPathMap) {
            throw XPathEvaluationException(
              'use-character-maps must be a map [err:XPTY0004]',
            );
          }
          final charMap = valSeq.first as XPathMap;
          final mapResult = <String, String>{};
          for (final e in charMap.entries.entries) {
            final k = e.key;
            if (k is! XPathString && k is! XPathUntypedAtomic) {
              throw XPathEvaluationException(
                'Character map keys must be single characters [err:XPTY0004]',
              );
            }
            final kStr = k.stringValue;
            if (kStr.runes.length != 1) {
              throw XPathEvaluationException(
                'Character map key must be a single character: $kStr [err:SEPM0016]',
              );
            }
            final vSeq = e.value;
            if (vSeq.length != 1) {
              throw XPathEvaluationException(
                'Character map value must be a single string [err:XPTY0004]',
              );
            }
            final vItem = vSeq.first;
            if (vItem is! XPathString && vItem is! XPathUntypedAtomic) {
              throw XPathEvaluationException(
                'Character map value must be a single string [err:XPTY0004]',
              );
            }
            mapResult[kStr] = vItem.stringValue;
          }
          params.useCharacterMaps = mapResult;

        default:
          // Unrecognized parameter names in standard options map are ignored.
          break;
      }
    }

    if (params.method == 'json' && hasItemSeparator) {
      throw XPathEvaluationException(
        'item-separator cannot be specified for JSON method [err:SERE0023]',
      );
    }

    return params;
  }

  static SerializationParameters fromElement(XmlElement element) {
    if (element.name.local != 'serialization-parameters' ||
        element.name.namespaceUri != _outputNamespace) {
      throw XPathEvaluationException(
        'Outermost element must be output:serialization-parameters in $_outputNamespace [err:XPTY0004]',
      );
    }
    for (final attr in element.attributes) {
      if (attr.name.prefix != 'xmlns' && attr.name.qualified != 'xmlns') {
        throw XPathEvaluationException(
          'Attributes on serialization-parameters not allowed [err:SEPM0017]',
        );
      }
    }

    final params = SerializationParameters();
    final seen = <(String?, String)>{};

    for (final child in element.childElements) {
      final name = child.name;
      final key = (name.namespaceUri, name.local);
      if (seen.contains(key)) {
        throw XPathEvaluationException(
          'Duplicate serialization parameter: ${name.qualified} [err:SEPM0019]',
        );
      }
      seen.add(key);

      if (name.namespaceUri != _outputNamespace) {
        if (name.namespaceUri == null || name.namespaceUri!.isEmpty) {
          throw XPathEvaluationException(
            'Elements must be in $_outputNamespace [err:SEPM0017]',
          );
        }
        // Implementation-defined extension parameter in non-null namespace; ignore
        continue;
      }

      final local = name.local;

      if (local == 'use-character-maps') {
        for (final attr in child.attributes) {
          if (attr.name.prefix != 'xmlns' && attr.name.qualified != 'xmlns') {
            throw XPathEvaluationException(
              'Attributes not allowed on use-character-maps [err:SEPM0017]',
            );
          }
        }
        final mapResult = <String, String>{};
        final seenChars = <String>{};
        for (final cmChild in child.childElements) {
          if (cmChild.name.local != 'character-map' ||
              cmChild.name.namespaceUri != _outputNamespace) {
            throw XPathEvaluationException(
              'Invalid child of use-character-maps [err:SEPM0017]',
            );
          }
          for (final attr in cmChild.attributes) {
            if (attr.name.local != 'character' &&
                attr.name.local != 'map-string' &&
                attr.name.prefix != 'xmlns' &&
                attr.name.qualified != 'xmlns') {
              throw XPathEvaluationException(
                'Invalid attribute on character-map [err:SEPM0017]',
              );
            }
          }
          final character = cmChild.getAttribute('character');
          final mapString = cmChild.getAttribute('map-string');
          if (character == null || mapString == null) {
            throw XPathEvaluationException(
              'character and map-string required on character-map [err:SEPM0017]',
            );
          }
          if (character.runes.length != 1) {
            throw XPathEvaluationException(
              'character-map character must be single char [err:SEPM0017]',
            );
          }
          if (seenChars.contains(character)) {
            throw XPathEvaluationException(
              'Duplicate character mapping for $character [err:SEPM0018]',
            );
          }
          seenChars.add(character);
          mapResult[character] = mapString;
        }
        params.useCharacterMaps = mapResult;
        continue;
      }

      for (final attr in child.attributes) {
        if (attr.name.local != 'value' &&
            attr.name.prefix != 'xmlns' &&
            attr.name.qualified != 'xmlns') {
          throw XPathEvaluationException(
            'Invalid attribute on serialization parameter [err:SEPM0017]',
          );
        }
      }
      final value = child.getAttribute('value');
      if (value == null) {
        throw XPathEvaluationException(
          'Missing value attribute on $local [err:SEPM0017]',
        );
      }

      switch (local) {
        case 'method':
          params.method = value;
        case 'indent':
          final v = value.trim();
          if (v != 'yes' && v != 'no') {
            throw XPathEvaluationException(
              'Invalid value for indent: $value [err:SEPM0017]',
            );
          }
          params.indent = v == 'yes';
        case 'omit-xml-declaration':
          final v = value.trim();
          if (v != 'yes' && v != 'no') {
            throw XPathEvaluationException(
              'Invalid value for omit-xml-declaration: $value [err:SEPM0017]',
            );
          }
          params.omitXmlDeclaration = v == 'yes';
        case 'standalone':
          final v = value.trim();
          if (v != 'yes' && v != 'no' && v != 'omit') {
            throw XPathEvaluationException(
              'Invalid value for standalone: $value [err:SEPM0017]',
            );
          }
          params.standalone = v == 'yes' ? true : (v == 'no' ? false : null);
        case 'item-separator':
          params.itemSeparator = value;
        case 'version':
          params.version = value.trim();
        case 'undeclare-prefixes':
          final v = value.trim();
          if (v != 'yes' && v != 'no') {
            throw XPathEvaluationException(
              'Invalid value for undeclare-prefixes: $value [err:SEPM0017]',
            );
          }
          params.undeclarePrefixes = v == 'yes';
        case 'encoding':
          params.encoding = value.trim();
        case 'cdata-section-elements':
          params.cdataSectionElements = value
              .split(RegExp(r'\s+'))
              .where((s) => s.isNotEmpty)
              .map(XmlName.parse)
              .toList();
        case 'suppress-indentation':
          params.suppressIndentation = value
              .split(RegExp(r'\s+'))
              .where((s) => s.isNotEmpty)
              .map(XmlName.parse)
              .toList();
        default:
          throw XPathEvaluationException(
            'Disallowed or unrecognized serialization parameter: $local [err:SEPM0017]',
          );
      }
    }

    return params;
  }

  static String _getStringOption(XPathSequence seq, String name) {
    final atom = seq.atomize().toList();
    if (atom.length != 1) {
      throw XPathEvaluationException(
        'Option "$name" must be a single string [err:XPTY0004]',
      );
    }
    final first = atom.first;
    if (first is XPathString || first is XPathUntypedAtomic) {
      return first.stringValue;
    }
    throw XPathEvaluationException(
      'Option "$name" must be a string [err:XPTY0004]',
    );
  }

  static bool _getBooleanOption(XPathSequence seq, String name) {
    final atom = seq.atomize().toList();
    if (atom.length != 1) {
      throw XPathEvaluationException(
        'Option "$name" must be a single boolean [err:XPTY0004]',
      );
    }
    final first = atom.first;
    if (first is XPathBoolean) {
      return first.value;
    }
    if (first is XPathUntypedAtomic) {
      if (first.value == 'true' || first.value == '1' || first.value == 'yes') {
        return true;
      }
      if (first.value == 'false' || first.value == '0' || first.value == 'no') {
        return false;
      }
    }
    throw XPathEvaluationException(
      'Option "$name" must be a boolean [err:XPTY0004]',
    );
  }

  static double _getNumberOption(XPathSequence seq, String name) {
    final atom = seq.atomize().toList();
    if (atom.length != 1) {
      throw XPathEvaluationException(
        'Option "$name" must be a single number [err:XPTY0004]',
      );
    }
    final first = atom.first;
    if (first is XPathNumeric) {
      return first.toDouble();
    }
    if (first is XPathUntypedAtomic) {
      final parsed = double.tryParse(first.value);
      if (parsed != null) return parsed;
    }
    throw XPathEvaluationException(
      'Option "$name" must be a number [err:XPTY0004]',
    );
  }
}

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
          'Cannot serialize free-standing attribute or namespace in XML method [err:SENR0001]',
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
  if (node is XmlDocument) {
    for (final child in node.children) {
      if (child is XmlDeclaration) continue;
      _writeXmlItemNode(sb, child, params);
    }
    return;
  }
  if (params.cdataSectionElements.isNotEmpty) {
    _writeNodeWithCdata(sb, node, params.cdataSectionElements);
  } else if (params.indent) {
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
      'JSON output method cannot serialize sequence of length > 1 [err:SERE0023]',
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
          'Duplicate key in JSON serialization: $keyStr [err:SERE0022]',
        );
      }
      seen.add(keyStr);
      sb.write(_escapeJsonString(keyStr, params.encoding));
      sb.write(':');
      final valSeq = entry.value;
      if (valSeq.isEmpty) {
        sb.write('null');
      } else if (valSeq.length > 1) {
        throw XPathEvaluationException(
          'Cannot serialize sequence with length > 1 inside JSON map [err:SERE0023]',
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
          'Cannot serialize sequence with length > 1 inside JSON array [err:SERE0023]',
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
    return _escapeJsonString(nodeXml, params.encoding);
  } else if (item is XPathBoolean) {
    return item.value ? 'true' : 'false';
  } else if (item is XPathNumeric) {
    final d = item.toDouble();
    if (d.isNaN || d.isInfinite) {
      throw XPathEvaluationException(
        'Cannot serialize NaN or Infinity with JSON method [err:SERE0020]',
      );
    }
    return item.stringValue;
  } else {
    return _escapeJsonString(item.stringValue, params.encoding);
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

String _escapeJsonString(String input, [String encoding = 'utf-8']) {
  final sb = StringBuffer();
  sb.write('"');
  final isIso88591 = encoding.toLowerCase().contains('8859-1');
  for (var i = 0; i < input.length; i++) {
    final code = input.codeUnitAt(i);
    switch (code) {
      case 0x22: // "
        sb.write(r'\"');
      case 0x5C: // \
        sb.write(r'\\');
      case 0x2F: // /
        sb.write(r'\/');
      case 0x08: // \b
        sb.write(r'\b');
      case 0x0C: // \f
        sb.write(r'\f');
      case 0x0A: // \n
        sb.write(r'\n');
      case 0x0D: // \r
        sb.write(r'\r');
      case 0x09: // \t
        sb.write(r'\t');
      default:
        if (code < 0x20 || (code >= 0x7F && code <= 0x9F)) {
          sb.write(
            '\\u${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
          );
        } else if (isIso88591 && code > 0xFF) {
          sb.write(
            '\\u${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
          );
        } else {
          sb.writeCharCode(code);
        }
    }
  }
  sb.write('"');
  return sb.toString();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
final fnSerialize = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:serialize'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:serialize'),
      (context, arg) => XPathSequence.single(
        XPathString(serializeSequence(arg, SerializationParameters())),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:serialize'),
      (context, arg, params) => XPathSequence.single(
        XPathString(
          serializeSequence(arg, SerializationParameters.fromSequence(params)),
        ),
      ),
    ),
  },
);
