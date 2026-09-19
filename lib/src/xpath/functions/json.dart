import '../../xml/builder/builder.dart';
import '../../xml/extensions/string.dart';
import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/text.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

XPathString? _expectOptionalString(XPathSequence seq, String funcName) {
  if (seq.length > 1) {
    throw XPathEvaluationException(
      '$funcName argument must contain at most one item [err:XPTY0004]',
    );
  }
  final item = seq.firstOrNull;
  if (item == null) return null;
  if (item is XPathString) return item;
  final atomized = XPathSequence.single(item).atomize();
  if (atomized.length == 1 && atomized.first is XPathString) {
    return atomized.first as XPathString;
  }
  throw XPathEvaluationException(
    '$funcName argument must be xs:string? [err:XPTY0004]',
  );
}

XPathMap? _expectOptionalMap(XPathSequence seq, String funcName) {
  if (seq.length > 1) {
    throw XPathEvaluationException(
      '$funcName options argument must contain at most one item [err:XPTY0004]',
    );
  }
  final item = seq.firstOrNull;
  if (item == null) return null;
  if (item is XPathMap) return item;
  throw XPathEvaluationException(
    '$funcName options argument must be map(*)? [err:XPTY0004]',
  );
}

XPathNode? _expectOptionalNode(XPathSequence seq, String funcName) {
  if (seq.length > 1) {
    throw XPathEvaluationException(
      '$funcName argument must contain at most one node [err:XPTY0004]',
    );
  }
  final item = seq.firstOrNull;
  if (item == null) return null;
  if (item is XPathNode) return item;
  throw XPathEvaluationException(
    '$funcName argument must be node()? [err:XPTY0004]',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
const fnParseJson = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:parse-json'),
  {
    1: XPathFunctionItem.fn1(XmlName.qualified('fn:parse-json'), _fnParseJson1),
    2: XPathFunctionItem.fn2(XmlName.qualified('fn:parse-json'), _fnParseJson2),
  },
);

XPathSequence _fnParseJson1(XPathContext context, XPathSequence jsonTextSeq) =>
    _evalParseJson(
      context,
      _expectOptionalString(jsonTextSeq, 'fn:parse-json'),
      null,
    );

XPathSequence _fnParseJson2(
  XPathContext context,
  XPathSequence jsonTextSeq,
  XPathSequence optionsSeq,
) => _evalParseJson(
  context,
  _expectOptionalString(jsonTextSeq, 'fn:parse-json'),
  _expectOptionalMap(optionsSeq, 'fn:parse-json'),
);

XPathSequence _evalParseJson(
  XPathContext context,
  XPathString? jsonText,
  XPathMap? options,
) {
  if (jsonText == null) return XPathSequence.empty;
  final opts = _parseJsonOptions(context, options, isXmlTarget: false);
  final parser = _JsonParser(
    jsonText.value,
    opts,
    context: context,
    isXmlTarget: false,
  );
  return parser.parseTopLevelToXPath();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-doc
const fnJsonDoc = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:json-doc'),
  {
    1: XPathFunctionItem.fn1(XmlName.qualified('fn:json-doc'), _fnJsonDoc1),
    2: XPathFunctionItem.fn2(XmlName.qualified('fn:json-doc'), _fnJsonDoc2),
  },
);

XPathSequence _fnJsonDoc1(XPathContext context, XPathSequence hrefSeq) =>
    _evalJsonDoc(context, _expectOptionalString(hrefSeq, 'fn:json-doc'), null);

XPathSequence _fnJsonDoc2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence optionsSeq,
) => _evalJsonDoc(
  context,
  _expectOptionalString(hrefSeq, 'fn:json-doc'),
  _expectOptionalMap(optionsSeq, 'fn:json-doc'),
);

