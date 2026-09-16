import 'dart:convert' as convert;

import '../../xml/builder/builder.dart';
import '../../xml/extensions/string.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/numeric.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/array.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
const fnParseJson = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:parse-json'),
  {
    1: XPathFunctionItem.fn1(XmlName.qualified('fn:parse-json'), _fnParseJson1),
    2: XPathFunctionItem.fn2(XmlName.qualified('fn:parse-json'), _fnParseJson2),
  },
);

XPathSequence _fnParseJson1(XPathContext context, XPathSequence jsonTextSeq) =>
    _evalParseJson(jsonTextSeq.firstOrNull as XPathString?, null);

XPathSequence _fnParseJson2(
  XPathContext context,
  XPathSequence jsonTextSeq,
  XPathSequence optionsSeq,
) => _evalParseJson(
  jsonTextSeq.firstOrNull as XPathString?,
  optionsSeq.firstOrNull as XPathMap?,
);

XPathSequence _evalParseJson(XPathString? jsonText, XPathMap? options) {
  if (jsonText == null) return XPathSequence.empty;
  try {
    final result = convert.json.decode(jsonText.value);
    return _jsonToXPath(result);
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid JSON: ${error.message}');
  }
}

XPathSequence _jsonToXPath(Object? json) => switch (json) {
  null => XPathSequence.empty,
  bool() => XPathSequence.single(XPathBoolean.fromBool(json)),
  num() => XPathSequence.single(XPathDouble(json.toDouble())),
  String() => XPathSequence.single(XPathString(json)),
  List() => XPathSequence.single(XPathArray(json.map(_jsonToXPath).toList())),
  Map() => XPathSequence.single(
    XPathMap(
      json.map(
        (key, value) =>
            MapEntry(XPathString(key.toString()), _jsonToXPath(value)),
      ),
    ),
  ),
  _ => throw StateError('Unknown JSON type: $json'),
};

/// https://www.w3.org/TR/xpath-functions-31/#func-json-doc
const fnJsonDoc = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:json-doc'),
  {
    1: XPathFunctionItem.fn1(XmlName.qualified('fn:json-doc'), _fnJsonDoc1),
    2: XPathFunctionItem.fn2(XmlName.qualified('fn:json-doc'), _fnJsonDoc2),
  },
);

XPathSequence _fnJsonDoc1(XPathContext context, XPathSequence hrefSeq) =>
    _evalJsonDoc(context, hrefSeq.firstOrNull as XPathString?, null);

XPathSequence _fnJsonDoc2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence optionsSeq,
) => _evalJsonDoc(
  context,
  hrefSeq.firstOrNull as XPathString?,
  optionsSeq.firstOrNull as XPathMap?,
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

  try {
    final result = convert.json.decode(loaded);
    return _jsonToXPath(result);
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid JSON: ${error.message}');
  }
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
    _evalJsonToXml(jsonTextSeq.firstOrNull as XPathString?, null);

XPathSequence _fnJsonToXml2(
  XPathContext context,
  XPathSequence jsonTextSeq,
  XPathSequence optionsSeq,
) => _evalJsonToXml(
  jsonTextSeq.firstOrNull as XPathString?,
  optionsSeq.firstOrNull as XPathMap?,
);

XPathSequence _evalJsonToXml(XPathString? jsonText, XPathMap? options) {
  if (jsonText == null) return XPathSequence.empty;
  try {
    final json = convert.json.decode(jsonText.value);
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0"');
    _jsonToXml(builder, json, namespaceUris: {null: _ns});
    return XPathSequence.single(XPathNode(builder.buildDocument()));
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
  switch (json) {
    case null:
      builder.element(
        'null',
        attributes: attributes,
        namespaceUris: namespaceUris,
      );
    case bool():
      builder.element(
        'boolean',
        attributes: attributes,
        namespaceUris: namespaceUris,
        nest: () {
          builder.text(json.toString());
        },
      );
    case num():
      builder.element(
        'number',
        attributes: attributes,
        namespaceUris: namespaceUris,
        nest: () {
          builder.text(json.toString());
        },
      );
    case String():
      builder.element(
        'string',
        attributes: attributes,
        namespaceUris: namespaceUris,
        nest: () {
          builder.text(json);
        },
      );
    case List():
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
    case Map():
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
    case _:
      throw StateError('Unknown JSON type: $json');
  }
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
    _evalXmlToJson(inputSeq.firstOrNull as XPathNode?, null);

XPathSequence _fnXmlToJson2(
  XPathContext context,
  XPathSequence inputSeq,
  XPathSequence optionsSeq,
) => _evalXmlToJson(
  inputSeq.firstOrNull as XPathNode?,
  optionsSeq.firstOrNull as XPathMap?,
);

XPathSequence _evalXmlToJson(XPathNode? input, XPathMap? options) {
  if (input == null) return XPathSequence.empty;
  final json = _xmlToJson(input.node);
  return XPathSequence.single(XPathString(convert.json.encode(json)));
}

Object? _xmlToJson(XmlNode node) => switch (node) {
  XmlElement() when node.name.namespaceUri == _ns => switch (node.localName) {
    'map' => _xmlMapToJson(node),
    'array' => _xmlArrayToJson(node),
    'string' => node.innerText,
    'number' => num.parse(node.innerText),
    'boolean' => node.innerText == 'true',
    'null' => null,
    _ => null,
  },
  XmlDocument() => _xmlDocumentToJson(node),
  _ => null,
};

Map<String, Object?> _xmlMapToJson(XmlElement node) {
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
}

List<Object?> _xmlArrayToJson(XmlElement node) {
  final result = <Object?>[];
  for (final child in node.children) {
    if (child is XmlElement && child.name.namespaceUri == _ns) {
      result.add(_xmlToJson(child));
    }
  }
  return result;
}

Object? _xmlDocumentToJson(XmlDocument node) {
  final child = node.rootElement;
  final result = _xmlToJson(child);
  if (result != null ||
      (child.name.namespaceUri == _ns && child.localName == 'null')) {
    return result;
  }
  return null;
}

const _ns = 'http://www.w3.org/2005/xpath-functions';
