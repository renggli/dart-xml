library xml.test.assertions;

import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

const Matcher isXmlParserException = TypeMatcher<XmlParserException>();
const Matcher isXmlNodeTypeException = TypeMatcher<XmlNodeTypeException>();
const Matcher isXmlParentException = TypeMatcher<XmlParentException>();
const Matcher isXmlTagException = TypeMatcher<XmlTagException>();

void assertParseInvariants(String input) {
  final tree = parse(input);
  assertTreeInvariants(tree);
  assertEventInvariants(input, tree);
  final copy = parse(tree.toXmlString());
  expect(tree.toXmlString(), copy.toXmlString());
}

void assertParseError(String input, String message) {
  try {
    final result = parse(input);
    fail('Expected parse error $message, but got $result.');
  } on XmlParserException catch (error) {
    expect(error.toString(), message);
  }
}

void assertTreeInvariants(XmlNode xml) {
  assertDocumentInvariants(xml);
  assertParentInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertTextInvariants(xml);
  assertIteratorInvariants(xml);
  assertCopyInvariants(xml);
  assertPrintingInvariants(xml);
}

void assertDocumentInvariants(XmlNode xml) {
  final root = xml.root;
  for (final child in xml.descendants) {
    expect(root, same(child.root));
    expect(root, same(child.document));
  }
  expect(xml.document.children, contains(xml.document.rootElement));
  if (xml.document.doctypeElement != null) {
    expect(xml.document.children, contains(xml.document.doctypeElement));
  }
  expect(root.depth, 0);
}

void assertParentInvariants(XmlNode xml) {
  for (final node in xml.descendants) {
    final isRootNode = node is XmlDocument || node is XmlDocumentFragment;
    expect(node.parent, isRootNode ? isNull : isNotNull);
    for (final child in node.children) {
      expect(child.parent, same(node));
      expect(child.depth, node.depth + 1);
    }
    for (final attribute in node.attributes) {
      expect(attribute.parent, same(node));
      expect(attribute.depth, node.depth + 1);
    }
  }
}

void assertForwardInvariants(XmlNode xml) {
  for (final node in xml.descendants) {
    var current = node.firstChild;
    for (var i = 0; i < node.children.length; i++) {
      expect(node.children[i], same(current));
      current = current.nextSibling;
    }
    expect(current, isNull);
  }
}

void assertBackwardInvariants(XmlNode xml) {
  for (final node in xml.descendants) {
    var current = node.lastChild;
    for (var i = node.children.length - 1; i >= 0; i--) {
      expect(node.children[i], same(current));
      current = current.previousSibling;
    }
    expect(current, isNull);
  }
}

void assertNameInvariants(XmlNode xml) {
  xml.descendants.whereType<XmlNamed>().forEach(assertNamedInvariant);
}

void assertNamedInvariant(XmlNamed named) {
  expect(named, same(named.name.parent));
  expect(named.name.local, isNot(isEmpty));
  expect(named.name.qualified, endsWith(named.name.local));
  if (named.name.prefix != null) {
    expect(named.name.qualified, startsWith(named.name.prefix));
  }
  expect(named.name.namespaceUri,
      anyOf(isNull, (node) => node is String && node.isNotEmpty));
  expect(named.name.qualified.hashCode, named.name.hashCode);
  expect(named.name.qualified, named.name.toString());
}

void assertAttributeInvariants(XmlNode xml) {
  for (final node in xml.descendants) {
    if (node is XmlElement) {
      for (final attribute in node.attributes) {
        expect(
            attribute, same(node.getAttributeNode(attribute.name.qualified)));
        expect(
            attribute.value, same(node.getAttribute(attribute.name.qualified)));
      }
      if (node.attributes.isEmpty) {
        expect(node.getAttribute('foo'), isNull);
        expect(node.getAttributeNode('foo'), isNull);
      }
    }
  }
}

void assertTextInvariants(XmlNode xml) {
  for (final node in xml.descendants) {
    if (node is XmlDocument || node is XmlDocumentFragment) {
      expect(node.text, isNull,
          reason: 'Document nodes are supposed to return null text.');
    } else {
      expect(node.text, (text) => text is String,
          reason: 'All nodes are supposed to return text strings.');
    }
    if (node is XmlText) {
      expect(node.text, isNotEmpty,
          reason: 'Text nodes are not suppoed to be empty.');
    }
    if (node is XmlParent) {
      XmlNodeType previousType;
      final nodeTypes = node.children.map((node) => node.nodeType);
      for (final currentType in nodeTypes) {
        expect(
            previousType == XmlNodeType.TEXT && currentType == XmlNodeType.TEXT,
            isFalse,
            reason: 'Consecutive text nodes detected: $nodeTypes');
        previousType = currentType;
      }
    }
  }
}

void assertIteratorInvariants(XmlNode xml) {
  final ancestors = <XmlNode>[];
  void check(XmlNode node) {
    final allAxis = [
      node.preceding,
      [node],
      node.descendants,
      node.following
    ].expand((each) => each);
    final allRoot = [
      [node.root],
      node.root.descendants
    ].expand((each) => each);
    expect(allAxis, allRoot,
        reason: 'All preceding nodes, the node, all decendant nodes, and all '
            'following nodes should be equal to all nodes in the tree.');
    expect(node.ancestors, ancestors.reversed);
    ancestors.add(node);
    node.attributes.forEach(check);
    node.children.forEach(check);
    ancestors.removeLast();
  }

  check(xml);
}

