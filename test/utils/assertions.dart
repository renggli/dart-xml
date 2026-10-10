import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart' show TestFailure;
import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import 'checks.dart';

Never fail(String message) => throw TestFailure(message);

class EmptyVisitor with XmlVisitor;

class EmptyEventVistor with XmlEventVisitor;

void assertDocumentParseInvariants(String input) {
  final document = XmlDocument.parse(input);
  assertDocumentTreeInvariants(document);
  assertIteratorEventInvariants(input, document);
  assertStreamEventInvariants(input, document);
  assertStreamNodeInvariants(input, document);
  final copy = XmlDocument.parse(document.toXmlString());
  check(document.toXmlString()).equals(copy.toXmlString());
}

void assertDocumentTreeInvariants(XmlNode xml) {
  assertDocumentInvariants(xml);
  assertParentInvariants(xml);
  assertSiblingInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertNamespaceInvariants(xml);
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
  check(fragment.toXmlString()).equals(copy.toXmlString());
}

void assertFragmentTreeInvariants(XmlNode xml) {
  assertFragmentInvariants(xml);
  assertParentInvariants(xml);
  assertSiblingInvariants(xml);
  assertForwardInvariants(xml);
  assertBackwardInvariants(xml);
  assertNameInvariants(xml);
  assertAttributeInvariants(xml);
  assertNamespaceInvariants(xml);
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
    check(child.root).identicalTo(root);
    check<Object?>(child.document).identicalTo(root);
  }
  final document = xml.document!;
  check(document.children).contains(document.rootElement);
  final declaration = document.declaration;
  if (declaration != null) {
    check(document.children).contains(declaration);
    if (declaration.version != null) {
      check(declaration.version!).isNotEmpty();
    }
    if (declaration.encoding != null) {
      check(declaration.encoding!).isNotEmpty();
    }
    check(declaration.standalone).isNotNull();
  }
  final doctypeElement = document.doctypeElement;
  if (doctypeElement != null) {
    check(document.children).contains(doctypeElement);
    check(doctypeElement.name).isNotEmpty();
    final externalId = doctypeElement.externalId;
    if (externalId != null) {
      check(externalId.systemId).isNotEmpty();
      if (externalId.publicId != null) {
        check(externalId.publicId!).isNotEmpty();
      }
    }
    if (doctypeElement.internalSubset != null) {
      check(doctypeElement.internalSubset!).isA<String>();
    }
  }
  check(root.depth).equals(0);
}

void assertFragmentInvariants(XmlNode xml) {
  final root = xml.root;
  for (final child in [xml, ...xml.descendants]) {
    check(child.root).identicalTo(root);
    check(child.document).isNull();
  }
  check(root.depth).equals(0);
}

void assertParentInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    if (node is XmlDocument || node is XmlDocumentFragment) {
      check(node.parent).isNull();
      check(node.hasParent).isFalse();
      check(node.remove)
          .throws<XmlParentException>()
          .which(isXmlParentException(node: node));
      check(() => node.replace(XmlDocument()))
          .throws<XmlParentException>()
          .which(isXmlParentException(node: node));
      check(() => node.attachParent(XmlDocument())).throws<UnsupportedError>();
      check(() => node.detachParent(XmlDocument())).throws<UnsupportedError>();
    } else {
      check(node.parent).isNotNull();
      check(node.hasParent).isTrue();
    }
    for (final child in node.children) {
      check(child.parent).identicalTo(node);
      check(child.depth).equals(node.depth + 1);
    }
    for (final attribute in node.attributes) {
      check(attribute.parent).identicalTo(node);
      check(attribute.depth).equals(node.depth + 1);
    }
  }
}

void assertSiblingInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    final parent = node.parent;
    if (parent != null) {
      final siblings = node is XmlAttribute
          ? parent.attributes
          : parent.children;
      check(node.siblings).identicalTo(siblings);
      check(node.siblingElements).deepEquals(siblings.whereType<XmlElement>());
    } else {
      check(() => node.siblings)
          .throws<XmlParentException>()
          .which(isXmlParentException(node: node));
      check(() => node.siblingElements)
          .throws<XmlParentException>()
          .which(isXmlParentException(node: node));
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
    check(children).deepEquals(node.children);

    final childElements = <XmlElement>[];
    var currentElement = node.firstElementChild;
    while (currentElement != null) {
      childElements.add(currentElement);
      currentElement = currentElement.nextElementSibling;
    }
    check(childElements).deepEquals(node.childElements);
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
    check(children).deepEquals(node.children);

    final childElements = <XmlElement>[];
    var currentElementChild = node.lastElementChild;
    while (currentElementChild != null) {
      childElements.insert(0, currentElementChild);
      currentElementChild = currentElementChild.previousElementSibling;
    }
    check(childElements).deepEquals(node.childElements);
  }
}

void assertNameInvariants(XmlNode xml) {
  [
    xml,
    ...xml.descendants,
  ].whereType<XmlHasName>().forEach(assertNamedInvariant);
}

void assertNamedInvariant(XmlHasName named) {
  check(named.qualifiedName).equals(named.name.qualified);
  check(named.localName).equals(named.name.local);
  check(named.namespacePrefix).equals(named.name.prefix);
  check(named.namespaceUri).equals(named.name.namespaceUri);
  check(named.name.local).isNotEmpty();
  check(named.name.qualified).endsWith(named.name.local);
  if (named.name.prefix != null) {
    check(named.name.qualified).startsWith(named.name.prefix!);
  }
  if (named.name.namespaceUri != null) {
    check(named.name.namespaceUri!).isNotEmpty();
  }
  check(named.name.qualified).equals(named.name.toString());
}

void assertAttributeInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    check(node.elementAttributes).deepEquals(
      node.attributes.where((attribute) => !attribute.isNamespaceDeclaration),
    );
    for (final attribute in node.attributes) {
      check(attribute.isNamespaceDeclaration).equals(
        attribute.name.prefix == 'xmlns' || attribute.name.local == 'xmlns',
      );
    }
    if (node is XmlElement) {
      for (final attribute in node.attributes) {
        check<XmlAttribute?>(node.getAttributeNode(attribute.name.qualified))
            .identicalTo(attribute);
        check<String?>(node.getAttribute(attribute.name.qualified))
            .identicalTo(attribute.value);
      }
      if (node.attributes.isEmpty) {
        check(node.getAttribute('foo')).isNull();
        check(node.getAttributeNode('foo')).isNull();
      }
    }
  }
}

void assertNamespaceInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    for (final namespace in node.namespaces) {
      check(namespace.nodeType).equals(XmlNodeType.NAMESPACE);
      check(namespace.parent).isNotNull();
      check(namespace.prefix).isA<String>();
      check(namespace.uri).isNotEmpty();
      check(namespace.name.qualified).equals(namespace.prefix);
      check(namespace.value).equals(namespace.uri);
      check(namespace.namespaces).isEmpty();
      check(namespace.attributes).isEmpty();
      check(namespace.children).isEmpty();
      check(namespace.document).identicalTo(node.document);
    }
  }
}

void assertChildrenInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    if (node.children.isEmpty) {
      check(node.firstChild).isNull();
      check(node.lastChild).isNull();
      check(node.firstElementChild).isNull();
      check(node.lastElementChild).isNull();
      check(node.getElement('foo')).isNull();
    } else {
      check(node.firstChild).identicalTo(node.children.first);
      check(node.lastChild).identicalTo(node.children.last);
      final elements = node.children.whereType<XmlElement>();
      if (elements.isEmpty) {
        check(node.firstElementChild).isNull();
        check(node.lastElementChild).isNull();
      } else {
        check(node.firstElementChild).identicalTo(elements.first);
        check(node.lastElementChild).identicalTo(elements.last);
        final seenNames = <String>{};
        for (final element in elements.where(
          (element) => seenNames.add(element.name.qualified),
        )) {
          check(node.getElement(element.name.qualified)).identicalTo(element);
        }
      }
    }
  }
}

