import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

const isXmlParserException = TypeMatcher<XmlParserException>();
const isXmlNodeTypeException = TypeMatcher<XmlNodeTypeException>();
const isXmlParentException = TypeMatcher<XmlParentException>();
const isXmlTagException = TypeMatcher<XmlTagException>();

void assertDocumentParseInvariants(String input) {
  final document = XmlDocument.parse(input);
  expect(document, isA<XmlDocument>());
  assertDocumentTreeInvariants(document);
  assertIteratorEventInvariants(input, document);
  assertStreamEventInvariants(input, document);
  final copy = XmlDocument.parse(document.toXmlString());
  expect(document.toXmlString(), copy.toXmlString());
}

void assertDocumentParseError(String input, String message, int position) {
  try {
    final result = XmlDocument.parse(input);
    fail('Expected parse error $message, but got $result.');
  } on XmlParserException catch (error) {
    expect(error.message, message);
    expect(error.position, position);
  }
}

void assertDocumentTreeInvariants(XmlNode xml) {
  assertDocumentInvariants(xml);
  assertParentInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertChildrenInvariants(xml);
  assertTextInvariants(xml);
  assertIteratorInvariants(xml);
  assertCopyInvariants(xml);
  assertPrintingInvariants(xml);
}

void assertFragmentParseInvariants(String input) {
  final fragment = XmlDocumentFragment.parse(input);
  expect(fragment, isA<XmlDocumentFragment>());
  assertFragmentTreeInvariants(fragment);
  assertIteratorEventInvariants(input, fragment);
  assertStreamEventInvariants(input, fragment);
  final copy = XmlDocumentFragment.parse(fragment.toXmlString());
  expect(fragment.toXmlString(), copy.toXmlString());
}

void assertFragmentParseError(String input, String message, int position) {
  try {
    final result = XmlDocumentFragment.parse(input);
    fail('Expected parse error $message, but got $result.');
  } on XmlParserException catch (error) {
    expect(error.message, message);
    expect(error.position, position);
  }
}

void assertFragmentTreeInvariants(XmlNode xml) {
  assertFragmentInvariants(xml);
  assertParentInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertChildrenInvariants(xml);
  assertTextInvariants(xml);
  assertIteratorInvariants(xml);
  assertCopyInvariants(xml);
}

void assertDocumentInvariants(XmlNode xml) {
  final root = xml.root;
  for (final child in [xml, ...xml.descendants]) {
    expect(child.root, same(root));
    expect(child.document, same(root));
  }
  final document = xml.document!;
  expect(document.children, contains(document.rootElement));
  if (document.declaration != null) {
    expect(document.children, contains(document.declaration));
  }
  if (document.doctypeElement != null) {
    expect(document.children, contains(document.doctypeElement));
  }
  expect(root.depth, 0);
}

void assertFragmentInvariants(XmlNode xml) {
  final root = xml.root;
  for (final child in [xml, ...xml.descendants]) {
    expect(child.root, same(root));
    expect(child.document, isNull);
  }
  expect(root.depth, 0);
}

void assertParentInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    if (node is XmlDocument || node is XmlDocumentFragment) {
      expect(node.parent, isNull);
      expect(node.hasParent, isFalse);
      expect(() => node.replace(XmlDocument()), throwsUnsupportedError);
      expect(() => node.attachParent(XmlDocument()), throwsUnsupportedError);
      expect(() => node.detachParent(XmlDocument()), throwsUnsupportedError);
    } else {
      expect(node.parent, isNotNull);
      expect(node.hasParent, isTrue);
    }
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
  for (final node in [xml, ...xml.descendants]) {
    var current = node.firstChild;
    for (var i = 0; i < node.children.length; i++) {
      expect(node.children[i], same(current));
      current = current!.nextSibling;
    }
    expect(current, isNull);
  }
}

void assertBackwardInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    var current = node.lastChild;
    for (var i = node.children.length - 1; i >= 0; i--) {
      expect(node.children[i], same(current));
      current = current!.previousSibling;
    }
    expect(current, isNull);
  }
}

void assertNameInvariants(XmlNode xml) {
  [xml, ...xml.descendants]
      .whereType<XmlHasName>()
      .forEach(assertNamedInvariant);
}

void assertNamedInvariant(XmlHasName named) {
  expect(named, same(named.name.parent));
  expect(named.name.local, isNot(isEmpty));
  expect(named.name.qualified, endsWith(named.name.local));
  if (named.name.prefix != null) {
    expect(named.name.qualified, startsWith(named.name.prefix!));
  }
  expect(named.name.namespaceUri,
      anyOf(isNull, (node) => node is String && node.isNotEmpty));
  expect(named.name.qualified.hashCode, named.name.hashCode);
  expect(named.name.qualified, named.name.toString());
}

void assertAttributeInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
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

void assertChildrenInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    if (node.children.isEmpty) {
      expect(node.firstChild, isNull);
      expect(node.lastChild, isNull);
      expect(node.firstElementChild, isNull);
      expect(node.lastElementChild, isNull);
      expect(node.getElement('foo'), isNull);
    } else {
      expect(node.firstChild, same(node.children.first));
      expect(node.lastChild, same(node.children.last));
      final elements = node.children.whereType<XmlElement>();
      if (elements.isEmpty) {
        expect(node.firstElementChild, isNull);
        expect(node.lastElementChild, isNull);
      } else {
        expect(node.firstElementChild, elements.first);
        expect(node.lastElementChild, elements.last);
        final seenNames = <String>{};
        for (final element in elements
            .where((element) => seenNames.add(element.name.qualified))) {
          expect(node.getElement(element.name.qualified), same(element));
        }
      }
    }
  }
}

void assertTextInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    expect(node.text, (text) => text is String,
        reason: 'All nodes are supposed to return text strings.');
    if (node is XmlText) {
      expect(node.text, isNotEmpty, reason: 'Text nodes cannot be empty.');
    }
    XmlNodeType? previousType;
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

void assertIteratorInvariants(XmlNode xml) {
  final ancestors = <XmlNode>[];
  void check(XmlNode node) {
    final allAxis = [
      ...node.preceding,
      node,
      ...node.descendants,
      ...node.following,
    ];
    final allRoot = [node.root, ...node.root.descendants];
    expect(allAxis, allRoot,
        reason: 'All preceding nodes, the node, all descendant nodes, and all '
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
  if (original is XmlHasName && copy is XmlHasName) {
    final originalNamed = original as XmlHasName; // ignore: avoid_as
    final copyNamed = copy as XmlHasName; // ignore: avoid_as
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

final _whitespaceOrLineTerminators = RegExp(r'\s+');

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
      .map((node) =>
          node.text.trim().replaceAll(_whitespaceOrLineTerminators, ' '))
      .join();
  final secondText = second.children
      .whereType<XmlText>()
      .map((node) =>
          node.text.trim().replaceAll(_whitespaceOrLineTerminators, ' '))
      .join();
  expect(firstText, secondText);
  expect(first.attributes.length, second.attributes.length);
  for (var i = 0; i < first.attributes.length; i++) {
    compareNode(first.attributes[i], second.attributes[i]);
  }
  if (first is! XmlHasChildren) {
    expect(first.toXmlString(), second.toXmlString());
  }
}

void assertPrintingInvariants(XmlNode xml) {
  compareNode(xml, XmlDocument.parse(xml.toXmlString(pretty: true)));
}

void assertIteratorEventInvariants(String input, XmlNode node) {
  const includedTypes = {
    XmlNodeType.CDATA,
    XmlNodeType.COMMENT,
    XmlNodeType.DECLARATION,
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
    final event = iterator.current;
    if (event is XmlStartElementEvent) {
      final expected = nodes.removeAt(0) as XmlElement;
      expect(event.nodeType, expected.nodeType);
      expect(event.name, expected.name.qualified);
      expect(event.localName, expected.name.local);
      expect(event.namespacePrefix, expected.name.prefix);
      expect(event.attributes.length, expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        expect(currentAttr.name, expectedAttr.name.qualified);
        expect(currentAttr.localName, expectedAttr.name.local);
        expect(currentAttr.namespacePrefix, expectedAttr.name.prefix);
        expect(currentAttr.value, expectedAttr.value);
        expect(currentAttr.attributeType, expectedAttr.attributeType);
      }
      expect(event.isSelfClosing,
          expected.children.isEmpty && expected.isSelfClosing);
      if (!event.isSelfClosing) {
        stack.add(event);
      }
    } else if (event is XmlEndElementEvent) {
      final expected = stack.removeLast();
      expect(event.nodeType, expected.nodeType);
      expect(event.name, expected.name);
      expect(event.localName, expected.localName);
      expect(event.namespacePrefix, expected.namespacePrefix);
    } else if (event is XmlCDATAEvent) {
      final expected = nodes.removeAt(0) as XmlCDATA;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else if (event is XmlCommentEvent) {
      final expected = nodes.removeAt(0) as XmlComment;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else if (event is XmlDoctypeEvent) {
      final expected = nodes.removeAt(0) as XmlDoctype;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else if (event is XmlDeclarationEvent) {
      final expected = nodes.removeAt(0) as XmlDeclaration;
      expect(event.nodeType, expected.nodeType);
      expect(event.attributes.length, expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        expect(currentAttr.name, expectedAttr.name.qualified);
        expect(currentAttr.localName, expectedAttr.name.local);
        expect(currentAttr.namespacePrefix, expectedAttr.name.prefix);
        expect(currentAttr.value, expectedAttr.value);
        expect(currentAttr.attributeType, expectedAttr.attributeType);
      }
    } else if (event is XmlProcessingEvent) {
      final expected = nodes.removeAt(0) as XmlProcessing;
      expect(event.nodeType, expected.nodeType);
      expect(event.target, expected.target);
      expect(event.text, expected.text);
    } else if (event is XmlTextEvent) {
      final expected = nodes.removeAt(0) as XmlText;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else {
      fail('Unexpected event type: $event');
    }
  }
  expect(nodes, isEmpty, reason: '$nodes were not closed.');
  expect(iterator.moveNext(), isFalse);
}

void assertStreamEventInvariants(String input, XmlNode node) {
  const includedTypes = {
    XmlNodeType.CDATA,
    XmlNodeType.COMMENT,
    XmlNodeType.DECLARATION,
    XmlNodeType.DOCUMENT_TYPE,
    XmlNodeType.ELEMENT,
    XmlNodeType.PROCESSING,
    XmlNodeType.TEXT,
  };
  final parsedEvents = XmlEventDecoder().convert(input);
  final parentEvents = const XmlWithParentEvents().convert(parsedEvents);
  final nodes = node.descendants
      .where((node) => includedTypes.contains(node.nodeType))
      .toList(growable: true);
  final stack = <XmlStartElementEvent>[];
  for (final event in parentEvents) {
    if (event is XmlStartElementEvent) {
      final expected = nodes.removeAt(0) as XmlElement;
      expect(event.nodeType, expected.nodeType);
      expect(event.name, expected.name.qualified);
      expect(event.qualifiedName, expected.name.qualified);
      expect(event.localName, expected.name.local);
      expect(event.namespacePrefix, expected.name.prefix);
      expect(event.namespaceUri, expected.name.namespaceUri);
      expect(event.attributes.length, expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        expect(currentAttr.name, expectedAttr.name.qualified);
        expect(currentAttr.qualifiedName, expectedAttr.name.qualified);
        expect(currentAttr.localName, expectedAttr.name.local);
        expect(currentAttr.namespacePrefix, expectedAttr.name.prefix);
        expect(currentAttr.namespaceUri, expectedAttr.name.namespaceUri);
        expect(currentAttr.value, expectedAttr.value);
        expect(currentAttr.attributeType, expectedAttr.attributeType);
      }
      expect(event.isSelfClosing,
          expected.children.isEmpty && expected.isSelfClosing);
      if (!event.isSelfClosing) {
        stack.add(event);
      }
    } else if (event is XmlEndElementEvent) {
      final expected = stack.removeLast();
      expect(event.nodeType, expected.nodeType);
      expect(event.name, expected.name);
      expect(event.qualifiedName, expected.qualifiedName);
      expect(event.localName, expected.localName);
      expect(event.namespacePrefix, expected.namespacePrefix);
      expect(event.namespaceUri, expected.namespaceUri);
    } else if (event is XmlCDATAEvent) {
      final expected = nodes.removeAt(0) as XmlCDATA;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else if (event is XmlCommentEvent) {
      final expected = nodes.removeAt(0) as XmlComment;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else if (event is XmlDoctypeEvent) {
      final expected = nodes.removeAt(0) as XmlDoctype;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else if (event is XmlDeclarationEvent) {
      final expected = nodes.removeAt(0) as XmlDeclaration;
      expect(event.nodeType, expected.nodeType);
      expect(event.attributes.length, expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        expect(currentAttr.name, expectedAttr.name.qualified);
        expect(currentAttr.qualifiedName, expectedAttr.name.qualified);
        expect(currentAttr.localName, expectedAttr.name.local);
        expect(currentAttr.namespacePrefix, expectedAttr.name.prefix);
        expect(currentAttr.namespaceUri, expectedAttr.name.namespaceUri);
        expect(currentAttr.value, expectedAttr.value);
        expect(currentAttr.attributeType, expectedAttr.attributeType);
      }
    } else if (event is XmlProcessingEvent) {
      final expected = nodes.removeAt(0) as XmlProcessing;
      expect(event.nodeType, expected.nodeType);
      expect(event.target, expected.target);
      expect(event.text, expected.text);
    } else if (event is XmlTextEvent) {
      final expected = nodes.removeAt(0) as XmlText;
      expect(event.nodeType, expected.nodeType);
      expect(event.text, expected.text);
    } else {
      fail('Unexpected event type: $event');
    }
  }

  final prettyInput = node.toXmlString(pretty: false);
  final decodedEvents = XmlEventCodec().decode(prettyInput);
  final decodedNodes = const XmlNodeCodec().decode(decodedEvents);
  final encodedNodes = const XmlNodeCodec().encode(decodedNodes);
  final encodeString = XmlEventCodec().encode(encodedNodes);
  expect(encodeString, prettyInput);
}
