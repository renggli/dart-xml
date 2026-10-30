import '../../xml/extensions/string.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';

class XmlToJsonSerializer {
  new({this.indent = false});

  final bool indent;

  String serialize(XmlNode node) {
    final rootElement = switch (node) {
      XmlDocument() => _findRootElement(node),
      XmlElement() => node,
      _ => throw XPathEvaluationException(
        XPathErrorCode.FOJS0006,
        'Input to xml-to-json must be a document or element node',
      ),
    };
    return _serializeElement(rootElement, 0);
  }

  XmlElement _findRootElement(XmlDocument doc) {
    for (final child in doc.children) {
      if (child is XmlElement) return child;
    }
    throw XPathEvaluationException(
      XPathErrorCode.FOJS0006,
      'Empty XML document',
    );
  }

  String _serializeElement(XmlElement element, int indentLevel) {
    if (element.name.namespaceUri != _ns) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0006,
        'Element is not in namespace $_ns: ${element.name}',
      );
    }

    _validateAttributes(element);

    switch (element.localName) {
      case 'map':
        return _serializeMap(element, indentLevel);
      case 'array':
        return _serializeArray(element, indentLevel);
      case 'string':
        return _serializeString(element);
      case 'number':
        return _serializeNumber(element);
      case 'boolean':
        return _serializeBoolean(element);
      case 'null':
        return _serializeNull(element);
      default:
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'Invalid element in $_ns: ${element.localName}',
        );
    }
  }

  void _validateAttributes(XmlElement element) {
    for (final attr in element.attributes) {
      final name = attr.name;
      if (name.prefix == 'xmlns' || name.qualified == 'xmlns') continue;
      if (name.namespaceUri == 'http://www.w3.org/2001/XMLSchema-instance') {
        continue;
      }
      if (name.namespaceUri == 'http://www.w3.org/XML/1998/namespace' &&
          name.local == 'space') {
        continue;
      }
      final uri = name.namespaceUri;
      if (name.prefix == null || uri == null || uri.isEmpty || uri == _ns) {
        if (name.local == 'key' ||
            name.local == 'escaped' ||
            name.local == 'escaped-key') {
          continue;
        }
      }
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0006,
        'Disallowed attribute on <${element.localName}>: ${attr.name}',
      );
    }
  }

  String _serializeMap(XmlElement element, int indentLevel) {
    final children = <XmlElement>[];
    for (final child in element.children) {
      if (child is XmlElement) {
        children.add(child);
      } else if (child is XmlText) {
        if (child.value.trim().isNotEmpty) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0006,
            'Map element contains non-whitespace text',
          );
        }
      }
    }

    if (children.isEmpty) return '{}';

    final sb = StringBuffer();
    sb.write('{');
    final seenKeys = <String>{};

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final rawKey = child.getAttribute('key');
      if (rawKey == null) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'Child of map element lacks "key" attribute',
        );
      }

      final isEscapedKey = _parseBoolAttribute(
        child.getAttribute('escaped-key'),
      );
      final effectiveKey = isEscapedKey ? _unescapeJsonString(rawKey) : rawKey;

      if (seenKeys.contains(effectiveKey)) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'Duplicate key in map: $effectiveKey',
        );
      }
      seenKeys.add(effectiveKey);

      if (indent) {
        sb.write('\n');
        sb.write('  ' * (indentLevel + 1));
      }

      sb.write(_serializeJsonStringContent(rawKey, isEscaped: isEscapedKey));
      sb.write(indent ? ' : ' : ':');
      sb.write(_serializeElement(child, indentLevel + 1));

      if (i < children.length - 1) {
        sb.write(',');
      }
    }

    if (indent) {
      sb.write('\n');
      sb.write('  ' * indentLevel);
    }
    sb.write('}');
    return sb.toString();
  }

  String _serializeArray(XmlElement element, int indentLevel) {
    final children = <XmlElement>[];
    for (final child in element.children) {
      if (child is XmlElement) {
        children.add(child);
      } else if (child is XmlText) {
        if (child.value.trim().isNotEmpty) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0006,
            'Array element contains non-whitespace text',
          );
        }
      }
    }

    if (children.isEmpty) return '[]';

    final sb = StringBuffer();
    sb.write('[');

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      if (indent) {
        sb.write('\n');
        sb.write('  ' * (indentLevel + 1));
      }
      sb.write(_serializeElement(child, indentLevel + 1));
      if (i < children.length - 1) {
        sb.write(',');
      }
    }

    if (indent) {
      sb.write('\n');
      sb.write('  ' * indentLevel);
    }
    sb.write(']');
    return sb.toString();
  }

  String _serializeString(XmlElement element) {
    for (final child in element.children) {
      if (child is XmlElement) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'String element cannot contain child elements',
        );
      }
    }
    final text = element.innerText;
    final isEscaped = _parseBoolAttribute(element.getAttribute('escaped'));
    return _serializeJsonStringContent(text, isEscaped: isEscaped);
  }

  String _serializeNumber(XmlElement element) {
    for (final child in element.children) {
      if (child is XmlElement) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'Number element cannot contain child elements',
        );
      }
    }
    final text = element.innerText.trim();
    if (text == 'NaN' || text == 'INF' || text == '-INF') {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0006,
        'Number cannot be NaN, INF, or -INF',
      );
    }
    final numVal = double.tryParse(text);
    if (numVal == null) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0006,
        'Invalid number format: $text',
      );
    }
    return _formatDoubleForJson(numVal, text);
  }

  String _formatDoubleForJson(double value, String originalText) {
    if (value == 0.0) {
      if (value.isNegative || originalText.trim().startsWith('-')) {
        return '-0';
      }
      return '0';
    }
    final absVal = value.abs();
    if (absVal >= 1e-6 && absVal < 1e6) {
      if (value == value.roundToDouble()) {
        final sign = (value < 0 || (value == 0.0 && value.isNegative))
            ? '-'
            : '';
        return '$sign${value.abs().toInt()}';
      }
      return value.toString();
    } else {
      final s = value.toStringAsExponential().toUpperCase();
      final parts = s.split('E');
      var mantissa = parts[0];
      var exp = parts[1];
      if (!mantissa.contains('.')) {
        mantissa = '$mantissa.0';
      }
      if (exp.startsWith('+')) {
        exp = exp.substring(1);
      }
      return '${mantissa}E$exp';
    }
  }

  String _serializeJsonStringContent(String text, {required bool isEscaped}) {
    final sb = StringBuffer();
    sb.write('"');
    if (!isEscaped) {
      for (var i = 0; i < text.length; i++) {
        final ch = text.codeUnitAt(i);
        switch (ch) {
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
            if (ch < 0x20 || (ch >= 0x7F && ch <= 0x9F)) {
              sb.write(
                '\\u${ch.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );
            } else {
              sb.writeCharCode(ch);
            }
        }
      }
    } else {
      var i = 0;
      while (i < text.length) {
        final ch = text.codeUnitAt(i);
        if (ch == 0x5C) {
          if (i + 1 >= text.length) {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0007,
              'Unterminated escape sequence in escaped string',
            );
          }
          final next = text.codeUnitAt(i + 1);
          if (next == 0x22 ||
              next == 0x5C ||
              next == 0x2F ||
              next == 0x62 ||
              next == 0x66 ||
              next == 0x6E ||
              next == 0x72 ||
              next == 0x74) {
            sb.writeCharCode(0x5C);
            sb.writeCharCode(next);
            i += 2;
          } else if (next == 0x75) {
            if (i + 5 >= text.length) {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0007,
                'Incomplete \\uXXXX escape in escaped string',
              );
            }
            final hex = text.substring(i + 2, i + 6);
            final code = int.tryParse(hex, radix: 16);
            if (code == null) {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0007,
                'Invalid hex in \\uXXXX escape in escaped string',
              );
            }
            sb.write('\\u$hex');
            i += 6;
          } else {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0007,
              'Invalid escape sequence in escaped string: \\${String.fromCharCode(next)}',
            );
          }
        } else if (ch == 0x22) {
          sb.write(r'\"');
          i++;
        } else if (ch < 0x20 || (ch >= 0x7F && ch <= 0x9F)) {
          switch (ch) {
            case 0x08:
              sb.write(r'\b');
            case 0x0C:
              sb.write(r'\f');
            case 0x0A:
              sb.write(r'\n');
            case 0x0D:
              sb.write(r'\r');
            case 0x09:
              sb.write(r'\t');
            default:
              sb.write(
                '\\u${ch.toRadixString(16).toUpperCase().padLeft(4, '0')}',
              );
          }
          i++;
        } else {
          sb.writeCharCode(ch);
          i++;
        }
      }
    }
    sb.write('"');
    return sb.toString();
  }

  String _serializeBoolean(XmlElement element) {
    for (final child in element.children) {
      if (child is XmlElement) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'Boolean element cannot contain child elements',
        );
      }
    }
    final text = element.innerText.trim();
    if (text == 'true' || text == '1') return 'true';
    if (text == 'false' || text == '0') return 'false';
    throw XPathEvaluationException(
      XPathErrorCode.FOJS0006,
      'Invalid boolean content: $text',
    );
  }

  String _serializeNull(XmlElement element) {
    for (final child in element.children) {
      if (child is XmlElement) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0006,
          'Null element cannot contain child elements',
        );
      }
    }
    final text = element.innerText.trim();
    if (text.isNotEmpty) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0006,
        'Null element cannot contain text',
      );
    }
    return 'null';
  }

  bool _parseBoolAttribute(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed == 'true' || trimmed == '1') return true;
    if (trimmed == 'false' || trimmed == '0') return false;
    throw XPathEvaluationException(
      XPathErrorCode.FOJS0006,
      'Invalid boolean attribute value: $value',
    );
  }

  String _unescapeJsonString(String input) {
    final sb = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final ch = input.codeUnitAt(i);
      if (ch == 0x5C) {
        // '\'
        if (i + 1 >= input.length) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0007,
            'Incomplete escape sequence in escaped string',
          );
        }
        i++;
        final next = input.codeUnitAt(i);
        switch (next) {
          case 0x22: // \"
            sb.write('"');
          case 0x5C: // \\
            sb.write(r'\');
          case 0x2F: // \/
            sb.write('/');
          case 0x62: // \b
            sb.write('\b');
          case 0x66: // \f
            sb.write('\f');
          case 0x6E: // \n
            sb.write('\n');
          case 0x72: // \r
            sb.write('\r');
          case 0x74: // \t
            sb.write('\t');
          case 0x75: // \uXXXX
            if (i + 4 >= input.length) {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0007,
                'Incomplete \\u hex escape in escaped string',
              );
            }
            final hex = input.substring(i + 1, i + 5);
            final code = int.tryParse(hex, radix: 16);
            if (code == null) {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0007,
                'Invalid \\u hex escape: $hex',
              );
            }
            i += 4;
            // Check if high surrogate
            if (code >= 0xD800 && code <= 0xDBFF) {
              if (i + 6 <= input.length &&
                  input.codeUnitAt(i + 1) == 0x5C &&
                  input.codeUnitAt(i + 2) == 0x75) {
                final lowHex = input.substring(i + 3, i + 7);
                final lowCode = int.tryParse(lowHex, radix: 16);
                if (lowCode != null && lowCode >= 0xDC00 && lowCode <= 0xDFFF) {
                  i += 6;
                  final full =
                      0x10000 + ((code - 0xD800) << 10) + (lowCode - 0xDC00);
                  sb.write(String.fromCharCode(full));
                  continue;
                }
              }
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0007,
                'Unpaired high surrogate in escaped string: $hex',
              );
            }
            if (code >= 0xDC00 && code <= 0xDFFF) {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0007,
                'Unpaired low surrogate in escaped string: $hex',
              );
            }
            sb.write(String.fromCharCode(code));
          default:
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0007,
              'Invalid escape sequence in escaped string: \\${String.fromCharCode(next)}',
            );
        }
      } else {
        sb.writeCharCode(ch);
      }
    }
    return sb.toString();
  }
}

const _ns = 'http://www.w3.org/2005/xpath-functions';
