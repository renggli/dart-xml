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
XPathSequence fnNodeName(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node
      : XPathEvaluationException.checkZeroOrOne(node);
  if (nodeOpt is XmlHasName) {
    return XPathSequence.single(nodeOpt.name);
  } else if (nodeOpt is XmlProcessing) {
    return XPathSequence.single(XmlName.fromString(nodeOpt.target));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
XPathSequence fnNilled(XPathContext context, [XPathSequence? node]) {
  final nodeOpt = node == null
      ? context.node
      : XPathEvaluationException.checkZeroOrOne(node);
  // PetitXml doesn't have a built-in concept of nilled, returning false
  // for elements.
  if (nodeOpt is XmlElement) return XPathSequence.falseSequence;
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
XPathSequence fnString(XPathContext context, [XPathSequence? arg]) {
  final argOpt = arg == null
      ? context.node
      : XPathEvaluationException.checkZeroOrOne(arg);
  if (argOpt != null) return XPathSequence.single(argOpt.toXPathString());
  return XPathSequence.single(XPathString.empty);
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
XPathSequence fnData(XPathContext context, [XPathSequence? arg]) {
  final argIter = arg ?? XPathSequence.single(context.node);
  return XPathSequence(
    argIter.expand((item) => item is Iterable<Object> ? item : [item]),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
XPathSequence fnBaseUri(XPathContext context, [XPathSequence? arg]) {
  final argOpt = arg == null
      ? context.node
      : XPathEvaluationException.checkZeroOrOne(arg);
  if (argOpt is XmlNode) {
    // 1. Look for xml:base on the node or its ancestors
    for (XmlNode? current = argOpt; current != null; current = current.parent) {
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
XPathSequence fnDocumentUri(XPathContext context, [XPathSequence? arg]) {
  final argOpt = arg == null
      ? context.node
      : XPathEvaluationException.checkZeroOrOne(arg);
  if (argOpt is XmlDocument) {
    // PetitXml does not track the source URI of a document.
    // If it did, we would return it here.
    // For now, return empty sequence as per spec for "no document URI"
  }
  return XPathSequence.empty;
}
