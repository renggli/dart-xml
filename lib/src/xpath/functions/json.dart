import '../../xml/builder/builder.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/error_code.dart';
import '../exceptions/evaluation_exception.dart';
import '../xdm/atomic/boolean.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/functions/map.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';
import 'json_options.dart';
import 'json_parser.dart';
import 'json_serializer.dart';
import 'uri.dart';

export 'json_options.dart';
export 'json_parser.dart';
export 'json_serializer.dart';

XPathString? _expectOptionalString(XPathSequence seq, String funcName) {
  if (seq.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      '$funcName argument must contain at most one item',
    );
  }
  final item = seq.firstOrNull;
  if (item == null) return null;
  if (item is XPathString) return item;
  final atomized = XPathSequence.single(item).atomize();
  if (atomized.length == 1) {
    final first = atomized.first;
    if (first is XPathString) return first;
    if (first is XPathUntypedAtomic) return XPathString(first.value);
  }
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    '$funcName argument must be xs:string?',
  );
}

XPathMap? _expectOptionalMap(XPathSequence seq, String funcName) {
  if (seq.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      '$funcName options argument must contain at most one item',
    );
  }
  final item = seq.firstOrNull;
  if (item == null) return null;
  if (item is XPathMap) return item;
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    '$funcName options argument must be map(*)?',
  );
}

XPathNode? _expectOptionalNode(XPathSequence seq, String funcName) {
  if (seq.length > 1) {
    throw XPathEvaluationException(
      XPathErrorCode.XPTY0004,
      '$funcName argument must contain at most one node',
    );
  }
  final item = seq.firstOrNull;
  if (item == null) return null;
  if (item is XPathNode) return item;
  throw XPathEvaluationException(
    XPathErrorCode.XPTY0004,
    '$funcName argument must be node()?',
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
  final parser = JsonParser(
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

  final textSeq = fnUnparsedText.call(context, [XPathSequence.single(href)]);
  if (textSeq.isEmpty) return XPathSequence.empty;
  final loaded = (textSeq.first as XPathString).value;

  final opts = _parseJsonOptions(context, options, isXmlTarget: false);
  final parser = JsonParser(loaded, opts, context: context, isXmlTarget: false);
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
  final parser = JsonParser(
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
  final serializer = XmlToJsonSerializer(indent: indent);
  final result = serializer.serialize(input.node);
  return XPathSequence.single(XPathString(result));
}

// ---------------------------------------------------------------------------

JsonOptions _parseJsonOptions(
  XPathContext context,
  XPathMap? options, {
  required bool isXmlTarget,
}) {
  if (options == null) {
    return JsonOptions(duplicates: isXmlTarget ? 'retain' : 'use-first');
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
            XPathErrorCode.XPTY0004,
            'Option "liberal" must be a single xs:boolean',
          );
        }
        liberal = (valueSeq.first as XPathBoolean).value;

      case 'duplicates':
        if (valueSeq.length != 1 || valueSeq.first is! XPathString) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Option "duplicates" must be a single xs:string',
          );
        }
        final dupStr = (valueSeq.first as XPathString).value;
        if (isXmlTarget) {
          if (dupStr != 'reject' &&
              dupStr != 'use-first' &&
              dupStr != 'retain') {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0005,
              'Invalid value for duplicates in json-to-xml: $dupStr',
            );
          }
        } else {
          if (dupStr != 'reject' &&
              dupStr != 'use-first' &&
              dupStr != 'use-last') {
            throw XPathEvaluationException(
              XPathErrorCode.FOJS0005,
              'Invalid value for duplicates in parse-json: $dupStr',
            );
          }
        }
        duplicates = dupStr;

      case 'escape':
        if (valueSeq.length != 1 || valueSeq.first is! XPathBoolean) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Option "escape" must be a single xs:boolean',
          );
        }
        escape = (valueSeq.first as XPathBoolean).value;

      case 'validate':
        if (valueSeq.length != 1 || valueSeq.first is! XPathBoolean) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Option "validate" must be a single xs:boolean',
          );
        }
        validate = (valueSeq.first as XPathBoolean).value;

      case 'fallback':
        if (valueSeq.length != 1 || valueSeq.first is! XPathFunctionItem) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Option "fallback" must be a function item',
          );
        }
        final fn = valueSeq.first as XPathFunctionItem;
        if (fn.arity != 1) {
          throw XPathEvaluationException(
            XPathErrorCode.XPTY0004,
            'Option "fallback" must be an arity-1 function',
          );
        }
        fallback = fn;

      case 'spec':
        // XPath 3.1: spec option is ignored if present.
        break;

      default:
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0005,
          'Unknown option key: $key',
        );
    }
  }

  if (escape && fallback != null) {
    throw XPathEvaluationException(
      XPathErrorCode.FOJS0005,
      'Cannot specify both escape=true and a fallback function',
    );
  }

  if (isXmlTarget && validate && duplicates == 'retain') {
    throw XPathEvaluationException(
      XPathErrorCode.FOJS0005,
      'duplicates="retain" cannot be used when validate=true',
    );
  }

  final effectiveDuplicates =
      duplicates ??
      (isXmlTarget ? (validate ? 'reject' : 'retain') : 'use-first');

  return JsonOptions(
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
            XPathErrorCode.XPTY0004,
            'Option "indent" must be a single xs:boolean',
          );
        }
        indent = (valueSeq.first as XPathBoolean).value;
      default:
        throw XPathEvaluationException(
          XPathErrorCode.FOJS0005,
          'Unknown option key in xml-to-json: $key',
        );
    }
  }
  return indent;
}
