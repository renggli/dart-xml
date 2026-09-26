import 'dart:core';

import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
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

String? _coerceString(XPathSequence seq) {
  final item = seq.atomize().firstOrNull;
  if (item == null) return null;
  if (item is XPathString ||
      item is XPathUntypedAtomic ||
      item is XPathAnyUri) {
    return item.stringValue;
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    'Expected xs:string or xs:anyURI, got ${item.type}',
  );
}

XPathSequence _fnResolveUri1(XPathContext context, XPathSequence relativeSeq) =>
    _evalResolveUri(context, _coerceString(relativeSeq), null);

XPathSequence _fnResolveUri2(
  XPathContext context,
  XPathSequence relativeSeq,
  XPathSequence baseSeq,
) => _evalResolveUri(
  context,
  _coerceString(relativeSeq),
  _coerceString(baseSeq),
);

XPathSequence _evalResolveUri(
  XPathContext context,
  String? relative,
  String? base,
) {
  if (relative == null) return XPathSequence.empty;
  try {
    final uri = Uri.parse(relative);
    if (uri.isAbsolute) {
      return XPathSequence.single(XPathAnyUri(relative));
    }
    final String resolvedBase;
    if (base == null) {
      final staticBase = context.configuration.baseUri;
      if (staticBase == null) {
        throw XPathEvaluationException(
          XPathErrorCode.XPST0001,
          'Static base URI is undefined',
        );
      }
      resolvedBase = staticBase;
    } else {
      resolvedBase = base;
    }
    return XPathSequence.single(
      XPathAnyUri(Uri.parse(resolvedBase).resolve(relative).toString()),
    );
  } on FormatException catch (error) {
    throw XPathEvaluationException(
      XPathErrorCode.FORG0002,
      'Invalid URI: ${error.message}',
    );
  }
}

bool _isValidUriPercentEncoding(String str) {
  for (var i = 0; i < str.length; i++) {
    if (str.codeUnitAt(i) == 0x25) {
      if (i + 2 >= str.length) return false;
      final c1 = str.codeUnitAt(i + 1);
      final c2 = str.codeUnitAt(i + 2);
      if (!_isHexDigit(c1) || !_isHexDigit(c2)) return false;
      i += 2;
    }
  }
  return true;
}

bool _isHexDigit(int c) =>
    (c >= 0x30 && c <= 0x39) ||
    (c >= 0x41 && c <= 0x46) ||
    (c >= 0x61 && c <= 0x66);

