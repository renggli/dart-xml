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
  XPathEvaluationException.checkArgumentCount('fn:node-name', arguments, 0, 1);
  final node = arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:node-name',
          'node',
          arguments[0],
        )
      : context.node;
  if (node is XmlHasName) {
    return XPathSequence.single(node.name);
  } else if (node is XmlProcessing) {
    return XPathSequence.single(XmlName.fromString(node.target));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
XPathSequence fnNilled(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:nilled', arguments, 0, 1);
  final node = arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:nilled',
          'node',
          arguments[0],
        )
      : context.node;
  // PetitXml doesn't have a built-in concept of nilled, returning false
  // for elements.
  if (node is XmlElement) return XPathSequence.falseSequence;
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
XPathSequence fnString(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:string', arguments, 0, 1);
  final arg = arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:string',
          'arg',
          arguments[0],
        )
      : context.node;
  if (arg != null) return XPathSequence.single(arg.toXPathString());
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
XPathSequence fnData(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:data', arguments, 0, 1);
  final arg = arguments.isNotEmpty
      ? arguments[0]
      : (XPathSequence.single(context.node));
  return XPathSequence(
    arg.expand((item) => item is Iterable<Object> ? item : [item]),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
XPathSequence fnBaseUri(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:base-uri', arguments, 0, 1);
  final node = arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:base-uri',
          'node',
          arguments[0],
        )
      : context.node;
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
  XPathEvaluationException.checkArgumentCount(
    'fn:document-uri',
    arguments,
    0,
    1,
  );
  final node = arguments.isNotEmpty
      ? XPathEvaluationException.extractZeroOrOne(
          'fn:document-uri',
          'node',
          arguments[0],
        )
      : context.node;
  if (node is XmlDocument) {
    // PetitXml does not track the source URI of a document.
    // If it did, we would return it here.
    // For now, return empty sequence as per spec for "no document URI"
  }
  return XPathSequence.empty;
}
