import 'dart:core';
import '../../xml/utils/name.dart';
import '../definitions/cardinality.dart';
import '../definitions/function.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/string.dart';
import '../values/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
const fnResolveUri = XPathFunctionDefinition(
  name: XmlName.qualified('fn:resolve-uri'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'relative',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [XPathArgumentDefinition(name: 'base', type: xsString)],
  function: _fnResolveUri,
);

XPathSequence _fnResolveUri(
  XPathContext context,
  String? relative, [
  String? base,
]) {
  if (relative == null) return XPathSequence.empty;
  try {
    final uri = Uri.parse(relative);
    if (uri.isAbsolute) return XPathSequence.single(relative);
    final String resolvedBase;
    if (base == null) {
      final staticBase = context.configuration.baseUri;
      if (staticBase == null) {
        throw XPathEvaluationException('Static base URI is undefined');
      }
      resolvedBase = staticBase;
    } else {
      resolvedBase = base;
    }
    return XPathSequence.single(
      Uri.parse(resolvedBase).resolve(relative).toString(),
    );
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid URI: ${error.message}');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
const fnDoc = XPathFunctionDefinition(
  name: XmlName.qualified('fn:doc'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDoc,
);

XPathSequence _fnDoc(XPathContext context, String? uri) {
  if (uri == null) return XPathSequence.empty;
  final document = context.configuration.documents[uri];
  if (document != null) return XPathSequence.single(document);
  throw XPathEvaluationException('Document not found: $uri');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
const fnDocAvailable = XPathFunctionDefinition(
  name: XmlName.qualified('fn:doc-available'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnDocAvailable,
);

XPathSequence _fnDocAvailable(XPathContext context, String? uri) {
  if (uri == null) return const XPathSequence.single(false);
  return XPathSequence.single(context.configuration.documents.containsKey(uri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
const fnCollection = XPathFunctionDefinition(
  name: XmlName.qualified('fn:collection'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnCollection,
);

XPathSequence _fnCollection(XPathContext context, [String? uri]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
const fnUriCollection = XPathFunctionDefinition(
  name: XmlName.qualified('fn:uri-collection'),
  optionalArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnUriCollection,
);

XPathSequence _fnUriCollection(XPathContext context, [String? uri]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
const fnUnparsedText = XPathFunctionDefinition(
  name: XmlName.qualified('fn:unparsed-text'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'encoding', type: xsString),
  ],
  function: _fnUnparsedText,
);

XPathSequence _fnUnparsedText(
  XPathContext context,
  String? href, [
  String? encoding,
]) {
  if (href == null) return XPathSequence.empty;

  // Resolve relative URI.
  String resolved;
  try {
    final uri = Uri.parse(href);
    if (uri.isAbsolute) {
      resolved = href;
    } else {
      final base = context.configuration.baseUri;
      if (base == null) {
        throw XPathEvaluationException('Static base URI is undefined');
      }
      resolved = Uri.parse(base).resolve(href).toString();
    }
  } on FormatException catch (e) {
    throw XPathEvaluationException('Invalid URI: $href (${e.message})');
  }

  // Check fragment identifier.
  final parsedResolved = Uri.parse(resolved);
  if (parsedResolved.hasFragment) {
    throw XPathEvaluationException(
      'URI contains a fragment identifier: $resolved',
    );
  }

  // Validate encoding name.
  if (encoding != null) {
    _validateEncodingName(encoding);
  }

  final loader = context.configuration.unparsedTextLoader;
  if (loader == null) {
    throw XPathEvaluationException(
      'No unparsed text loader available to load $resolved',
    );
  }

  final String? loaded;
  try {
    loaded = loader(resolved, encoding);
  } catch (e) {
    if (e is XPathEvaluationException) rethrow;
    throw XPathEvaluationException('Failed to load resource $resolved: $e');
  }

  if (loaded == null) {
    throw XPathEvaluationException('Resource not found: $resolved');
  }

  // Validate XML characters in text.
  _validateXmlCharacters(loaded);

  return XPathSequence.single(loaded);
}

void _validateEncodingName(String encoding) {
  final normalized = encoding.toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]'),
    '',
  );
  const supported = {
    'utf8',
    'utf16',
    'utf16le',
    'utf16be',
    'iso88591',
    'latin1',
    'usascii',
    'ascii',
  };
  if (!supported.contains(normalized)) {
    throw XPathEvaluationException('Unsupported encoding: $encoding');
  }
}

void _validateXmlCharacters(String text) {
  for (final char in text.runes) {
    if (char == 0x9 ||
        char == 0xA ||
        char == 0xD ||
        (char >= 0x20 && char <= 0xD7FF) ||
        (char >= 0xE000 && char <= 0xFFFD) ||
        (char >= 0x10000 && char <= 0x10FFFF)) {
      continue;
    }
    throw XPathEvaluationException(
      'Invalid XML character: U+${char.toRadixString(16).toUpperCase()}',
    );
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-lines
const fnUnparsedTextLines = XPathFunctionDefinition(
  name: XmlName.qualified('fn:unparsed-text-lines'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'encoding', type: xsString),
  ],
  function: _fnUnparsedTextLines,
);

XPathSequence _fnUnparsedTextLines(
  XPathContext context,
  String? href, [
  String? encoding,
]) {
  if (href == null) return XPathSequence.empty;
  final textSequence = _fnUnparsedText(context, href, encoding);
  if (textSequence.isEmpty) return XPathSequence.empty;
  final text = textSequence.single as String;
  if (text.isEmpty) return XPathSequence.empty;

  final lines = text.split(RegExp(r'\r\n|\r|\n'));
  if (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return XPathSequence(lines);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
const fnUnparsedTextAvailable = XPathFunctionDefinition(
  name: XmlName.qualified('fn:unparsed-text-available'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'href',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  optionalArguments: [
    XPathArgumentDefinition(name: 'encoding', type: xsString),
  ],
  function: _fnUnparsedTextAvailable,
);

XPathSequence _fnUnparsedTextAvailable(
  XPathContext context,
  String? href, [
  String? encoding,
]) {
  if (href == null) return const XPathSequence.single(false);
  try {
    _fnUnparsedText(context, href, encoding);
    return const XPathSequence.single(true);
  } catch (_) {
    return const XPathSequence.single(false);
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
const fnEnvironmentVariable = XPathFunctionDefinition(
  name: XmlName.qualified('fn:environment-variable'),
  requiredArguments: [XPathArgumentDefinition(name: 'name', type: xsString)],
  function: _fnEnvironmentVariable,
);

XPathSequence _fnEnvironmentVariable(XPathContext context, String name) {
  final value = context.configuration.environment[name];
  if (value != null) return XPathSequence.single(value);
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
const fnAvailableEnvironmentVariables = XPathFunctionDefinition(
  name: XmlName.qualified('fn:available-environment-variables'),
  function: _fnAvailableEnvironmentVariables,
);

XPathSequence _fnAvailableEnvironmentVariables(XPathContext context) =>
    XPathSequence(context.configuration.environment.keys.toList());

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
const fnEncodeForUri = XPathFunctionDefinition(
  name: XmlName.qualified('fn:encode-for-uri'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri-part',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnEncodeForUri,
);

XPathSequence _fnEncodeForUri(XPathContext context, String? uriPart) {
  if (uriPart == null) return XPathSequence.emptyString;
  return XPathSequence.single(Uri.encodeComponent(uriPart));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
const fnIriToUri = XPathFunctionDefinition(
  name: XmlName.qualified('fn:iri-to-uri'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'iri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnIriToUri,
);

XPathSequence _fnIriToUri(XPathContext context, String? iri) {
  if (iri == null) return XPathSequence.emptyString;
  return XPathSequence.single(Uri.encodeFull(iri));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
const fnEscapeHtmlUri = XPathFunctionDefinition(
  name: XmlName.qualified('fn:escape-html-uri'),
  requiredArguments: [
    XPathArgumentDefinition(
      name: 'uri',
      type: xsString,
      cardinality: XPathCardinality.zeroOrOne,
    ),
  ],
  function: _fnEscapeHtmlUri,
);

XPathSequence _fnEscapeHtmlUri(XPathContext context, String? uri) {
  if (uri == null) return XPathSequence.emptyString;
  // TODO: Proper HTML URI escaping
  return XPathSequence.single(Uri.encodeFull(uri));
}