XPathSequence _evalJsonDoc(
  XPathContext context,
  XPathString? href,
  XPathMap? options,
) {
  if (href == null) return XPathSequence.empty;

  // Resolve relative URI.
  String resolved;
  try {
    final uri = Uri.parse(href.value);
    if (uri.isAbsolute) {
      resolved = href.value;
    } else {
      final base = context.configuration.baseUri;
      if (base == null) {
        throw XPathEvaluationException('Static base URI is undefined');
      }
      resolved = Uri.parse(base).resolve(href.value).toString();
    }
  } on FormatException catch (error) {
    throw XPathEvaluationException(
      'Invalid URI: ${href.value} (${error.message})',
    );
  }

  // Check fragment identifier.
  final parsedResolved = Uri.parse(resolved);
  if (parsedResolved.hasFragment) {
    throw XPathEvaluationException(
      'URI contains a fragment identifier: $resolved',
    );
  }

  final loader = context.configuration.unparsedTextLoader;
  if (loader == null) {
    throw XPathEvaluationException(
      'No unparsed text loader available to load $resolved',
    );
  }

  final String? loaded;
  try {
    loaded = loader(resolved, null);
  } catch (exception) {
    if (exception is XPathEvaluationException) rethrow;
    throw XPathEvaluationException(
      'Failed to load resource $resolved: $exception',
    );
  }

  if (loaded == null) {
    throw XPathEvaluationException('Resource not found: $resolved');
  }

  final opts = _parseJsonOptions(context, options, isXmlTarget: false);
  final parser = _JsonParser(
    loaded,
    opts,
    context: context,
    isXmlTarget: false,
  );
  return parser.parseTopLevelToXPath();
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml
const fnJsonToXml = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:json-to-xml'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:json-to-xml'),
      _fnJsonToXml1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:json-to-xml'),
      _fnJsonToXml2,
    ),
  },
);

XPathSequence _fnJsonToXml1(XPathContext context, XPathSequence jsonTextSeq) =>
    _evalJsonToXml(
      context,
      _expectOptionalString(jsonTextSeq, 'fn:json-to-xml'),
      null,
    );

XPathSequence _fnJsonToXml2(
  XPathContext context,
  XPathSequence jsonTextSeq,
  XPathSequence optionsSeq,
) => _evalJsonToXml(
  context,
  _expectOptionalString(jsonTextSeq, 'fn:json-to-xml'),
  _expectOptionalMap(optionsSeq, 'fn:json-to-xml'),
);

XPathSequence _evalJsonToXml(
  XPathContext context,
  XPathString? jsonText,
  XPathMap? options,
) {
  if (jsonText == null) return XPathSequence.empty;
  final opts = _parseJsonOptions(context, options, isXmlTarget: true);
  final parser = _JsonParser(
    jsonText.value,
    opts,
    context: context,
    isXmlTarget: true,
  );
  final builder = XmlBuilder();
  parser.parseTopLevelToXml(builder);
  return XPathSequence.single(XPathNode(builder.buildDocument()));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-xml-to-json
const fnXmlToJson = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:xml-to-json'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:xml-to-json'),
      _fnXmlToJson1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:xml-to-json'),
      _fnXmlToJson2,
    ),
  },
);

XPathSequence _fnXmlToJson1(XPathContext context, XPathSequence inputSeq) =>
    _evalXmlToJson(
      context,
      _expectOptionalNode(inputSeq, 'fn:xml-to-json'),
      null,
    );

XPathSequence _fnXmlToJson2(
  XPathContext context,
  XPathSequence inputSeq,
  XPathSequence optionsSeq,
) => _evalXmlToJson(
  context,
  _expectOptionalNode(inputSeq, 'fn:xml-to-json'),
  _expectOptionalMap(optionsSeq, 'fn:xml-to-json'),
);

XPathSequence _evalXmlToJson(
  XPathContext context,
  XPathNode? input,
  XPathMap? options,
) {
  if (input == null) return XPathSequence.empty;
  final indent = _parseXmlToJsonOptions(options);
  final serializer = _XmlToJsonSerializer(indent: indent);
  final result = serializer.serialize(input.node);
  return XPathSequence.single(XPathString(result));
}