bool _isValidUriReference(String s) {
  if (s.contains('\\') ||
      s.contains('>') ||
      s.contains('<') ||
      s.contains(' ') ||
      s.startsWith(':/')) {
    return false;
  }
  if (!_isValidUriPercentEncoding(s)) {
    return false;
  }
  try {
    Uri.parse(s);
    return true;
  } on FormatException {
    return false;
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc
const fnDoc = XPathFunctionItem.fn1(XmlName.qualified('fn:doc'), _fnDoc);

XPathSequence _fnDoc(XPathContext context, XPathSequence uriSeq) {
  final uri = _coerceString(uriSeq);
  if (uri == null) return XPathSequence.empty;
  if (!_isValidUriReference(uri)) {
    throw XPathEvaluationException(
      XPathErrorCode.FODC0005,
      'Invalid URI: $uri',
    );
  }
  final document = context.configuration.documents[uri];
  if (document != null) return XPathSequence.single(XPathNode(document));
  throw XPathEvaluationException(
    XPathErrorCode.FODC0002,
    'Document not found: $uri',
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-doc-available
const fnDocAvailable = XPathFunctionItem.fn1(
  XmlName.qualified('fn:doc-available'),
  _fnDocAvailable,
);

XPathSequence _fnDocAvailable(XPathContext context, XPathSequence uriSeq) {
  final uri = _coerceString(uriSeq);
  if (uri == null) return XPathSequence.falseSequence;
  final available = context.configuration.documents.containsKey(uri);
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
    XPathErrorCode.FODC0002,
    'No default collection available',
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
    XPathErrorCode.FODC0002,
    'Collection not found: $uriStr',
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
    XPathErrorCode.FODC0002,
    'No default collection available',
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
    XPathErrorCode.FODC0002,
    'Collection not found: $uriStr',
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
    _evalUnparsedText(context, _coerceString(hrefSeq), null);

XPathSequence _fnUnparsedText2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence encodingSeq,
) => _evalUnparsedText(
  context,
  _coerceString(hrefSeq),
  _coerceString(encodingSeq),
);

XPathSequence _evalUnparsedText(
  XPathContext context,
  String? href,
  String? encoding,
) {
  if (href == null) return XPathSequence.empty;
  if (!_isValidUriReference(href) || href.contains('#')) {
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1170,
      'Invalid URI: $href',
    );
  }

  // Resolve relative URI.
  String resolved;
  try {
    final uri = Uri.parse(href);
    if (uri.isAbsolute) {
      resolved = href;
    } else {
      final base = context.configuration.baseUri;
      if (base == null) {
        throw XPathEvaluationException(
          XPathErrorCode.FOUT1170,
          'Static base URI is undefined',
        );
      }
      resolved = Uri.parse(base).resolve(href).toString();
    }
  } on FormatException catch (e) {
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1170,
      'Invalid URI: $href (${e.message})',
    );
  }

  // Check scheme.
  final parsedResolved = Uri.parse(resolved);
  if (parsedResolved.hasScheme &&
      !['file', 'http', 'https', 'data'].contains(parsedResolved.scheme)) {
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1170,
      'Unsupported URI scheme: ${parsedResolved.scheme}',
    );
  }

  // Validate encoding name.
  if (encoding != null) {
    _validateEncodingName(encoding);
  }

  final loader = context.configuration.unparsedTextLoader;
  if (loader == null) {
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1200,
      'No unparsed text loader available to load $resolved',
    );
  }

  final String? loaded;
  try {
    loaded = loader(resolved, encoding);
  } catch (e) {
    if (e is XPathEvaluationException) rethrow;
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1200,
      'Failed to load resource $resolved: $e',
    );
  }

  if (loaded == null) {
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1200,
      'Resource not found: $resolved',
    );
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
    throw XPathEvaluationException(
      XPathErrorCode.FOUT1190,
      'Unsupported encoding: $encoding',
    );
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
      XPathErrorCode.FOUT1190,
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
) => _evalUnparsedTextLines(context, _coerceString(hrefSeq), null);

XPathSequence _fnUnparsedTextLines2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence encodingSeq,
) => _evalUnparsedTextLines(
  context,
  _coerceString(hrefSeq),
  _coerceString(encodingSeq),
);

XPathSequence _evalUnparsedTextLines(
  XPathContext context,
  String? href,
  String? encoding,
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
) => _evalUnparsedTextAvailable(context, _coerceString(hrefSeq), null);

XPathSequence _fnUnparsedTextAvailable2(
  XPathContext context,
  XPathSequence hrefSeq,
  XPathSequence encodingSeq,
) => _evalUnparsedTextAvailable(
  context,
  _coerceString(hrefSeq),
  _coerceString(encodingSeq),
);

XPathSequence _evalUnparsedTextAvailable(
  XPathContext context,
  String? href,
  String? encoding,
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
  final name = _coerceString(nameSeq);
  if (name == null) return XPathSequence.empty;
  final value = context.configuration.environment[name];
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
  final uriPart = _coerceString(uriPartSeq);
  if (uriPart == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(Uri.encodeComponent(uriPart)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-iri-to-uri
const fnIriToUri = XPathFunctionItem.fn1(
  XmlName.qualified('fn:iri-to-uri'),
  _fnIriToUri,
);

XPathSequence _fnIriToUri(XPathContext context, XPathSequence iriSeq) {
  final iri = _coerceString(iriSeq);
  if (iri == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(Uri.encodeFull(iri)));
}

/// https://www.w3.org/TR/xpath-functions-31/#func-escape-html-uri
const fnEscapeHtmlUri = XPathFunctionItem.fn1(
  XmlName.qualified('fn:escape-html-uri'),
  _fnEscapeHtmlUri,
);

XPathSequence _fnEscapeHtmlUri(XPathContext context, XPathSequence uriSeq) {
  final uri = _coerceString(uriSeq);
  if (uri == null) return const XPathSequence.single(XPathString.empty);
  return XPathSequence.single(XPathString(Uri.encodeFull(uri)));
}
