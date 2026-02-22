import 'dart:convert' as convert;

import '../../xml/builder/builder.dart';
import '../../xml/extensions/string.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/map.dart';
import '../types/node.dart';
import '../types/sequence.dart';
import '../types/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
const fnParseJson = XPathFunctionDefinition(
  name: XmlName.qualified('fn:parse-json'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnParseJson,
);

XPathSequence _fnParseJson(
  XPathContext context, [
  String? jsonText,
  Map<Object, Object>? options,
]) {
  if (jsonText == null) return XPathSequence.empty;
  try {
    final result = convert.json.decode(jsonText);
    return _jsonToXPath(result);
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid JSON: ${error.message}');
  }
}

XPathSequence _jsonToXPath(Object? json) {
  if (json == null) {
    return XPathSequence.empty;
  } else if (json is bool) {
    return json ? XPathSequence.trueSequence : XPathSequence.falseSequence;
  } else if (json is num) {
    return XPathSequence.single(json.toDouble());
  } else if (json is String) {
    return XPathSequence.single(json);
  } else if (json is List) {
    return XPathSequence.single(
      json.map((element) => _jsonToXPath(element).toAtomicValue()).toList(),
    );
  } else if (json is Map) {
    return XPathSequence.single(
      json.map(
        (key, value) => MapEntry(key, _jsonToXPath(value).toAtomicValue()),
      ),
    );
  } else {
    throw StateError('Unknown JSON type: $json');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-doc
const fnJsonDoc = XPathFunctionDefinition(
  name: XmlName.qualified('fn:json-doc'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnJsonDoc,
);

XPathSequence _fnJsonDoc(
  XPathContext context,
  String? href, [
  Map<Object, Object>? options,
]) {
  if (href == null) return XPathSequence.empty;
  // TODO: Implement fetching from URI
  throw UnimplementedError('fn:json-doc');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml
const fnJsonToXml = XPathFunctionDefinition(
  name: XmlName.qualified('fn:json-to-xml'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'json-text',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnJsonToXml,
);

XPathSequence _fnJsonToXml(
  XPathContext context,
  String? jsonText, [
  Map<Object, Object>? options,
]) {
  if (jsonText == null) return XPathSequence.empty;
  try {
    final json = convert.json.decode(jsonText);
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    _jsonToXml(builder, json, namespaceUris: {null: _ns});
    return XPathSequence.single(builder.buildDocument());
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid JSON: ${error.message}');
  }
}

void _jsonToXml(
  XmlBuilder builder,
  Object? json, {
  Map<String, String> attributes = const {},
  Map<String?, String> namespaceUris = const {},
}) {
  if (json == null) {
    builder.element(
      'null',
      attributes: attributes,
      namespaceUris: namespaceUris,
    );
  } else if (json is bool) {
    builder.element(
      'boolean',
      attributes: attributes,
      namespaceUris: namespaceUris,
      nest: () {
        builder.text(json.toString());
      },
    );
  } else if (json is num) {
    builder.element(
      'number',
      attributes: attributes,
      namespaceUris: namespaceUris,
      nest: () {
        builder.text(json.toString());
      },
    );
  } else if (json is String) {
    builder.element(
      'string',
      attributes: attributes,
      namespaceUris: namespaceUris,
      nest: () {
        builder.text(json);
      },
    );
  } else if (json is List) {
    builder.element(
      'array',
      attributes: attributes,
      namespaceUris: namespaceUris,
      nest: () {
        for (final item in json) {
          _jsonToXml(builder, item);
        }
      },
    );
  } else if (json is Map) {
    builder.element(
      'map',
      attributes: attributes,
      namespaceUris: namespaceUris,
      nest: () {
        for (final MapEntry(key: String key, value: Object? value)
            in json.entries) {
          _jsonToXml(builder, value, attributes: {'key': key});
        }
      },
    );
  } else {
    throw StateError('Unknown JSON type: $json');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-xml-to-json
const fnXmlToJson = XPathFunctionDefinition(
  name: XmlName.qualified('fn:xml-to-json'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'input',
      type: xsNode,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'options', type: xsMap)],
  function: _fnXmlToJson,
);

XPathSequence _fnXmlToJson(
  XPathContext context,
  XmlNode? input, [
  Map<Object, Object>? options,
]) {
  if (input == null) return XPathSequence.empty;
  final json = _xmlToJson(input);
  return XPathSequence.single(convert.json.encode(json));
}

Object? _xmlToJson(XmlNode node) {
  if (node is XmlElement) {
    if (node.name.namespaceUri != _ns) {
      return null;
    }
    if (node.localName == 'map') {
      final result = <String, Object?>{};
      for (final child in node.children) {
        if (child is XmlElement && child.name.namespaceUri == _ns) {
          final key = child.getAttribute('key');
          if (key != null) {
            result[key] = _xmlToJson(child);
          }
        }
      }
      return result;
    } else if (node.localName == 'array') {
      final result = <Object?>[];
      for (final child in node.children) {
        if (child is XmlElement && child.name.namespaceUri == _ns) {
          result.add(_xmlToJson(child));
        }
      }
      return result;
    } else if (node.localName == 'string') {
      return node.innerText;
    } else if (node.localName == 'number') {
      return num.parse(node.innerText);
    } else if (node.localName == 'boolean') {
      return node.innerText == 'true';
    } else if (node.localName == 'null') {
      return null;
    }
  } else if (node is XmlDocument) {
    final child = node.rootElement;
    final result = _xmlToJson(child);
    if (result != null ||
        (child.name.namespaceUri == _ns && child.localName == 'null')) {
      return result;
    }
  }
  return null;
}

const _ns = 'http://www.w3.org/2005/xpath-functions';