void assertTextInvariants(XmlNode xml) {
  for (final node in [xml, ...xml.descendants]) {
    // ignore: deprecated_member_use_from_same_package
    check(
      because: 'All nodes are supposed to return text strings.',
      node.innerText,
    ).isA<String>();
    if (node is XmlAttribute ||
        node is XmlCDATA ||
        node is XmlComment ||
        node is XmlDeclaration ||
        node is XmlNamespace ||
        node is XmlProcessing ||
        node is XmlText) {
      check(because: 'Values cannot be empty.', node.value).isA<String>();
    } else {
      check(node.value).isNull();
    }
    XmlNodeType? previousType;
    final nodeTypes = node.children.map((node) => node.nodeType);
    for (final currentType in nodeTypes) {
      check(
        because: 'Consecutive text nodes detected: $nodeTypes',
        previousType == XmlNodeType.TEXT && currentType == XmlNodeType.TEXT,
      ).isFalse();
      previousType = currentType;
    }
  }
}

void assertIteratorInvariants(XmlNode xml) {
  final ancestors = <XmlNode>[];
  void checkTree(XmlNode node) {
    final allAxis = [
      ...node.preceding,
      node,
      ...node.descendants,
      ...node.following,
    ];
    final allRoot = [node.root, ...node.root.descendants];
    check(
      because:
          'All preceding nodes, the node, all descendant nodes, and all '
          'following nodes should be equal to all nodes in the tree.',
      allAxis,
    ).deepEquals(allRoot);
    check(node.ancestors).deepEquals(ancestors.reversed);
    ancestors.add(node);
    node.attributes.forEach(checkTree);
    node.children.forEach(checkTree);
    ancestors.removeLast();
  }

  checkTree(xml);
}

void assertComparatorInvariants(XmlNode xml) {
  const unique = 'unique-2404879675441';
  final uniqueNodes = [
    XmlAttribute(const XmlName.qualified(unique), unique),
    XmlCDATA(unique),
    XmlComment(unique),
    XmlDeclaration([XmlAttribute(const XmlName.qualified(unique), unique)]),
    XmlDoctype(unique),
    XmlDocument([XmlElement(const XmlName.qualified(unique))]),
    XmlDocumentFragment([XmlElement(const XmlName.qualified(unique))]),
    XmlElement(const XmlName.qualified(unique)),
    XmlNamespace(unique, unique),
    XmlProcessing(unique, unique),
    XmlText(unique),
  ];
  for (final node in [xml, ...xml.descendants]) {
    // compare
    check(node.isEqualNode(node)).isTrue();
    for (final uniqueNode in uniqueNodes) {
      check(node.isEqualNode(uniqueNode)).isFalse();
      check(uniqueNode.isEqualNode(node)).isFalse();
    }
    // contains
    check(node.contains(node)).isTrue();
    check(node.descendants.map(node.contains)).every((it) => it.isTrue());
    check(node.ancestors.map(node.contains)).every((it) => it.isFalse());
    check(node.following.map(node.contains)).every((it) => it.isFalse());
    for (final uniqueNode in uniqueNodes) {
      check(node.contains(uniqueNode)).isFalse();
      check(uniqueNode.contains(node)).isFalse();
    }
    // compareNodePosition
    check(node.preceding.map(node.compareNodePosition))
        .every((it) => it.equals(1));
    check(node.compareNodePosition(node)).equals(0);
    check(node.following.map(node.compareNodePosition))
        .every((it) => it.equals(-1));
    for (final uniqueNode in uniqueNodes) {
      check(() => node.compareNodePosition(uniqueNode)).throws<StateError>();
      check(() => uniqueNode.compareNodePosition(node)).throws<StateError>();
    }
    // compareDocumentPosition
    check(node.compareDocumentPosition(node).isSame).isTrue();
    for (final other in node.preceding) {
      final pos = node.compareDocumentPosition(other);
      final sameElementAttributes =
          node is XmlAttribute &&
          other is XmlAttribute &&
          node.parent == other.parent;
      check(pos.isSame).isFalse();
      check(pos.isPreceding).isTrue();
      check(pos.isFollowing).isFalse();
      check(pos.isDisconnected).isFalse();
      check(pos.isImplementationSpecific).equals(sameElementAttributes);
    }
    for (final other in node.following) {
      final pos = node.compareDocumentPosition(other);
      final sameElementAttributes =
          node is XmlAttribute &&
          other is XmlAttribute &&
          node.parent == other.parent;
      check(pos.isSame).isFalse();
      check(pos.isDisconnected).isFalse();
      check(pos.isPreceding).isFalse();
      check(pos.isFollowing).isTrue();
      check(pos.isImplementationSpecific).equals(sameElementAttributes);
    }
    for (final other in node.descendants) {
      final pos = node.compareDocumentPosition(other);
      final sameElementAttributes =
          node is XmlAttribute &&
          other is XmlAttribute &&
          node.parent == other.parent;
      check(pos.isSame).isFalse();
      check(pos.isDisconnected).isFalse();
      check(pos.isPreceding).isFalse();
      check(pos.isFollowing).isTrue();
      check(pos.isContains).isFalse();
      check(pos.isContainedBy).isTrue();
      check(pos.isImplementationSpecific).equals(sameElementAttributes);
    }
    for (final other in node.ancestors) {
      final pos = node.compareDocumentPosition(other);
      check(pos.isSame).isFalse();
      check(pos.isDisconnected).isFalse();
      check(pos.isPreceding).isTrue();
      check(pos.isFollowing).isFalse();
      check(pos.isContains).isTrue();
      check(pos.isContainedBy).isFalse();
      check(pos.isImplementationSpecific).isFalse();
    }
    for (final uniqueNode in uniqueNodes) {
      final pos1 = node.compareDocumentPosition(uniqueNode);
      check(pos1.isSame).isFalse();
      check(pos1.isDisconnected).isTrue();
      check(pos1.isContains).isFalse();
      check(pos1.isContainedBy).isFalse();
      check(pos1.isImplementationSpecific).isTrue();
      check(pos1.isPreceding || pos1.isFollowing).isTrue();

      final pos2 = uniqueNode.compareDocumentPosition(node);
      check(pos2.isSame).isFalse();
      check(pos2.isDisconnected).isTrue();
      check(pos2.isContains).isFalse();
      check(pos2.isContainedBy).isFalse();
      check(pos2.isImplementationSpecific).isTrue();
      check(pos2.isPreceding || pos2.isFollowing).isTrue();
      check(pos1.isPreceding).not((it) => it.equals(pos2.isPreceding));
    }
  }
}

