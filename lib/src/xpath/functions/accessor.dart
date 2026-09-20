import '../../xml/nodes/attribute.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/document_fragment.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/utils/name.dart';
import '../xdm/atomic/qname.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/item.dart';
import '../xdm/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-node-name
final fnNodeName = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:node-name'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:node-name'),
      (context) => _evalNodeName(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:node-name'),
      (context, arg) => _evalNodeName(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalNodeName(XPathNode? nodeItem) {
  if (nodeItem == null) return XPathSequence.empty;
  final node = nodeItem.node;
  if (node is XmlElement) return XPathSequence.single(XPathQName(node.name));
  if (node is XmlAttribute) return XPathSequence.single(XPathQName(node.name));
  if (node is XmlProcessing) {
    return XPathSequence.single(XPathQName(XmlName.qualified(node.target)));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
final fnNilled = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:nilled'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:nilled'),
      (context) => _evalNilled(context.item as XPathNode?),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:nilled'),
      (context, arg) => _evalNilled(arg.firstOrNull as XPathNode?),
    ),
  },
);

XPathSequence _evalNilled(XPathNode? nodeItem) {
  if (nodeItem == null) return XPathSequence.empty;
  final node = nodeItem.node;
  if (node is XmlElement) {
    // TODO: Implement proper nilled check based on xsi:nil attribute
    return XPathSequence.falseSequence;
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
final fnString = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:string'),
  {
    0: XPathFunctionItem.fn0(const XmlName.qualified('fn:string'), (context) {
      final item = context.item;
      return XPathSequence.single(XPathString((item as XPathItem).stringValue));
    }),
    1: XPathFunctionItem.fn1(const XmlName.qualified('fn:string'), (
      context,
      arg,
    ) {
      final item = arg.firstOrNull;
      if (item == null) return const XPathSequence.single(XPathString.empty);
      return XPathSequence.single(XPathString(item.stringValue));
    }),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-data
final fnData = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:data'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:data'),
      (context) => XPathSequence([(context.item as XPathItem).atomize()]),
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:data'),
      (context, arg) => XPathSequence(arg.atomize()),
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
// TODO: Add support for xml:base and tracking source URI
final fnBaseUri = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:base-uri'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:base-uri'),
      (context) => XPathSequence.empty,
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:base-uri'),
      (context, arg) => XPathSequence.empty,
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-document-uri
// TODO: Add support for tracking source document URI
final fnDocumentUri = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:document-uri'),
  {
    0: XPathFunctionItem.fn0(
      const XmlName.qualified('fn:document-uri'),
      (context) => XPathSequence.empty,
    ),
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:document-uri'),
      (context, arg) => XPathSequence.empty,
    ),
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml
final fnParseXml = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:parse-xml'),
  (context, arg) {
    final str = arg.firstOrNull;
    if (str == null) return XPathSequence.empty;
    return XPathSequence.single(XPathNode(XmlDocument.parse(str.stringValue)));
  },
);

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-xml-fragment
final fnParseXmlFragment = XPathFunctionItem.fn1(
  const XmlName.qualified('fn:parse-xml-fragment'),
  (context, arg) {
    final str = arg.firstOrNull;
    if (str == null) return XPathSequence.empty;
    return XPathSequence.single(
      XPathNode(XmlDocumentFragment.parse(str.stringValue)),
    );
  },
);