void assertCopyInvariants(XmlNode xml) {
  final copy = xml.copy();
  assertParentInvariants(xml);
  assertParentInvariants(copy);
  assertNameInvariants(xml);
  assertNameInvariants(copy);
  assertCompareInvariants(xml, copy);
}

void assertCompareInvariants(XmlNode original, XmlNode copy) {
  expect(original, isNot(same(copy)),
      reason: 'The copied node should not be identical.');
  expect(original.nodeType, copy.nodeType,
      reason: 'The copied node type should be the same.');
  if (original is XmlNamed && copy is XmlNamed) {
    final originalNamed = original as XmlNamed; // ignore: avoid_as
    final copyNamed = copy as XmlNamed; // ignore: avoid_as
    expect(originalNamed.name, copyNamed.name,
        reason: 'The copied name should be equal.');
    expect(originalNamed.name, isNot(same(copyNamed.name)),
        reason: 'The copied name should not be identical.');
  }
  expect(original.attributes.length, copy.attributes.length,
      reason: 'The amount of copied attributes should be the same.');
  for (var i = 0; i < original.attributes.length; i++) {
    assertCompareInvariants(original.attributes[i], copy.attributes[i]);
  }
  expect(original.children.length, copy.children.length,
      reason: 'The amount of copied children should be the same.');
  for (var i = 0; i < original.children.length; i++) {
    assertCompareInvariants(original.children[i], copy.children[i]);
  }
  if (original is XmlElement && copy is XmlElement) {
    expect(original.isSelfClosing, copy.isSelfClosing,
        reason: 'The copied self-closing attribute should be equal.');
  }
}

void compareNode(XmlNode first, XmlNode second) {
  expect(first.nodeType, second.nodeType);
  final firstChildren =
      first.children.where((node) => node is! XmlText).toList();
  final secondChildren =
      second.children.where((node) => node is! XmlText).toList();
  expect(firstChildren.length, secondChildren.length);
  for (var i = 0; i < firstChildren.length; i++) {
    compareNode(firstChildren[i], secondChildren[i]);
  }
  final firstText = first.children
      .whereType<XmlText>()
      .map((node) => node.text.trim())
      .join();
  final secondText = second.children
      .whereType<XmlText>()
      .map((node) => node.text.trim())
      .join();
  expect(firstText, secondText);
  expect(first.attributes.length, second.attributes.length);
  for (var i = 0; i < first.attributes.length; i++) {
    compareNode(first.attributes[i], second.attributes[i]);
  }
  if (first is! XmlParent) {
    expect(first.toXmlString(), second.toXmlString());
  }
}

void assertPrintingInvariants(XmlNode xml) {
  compareNode(xml, parse(xml.toXmlString(pretty: true)));
}

void assertEventInvariants(String input, XmlNode node) {
  const includedTypes = {
    XmlNodeType.CDATA,
    XmlNodeType.COMMENT,
    XmlNodeType.DOCUMENT_TYPE,
    XmlNodeType.ELEMENT,
    XmlNodeType.PROCESSING,
    XmlNodeType.TEXT,
  };
  final iterator = parseEvents(input).iterator;
  final nodes = node.descendants
      .where((node) => includedTypes.contains(node.nodeType))
      .toList(growable: true);
  final stack = <XmlStartElementEvent>[];
  while (iterator.moveNext()) {
    final current = iterator.current;
    if (current is XmlStartElementEvent) {
      final XmlElement expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.name, expected.name.qualified);
      expect(current.localName, expected.name.local);
      expect(current.namespacePrefix, expected.name.prefix);
      expect(current.attributes.length, expected.attributes.length);
      for (var i = 0; i < current.attributes.length; i++) {
        final currentAttr = current.attributes[i];
        final expectedAttr = expected.attributes[i];
        expect(currentAttr.name, expectedAttr.name.qualified);
        expect(currentAttr.localName, expectedAttr.name.local);
        expect(currentAttr.namespacePrefix, expectedAttr.name.prefix);
        expect(currentAttr.value, expectedAttr.value);
        expect(currentAttr.attributeType, expectedAttr.attributeType);
      }
      expect(current.isSelfClosing,
          expected.children.isEmpty && expected.isSelfClosing);
      if (!current.isSelfClosing) {
        stack.add(current);
      }
    } else if (current is XmlEndElementEvent) {
      final expected = stack.removeLast();
      expect(current.nodeType, expected.nodeType);
      expect(current.name, expected.name);
      expect(current.localName, expected.localName);
      expect(current.namespacePrefix, expected.namespacePrefix);
    } else if (current is XmlCDATAEvent) {
      final XmlCDATA expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.text, expected.text);
    } else if (current is XmlCommentEvent) {
      final XmlComment expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.text, expected.text);
    } else if (current is XmlDoctypeEvent) {
      final XmlDoctype expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.text, expected.text);
    } else if (current is XmlProcessingEvent) {
      final XmlProcessing expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.target, expected.target);
      expect(current.text, expected.text);
    } else if (current is XmlTextEvent) {
      final XmlText expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.text, expected.text);
    } else {
      fail('Unexpected event type: $current');
    }
  }
  expect(nodes, isEmpty, reason: '$nodes were not closed.');
  expect(iterator.current, isNull);
  expect(iterator.moveNext(), isFalse);

  final prettyInput = node.toXmlString(pretty: false);
  final decodedEvents = const XmlEventCodec().decode(prettyInput);
  final decodedNodes = const XmlNodeCodec().decode(decodedEvents);
  final encodedNodes = const XmlNodeCodec().encode(decodedNodes);
  final encodeString = const XmlEventCodec().encode(encodedNodes);
  expect(encodeString, prettyInput);
}