void assertCopyInvariants(XmlNode xml) {
  final copy = xml.copy();
  check(
    because: 'The copied node should not be equal.',
    xml,
  ).not((it) => it.equals(copy));
  check(
    because: 'The copied node should not be identical.',
    xml,
  ).not((it) => it.identicalTo(copy));
  check(
    because: 'The copied node should be equal',
    xml.isEqualNode(copy),
  ).isTrue();
  assertParentInvariants(copy);
  assertNameInvariants(copy);
}

void assertVisitorInvariants(XmlNode xml) {
  final visitor = EmptyVisitor();
  for (final node in [xml, ...xml.descendants]) {
    visitor.visit(node);
    if (node is XmlHasName) {
      visitor.visit((node as XmlHasName).name);
    }
    for (final namespace in node.namespaces) {
      visitor.visit(namespace);
    }
  }
}

final _whitespaceOrLineTerminators = RegExp(r'\s+');

void compareNode(XmlNode first, XmlNode second) {
  check(first.nodeType).equals(second.nodeType);
  final firstChildren = first.children
      .where((node) => node is! XmlText)
      .toList();
  final secondChildren = second.children
      .where((node) => node is! XmlText)
      .toList();
  check(firstChildren.length).equals(secondChildren.length);
  for (var i = 0; i < firstChildren.length; i++) {
    compareNode(firstChildren[i], secondChildren[i]);
  }
  final firstText = first.children
      .whereType<XmlText>()
      .map(
        (node) =>
            node.value.trim().replaceAll(_whitespaceOrLineTerminators, ' '),
      )
      .join();
  final secondText = second.children
      .whereType<XmlText>()
      .map(
        (node) =>
            node.value.trim().replaceAll(_whitespaceOrLineTerminators, ' '),
      )
      .join();
  check(firstText).equals(secondText);
  check(first.attributes.length).equals(second.attributes.length);
  for (var i = 0; i < first.attributes.length; i++) {
    compareAttribute(first.attributes[i], second.attributes[i]);
  }
  if (first is! XmlHasChildren) {
    check(first.toXmlString()).equals(second.toXmlString());
  }
}

