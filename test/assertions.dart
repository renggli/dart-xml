library xml.test.assertions;

import 'package:test/test.dart';
import 'package:xml/xml.dart';

const Matcher isXmlParserException = TypeMatcher<XmlParserException>();
const Matcher isXmlNodeTypeException = TypeMatcher<XmlNodeTypeException>();
const Matcher isXmlParentException = TypeMatcher<XmlParentException>();

void assertParseInvariants(String input) {
  final tree = parse(input);
  assertTreeInvariants(tree);
  assertParseIteratorInvariants(input, tree);
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
  for (var child in xml.descendants) {
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
  for (var node in xml.descendants) {
    final isRootNode = node is XmlDocument || node is XmlDocumentFragment;
    expect(node.parent, isRootNode ? isNull : isNotNull);
    for (var child in node.children) {
      expect(child.parent, same(node));
      expect(child.depth, node.depth + 1);
    }
    for (var attribute in node.attributes) {
      expect(attribute.parent, same(node));
      expect(attribute.depth, node.depth + 1);
    }
  }
}

void assertForwardInvariants(XmlNode xml) {
  for (var node in xml.descendants) {
    var current = node.firstChild;
    for (var i = 0; i < node.children.length; i++) {
      expect(node.children[i], same(current));
      current = current.nextSibling;
    }
    expect(current, isNull);
  }
}

void assertBackwardInvariants(XmlNode xml) {
  for (var node in xml.descendants) {
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
  for (var node in xml.descendants) {
    if (node is XmlElement) {
      for (var attribute in node.attributes) {
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
  for (var node in xml.descendants) {
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
      for (var currentType in nodeTypes) {
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

void assertPrintingInvariants(XmlNode xml) {
  void compare(XmlNode source, XmlNode pretty) {
    expect(source.nodeType, pretty.nodeType);
    final sourceChildren =
        source.children.where((node) => node is! XmlText).toList();
    final prettyChildren =
        pretty.children.where((node) => node is! XmlText).toList();
    expect(sourceChildren.length, prettyChildren.length);
    for (var i = 0; i < sourceChildren.length; i++) {
      compare(sourceChildren[i], prettyChildren[i]);
    }
    final sourceText = source.children
        .whereType<XmlText>()
        .map((node) => node.text.trim())
        .join();
    final prettyText = pretty.children
        .whereType<XmlText>()
        .map((node) => node.text.trim())
        .join();
    expect(sourceText, prettyText);
    expect(source.attributes.length, pretty.attributes.length);
    for (var i = 0; i < source.attributes.length; i++) {
      compare(source.attributes[i], pretty.attributes[i]);
    }
    if (source is! XmlParent) {
      expect(source.toXmlString(), pretty.toXmlString());
    }
  }

  compare(xml, parse(xml.toXmlString(pretty: true)));
}

void assertParseIteratorInvariants(String input, XmlNode node) {
  final includedTypes = Set.from([
    XmlNodeType.CDATA,
    XmlNodeType.COMMENT,
    XmlNodeType.DOCUMENT_TYPE,
    XmlNodeType.ELEMENT,
    XmlNodeType.PROCESSING,
    XmlNodeType.TEXT,
  ]);
  final iterator = parseIterator(input);
  final nodes = node.descendants
      .where((node) => includedTypes.contains(node.nodeType))
      .toList(growable: true);
  final stack = <XmlStartElement>[];
  while (iterator.moveNext()) {
    final current = iterator.current;
    if (current is XmlStartElement) {
      final XmlElement expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.name.qualified, expected.name.qualified);
      expect(current.attributes.length, expected.attributes.length);
      expect(current.isSelfClosing, expected.isSelfClosing);
      for (var i = 0; i < expected.attributes.length; i++) {
        assertCompareInvariants(expected.attributes[i], current.attributes[i]);
      }
      expect(current.depth, stack.length);
      if (!current.isSelfClosing) {
        stack.add(current);
      }
    } else if (current is XmlEndElement) {
      final expected = stack.removeLast();
      expect(current.nodeType, expected.nodeType);
      expect(current.name.qualified, expected.name.qualified);
      expect(current.depth, stack.length);
    } else if (current is XmlData) {
      final expected = nodes.removeAt(0);
      expect(current.nodeType, expected.nodeType);
      expect(current.text, expected.text);
      expect(current.depth, stack.length);
      if (current is XmlProcessing) {
        final XmlProcessing expectedProcessing = expected;
        expect(current.target, expectedProcessing.target);
      }
    } else {
      fail('Unexpected node type: $current');
    }
  }
  expect(nodes, isEmpty, reason: '$nodes were not closed.');
}
