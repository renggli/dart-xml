import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/document.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types31/sequence.dart';
import '../types31/string.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-node-name
XPathSequence fnNodeName(XPathContext context, List<XPathSequence> arguments) {
  final node = _nodeOrContext('fn:node-name', context, arguments);
  if (node is XmlHasName) {
    return XPathSequence.single(node.name);
  } else if (node is XmlProcessing) {
    return XPathSequence.single(XmlName.fromString(node.target));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
XPathSequence fnNilled(XPathContext context, List<XPathSequence> arguments) {
  final node = _nodeOrContext('fn:nilled', context, arguments);
  // PetitXml doesn't have a built-in concept of nilled, returning false
  // for elements.
  if (node is XmlElement) return XPathSequence.falseSequence;
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
XPathSequence fnString(XPathContext context, List<XPathSequence> arguments) {
  final arg = _nodeOrContext('fn:string', context, arguments);
  if (arg != null) return XPathSequence.single(arg.toXPathString());
  return const XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
XPathSequence fnData(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:data', arguments, 0, 1);
  final arg = arguments.isNotEmpty
      ? arguments[0]
      : (XPathSequence.single(context.node));
  return XPathSequence(arg.expand(_atomize));
}

Iterable<Object> _atomize(Object item) {
  if (item is XmlNode) {
    return [item.toXPathString()];
  } else if (item is Iterable<Object>) {
    return item.expand(_atomize);
  } else {
    return [item];
  }
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
XPathSequence fnBaseUri(XPathContext context, List<XPathSequence> arguments) {
  final node = _nodeOrContext('fn:base-uri', context, arguments);
  if (node is XmlNode) {
    // 1. Look for xml:base on the node or its ancestors
    for (XmlNode? current = node; current != null; current = current.parent) {
      if (current is XmlElement) {
        final xmlBase = current.getAttribute('xml:base');
        if (xmlBase != null) {
          try {
            return XPathSequence.single(
              XPathString(Uri.parse(xmlBase).toString()),
            );
          } catch (_) {
            // If invalid URI, ignore
          }
        }
      }
    }
    // 2. Fallback to static base URI if available (not tracked in PetitXml currently)
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-document-uri
XPathSequence fnDocumentUri(
  XPathContext context,
  List<XPathSequence> arguments,
) {
  final node = _nodeOrContext('fn:document-uri', context, arguments);
  if (node is XmlDocument) {
    // PetitXml does not track the source URI of a document.
    // If it did, we would return it here.
    // For now, return empty sequence as per spec for "no document URI"
  }
  return XPathSequence.empty;
}

Object? _nodeOrContext(
  String name,
  XPathContext context,
  List<XPathSequence> arguments,
) {
  XPathEvaluationException.checkArgumentCount(name, arguments, 0, 1);
  return arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(name, 'node', arguments[0])
      : context.node;
}