// ---------------------------------------------------------------------------
// Options parsing
// ---------------------------------------------------------------------------

class _JsonOptions {
  const new({
    this.liberal = false,
    this.duplicates = 'use-first',
    this.escape = false,
    this.validate = false,
    this.fallback,
  });

  final bool liberal;
  final String duplicates;
  final bool escape;
  final bool validate;
  final XPathFunctionItem? fallback;
}

_JsonOptions _parseJsonOptions(
  XPathContext context,
  XPathMap? options, {
  required bool isXmlTarget,
}) {
  if (options == null) {
    return _JsonOptions(duplicates: isXmlTarget ? 'retain' : 'use-first');
  }

  var liberal = false;
  String? duplicates;
  var escape = false;
  var validate = false;
  XPathFunctionItem? fallback;

  for (final entry in options.entries.entries) {
    final key = entry.key.stringValue;
    final valueSeq = entry.value;

    switch (key) {
      case 'liberal':
        if (valueSeq.length != 1 || valueSeq.first is! XPathBoolean) {
          throw XPathEvaluationException(
            'Option "liberal" must be a single xs:boolean [err:XPTY0004]',
          );
        }
        liberal = (valueSeq.first as XPathBoolean).value;

      case 'duplicates':
        if (valueSeq.length != 1 || valueSeq.first is! XPathString) {
          throw XPathEvaluationException(
            'Option "duplicates" must be a single xs:string [err:XPTY0004]',
          );
        }
        final dupStr = (valueSeq.first as XPathString).value;
        if (isXmlTarget) {
          if (dupStr != 'reject' &&
              dupStr != 'use-first' &&
              dupStr != 'retain') {
            throw XPathEvaluationException(
              'Invalid value for duplicates in json-to-xml: $dupStr [err:FOJS0005]',
            );
          }
        } else {
          if (dupStr != 'reject' &&
              dupStr != 'use-first' &&
              dupStr != 'use-last') {
            throw XPathEvaluationException(
              'Invalid value for duplicates in parse-json: $dupStr [err:FOJS0005]',
            );
          }
        }
        duplicates = dupStr;

      case 'escape':
        if (valueSeq.length != 1 || valueSeq.first is! XPathBoolean) {
          throw XPathEvaluationException(
            'Option "escape" must be a single xs:boolean [err:XPTY0004]',
          );
        }
        escape = (valueSeq.first as XPathBoolean).value;

      case 'validate':
        if (valueSeq.length != 1 || valueSeq.first is! XPathBoolean) {
          throw XPathEvaluationException(
            'Option "validate" must be a single xs:boolean [err:XPTY0004]',
          );
        }
        validate = (valueSeq.first as XPathBoolean).value;

      case 'fallback':
        if (valueSeq.length != 1 || valueSeq.first is! XPathFunctionItem) {
          throw XPathEvaluationException(
            'Option "fallback" must be a function item [err:XPTY0004]',
          );
        }
        final fn = valueSeq.first as XPathFunctionItem;
        if (fn.arity != 1) {
          throw XPathEvaluationException(
            'Option "fallback" must be an arity-1 function [err:XPTY0004]',
          );
        }
        fallback = fn;

      case 'spec':
        // XPath 3.1: spec option is ignored if present.
        break;

      default:
        throw XPathEvaluationException(
          'Unknown option key: $key [err:FOJS0005]',
        );
    }
  }

  if (escape && fallback != null) {
    throw XPathEvaluationException(
      'Cannot specify both escape=true and a fallback function [err:FOJS0005]',
    );
  }

  if (isXmlTarget && validate && duplicates == 'retain') {
    throw XPathEvaluationException(
      'duplicates="retain" cannot be used when validate=true [err:FOJS0005]',
    );
  }

  final effectiveDuplicates =
      duplicates ??
      (isXmlTarget ? (validate ? 'reject' : 'retain') : 'use-first');

  return _JsonOptions(
    liberal: liberal,
    duplicates: effectiveDuplicates,
    escape: escape,
    validate: validate,
    fallback: fallback,
  );
}

