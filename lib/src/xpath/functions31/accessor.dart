import '../../xml/mixins/has_name.dart';
import '../../xml/nodes/element.dart';
import '../../xml/nodes/node.dart';
import '../../xml/nodes/processing.dart';
import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../types31/sequence.dart';
import '../types31/string.dart' as values31_string;
import 'utils.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-node-name
XPathSequence fnNodeName(XPathContext context, [XPathSequence? node]) {
  final sequence = node ?? contextNode(context);
  if (sequence.isEmpty) return XPathSequence.empty;
  final item = sequence.first;
  if (item is XmlHasName) {
    return XPathSequence.single(item.name);
  } else if (item is XmlProcessing) {
    return XPathSequence.single(XmlName.fromString(item.target));
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-nilled
XPathSequence fnNilled(XPathContext context, [XPathSequence? node]) {
  final sequence = node ?? contextNode(context);
  if (sequence.isEmpty) return XPathSequence.empty;
  // PetitXml doesn't have a built-in concept of nilled, returning false for elements.
  final item = sequence.first;
  if (item is XmlElement) {
    return XPathSequence.falseSequence;
  }
  return XPathSequence.empty;
}

/// https://www.w3.org/TR/xpath-functions-31/#func-string
XPathSequence fnString(XPathContext context, [XPathSequence? node]) {
  final sequence = node ?? contextNode(context);
  if (sequence.isEmpty) {
    return XPathSequence.single(values31_string.XPathString.empty);
  }
  return XPathSequence.single(sequence.first.toXPathString());
}

/// https://www.w3.org/TR/xpath-functions-31/#func-data
XPathSequence fnData(XPathContext context, [XPathSequence? node]) {
  final sequence = node ?? contextNode(context);
  return XPathSequence(
    sequence.map((item) {
      if (item is XmlNode) {
        return item.toXPathString();
      }
      return item;
    }),
  );
}

/// https://www.w3.org/TR/xpath-functions-31/#func-base-uri
XPathSequence fnBaseUri(XPathContext context, [XPathSequence? node]) =>
    XPathSequence.empty;

/// https://www.w3.org/TR/xpath-functions-31/#func-document-uri
XPathSequence fnDocumentUri(XPathContext context, [XPathSequence? node]) =>
    XPathSequence.empty;
