import '../../xml/builder/builder.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/sequence.dart';
import 'json_options.dart';

class JsonParser {
  new(this.input, this.options, {this.context, required this.isXmlTarget});

  final String input;
  final JsonOptions options;
  final XPathContext? context;
  final bool isXmlTarget;

  int _pos = 0;

  bool get _isEof => _pos >= input.length;

  int _peek() => _pos < input.length ? input.codeUnitAt(_pos) : -1;

  int _next() => _pos < input.length ? input.codeUnitAt(_pos++) : -1;

  void _skipWhitespace() {
    while (!_isEof) {
      final ch = _peek();
      if (ch == 0x20 || ch == 0x09 || ch == 0x0A || ch == 0x0D) {
        _pos++;
      } else {
        break;
      }
    }
  }

  XPathSequence parseTopLevelToXPath() {
    // Check for optional Byte-Order-Mark (U+FEFF)
    if (_pos < input.length && input.codeUnitAt(_pos) == 0xFEFF) {
      _pos++;
    }
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Empty JSON input',
      );
    }
    final result = _parseValueToXPath();
    _skipWhitespace();
    if (!_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected character after JSON value',
      );
    }
    return result;
  }

  void parseTopLevelToXml(XmlBuilder builder) {
    if (_pos < input.length && input.codeUnitAt(_pos) == 0xFEFF) {
      _pos++;
    }
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Empty JSON input',
      );
    }
    _parseValueToXml(builder, isRoot: true);
    _skipWhitespace();
    if (!_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected character after JSON value',
      );
    }
  }

  XPathSequence _parseValueToXPath() {
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected end of JSON',
      );
    }
    final ch = _peek();
    if (ch == 0x7B) {
      // '{' -> object
      return _parseObjectToXPath();
    } else if (ch == 0x5B) {
      // '[' -> array
      return _parseArrayToXPath();
    } else if (ch == 0x22) {
      // '"' -> string
      final str = _parseString();
      return XPathSequence.single(XPathString(str.effectiveValue));
    } else if (ch == 0x74) {
      // 'true'
      _expectLiteral('true');
      return XPathSequence.trueSequence;
    } else if (ch == 0x66) {
      // 'false'
      _expectLiteral('false');
      return XPathSequence.falseSequence;
    } else if (ch == 0x6E) {
      // 'null'
      _expectLiteral('null');
      return XPathSequence.empty;
    } else if (ch == 0x2D || (ch >= 0x30 && ch <= 0x39)) {
      // number
      final numStr = _parseNumber();
      return XPathSequence.single(XPathDouble(double.parse(numStr)));
    } else {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected character in JSON: "${String.fromCharCode(ch)}"',
      );
    }
  }

  void _parseValueToXml(
    XmlBuilder builder, {
    Map<String, String> attributes = const {},
    bool isRoot = false,
  }) {
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected end of JSON',
      );
    }
    final ch = _peek();
    final nsMap = isRoot
        ? <String?, String>{null: jsonNamespace}
        : const <String?, String>{};

    if (ch == 0x7B) {
      // object -> <map>
      _parseObjectToXml(builder, attributes: attributes, isRoot: isRoot);
    } else if (ch == 0x5B) {
      // array -> <array>
      _parseArrayToXml(builder, attributes: attributes, isRoot: isRoot);
    } else if (ch == 0x22) {
      // string -> <string>
      final str = _parseString();
      final attrMap = Map<String, String>.from(attributes);
      if (str.escaped) {
        attrMap['escaped'] = 'true';
      }
      builder.element(
        'string',
        namespaceUri: jsonNamespace,
        namespaceUris: nsMap,
        attributes: attrMap,
        nest: () {
          if (str.effectiveValue.isNotEmpty) {
            builder.text(str.effectiveValue);
          }
        },
      );
    } else if (ch == 0x74) {
      _expectLiteral('true');
      builder.element(
        'boolean',
        namespaceUri: jsonNamespace,
        namespaceUris: nsMap,
        attributes: attributes,
        nest: 'true',
      );
    } else if (ch == 0x66) {
      _expectLiteral('false');
      builder.element(
        'boolean',
        namespaceUri: jsonNamespace,
        namespaceUris: nsMap,
        attributes: attributes,
        nest: 'false',
      );
    } else if (ch == 0x6E) {
      _expectLiteral('null');
      builder.element(
        'null',
        namespaceUri: jsonNamespace,
        namespaceUris: nsMap,
        attributes: attributes,
      );
    } else if (ch == 0x2D || (ch >= 0x30 && ch <= 0x39)) {
      final numStr = _parseNumber();
      builder.element(
        'number',
        namespaceUri: jsonNamespace,
        namespaceUris: nsMap,
        attributes: attributes,
        nest: numStr,
      );
    } else {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected character in JSON: "${String.fromCharCode(ch)}"',
      );
    }
  }

  XPathSequence _parseObjectToXPath() {
    _pos++; // consume '{'
    _skipWhitespace();
    final entries = <XPathAtomic, XPathSequence>{};
    final seenEscapedKeys = <String>{};

    if (_peek() == 0x7D) {
      // '}'
      _pos++;
      return XPathSequence.single(XPathMap(entries));
    }

    while (true) {
      _skipWhitespace();
      if (_peek() != 0x22) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0001,
          'Expected string key in JSON object',
        );
      }
      final keyParsed = _parseString();
      _skipWhitespace();
      if (_next() != 0x3A) {
        // ':'
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0001,
          'Expected ":" after key in JSON object',
        );
      }

      // Check duplicate keys
      final escapedKey = keyParsed.escapedComparisonKey;
      final isDuplicate = seenEscapedKeys.contains(escapedKey);
      seenEscapedKeys.add(escapedKey);

      if (isDuplicate && options.duplicates == 'reject') {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0003,
          'Duplicate key: ${keyParsed.effectiveValue}',
        );
      }

      final value = _parseValueToXPath();
      final keyAtomic = XPathString(keyParsed.effectiveValue);

      if (!isDuplicate || options.duplicates == 'use-last') {
        entries[keyAtomic] = value;
      }

      _skipWhitespace();
      final nextCh = _peek();
      if (nextCh == 0x2C) {
        // ','
        _pos++;
        _skipWhitespace();
        if (_peek() == 0x7D) {
          // trailing comma
          if (!options.liberal) {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Trailing comma in JSON object',
            );
          }
          _pos++;
          break;
        }
      } else if (nextCh == 0x7D) {
        // '}'
        _pos++;
        break;
      } else {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0001,
          'Expected "," or "}" in JSON object',
        );
      }
    }

    return XPathSequence.single(XPathMap(entries));
  }

  void _parseObjectToXml(
    XmlBuilder builder, {
    Map<String, String> attributes = const {},
    bool isRoot = false,
  }) {
    _pos++; // consume '{'
    _skipWhitespace();
    final nsMap = isRoot
        ? <String?, String>{null: jsonNamespace}
        : const <String?, String>{};

    builder.element(
      'map',
      namespaceUri: jsonNamespace,
      namespaceUris: nsMap,
      attributes: attributes,
      nest: () {
        if (_peek() == 0x7D) {
          _pos++;
          return;
        }

        final seenEscapedKeys = <String>{};

        while (true) {
          _skipWhitespace();
          if (_peek() != 0x22) {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Expected string key in JSON object',
            );
          }
          final keyParsed = _parseString();
          _skipWhitespace();
          if (_next() != 0x3A) {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Expected ":" after key in JSON object',
            );
          }

          final escapedKey = keyParsed.escapedComparisonKey;
          final isDuplicate = seenEscapedKeys.contains(escapedKey);
          seenEscapedKeys.add(escapedKey);

          if (isDuplicate) {
            if (options.duplicates == 'reject') {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0003,
                'Duplicate key: ${keyParsed.effectiveValue}',
              );
            }
            if (options.validate) {
              throw XPathEvaluationException(
                XPathErrorCode.FOJS0003,
                'Duplicate key with validate=true: ${keyParsed.effectiveValue}',
              );
            }
          }

          final childAttrs = <String, String>{'key': keyParsed.effectiveValue};
          if (keyParsed.escaped) {
            childAttrs['escaped-key'] = 'true';
          }

          final shouldEmit = !isDuplicate || options.duplicates == 'retain';
          if (shouldEmit) {
            _parseValueToXml(builder, attributes: childAttrs);
          } else {
            // If use-first and duplicate, skip parsing value to XML
            _skipJsonValue();
          }

          _skipWhitespace();
          final nextCh = _peek();
          if (nextCh == 0x2C) {
            _pos++;
            _skipWhitespace();
            if (_peek() == 0x7D) {
              if (!options.liberal) {
                throw XPathEvaluationException(
                  XPathErrorCode.FOJS0001,
                  'Trailing comma in JSON object',
                );
              }
              _pos++;
              break;
            }
          } else if (nextCh == 0x7D) {
            _pos++;
            break;
          } else {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Expected "," or "}" in JSON object',
            );
          }
        }
      },
    );
  }

  void _skipJsonValue() {
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Unexpected end of JSON',
      );
    }
    final ch = _peek();
    if (ch == 0x7B) {
      _pos++;
      _skipWhitespace();
      if (_peek() == 0x7D) {
        _pos++;
        return;
      }
      while (true) {
        _skipWhitespace();
        _parseString();
        _skipWhitespace();
        if (_next() != 0x3A) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0001,
            'Expected ":"',
          );
        }
        _skipJsonValue();
        _skipWhitespace();
        final nextCh = _peek();
        if (nextCh == 0x2C) {
          _pos++;
          _skipWhitespace();
          if (_peek() == 0x7D) {
            _pos++;
            break;
          }
        } else if (nextCh == 0x7D) {
          _pos++;
          break;
        } else {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0001,
            'Expected "," or "}"',
          );
        }
      }
    } else if (ch == 0x5B) {
      _pos++;
      _skipWhitespace();
      if (_peek() == 0x5D) {
        _pos++;
        return;
      }
      while (true) {
        _skipJsonValue();
        _skipWhitespace();
        final nextCh = _peek();
        if (nextCh == 0x2C) {
          _pos++;
          _skipWhitespace();
          if (_peek() == 0x5D) {
            _pos++;
            break;
          }
        } else if (nextCh == 0x5D) {
          _pos++;
          break;
        } else {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0001,
            'Expected "," or "]"',
          );
        }
      }
    } else if (ch == 0x22) {
      _parseString();
    } else if (ch == 0x74) {
      _expectLiteral('true');
    } else if (ch == 0x66) {
      _expectLiteral('false');
    } else if (ch == 0x6E) {
      _expectLiteral('null');
    } else {
      _parseNumber();
    }
  }

  XPathSequence _parseArrayToXPath() {
    _pos++; // consume '['
    _skipWhitespace();
    final items = <XPathSequence>[];

    if (_peek() == 0x5D) {
      // ']'
      _pos++;
      return XPathSequence.single(XPathArray(items));
    }

    while (true) {
      final value = _parseValueToXPath();
      items.add(value);
      _skipWhitespace();
      final nextCh = _peek();
      if (nextCh == 0x2C) {
        _pos++;
        _skipWhitespace();
        if (_peek() == 0x5D) {
          if (!options.liberal) {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Trailing comma in JSON array',
            );
          }
          _pos++;
          break;
        }
      } else if (nextCh == 0x5D) {
        _pos++;
        break;
      } else {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0001,
          'Expected "," or "]" in JSON array',
        );
      }
    }

    return XPathSequence.single(XPathArray(items));
  }

  void _parseArrayToXml(
    XmlBuilder builder, {
    Map<String, String> attributes = const {},
    bool isRoot = false,
  }) {
    _pos++; // consume '['
    _skipWhitespace();
    final nsMap = isRoot
        ? <String?, String>{null: jsonNamespace}
        : const <String?, String>{};

    builder.element(
      'array',
      namespaceUri: jsonNamespace,
      namespaceUris: nsMap,
      attributes: attributes,
      nest: () {
        if (_peek() == 0x5D) {
          _pos++;
          return;
        }

        while (true) {
          _parseValueToXml(builder);
          _skipWhitespace();
          final nextCh = _peek();
          if (nextCh == 0x2C) {
            _pos++;
            _skipWhitespace();
            if (_peek() == 0x5D) {
              if (!options.liberal) {
                throw XPathEvaluationException(
                  XPathErrorCode.FOJS0001,
                  'Trailing comma in JSON array',
                );
              }
              _pos++;
              break;
            }
          } else if (nextCh == 0x5D) {
            _pos++;
            break;
          } else {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Expected "," or "]" in JSON array',
            );
          }
        }
      },
    );
  }

  ParsedString _parseString() {
    _pos++; // consume opening '"'
    final sb = StringBuffer();
    final cmpSb = StringBuffer();
    var escapedAttribute = false;

    while (!_isEof) {
      final ch = _next();
      if (ch == 0x22) {
        // closing '"'
        return ParsedString(
          effectiveValue: sb.toString(),
          escapedComparisonKey: cmpSb.toString(),
          escaped: escapedAttribute,
        );
      }

      if (ch == 0x5C) {
        // backslash '\'
        if (_isEof) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0001,
            'Unterminated escape in JSON string',
          );
        }
        final esc = _next();
        switch (esc) {
          case 0x22: // \"
            sb.write('"');
            cmpSb.write('"');
          case 0x5C: // \\
            sb.write(options.escape ? r'\\' : r'\');
            cmpSb.write(options.escape ? r'\\' : r'\');
            if (options.escape) escapedAttribute = true;
          case 0x2F: // \/
            sb.write('/');
            cmpSb.write('/');
          case 0x62: // \b
            _handleControlEscape(
              sb,
              cmpSb,
              0x08,
              r'\b',
              () => escapedAttribute = true,
            );
          case 0x66: // \f
            _handleControlEscape(
              sb,
              cmpSb,
              0x0C,
              r'\f',
              () => escapedAttribute = true,
            );
          case 0x6E: // \n
            _handleControlEscape(
              sb,
              cmpSb,
              0x0A,
              r'\n',
              () => escapedAttribute = true,
              xml10Valid: true,
            );
          case 0x72: // \r
            _handleControlEscape(
              sb,
              cmpSb,
              0x0D,
              r'\r',
              () => escapedAttribute = true,
              xml10Valid: true,
            );
          case 0x74: // \t
            _handleControlEscape(
              sb,
              cmpSb,
              0x09,
              r'\t',
              () => escapedAttribute = true,
              xml10Valid: true,
            );
          case 0x75: // \uXXXX
            final code = _parseHex4();
            _handleUnicodeEscape(
              sb,
              cmpSb,
              code,
              () => escapedAttribute = true,
            );
          default:
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0001,
              'Invalid escape character in JSON string: \\${String.fromCharCode(esc)}',
            );
        }
      } else {
        // Raw character
        if (ch < 0x20) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0001,
            'Unescaped control character in JSON string',
          );
        }
        final charStr = String.fromCharCode(ch);
        sb.write(charStr);
        cmpSb.write(charStr);
      }
    }

    throw XPathEvaluationException(
      XPathErrorCode.FOJS0001,
      'Unterminated JSON string',
    );
  }

  void _handleControlEscape(
    StringBuffer sb,
    StringBuffer cmpSb,
    int code,
    String escapeSeq,
    void Function() setEscaped, {
    bool xml10Valid = false,
  }) {
    if (options.escape) {
      if (!xml10Valid) {
        sb.write(escapeSeq);
        cmpSb.write(escapeSeq);
        setEscaped();
      } else {
        sb.write(escapeSeq);
        cmpSb.write(String.fromCharCode(code));
        setEscaped();
      }
    } else {
      if (xml10Valid) {
        final ch = String.fromCharCode(code);
        sb.write(ch);
        cmpSb.write(ch);
      } else {
        // Not valid in XML 1.0! Check fallback
        if (options.fallback != null) {
          final res = _invokeFallback(escapeSeq);
          sb.write(res);
          cmpSb.write(res);
        } else {
          sb.write('\uFFFD');
          cmpSb.write('\uFFFD');
        }
      }
    }
  }

  int _parseHex4() {
    if (_pos + 4 > input.length) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Insufficient hex digits in \\u escape',
      );
    }
    final hexStr = input.substring(_pos, _pos + 4);
    _pos += 4;
    final code = int.tryParse(hexStr, radix: 16);
    if (code == null) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Invalid hex digits in \\u escape: $hexStr',
      );
    }
    return code;
  }

  void _handleUnicodeEscape(
    StringBuffer sb,
    StringBuffer cmpSb,
    int code,
    void Function() setEscaped,
  ) {
    // Check if high surrogate
    if (code >= 0xD800 && code <= 0xDBFF) {
      // Lookahead for \uDC00..\uDFFF
      if (_pos + 6 <= input.length &&
          input.codeUnitAt(_pos) == 0x5C &&
          input.codeUnitAt(_pos + 1) == 0x75) {
        final lowHex = input.substring(_pos + 2, _pos + 6);
        final lowCode = int.tryParse(lowHex, radix: 16);
        if (lowCode != null && lowCode >= 0xDC00 && lowCode <= 0xDFFF) {
          // Valid surrogate pair
          _pos += 6;
          final fullCode =
              0x10000 + ((code - 0xD800) << 10) + (lowCode - 0xDC00);
          final fullChar = String.fromCharCode(fullCode);
          sb.write(fullChar);
          cmpSb.write(fullChar);
          return;
        }
      }
      // Unpaired high surrogate
      _handleSpecialUnicode(sb, cmpSb, code, setEscaped);
      return;
    }

    if (code >= 0xDC00 && code <= 0xDFFF) {
      // Unpaired low surrogate
      _handleSpecialUnicode(sb, cmpSb, code, setEscaped);
      return;
    }

    // Normal unicode code
    // Check if invalid XML 1.0 character:
    // (code < 0x20 && code != 9 && code != 10 && code != 13) || code == 0xFFFE || code == 0xFFFF
    final isInvalidXml =
        (code < 0x20 && code != 0x09 && code != 0x0A && code != 0x0D) ||
        code == 0xFFFE ||
        code == 0xFFFF;

    if (isInvalidXml) {
      _handleSpecialUnicode(sb, cmpSb, code, setEscaped);
    } else {
      if (options.escape && (code == 0x09 || code == 0x0A || code == 0x0D)) {
        final esc = code == 0x09 ? r'\t' : (code == 0x0A ? r'\n' : r'\r');
        sb.write(esc);
        cmpSb.write(String.fromCharCode(code));
        setEscaped();
      } else {
        final charStr = String.fromCharCode(code);
        sb.write(charStr);
        cmpSb.write(charStr);
      }
    }
  }

  void _handleSpecialUnicode(
    StringBuffer sb,
    StringBuffer cmpSb,
    int code,
    void Function() setEscaped,
  ) {
    final String escapeSeq;
    if (code == 0x08) {
      escapeSeq = r'\b';
    } else if (code == 0x0C) {
      escapeSeq = r'\f';
    } else {
      final hex = code.toRadixString(16).toUpperCase().padLeft(4, '0');
      escapeSeq = '\\u$hex';
    }

    if (options.escape) {
      sb.write(escapeSeq);
      cmpSb.write(escapeSeq);
      setEscaped();
    } else if (options.fallback != null) {
      final res = _invokeFallback(escapeSeq);
      sb.write(res);
      cmpSb.write(res);
    } else {
      sb.write('\uFFFD');
      cmpSb.write('\uFFFD');
    }
  }

  String _invokeFallback(String escapeSeq) {
    if (options.fallback == null || context == null) return '\uFFFD';
    try {
      final resSeq = options.fallback!.call(context!, [
        XPathSequence.single(XPathString(escapeSeq)),
      ]);
      final first = resSeq.firstOrNull;
      if (resSeq.length != 1 || first is! XPathString) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0005,
          'Fallback function must return a single xs:string',
        );
      }
      return first.value;
    } catch (e) {
      if (e is XPathEvaluationException) rethrow;
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0005,
        'Fallback function failed: $e',
      );
    }
  }

  String _parseNumber() {
    final start = _pos;
    if (_peek() == 0x2D) {
      // '-'
      _pos++;
    }

    if (_isEof) {
      throw XPathEvaluationException(XPathErrorCode.FOJS0001, 'Invalid number');
    }
    final firstDigit = _peek();
    if (firstDigit < 0x30 || firstDigit > 0x39) {
      throw XPathEvaluationException(XPathErrorCode.FOJS0001, 'Invalid number');
    }

    if (firstDigit == 0x30) {
      _pos++;
      if (!_isEof) {
        final nextD = _peek();
        if (nextD >= 0x30 && nextD <= 0x39) {
          throw XPathEvaluationException(
            XPathErrorCode.FOJS0001,
            'Leading zero not allowed in number',
          );
        }
      }
    } else {
      while (!_isEof && _peek() >= 0x30 && _peek() <= 0x39) {
        _pos++;
      }
    }

    // Fraction
    if (!_isEof && _peek() == 0x2E) {
      // '.'
      _pos++;
      if (_isEof || _peek() < 0x30 || _peek() > 0x39) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0001,
          'Decimal point must be followed by digits',
        );
      }
      while (!_isEof && _peek() >= 0x30 && _peek() <= 0x39) {
        _pos++;
      }
    }

    // Exponent
    if (!_isEof && (_peek() == 0x65 || _peek() == 0x45)) {
      // 'e' or 'E'
      _pos++;
      if (!_isEof && (_peek() == 0x2B || _peek() == 0x2D)) {
        // '+' or '-'
        _pos++;
      }
      if (_isEof || _peek() < 0x30 || _peek() > 0x39) {
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0001,
          'Exponent must be followed by digits',
        );
      }
      while (!_isEof && _peek() >= 0x30 && _peek() <= 0x39) {
        _pos++;
      }
    }

    return input.substring(start, _pos);
  }

  void _expectLiteral(String literal) {
    if (_pos + literal.length > input.length ||
        input.substring(_pos, _pos + literal.length) != literal) {
      throw XPathEvaluationException(
        XPathErrorCode.FOJS0001,
        'Expected "$literal" in JSON',
      );
    }
    _pos += literal.length;
  }
}

class ParsedString {
  const new({
    required this.effectiveValue,
    required this.escapedComparisonKey,
    required this.escaped,
  });

  final String effectiveValue;
  final String escapedComparisonKey;
  final bool escaped;
}
