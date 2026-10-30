import '../../xml/nodes/element.dart';
import '../../xml/utils/name.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/qname.dart';
import '../xdm/atomic/string.dart';
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
      XPathErrorCode.XPTY0004,
      'Serialization parameters must be a map or an element',
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
          XPathErrorCode.XPTY0004,
          'Serialization parameter key must be xs:string or xs:QName',
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
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0016,
              'Unknown method: $v',
            );
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
                  XPathErrorCode.XPTY0004,
                  'Invalid standalone value',
                );
              }
            } else {
              throw XPathEvaluationException(
                XPathErrorCode.XPTY0004,
                'Invalid standalone sequence',
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
                XPathErrorCode.XPTY0004,
                'cdata-section-elements items must be QNames',
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
                XPathErrorCode.XPTY0004,
                'suppress-indentation items must be QNames',
              );
            }
          }
          params.suppressIndentation = list;

        case 'use-character-maps':
          if (valSeq.length != 1 || valSeq.first is! XPathMap) {
            throw XPathEvaluationException(
              XPathErrorCode.XPTY0004,
              'use-character-maps must be a map',
            );
          }
          final charMap = valSeq.first as XPathMap;
          final mapResult = <String, String>{};
          for (final e in charMap.entries.entries) {
            final k = e.key;
            if (k is! XPathString && k is! XPathUntypedAtomic) {
              throw XPathEvaluationException(
                XPathErrorCode.XPTY0004,
                'Character map keys must be single characters',
              );
            }
            final kStr = k.stringValue;
            if (kStr.runes.length != 1) {
              throw XPathEvaluationException(
                XPathErrorCode.SEPM0016,
                'Character map key must be a single character: $kStr',
              );
            }
            final vSeq = e.value;
            if (vSeq.length != 1) {
              throw XPathEvaluationException(
                XPathErrorCode.XPTY0004,
                'Character map value must be a single string',
              );
            }
            final vItem = vSeq.first;
            if (vItem is! XPathString && vItem is! XPathUntypedAtomic) {
              throw XPathEvaluationException(
                XPathErrorCode.XPTY0004,
                'Character map value must be a single string',
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
        XPathErrorCode.SERE0023,
        'item-separator cannot be specified for JSON method',
      );
    }

    return params;
  }

  static SerializationParameters fromElement(XmlElement element) {
    if (element.name.local != 'serialization-parameters' ||
        element.name.namespaceUri != _outputNamespace) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Outermost element must be output:serialization-parameters in $_outputNamespace',
      );
    }
    for (final attr in element.attributes) {
      if (attr.name.prefix != 'xmlns' && attr.name.qualified != 'xmlns') {
        throw XPathEvaluationException(
          XPathErrorCode.SEPM0017,
          'Attributes on serialization-parameters not allowed',
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
          XPathErrorCode.SEPM0019,
          'Duplicate serialization parameter: ${name.qualified}',
        );
      }
      seen.add(key);

      if (name.namespaceUri != _outputNamespace) {
        if (name.namespaceUri == null || name.namespaceUri!.isEmpty) {
          throw XPathEvaluationException(
            XPathErrorCode.SEPM0017,
            'Elements must be in $_outputNamespace',
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
              XPathErrorCode.SEPM0017,
              'Attributes not allowed on use-character-maps',
            );
          }
        }
        final mapResult = <String, String>{};
        final seenChars = <String>{};
        for (final cmChild in child.childElements) {
          if (cmChild.name.local != 'character-map' ||
              cmChild.name.namespaceUri != _outputNamespace) {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0017,
              'Invalid child of use-character-maps',
            );
          }
          for (final attr in cmChild.attributes) {
            if (attr.name.local != 'character' &&
                attr.name.local != 'map-string' &&
                attr.name.prefix != 'xmlns' &&
                attr.name.qualified != 'xmlns') {
              throw XPathEvaluationException(
                XPathErrorCode.SEPM0017,
                'Invalid attribute on character-map',
              );
            }
          }
          final character = cmChild.getAttribute('character');
          final mapString = cmChild.getAttribute('map-string');
          if (character == null || mapString == null) {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0017,
              'character and map-string required on character-map',
            );
          }
          if (character.runes.length != 1) {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0017,
              'character-map character must be single char',
            );
          }
          if (seenChars.contains(character)) {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0018,
              'Duplicate character mapping for $character',
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
            XPathErrorCode.SEPM0017,
            'Invalid attribute on serialization parameter',
          );
        }
      }
      final value = child.getAttribute('value');
      if (value == null) {
        throw XPathEvaluationException(
          XPathErrorCode.SEPM0017,
          'Missing value attribute on $local',
        );
      }

      switch (local) {
        case 'method':
          params.method = value;
        case 'indent':
          final v = value.trim();
          if (v != 'yes' && v != 'no') {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0017,
              'Invalid value for indent: $value',
            );
          }
          params.indent = v == 'yes';
        case 'omit-xml-declaration':
          final v = value.trim();
          if (v != 'yes' && v != 'no') {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0017,
              'Invalid value for omit-xml-declaration: $value',
            );
          }
          params.omitXmlDeclaration = v == 'yes';
        case 'standalone':
          final v = value.trim();
          if (v != 'yes' && v != 'no' && v != 'omit') {
            throw XPathEvaluationException(
              XPathErrorCode.SEPM0017,
              'Invalid value for standalone: $value',
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
              XPathErrorCode.SEPM0017,
              'Invalid value for undeclare-prefixes: $value',
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
            XPathErrorCode.SEPM0017,
            'Disallowed or unrecognized serialization parameter: $local',
          );
      }
    }

    return params;
  }

  static String _getStringOption(XPathSequence seq, String name) {
    final atom = seq.atomize().toList();
    if (atom.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Option "$name" must be a single string',
      );
    }
    final first = atom.first;
    if (first is XPathString || first is XPathUntypedAtomic) {
      return first.stringValue;
    }
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      'Option "$name" must be a string',
    );
  }

  static bool _getBooleanOption(XPathSequence seq, String name) {
    final atom = seq.atomize().toList();
    if (atom.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Option "$name" must be a single boolean',
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
      XPathErrorCode.XPTY0004,
      'Option "$name" must be a boolean',
    );
  }

  static double _getNumberOption(XPathSequence seq, String name) {
    final atom = seq.atomize().toList();
    if (atom.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Option "$name" must be a single number',
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
      XPathErrorCode.XPTY0004,
      'Option "$name" must be a number',
    );
  }
}
