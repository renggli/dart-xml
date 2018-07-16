library xml.test.assertions;

import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml/utils/errors.dart';

const Matcher isXmlNodeTypeError = const TypeMatcher<XmlNodeTypeError>();

const Matcher isXmlParentError = const TypeMatcher<XmlParentError>();

void assetParseInvariants(String input) {
  var tree = parse(input);
  assertTreeInvariants(tree);
  assertReaderInvariants(input, tree);
  var copy = parse(tree.toXmlString());
  expect(tree.toXmlString(), copy.toXmlString());
}

void assertParseError(String input, String message) {
  try {
    var result = parse(input);
    fail('Expected parse error $message, but got $result');
  } on ArgumentError catch (error) {
    expect(error.message, message);
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
  var root = xml.root;
  for (var child in xml.descendants) {
    expect(root, same(child.root));
    expect(root, same(child.document));
  }
  var document = xml.document;
  expect(document.children, contains(document.rootElement));
  if (document.doctypeElement != null) {
    expect(document.children, contains(document.doctypeElement));
  }
}

void assertParentInvariants(XmlNode xml) {
  for (var node in xml.descendants) {
    var isRootNode = node is XmlDocument || node is XmlDocumentFragment;
    expect(node.parent, isRootNode ? isNull : isNotNull);
    for (var child in node.children) {
      expect(child.parent, same(node));
    }
    for (var attribute in node.attributes) {
      expect(attribute.parent, same(node));
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
  for (var node in xml.descendants) {
    if (node is XmlNamed) {
      assertNamedInvariant(node as XmlNamed);
    }
  }
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
  expect(const XmlVisitor().visit(named.name), isNull);
}

void assertAttributeInvariants(XmlNode xml) {
  for (var node in xml.descendants) {
    if (node is XmlElement) {
      var element = node;
      for (var attribute in element.attributes) {
        expect(attribute,
            same(element.getAttributeNode(attribute.name.qualified)));
        expect(attribute.value,
            same(element.getAttribute(attribute.name.qualified)));
      }
      if (element.attributes.isEmpty) {
        expect(element.getAttribute('foo'), isNull);
        expect(element.getAttributeNode('foo'), isNull);
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
      var previousType;
      var nodeTypes = node.children.map((node) => node.nodeType);
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
  var ancestors = [];
  void check(XmlNode node) {
    var allAxis = [
      node.preceding,
      [node],
      node.descendants,
      node.following
    ].expand((each) => each);
    var allRoot = [
      [node.root],
      node.root.descendants
    ].expand((each) => each);
    expect(allAxis, allRoot,
        reason: 'All preceding nodes, the node, all decendant '
            'nodes, and all following nodes should be equal to all nodes in the tree.');
    expect(node.ancestors, ancestors.reversed);
    expect(const XmlVisitor().visit(node), isNull);
    ancestors.add(node);
    node.attributes.forEach(check);
    node.children.forEach(check);
    ancestors.removeLast();
  }

  check(xml);
}

void assertCopyInvariants(XmlNode xml) {
  var copy = xml.copy();
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
    var originalNamed = original as XmlNamed;
    var copyNamed = copy as XmlNamed;
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
}

void assertPrintingInvariants(XmlNode xml) {
  void compare(XmlNode source, XmlNode pretty) {
    expect(source.nodeType, pretty.nodeType);
    expect(source.attributes.length, pretty.attributes.length);
    for (var i = 0; i < source.attributes.length; i++) {
      compare(source.attributes[i], pretty.attributes[i]);
    }
    var sourceChildren =
        source.children.where((node) => node is! XmlText).toList();
    var prettyChildren =
        pretty.children.where((node) => node is! XmlText).toList();
    expect(sourceChildren.length, prettyChildren.length);
    for (var i = 0; i < sourceChildren.length; i++) {
      compare(sourceChildren[i], prettyChildren[i]);
    }
    var sourceText = source.children
        .where((node) => node is XmlText)
        .map((node) => node.text.trim())
        .join();
    var prettyText = pretty.children
        .where((node) => node is XmlText)
        .map((node) => node.text.trim())
        .join();
    expect(sourceText, prettyText);
    if (source is! XmlParent) {
      expect(source.toXmlString(), pretty.toXmlString());
    }
  }

  compare(xml, parse(xml.toXmlString(pretty: true)));
}

void assertReaderInvariants(String input, XmlNode node) {
  var includedTypes = new Set.from([
    XmlNodeType.ELEMENT,
    XmlNodeType.TEXT,
    XmlNodeType.CDATA,
    XmlNodeType.PROCESSING,
  ]);
  var nodes = node.descendants
      .where((node) => includedTypes.contains(node.nodeType))
      .toList(growable: true);
  var stack = <XmlName>[];
  var state = 0;
  var reader = new XmlReader(
    onStartDocument: () {
      expect(state, 0, reason: 'Reader already started.');
      state = 1;
    },
    onEndDocument: () {
      expect(state, 1, reason: 'Reader not started');
      state = 2;
    },
    onStartElement: (name, attributes) {
      expect(state, 1, reason: 'Reader not started');
      expect(nodes, isNotEmpty, reason: 'Missing element in node list.');
      XmlNode node = nodes.removeAt(0);
      expect(node.nodeType, XmlNodeType.ELEMENT,
          reason: 'Node type should be an ELEMENT.');
      expect(node.attributes.length, attributes.length,
          reason: 'The amount of attributes should match.');
      for (var i = 0; i < node.attributes.length; i++) {
        assertCompareInvariants(node.attributes[i], attributes[i]);
      }
      stack.add(name);
    },
    onEndElement: (name) {
      expect(stack, isNotEmpty, reason: 'Missing matching start element.');
      expect(stack.removeLast(), name, reason: 'Non-matching start element.');
    },
    onCharacterData: (text) {
      expect(state, 1, reason: 'Reader not started');
      expect(nodes, isNotEmpty, reason: 'Missing element in node list.');
      XmlNode node = nodes.removeAt(0);
      expect(node.nodeType, anyOf(XmlNodeType.TEXT, XmlNodeType.CDATA),
          reason: 'Node type should be TEXT or CDATA.');
      expect(text, node.text, reason: 'Text data should match.');
    },
    onProcessingInstruction: (target, text) {
      expect(state, 1, reason: 'Reader not started');
      expect(nodes, isNotEmpty, reason: 'Missing element in node list.');
      XmlNode node = nodes.removeAt(0);
      expect(node.nodeType, XmlNodeType.PROCESSING,
          reason: 'Node type should be PROCESSING.');
      XmlProcessing processing = node as XmlProcessing;
      expect(target, processing.target, reason: 'Target data should match.');
      expect(text, processing.text, reason: 'Text data should match.');
    },
    onParseError: (index) => fail('Parser error at $index.'),
    onFatalError: (index, _) => fail('Fatal error at $index.'),
  );
  reader.parse(input);
  expect(nodes, isEmpty, reason: 'All nodes should be processed.');
  expect(stack, isEmpty, reason: 'All elements should be closed.');
  expect(state, 2, reason: 'Reader not completed.');
}
