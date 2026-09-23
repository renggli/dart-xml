import 'dart:core';

import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-resolve-uri
const fnResolveUri = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:resolve-uri'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:resolve-uri'),
      _fnResolveUri1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:resolve-uri'),
      _fnResolveUri2,
    ),
  },
);

XPathSequence _fnResolveUri1(XPathContext context, XPathSequence relativeSeq) =>
    _evalResolveUri(context, relativeSeq.firstOrNull as XPathString?, null);

XPathSequence _fnResolveUri2(
  XPathContext context,
  XPathSequence relativeSeq,
  XPathSequence baseSeq,
) => _evalResolveUri(
  context,
  relativeSeq.firstOrNull as XPathString?,
  baseSeq.firstOrNull as XPathString?,
);

XPathSequence _evalResolveUri(
  XPathContext context,
  XPathString? relative,
  XPathString? base,
) {
  if (relative == null) return XPathSequence.empty;
  try {
    final uri = Uri.parse(relative.value);
    if (uri.isAbsolute) {
      return XPathSequence.single(XPathAnyUri(relative.value));
    }
    final String resolvedBase;
    if (base == null) {
      final staticBase = context.configuration.baseUri;
      if (staticBase == null) {
        throw XPathEvaluationException('Static base URI is undefined');
      }
      resolvedBase = staticBase;
    } else {
      resolvedBase = base.value;
    }
    return XPathSequence.single(
      XPathAnyUri(Uri.parse(resolvedBase).resolve(relative.value).toString()),
    );
  } on FormatException catch (error) {
    throw XPathEvaluationException('Invalid URI: ${error.message}');
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
const fnDoc = XPathFunctionItem.fn1(XmlName.qualified('fn:doc'), _fnDoc);

XPathSequence _fnDoc(XPathContext context, XPathSequence uriSeq) {
  final uri = uriSeq.firstOrNull as XPathString?;
  if (uri == null) return XPathSequence.empty;
  final document = context.configuration.documents[uri.value];
  if (document != null) return XPathSequence.single(XPathNode(document));
  throw XPathEvaluationException('Document not found: ${uri.value}');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
const fnDocAvailable = XPathFunctionItem.fn1(
  XmlName.qualified('fn:doc-available'),
  _fnDocAvailable,
);

XPathSequence _fnDocAvailable(XPathContext context, XPathSequence uriSeq) {
  final uri = uriSeq.firstOrNull as XPathString?;
  if (uri == null) return XPathSequence.falseSequence;
  final available = context.configuration.documents.containsKey(uri.value);
  return available ? XPathSequence.trueSequence : XPathSequence.falseSequence;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-collection
const fnCollection = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:collection'),
  {
    0: XPathFunctionItem.fn0(
      XmlName.qualified('fn:collection'),
      _fnCollection0,
    ),
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:collection'),
      _fnCollection1,
    ),
  },
);

XPathSequence _fnCollection0(XPathContext context) {
  final nodes = context.configuration.collections[''];
  if (nodes != null) {
    return XPathSequence(nodes.map(XPathNode.new));
  }
  throw XPathEvaluationException(
    'No default collection available [err:FODC0002]',
  );
}

XPathSequence _fnCollection1(XPathContext context, XPathSequence uriSeq) {
  final uriItem = uriSeq.firstOrNull;
  if (uriItem == null) return _fnCollection0(context);
  final uriStr = uriItem is XPathString ? uriItem.value : uriItem.stringValue;
  if (uriStr.isEmpty) return _fnCollection0(context);

  final base = context.configuration.baseUri;
  var resolved = uriStr;
  if (base != null) {
    try {
      resolved = Uri.parse(base).resolve(uriStr).toString();
    } catch (_) {}
  }
  final nodes =
      context.configuration.collections[resolved] ??
      context.configuration.collections[uriStr];
  if (nodes != null) {
    return XPathSequence(nodes.map(XPathNode.new));
  }
  throw XPathEvaluationException(
    'Collection not found: $uriStr [err:FODC0002]',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-uri-collection
const fnUriCollection = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:uri-collection'),
  {
    0: XPathFunctionItem.fn0(
      XmlName.qualified('fn:uri-collection'),
      _fnUriCollection0,
    ),
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:uri-collection'),
      _fnUriCollection1,
    ),
  },
);

XPathSequence _fnUriCollection0(XPathContext context) {
  final nodes = context.configuration.collections[''];
  if (nodes != null) {
    final uris = <XPathItem>[];
    for (final node in nodes) {
      for (final entry in context.configuration.documents.entries) {
        if (identical(entry.value, node)) {
          if (entry.key.contains('://') || entry.key.startsWith('/')) {
            uris.add(XPathAnyUri(entry.key));
            break;
          }
        }
      }
    }
    return XPathSequence(uris);
  }
  throw XPathEvaluationException(
    'No default collection available [err:FODC0002]',
  );
}

XPathSequence _fnUriCollection1(XPathContext context, XPathSequence uriSeq) {
  final uriItem = uriSeq.firstOrNull;
  if (uriItem == null) return _fnUriCollection0(context);
  final uriStr = uriItem is XPathString ? uriItem.value : uriItem.stringValue;
  if (uriStr.isEmpty) return _fnUriCollection0(context);

  final base = context.configuration.baseUri;
  var resolved = uriStr;
  if (base != null) {
    try {
      resolved = Uri.parse(base).resolve(uriStr).toString();
    } catch (_) {}
  }
  final nodes =
      context.configuration.collections[resolved] ??
      context.configuration.collections[uriStr];
  if (nodes != null) {
    final uris = <XPathItem>[];
    for (final node in nodes) {
      for (final entry in context.configuration.documents.entries) {
        if (identical(entry.value, node)) {
          if (entry.key.contains('://') || entry.key.startsWith('/')) {
            uris.add(XPathAnyUri(entry.key));
            break;
          }
        }
      }
    }
    return XPathSequence(uris);
  }
  throw XPathEvaluationException(
    'Collection not found: $uriStr [err:FODC0002]',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text
const fnUnparsedText = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:unparsed-text'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:unparsed-text'),
      _fnUnparsedText1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:unparsed-text'),
      _fnUnparsedText2,
    ),
  },
);