void compareAttribute(XmlAttribute first, XmlAttribute second) {
  check(first.name.qualified).equals(second.name.qualified);
  check(first.name.namespaceUri).equals(second.name.namespaceUri);
  check(first.attributeType).equals(second.attributeType);
  check(first.value).equals(second.value);
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
  final visitor = EmptyEventVistor();
  while (iterator.moveNext()) {
    final event = iterator.current;
    if (event is XmlStartElementEvent) {
      final expected = nodes.removeAt(0) as XmlElement;
      check(event.nodeType).equals(expected.nodeType);
      check(event.name).equals(expected.name.qualified);
      check(event.localName).equals(expected.name.local);
      check(event.namespacePrefix).equals(expected.name.prefix);
      check(event.attributes.length).equals(expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        check(currentAttr.name).equals(expectedAttr.name.qualified);
        check(currentAttr.localName).equals(expectedAttr.name.local);
        check(currentAttr.namespacePrefix).equals(expectedAttr.name.prefix);
        check(currentAttr.value).equals(expectedAttr.value);
        check(currentAttr.attributeType).equals(expectedAttr.attributeType);
      }
      check(event.isSelfClosing)
          .equals(expected.children.isEmpty && expected.isSelfClosing);
      if (!event.isSelfClosing) {
        stack.add(event);
      }
    } else if (event is XmlEndElementEvent) {
      final expected = stack.removeLast();
      check(event.nodeType).equals(expected.nodeType);
      check(event.name).equals(expected.name);
      check(event.localName).equals(expected.localName);
      check(event.namespacePrefix).equals(expected.namespacePrefix);
    } else if (event is XmlCDATAEvent) {
      final expected = nodes.removeAt(0) as XmlCDATA;
      check(event.nodeType).equals(expected.nodeType);
      check(event.value).equals(expected.value);
      // ignore: deprecated_member_use_from_same_package
      check(event.text).equals(expected.value);
    } else if (event is XmlCommentEvent) {
      final expected = nodes.removeAt(0) as XmlComment;
      check(event.nodeType).equals(expected.nodeType);
      check(event.value).equals(expected.value);
      // ignore: deprecated_member_use_from_same_package
      check(event.text).equals(expected.value);
    } else if (event is XmlDoctypeEvent) {
      final expected = nodes.removeAt(0) as XmlDoctype;
      check(event.nodeType).equals(expected.nodeType);
      check(event.name).equals(expected.name);
      check(event.externalId).equals(expected.externalId);
      check(event.internalSubset).equals(expected.internalSubset);
    } else if (event is XmlDeclarationEvent) {
      final expected = nodes.removeAt(0) as XmlDeclaration;
      check(event.nodeType).equals(expected.nodeType);
      check(event.attributes.length).equals(expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        check(currentAttr.name).equals(expectedAttr.name.qualified);
        check(currentAttr.localName).equals(expectedAttr.name.local);
        check(currentAttr.namespacePrefix).equals(expectedAttr.name.prefix);
        check(currentAttr.value).equals(expectedAttr.value);
        check(currentAttr.attributeType).equals(expectedAttr.attributeType);
      }
    } else if (event is XmlProcessingEvent) {
      final expected = nodes.removeAt(0) as XmlProcessing;
      check(event.nodeType).equals(expected.nodeType);
      check(event.target).equals(expected.target);
      check(event.value).equals(expected.value);
      // ignore: deprecated_member_use_from_same_package
      check(event.text).equals(expected.value);
    } else if (event is XmlTextEvent) {
      final expected = nodes.removeAt(0) as XmlText;
      check(event.nodeType).equals(expected.nodeType);
      check(event.value).equals(expected.value);
      // ignore: deprecated_member_use_from_same_package
      check(event.text).equals(expected.value);
    } else {
      fail('Unexpected event type: $event');
    }
    visitor.visit(event);
  }
  check(because: '$nodes were not closed.', nodes).isEmpty();
  check(iterator.moveNext()).isFalse();
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
  final parsedEvents = XmlEventDecoder(withNamespace: true).convert(input);
  final nodes = node.descendants
      .where((node) => includedTypes.contains(node.nodeType))
      .toList(growable: true);
  final stack = <XmlStartElementEvent>[];
  for (final event in parsedEvents) {
    if (event is XmlStartElementEvent) {
      final expected = nodes.removeAt(0) as XmlElement;
      check(event.nodeType).equals(expected.nodeType);
      check(event.name).equals(expected.name.qualified);
      check(event.qualifiedName).equals(expected.name.qualified);
      check(event.localName).equals(expected.name.local);
      check(event.namespacePrefix).equals(expected.name.prefix);
      check(event.namespaceUri).equals(expected.name.namespaceUri);
      check(event.attributes.length).equals(expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        check(currentAttr.name).equals(expectedAttr.name.qualified);
        check(currentAttr.qualifiedName).equals(expectedAttr.name.qualified);
        check(currentAttr.localName).equals(expectedAttr.name.local);
        check(currentAttr.namespacePrefix).equals(expectedAttr.name.prefix);
        check(currentAttr.namespaceUri).equals(expectedAttr.name.namespaceUri);
        check(currentAttr.value).equals(expectedAttr.value);
        check(currentAttr.attributeType).equals(expectedAttr.attributeType);
      }
      check(event.isSelfClosing)
          .equals(expected.children.isEmpty && expected.isSelfClosing);
      if (!event.isSelfClosing) {
        stack.add(event);
      }
    } else if (event is XmlEndElementEvent) {
      final expected = stack.removeLast();
      check(event.nodeType).equals(expected.nodeType);
      check(event.name).equals(expected.name);
      check(event.qualifiedName).equals(expected.qualifiedName);
      check(event.localName).equals(expected.localName);
      check(event.namespacePrefix).equals(expected.namespacePrefix);
      check(event.namespaceUri).equals(expected.namespaceUri);
    } else if (event is XmlCDATAEvent) {
      final expected = nodes.removeAt(0) as XmlCDATA;
      check(event.nodeType).equals(expected.nodeType);
      check(event.value).equals(expected.value);
    } else if (event is XmlCommentEvent) {
      final expected = nodes.removeAt(0) as XmlComment;
      check(event.nodeType).equals(expected.nodeType);
      check(event.value).equals(expected.value);
    } else if (event is XmlDoctypeEvent) {
      final expected = nodes.removeAt(0) as XmlDoctype;
      check(event.nodeType).equals(expected.nodeType);
      check(event.name).equals(expected.name);
      check(event.externalId).equals(expected.externalId);
      check(event.internalSubset).equals(expected.internalSubset);
    } else if (event is XmlDeclarationEvent) {
      final expected = nodes.removeAt(0) as XmlDeclaration;
      check(event.nodeType).equals(expected.nodeType);
      check(event.attributes.length).equals(expected.attributes.length);
      for (var i = 0; i < event.attributes.length; i++) {
        final currentAttr = event.attributes[i];
        final expectedAttr = expected.attributes[i];
        check(currentAttr.name).equals(expectedAttr.name.qualified);
        check(currentAttr.qualifiedName).equals(expectedAttr.name.qualified);
        check(currentAttr.localName).equals(expectedAttr.name.local);
        check(currentAttr.namespacePrefix).equals(expectedAttr.name.prefix);
        check(currentAttr.namespaceUri).equals(expectedAttr.name.namespaceUri);
        check(currentAttr.value).equals(expectedAttr.value);
        check(currentAttr.attributeType).equals(expectedAttr.attributeType);
      }
    } else if (event is XmlProcessingEvent) {
      final expected = nodes.removeAt(0) as XmlProcessing;
      check(event.nodeType).equals(expected.nodeType);
      check(event.target).equals(expected.target);
      check(event.value).equals(expected.value);
    } else if (event is XmlTextEvent) {
      final expected = nodes.removeAt(0) as XmlText;
      check(event.nodeType).equals(expected.nodeType);
      check(event.value).equals(expected.value);
    } else {
      fail('Unexpected event type: $event');
    }
  }
}

void assertStreamNodeInvariants(String input, XmlNode node) {
  final events = XmlEventCodec(withNamespace: true).decode(input);
  final nodes = const XmlNodeCodec().decode(events);
  check(nodes.length).equals(node.children.length);
  check(nodes.map((each) => each.toXmlString()).join())
      .equals(node.children.map((each) => each.toXmlString()).join());
  for (var i = 0; i < nodes.length; i++) {
    compareNode(nodes[i], node.children[i]);
  }
}
