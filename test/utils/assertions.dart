// ignore_for_file: unnecessary_lambdas

import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'matchers.dart';

void assertDocumentParseInvariants(String input) {
  final document = XmlDocument.parse(input);
  assertDocumentTreeInvariants(document);
  assertIteratorEventInvariants(input, document);
  assertStreamEventInvariants(input, document);
  assertStreamNodeInvariants(input, document);
  final copy = XmlDocument.parse(document.toXmlString());
  expect(document.toXmlString(), copy.toXmlString());
}

void assertDocumentTreeInvariants(XmlNode xml) {
  assertDocumentInvariants(xml);
  assertParentInvariants(xml);
  assertSiblingInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertChildrenInvariants(xml);
  assertTextInvariants(xml);
  assertIteratorInvariants(xml);
  assertComparatorInvariants(xml);
  assertCopyInvariants(xml);
  assertVisitorInvariants(xml);
  assertPrintingInvariants(xml);
}

void assertFragmentParseInvariants(String input) {
  final fragment = XmlDocumentFragment.parse(input);
  assertFragmentTreeInvariants(fragment);
  assertIteratorEventInvariants(input, fragment);
  assertStreamEventInvariants(input, fragment);
  assertStreamNodeInvariants(input, fragment);
  final copy = XmlDocumentFragment.parse(fragment.toXmlString());
  expect(fragment.toXmlString(), copy.toXmlString());
}

void assertFragmentTreeInvariants(XmlNode xml) {
  assertFragmentInvariants(xml);
  assertParentInvariants(xml);
  assertSiblingInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertChildrenInvariants(xml);
  assertTextInvariants(xml);
  assertIteratorInvariants(xml);
  assertComparatorInvariants(xml);
  assertCopyInvariants(xml);
  assertVisitorInvariants(xml);
}

void assertDocumentInvariants(XmlNode xml) {
  final root = xml.root;
  for (final child in [xml, ...xml.descendants]) {
    expect(child.root, same(root));
    expect(child.document, same(root));
  }
  final document = xml.document!;
  expect(document.children, contains(document.rootElement));
  final declaration = document.declaration;
  if (declaration != null) {
    expect(document.children, contains(declaration));
    expect(declaration.version, anyOf(isNull, isNotEmpty));
    expect(declaration.encoding, anyOf(isNull, isNotEmpty));
    expect(declaration.standalone, anyOf(false, true));
  }
  final doctypeElement = document.doctypeElement;
  if (doctypeElement != null) {
    expect(document.children, contains(doctypeElement));
    expect(doctypeElement.name, isNotEmpty);
    final externalId = doctypeElement.externalId;
    if (externalId != null) {
      expect(externalId.systemId, isNotEmpty);
      expect(externalId.publicId, anyOf(isNull, isNotEmpty));
    }
    expect(doctypeElement.internalSubset, anyOf(isNull, isA<String>()));
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
      expect(() => node.remove(), throwsA(isXmlParentException(node: node)));
      expect(() => node.replace(XmlDocument()),
          throwsA(isXmlParentException(node: node)));
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

void assertSiblingInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    final parent = node.parent;
    if (parent != null) {
      final siblings =
          node is XmlAttribute ? parent.attributes : parent.children;
      expect(node.siblings, same(siblings));
      expect(node.siblingElements, siblings.whereType<XmlElement>());
    } else {
      expect(() => node.siblings, throwsA(isXmlParentException(node: node)));
      expect(() => node.siblingElements,
          throwsA(isXmlParentException(node: node)));
    }
  }
}

void assertForwardInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    final children = <XmlNode>[];
    var currentChild = node.firstChild;
    while (currentChild != null) {
      children.add(currentChild);
      currentChild = currentChild.nextSibling;
    }
    expect(children, orderedEquals(node.children));

    final childElements = <XmlElement>[];
    var currentElement = node.firstElementChild;
    while (currentElement != null) {
      childElements.add(currentElement);
      currentElement = currentElement.nextElementSibling;
    }
    expect(childElements, orderedEquals(node.childElements));
  }
}

void assertBackwardInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    final children = <XmlNode>[];
    var currentChild = node.lastChild;
    while (currentChild != null) {
      children.insert(0, currentChild);
      currentChild = currentChild.previousSibling;
    }
    expect(children, orderedEquals(node.children));

    final childElements = <XmlElement>[];
    var currentElementChild = node.lastElementChild;
    while (currentElementChild != null) {
      childElements.insert(0, currentElementChild);
      currentElementChild = currentElementChild.previousElementSibling;
    }
    expect(childElements, orderedEquals(node.childElements));
  }
}

void assertNameInvariants(XmlNode xml) {
  [xml, ...xml.descendants]
      .whereType<XmlHasName>()
      .forEach(assertNamedInvariant);
}

void assertNamedInvariant(XmlHasName named) {
  expect(named, same(named.name.parent));
  expect(named.qualifiedName, named.name.qualified);
  expect(named.localName, named.name.local);
  expect(named.namespacePrefix, named.name.prefix);
  expect(named.namespaceUri, named.name.namespaceUri);
  expect(named.name.local, isNot(isEmpty));
  expect(named.name.qualified, endsWith(named.name.local));
  if (named.name.prefix != null) {
    expect(named.name.qualified, startsWith(named.name.prefix!));
  }
  expect(named.name.namespaceUri, anyOf(isNull, isNot(isEmpty)));
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
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, isA<String>(),
        reason: 'All nodes are supposed to return text strings.');
    if (node is XmlAttribute ||
        node is XmlCDATA ||
        node is XmlComment ||
        node is XmlDeclaration ||
        node is XmlProcessing ||
        node is XmlText) {
      expect(node.value, isA<String>(), reason: 'Values cannot be empty.');
    } else {
      expect(node.value, isNull);
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

void assertComparatorInvariants(XmlNode xml) {
  const unique = 'unique-2404879675441';
  final uniqueNodes = [
    XmlAttribute(XmlName(unique), unique),
    XmlCDATA(unique),
    XmlComment(unique),
    XmlDeclaration([XmlAttribute(XmlName(unique), unique)]),
    XmlDoctype(unique),
    XmlDocument([XmlElement(XmlName(unique))]),
    XmlDocumentFragment([XmlElement(XmlName(unique))]),
    XmlElement(XmlName(unique)),
    XmlProcessing(unique, unique),
    XmlText(unique),
  ];
  for (final node in [xml, ...xml.descendants]) {
    // compare
    expect(node.isEqualNode(node), isTrue);
    for (final uniqueNode in uniqueNodes) {
      expect(node.isEqualNode(uniqueNode), isFalse);
      expect(uniqueNode.isEqualNode(node), isFalse);
    }
    // contains
    expect(node.contains(node), isTrue);
    expect(node.descendants.map(node.contains), everyElement(isTrue));
    expect(node.ancestors.map(node.contains), everyElement(isFalse));
    expect(node.following.map(node.contains), everyElement(isFalse));
    for (final uniqueNode in uniqueNodes) {
      expect(node.contains(uniqueNode), isFalse);
      expect(uniqueNode.contains(node), isFalse);
    }
    // compareNodePosition
    expect(node.preceding.map(node.compareNodePosition), everyElement(1));
    expect(node.compareNodePosition(node), 0);
    expect(node.following.map(node.compareNodePosition), everyElement(-1));
    for (final uniqueNode in uniqueNodes) {
      expect(() => node.compareNodePosition(uniqueNode), throwsStateError);
      expect(() => uniqueNode.compareNodePosition(node), throwsStateError);
    }
  }
}

void assertCopyInvariants(XmlNode xml) {
  final copy = xml.copy();
  expect(xml, isNot(copy), reason: 'The copied node should not be equal.');
  expect(xml, isNot(same(copy)),
      reason: 'The copied node should not be identical.');
  expect(xml.isEqualNode(copy), isTrue,
      reason: 'The copied node should be equal');
  assertParentInvariants(copy);
  assertNameInvariants(copy);
}

class EmptyVisitor with XmlVisitor {}

void assertVisitorInvariants(XmlNode xml) {
  final visitor = EmptyVisitor();
  for (final node in [xml, ...xml.descendants]) {
    visitor.visit(node);
    if (node is XmlHasName) {
      visitor.visit((node as XmlHasName).name);
    }
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
          node.value.trim().replaceAll(_whitespaceOrLineTerminators, ' '))
      .join();
  final secondText = second.children
      .whereType<XmlText>()
      .map((node) =>
          node.value.trim().replaceAll(_whitespaceOrLineTerminators, ' '))
      .join();
  expect(firstText, secondText);
  expect(first.attributes.length, second.attributes.length);
  for (var i = 0; i < first.attributes.length; i++) {
    compareAttribute(first.attributes[i], second.attributes[i]);
  }
  if (first is! XmlHasChildren) {
    expect(first.toXmlString(), second.toXmlString());
  }
}

void compareAttribute(XmlAttribute first, XmlAttribute second) {
  expect(first.name.qualified, second.name.qualified);
  expect(first.name.namespaceUri, second.name.namespaceUri);
  expect(first.attributeType, second.attributeType);
  expect(first.value, second.value);
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
      expect(event.value, expected.value);
      // ignore: deprecated_member_use_from_same_package
      expect(event.text, expected.value);
    } else if (event is XmlCommentEvent) {
      final expected = nodes.removeAt(0) as XmlComment;
      expect(event.nodeType, expected.nodeType);
      expect(event.value, expected.value);
      // ignore: deprecated_member_use_from_same_package
      expect(event.text, expected.value);
    } else if (event is XmlDoctypeEvent) {
      final expected = nodes.removeAt(0) as XmlDoctype;
      expect(event.nodeType, expected.nodeType);
      expect(event.name, expected.name);
      expect(event.externalId, expected.externalId);
      expect(event.internalSubset, expected.internalSubset);
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
      expect(event.value, expected.value);
      // ignore: deprecated_member_use_from_same_package
      expect(event.text, expected.value);
    } else if (event is XmlTextEvent) {
      final expected = nodes.removeAt(0) as XmlText;
      expect(event.nodeType, expected.nodeType);
      expect(event.value, expected.value);
      // ignore: deprecated_member_use_from_same_package
      expect(event.text, expected.value);
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
      expect(event.value, expected.value);
    } else if (event is XmlCommentEvent) {
      final expected = nodes.removeAt(0) as XmlComment;
      expect(event.nodeType, expected.nodeType);
      expect(event.value, expected.value);
    } else if (event is XmlDoctypeEvent) {
      final expected = nodes.removeAt(0) as XmlDoctype;
      expect(event.nodeType, expected.nodeType);
      expect(event.name, expected.name);
      expect(event.externalId, expected.externalId);
      expect(event.internalSubset, expected.internalSubset);
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
      expect(event.value, expected.value);
    } else if (event is XmlTextEvent) {
      final expected = nodes.removeAt(0) as XmlText;
      expect(event.nodeType, expected.nodeType);
      expect(event.value, expected.value);
    } else {
      fail('Unexpected event type: $event');
    }
  }
}

void assertStreamNodeInvariants(String input, XmlNode node) {
  final events = XmlEventCodec().decode(input);
  final nodes = const XmlNodeCodec().decode(events);
  expect(nodes.length, node.children.length);
  expect(
    nodes.map((each) => each.toXmlString()).join(),
    node.children.map((each) => each.toXmlString()).join(),
  );
  for (var i = 0; i < nodes.length; i++) {
    compareNode(nodes[i], node.children[i]);
  }
}