XPathSequence _fnUnparsedText1(XPathContext context, XPathSequence hrefSeq) =>
    _evalUnparsedText(context, hrefSeq.firstOrNull as XPathString?, null);

XPathSequence _fnUnparsedText2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence encodingSeq,
) => _evalUnparsedText(
  context,
  hrefSeq.firstOrNull as XPathString?,
  encodingSeq.firstOrNull as XPathString?,
);

XPathSequence _evalUnparsedText(
  XPathContext context,
  XPathString? href,
  XPathString? encoding,
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
  } on FormatException catch (e) {
    throw XPathEvaluationException('Invalid URI: ${href.value} (${e.message})');
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
    _validateEncodingName(encoding.value);
  }

  final loader = context.configuration.unparsedTextLoader;
  if (loader == null) {
    throw XPathEvaluationException(
      'No unparsed text loader available to load $resolved',
    );
  }

  final String? loaded;
  try {
    loaded = loader(resolved, encoding?.value);
  } catch (e) {
    if (e is XPathEvaluationException) rethrow;
    throw XPathEvaluationException('Failed to load resource $resolved: $e');
  }

  if (loaded == null) {
    throw XPathEvaluationException('Resource not found: $resolved');
  }

  // Validate XML characters in text.
  _validateXmlCharacters(loaded);

  return XPathSequence.single(XPathString(loaded));
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
const fnUnparsedTextLines = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:unparsed-text-lines'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:unparsed-text-lines'),
      _fnUnparsedTextLines1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:unparsed-text-lines'),
      _fnUnparsedTextLines2,
    ),
  },
);

XPathSequence _fnUnparsedTextLines1(
  XPathContext context,
  XPathSequence hrefSeq,
) => _evalUnparsedTextLines(context, hrefSeq.firstOrNull as XPathString?, null);

XPathSequence _fnUnparsedTextLines2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence encodingSeq,
) => _evalUnparsedTextLines(
  context,
  hrefSeq.firstOrNull as XPathString?,
  encodingSeq.firstOrNull as XPathString?,
);