bool _parseXmlToJsonOptions(XPathMap? options) {
  if (options == null) return false;
  var indent = false;
  for (final entry in options.entries.entries) {
    final key = entry.key.stringValue;
    final valueSeq = entry.value;
    switch (key) {
      case 'indent':
        if (valueSeq.length != 1 || valueSeq.first is! XPathBoolean) {
          throw XPathEvaluationException(
            'Option "indent" must be a single xs:boolean [err:XPTY0004]',
          );
        }
        indent = (valueSeq.first as XPathBoolean).value;
      default:
        throw XPathEvaluationException(
          'Unknown option key in xml-to-json: $key [err:FOJS0005]',
        );
    }
  }
  return indent;
}

// ---------------------------------------------------------------------------
// Custom JSON Parser supporting XPath 3.1 options
// ---------------------------------------------------------------------------

class _JsonParser {
  _JsonParser(
    this.input,
    this.options, {
    this.context,
    required this.isXmlTarget,
  });

  final String input;
  final _JsonOptions options;
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
      throw XPathEvaluationException('Empty JSON input [err:FOJS0001]');
    }
    final result = _parseValueToXPath();
    _skipWhitespace();
    if (!_isEof) {
      throw XPathEvaluationException(
        'Unexpected character after JSON value [err:FOJS0001]',
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
      throw XPathEvaluationException('Empty JSON input [err:FOJS0001]');
    }
    _parseValueToXml(builder, isRoot: true);
    _skipWhitespace();
    if (!_isEof) {
      throw XPathEvaluationException(
        'Unexpected character after JSON value [err:FOJS0001]',
      );
    }
  }

  XPathSequence _parseValueToXPath() {
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException('Unexpected end of JSON [err:FOJS0001]');
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
        'Unexpected character in JSON: "${String.fromCharCode(ch)}" [err:FOJS0001]',
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
      throw XPathEvaluationException('Unexpected end of JSON [err:FOJS0001]');
    }
    final ch = _peek();
    final nsMap = isRoot
        ? <String?, String>{null: _ns}
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
        namespaceUri: _ns,
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
        namespaceUri: _ns,
        namespaceUris: nsMap,
        attributes: attributes,
        nest: 'true',
      );
    } else if (ch == 0x66) {
      _expectLiteral('false');
      builder.element(
        'boolean',
        namespaceUri: _ns,
        namespaceUris: nsMap,
        attributes: attributes,
        nest: 'false',
      );
    } else if (ch == 0x6E) {
      _expectLiteral('null');
      builder.element(
        'null',
        namespaceUri: _ns,
        namespaceUris: nsMap,
        attributes: attributes,
      );
    } else if (ch == 0x2D || (ch >= 0x30 && ch <= 0x39)) {
      final numStr = _parseNumber();
      builder.element(
        'number',
        namespaceUri: _ns,
        namespaceUris: nsMap,
        attributes: attributes,
        nest: numStr,
      );
    } else {
      throw XPathEvaluationException(
        'Unexpected character in JSON: "${String.fromCharCode(ch)}" [err:FOJS0001]',
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
          'Expected string key in JSON object [err:FOJS0001]',
        );
      }
      final keyParsed = _parseString();
      _skipWhitespace();
      if (_next() != 0x3A) {
        // ':'
        throw XPathEvaluationException(
          'Expected ":" after key in JSON object [err:FOJS0001]',
        );
      }

      // Check duplicate keys
      final escapedKey = keyParsed.escapedComparisonKey;
      final isDuplicate = seenEscapedKeys.contains(escapedKey);
      seenEscapedKeys.add(escapedKey);

      if (isDuplicate && options.duplicates == 'reject') {
        throw XPathEvaluationException(
          'Duplicate key: ${keyParsed.effectiveValue} [err:FOJS0003]',
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
              'Trailing comma in JSON object [err:FOJS0001]',
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
          'Expected "," or "}" in JSON object [err:FOJS0001]',
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
        ? <String?, String>{null: _ns}
        : const <String?, String>{};

    builder.element(
      'map',
      namespaceUri: _ns,
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
              'Expected string key in JSON object [err:FOJS0001]',
            );
          }
          final keyParsed = _parseString();
          _skipWhitespace();
          if (_next() != 0x3A) {
            throw XPathEvaluationException(
              'Expected ":" after key in JSON object [err:FOJS0001]',
            );
          }

          final escapedKey = keyParsed.escapedComparisonKey;
          final isDuplicate = seenEscapedKeys.contains(escapedKey);
          seenEscapedKeys.add(escapedKey);

          if (isDuplicate) {
            if (options.duplicates == 'reject') {
              throw XPathEvaluationException(
                'Duplicate key: ${keyParsed.effectiveValue} [err:FOJS0003]',
              );
            }
            if (options.validate) {
              throw XPathEvaluationException(
                'Duplicate key with validate=true: ${keyParsed.effectiveValue} [err:FOJS0003]',
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
                  'Trailing comma in JSON object [err:FOJS0001]',
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
              'Expected "," or "}" in JSON object [err:FOJS0001]',
            );
          }
        }
      },
    );
  }

  void _skipJsonValue() {
    _skipWhitespace();
    if (_isEof) {
      throw XPathEvaluationException('Unexpected end of JSON [err:FOJS0001]');
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
        if (_next() != 0x3A) throw XPathEvaluationException('Expected ":"');
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
          throw XPathEvaluationException('Expected "," or "}"');
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
          throw XPathEvaluationException('Expected "," or "]"');
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
              'Trailing comma in JSON array [err:FOJS0001]',
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
          'Expected "," or "]" in JSON array [err:FOJS0001]',
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
        ? <String?, String>{null: _ns}
        : const <String?, String>{};

    builder.element(
      'array',
      namespaceUri: _ns,
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
                  'Trailing comma in JSON array [err:FOJS0001]',
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
              'Expected "," or "]" in JSON array [err:FOJS0001]',
            );
          }
        }
      },
    );
  }

  _ParsedString _parseString() {
    _pos++; // consume opening '"'
    final sb = StringBuffer();
    final cmpSb = StringBuffer();
    bool escapedAttribute = false;

    while (!_isEof) {
      final ch = _next();
      if (ch == 0x22) {
        // closing '"'
        return _ParsedString(
          effectiveValue: sb.toString(),
          escapedComparisonKey: cmpSb.toString(),
          escaped: escapedAttribute,
        );
      }

      if (ch == 0x5C) {
        // backslash '\'
        if (_isEof) {
          throw XPathEvaluationException(
            'Unterminated escape in JSON string [err:FOJS0001]',
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
              'Invalid escape character in JSON string: \\${String.fromCharCode(esc)} [err:FOJS0001]',
            );
        }
      } else {
        // Raw character
        if (ch < 0x20) {
          throw XPathEvaluationException(
            'Unescaped control character in JSON string [err:FOJS0001]',
          );
        }
        final charStr = String.fromCharCode(ch);
        sb.write(charStr);
        cmpSb.write(charStr);
      }
    }

    throw XPathEvaluationException('Unterminated JSON string [err:FOJS0001]');
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
        'Insufficient hex digits in \\u escape [err:FOJS0001]',
      );
    }
    final hexStr = input.substring(_pos, _pos + 4);
    _pos += 4;
    final code = int.tryParse(hexStr, radix: 16);
    if (code == null) {
      throw XPathEvaluationException(
        'Invalid hex digits in \\u escape: $hexStr [err:FOJS0001]',
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
          'Fallback function must return a single xs:string [err:FOJS0005]',
        );
      }
      return first.value;
    } catch (e) {
      if (e is XPathEvaluationException) rethrow;
      throw XPathEvaluationException('Fallback function failed: $e');
    }
  }

  String _parseNumber() {
    final start = _pos;
    if (_peek() == 0x2D) {
      // '-'
      _pos++;
    }

    if (_isEof) throw XPathEvaluationException('Invalid number [err:FOJS0001]');
    final firstDigit = _peek();
    if (firstDigit < 0x30 || firstDigit > 0x39) {
      throw XPathEvaluationException('Invalid number [err:FOJS0001]');
    }

    if (firstDigit == 0x30) {
      _pos++;
      if (!_isEof) {
        final nextD = _peek();
        if (nextD >= 0x30 && nextD <= 0x39) {
          throw XPathEvaluationException(
            'Leading zero not allowed in number [err:FOJS0001]',
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
          'Decimal point must be followed by digits [err:FOJS0001]',
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
          'Exponent must be followed by digits [err:FOJS0001]',
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
        'Expected "$literal" in JSON [err:FOJS0001]',
      );
    }
    _pos += literal.length;
  }
}

class _ParsedString {
  const _ParsedString({
    required this.effectiveValue,
    required this.escapedComparisonKey,
    required this.escaped,
  });

  final String effectiveValue;
  final String escapedComparisonKey;
  final bool escaped;
}

// ---------------------------------------------------------------------------
// XML to JSON Serializer supporting XPath 3.1 schema validation and options
// ---------------------------------------------------------------------------

class _XmlToJsonSerializer {
  _XmlToJsonSerializer({this.indent = false});

  final bool indent;

  String serialize(XmlNode node) {
    final rootElement = switch (node) {
      XmlDocument() => _findRootElement(node),
      XmlElement() => node,
      _ => throw XPathEvaluationException(
        'Input to xml-to-json must be a document or element node [err:FOJS0006]',
      ),
    };
    return _serializeElement(rootElement, 0);
  }

  XmlElement _findRootElement(XmlDocument doc) {
    for (final child in doc.children) {
      if (child is XmlElement) return child;
    }
    throw XPathEvaluationException('Empty XML document [err:FOJS0006]');
  }

  String _serializeElement(XmlElement element, int indentLevel) {
    if (element.name.namespaceUri != _ns) {
      throw XPathEvaluationException(
        'Element is not in namespace $_ns: ${element.name} [err:FOJS0006]',
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
          'Invalid element in $_ns: ${element.localName} [err:FOJS0006]',
        );
    }
  }

  void _validateAttributes(XmlElement element) {
    for (final attr in element.attributes) {
      final name = attr.name;
      if (name.prefix == 'xmlns' || name.qualified == 'xmlns') continue;
      if (name.namespaceUri == 'http://www.w3.org/2001/XMLSchema-instance')
        continue;
      if (name.namespaceUri == 'http://www.w3.org/XML/1998/namespace' &&
          name.local == 'space')
        continue;
      final uri = name.namespaceUri;
      if (name.prefix == null || uri == null || uri.isEmpty || uri == _ns) {
        if (name.local == 'key' ||
            name.local == 'escaped' ||
            name.local == 'escaped-key') {
          continue;
        }
      }
      throw XPathEvaluationException(
        'Disallowed attribute on <${element.localName}>: ${attr.name} [err:FOJS0006]',
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
            'Map element contains non-whitespace text [err:FOJS0006]',
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
          'Child of map element lacks "key" attribute [err:FOJS0006]',
        );
      }

      final isEscapedKey = _parseBoolAttribute(
        child.getAttribute('escaped-key'),
      );
      final effectiveKey = isEscapedKey ? _unescapeJsonString(rawKey) : rawKey;

      if (seenKeys.contains(effectiveKey)) {
        throw XPathEvaluationException(
          'Duplicate key in map: $effectiveKey [err:FOJS0006]',
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
            'Array element contains non-whitespace text [err:FOJS0006]',
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
          'String element cannot contain child elements [err:FOJS0006]',
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
          'Number element cannot contain child elements [err:FOJS0006]',
        );
      }
    }
    final text = element.innerText.trim();
    if (text == 'NaN' || text == 'INF' || text == '-INF') {
      throw XPathEvaluationException(
        'Number cannot be NaN, INF, or -INF [err:FOJS0006]',
      );
    }
    final numVal = double.tryParse(text);
    if (numVal == null) {
      throw XPathEvaluationException(
        'Invalid number format: $text [err:FOJS0006]',
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
      var s = value.toString();
      if (s.contains('e') || s.contains('E')) {
        final sign = value < 0 ? '-' : '';
        s = '$sign${absVal.toStringAsFixed(6)}'
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      }
      return s;
    } else {
      var s = value.toStringAsExponential().toUpperCase();
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
              'Unterminated escape sequence in escaped string [err:FOJS0007]',
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
                'Incomplete \\uXXXX escape in escaped string [err:FOJS0007]',
              );
            }
            final hex = text.substring(i + 2, i + 6);
            final code = int.tryParse(hex, radix: 16);
            if (code == null) {
              throw XPathEvaluationException(
                'Invalid hex in \\uXXXX escape in escaped string [err:FOJS0007]',
              );
            }
            sb.write('\\u$hex');
            i += 6;
          } else {
            throw XPathEvaluationException(
              'Invalid escape sequence in escaped string: \\${String.fromCharCode(next)} [err:FOJS0007]',
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
          'Boolean element cannot contain child elements [err:FOJS0006]',
        );
      }
    }
    final text = element.innerText.trim();
    if (text == 'true' || text == '1') return 'true';
    if (text == 'false' || text == '0') return 'false';
    throw XPathEvaluationException(
      'Invalid boolean content: $text [err:FOJS0006]',
    );
  }

  String _serializeNull(XmlElement element) {
    for (final child in element.children) {
      if (child is XmlElement) {
        throw XPathEvaluationException(
          'Null element cannot contain child elements [err:FOJS0006]',
        );
      }
    }
    final text = element.innerText.trim();
    if (text.isNotEmpty) {
      throw XPathEvaluationException(
        'Null element cannot contain text [err:FOJS0006]',
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
      'Invalid boolean attribute value: $value [err:FOJS0006]',
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
            'Incomplete escape sequence in escaped string [err:FOJS0007]',
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
                'Incomplete \\u hex escape in escaped string [err:FOJS0007]',
              );
            }
            final hex = input.substring(i + 1, i + 5);
            final code = int.tryParse(hex, radix: 16);
            if (code == null) {
              throw XPathEvaluationException(
                'Invalid \\u hex escape: $hex [err:FOJS0007]',
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
                'Unpaired high surrogate in escaped string: $hex [err:FOJS0007]',
              );
            }
            if (code >= 0xDC00 && code <= 0xDFFF) {
              throw XPathEvaluationException(
                'Unpaired low surrogate in escaped string: $hex [err:FOJS0007]',
              );
            }
            sb.write(String.fromCharCode(code));
          default:
            throw XPathEvaluationException(
              'Invalid escape sequence in escaped string: \\${String.fromCharCode(next)} [err:FOJS0007]',
            );
        }
      } else {
        sb.writeCharCode(ch);
      }
    }
    return sb.toString();
  }

  String _escapeJsonString(String input) {
    final sb = StringBuffer();
    sb.write('"');
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
          } else {
            sb.writeCharCode(code);
          }
      }
    }
    sb.write('"');
    return sb.toString();
  }
}

const _ns = 'http://www.w3.org/2005/xpath-functions';