XPathSequence _evalUnparsedTextLines(
  XPathContext context,
  XPathString? href,
  XPathString? encoding,
) {
  if (href == null) return XPathSequence.empty;
  final textSequence = _evalUnparsedText(context, href, encoding);
  if (textSequence.isEmpty) return XPathSequence.empty;
  final text = (textSequence.first as XPathString).value;
  if (text.isEmpty) return XPathSequence.empty;

  final lines = text.split(RegExp(r'\r\n|\r|\n'));
  if (lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }
  return XPathSequence(lines.map(XPathString.new));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-unparsed-text-available
const fnUnparsedTextAvailable = XPathFunctionItem.overloaded(
  XmlName.qualified('fn:unparsed-text-available'),
  {
    1: XPathFunctionItem.fn1(
      XmlName.qualified('fn:unparsed-text-available'),
      _fnUnparsedTextAvailable1,
    ),
    2: XPathFunctionItem.fn2(
      XmlName.qualified('fn:unparsed-text-available'),
      _fnUnparsedTextAvailable2,
    ),
  },
);

XPathSequence _fnUnparsedTextAvailable1(
  XPathContext context,
  XPathSequence hrefSeq,
) => _evalUnparsedTextAvailable(
  context,
  hrefSeq.firstOrNull as XPathString?,
  null,
);

XPathSequence _fnUnparsedTextAvailable2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence encodingSeq,
) => _evalUnparsedTextAvailable(
  context,
  hrefSeq.firstOrNull as XPathString?,
  encodingSeq.firstOrNull as XPathString?,
);

XPathSequence _evalUnparsedTextAvailable(
  XPathContext context,
  XPathString? href,
  XPathString? encoding,
) {
  if (href == null) return XPathSequence.falseSequence;
  try {
    _evalUnparsedText(context, href, encoding);
    return XPathSequence.trueSequence;
  } catch (_) {
    return XPathSequence.falseSequence;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-environment-variable
const fnEnvironmentVariable = XPathFunctionItem.fn1(
  XmlName.qualified('fn:environment-variable'),
  _fnEnvironmentVariable,
);

XPathSequence _fnEnvironmentVariable(
  XPathContext context,
  XPathSequence nameSeq,
) {
  final name = nameSeq.first as XPathString;
  final value = context.configuration.environment[name.value];
  if (value != null) return XPathSequence.single(XPathString(value));
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-available-environment-variables
const fnAvailableEnvironmentVariables = XPathFunctionItem.fn0(
  XmlName.qualified('fn:available-environment-variables'),
  _fnAvailableEnvironmentVariables,
);

XPathSequence _fnAvailableEnvironmentVariables(XPathContext context) =>
    XPathSequence(context.configuration.environment.keys.map(XPathString.new));

/// https://www.w3.org/TR/xpath-functions-31/#func-encode-for-uri
const fnEncodeForUri = XPathFunctionItem.fn1(
  XmlName.qualified('fn:encode-for-uri'),
  _fnEncodeForUri,
);

XPathSequence _fnEncodeForUri(XPathContext context, XPathSequence uriPartSeq) {
  final uriPart = uriPartSeq.firstOrNull as XPathString?;
  if (uriPart == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(Uri.encodeComponent(uriPart.value)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
const fnIriToUri = XPathFunctionItem.fn1(
  XmlName.qualified('fn:iri-to-uri'),
  _fnIriToUri,
);

XPathSequence _fnIriToUri(XPathContext context, XPathSequence iriSeq) {
  final iri = iriSeq.firstOrNull as XPathString?;
  if (iri == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(Uri.encodeFull(iri.value)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
const fnEscapeHtmlUri = XPathFunctionItem.fn1(
  XmlName.qualified('fn:escape-html-uri'),
  _fnEscapeHtmlUri,
);

XPathSequence _fnEscapeHtmlUri(XPathContext context, XPathSequence uriSeq) {
  final uri = uriSeq.firstOrNull as XPathString?;
  if (uri == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(Uri.encodeFull(uri.value)));
}
