library xml.test.xml_test;

import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xml/utils/errors.dart';

import 'xml_examples.dart';

const Matcher isXmlNodeTypeError = const _XmlNodeTypeError();

class _XmlNodeTypeError extends TypeMatcher {
  const _XmlNodeTypeError() : super('XmlNodeTypeError');
  @override
  bool matches(item, Map matchState) => item is XmlNodeTypeError;
}

const Matcher isXmlParentError = const _XmlParentError();

class _XmlParentError extends TypeMatcher {
  const _XmlParentError() : super('XmlParentError');
  @override
  bool matches(item, Map matchState) => item is XmlParentError;
}

void assetParseInvariants(String input) {
  var tree = parse(input);
  assertTreeInvariants(tree);
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
  void compare(XmlNode original, XmlNode copy) {
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
      compare(original.attributes[i], copy.attributes[i]);
    }
    expect(original.children.length, copy.children.length,
        reason: 'The amount of copied children should be the same.');
    for (var i = 0; i < original.children.length; i++) {
      compare(original.children[i], copy.children[i]);
    }
  }

  var copy = xml.copy();
  assertParentInvariants(xml);
  assertParentInvariants(copy);
  assertNameInvariants(xml);
  assertNameInvariants(copy);
  compare(xml, copy);
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

void main() {
  group('parsing', () {
    test('comment', () {
      assetParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
          '<schema><!-- comment --></schema>');
    });
    test('comment with xml', () {
      assetParseInvariants('<?xml version="1.0" encoding="UTF-8"?>'
          '<schema><!-- <foo></foo> --></schema>');
    });
    test('complicated', () {
      assetParseInvariants('<?xml foo?>\n'
          '<!DOCTYPE name [ something ]>\n'
          '<ns:foo attr="not namespaced" n1:ans="namespaced 1" n2:ans="namespace 2" >\n'
          '  <element/>\n'
          '  <ns:element/>\n'
          '  <!-- comment -->\n'
          '  <![CDATA[cdata]]>\n'
          '  <?processing instruction?>\n'
          '</ns:foo>');
    });
    test('doctype (system)', () {
      assetParseInvariants('<!DOCTYPE root-name SYSTEM "uri-reference">'
          '<root />');
    });
    test('doctype (public)', () {
      assetParseInvariants(
          '<!DOCTYPE root-name PUBLIC "public-identifier" "uri-reference">'
          '<root />');
    });
    test('doctype (subset)', () {
      assetParseInvariants('<!DOCTYPE root ['
          '  <!ELEMENT root (child)>'
          '  <!ATTLIST root attribute #IMPLIED>'
          '  <!ENTITY copy "©">'
          ']>'
          '<root />');
    });
    test('doctype (combined)', () {
      assetParseInvariants('<!DOCTYPE root SYSTEM "uri-reference" ['
          '  <!ELEMENT root (child)>'
          '  <!ATTLIST root attribute #IMPLIED>'
          '  <!ENTITY copy "©">'
          ']>'
          '<root />');
    });
    test('empty element', () {
      assetParseInvariants('<root/>');
      assetParseInvariants('<root />');
      assetParseInvariants('<root key="value"/>');
      assetParseInvariants('<root key="value" />');
    });
    test('namespace', () {
      assetParseInvariants('<xs:schema xs:attr="1"></xs:schema>');
    });
    test('simple', () {
      assetParseInvariants('<schema></schema>');
    });
    test('simple double quote attribute', () {
      assetParseInvariants('<schema foo="bar"></schema>');
    });
    test('simple single quote attribute', () {
      assetParseInvariants('<schema foo=\'bar\'></schema>');
    });
    test('short cdata section', () {
      assetParseInvariants('<data><![CDATA[]]></data>');
    });
    test('short cdata section', () {
      assetParseInvariants('<data><![CDATA[<data></data>]]></data>');
    });
    test('short processing instruction', () {
      assetParseInvariants('<?xml?><data />');
    });
    test('long processing instruction', () {
      assetParseInvariants('<?xml version="1.0"?><data />');
    });
    test('whitespace after prolog', () {
      assetParseInvariants('<?xml version="1.0" encoding="UTF-8"?>\n\t'
          '<schema></schema>\t\n');
    });
    test('parse errors', () {
      assertParseError('<data></tada>', 'Expected </data>, but found </tada>');
      assertParseError('<data key="ab', '">" expected at 1:7');
      assertParseError('<data key', '">" expected at 1:7');
      assertParseError('<data', '">" expected at 1:6');
      assertParseError('<>', 'Expected name at 1:2');
    });
  });
  group('nodes', () {
    test('element', () {
      XmlDocument document =
          parse('<ns:data key="value">Am I or are the other crazy?</ns:data>');
      XmlElement node = document.rootElement;
      expect(node.name, new XmlName.fromString('ns:data'));
      expect(node.parent, same(document));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, hasLength(1));
      expect(node.children, hasLength(1));
      expect(node.descendants, hasLength(2));
      expect(node.text, 'Am I or are the other crazy?');
      expect(node.nodeType, XmlNodeType.ELEMENT);
      expect(node.nodeType.toString(), 'XmlNodeType.ELEMENT');
      expect(node.toString(),
          '<ns:data key="value">Am I or are the other crazy?</ns:data>');
    });
    test('element (readopt name)', () {
      XmlDocument document = parse('<element attr="value1">text</element>');
      XmlElement node = document.rootElement;
      expect(() => new XmlElement(node.name), throwsArgumentError);
      expect(() => new XmlElement(new XmlName('data'), node.attributes),
          throwsArgumentError);
      expect(() => new XmlElement(new XmlName('data'), [], node.children),
          throwsArgumentError);
    });
    test('attribute', () {
      XmlDocument document =
          parse('<data ns:attr="Am I or are the other crazy?" />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(node.name, new XmlName.fromString('ns:attr'));
      expect(node.value, 'Am I or are the other crazy?');
      expect(node.attributeType, XmlAttributeType.DOUBLE_QUOTE);
      expect(node.parent, same(document.rootElement));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.descendants, isEmpty);
      expect(node.text, isEmpty);
      expect(node.nodeType, XmlNodeType.ATTRIBUTE);
      expect(node.nodeType.toString(), 'XmlNodeType.ATTRIBUTE');
      expect(node.toString(), 'ns:attr="Am I or are the other crazy?"');
    });
    test('attribute (empty)', () {
      XmlDocument document = parse('<data attr="" />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(node.value, '');
      expect(node.toString(), 'attr=""');
    });
    test('attribute (character references)', () {
      XmlDocument document =
          parse('<data ns:attr="&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;" />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(node.value, '<>&\'"\n\r\t');
      expect(node.toString(), 'ns:attr="&lt;>&amp;\'&quot;&#xA;&#xD;&#x9;"');
    });
    test('attribute (single)', () {
      XmlDocument document =
          parse('<data ns:attr=\'Am I or are the other crazy?\' />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(node.name, new XmlName.fromString('ns:attr'));
      expect(node.value, 'Am I or are the other crazy?');
      expect(node.attributeType, XmlAttributeType.SINGLE_QUOTE);
      expect(node.parent, same(document.rootElement));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.descendants, isEmpty);
      expect(node.text, isEmpty);
      expect(node.nodeType, XmlNodeType.ATTRIBUTE);
      expect(node.nodeType.toString(), 'XmlNodeType.ATTRIBUTE');
      expect(node.toString(), "ns:attr='Am I or are the other crazy?'");
    });
    test('attribute (single, empty)', () {
      XmlDocument document = parse('<data attr=\'\' />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(node.value, '');
      expect(node.toString(), "attr=''");
    });
    test('attribute (single, character references)', () {
      XmlDocument document = parse(
          '<data ns:attr=\'&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;\' />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(node.value, '<>&\'"\n\r\t');
      expect(node.toString(), "ns:attr='&lt;>&amp;&apos;\"&#xA;&#xD;&#x9;'");
    });
    test('attribute (readopt name)', () {
      XmlDocument document = parse(
          '<data ns:attr=\'&lt;&gt;&amp;&apos;&quot;&#xA;&#xD;&#x9;\' />');
      XmlAttribute node = document.rootElement.attributes.single;
      expect(() => new XmlAttribute(node.name, ''), throwsArgumentError);
    });
    test('text', () {
      XmlDocument document = parse('<data>Am I or are the other crazy?</data>');
      XmlText node = document.rootElement.children.single;
      expect(node.text, 'Am I or are the other crazy?');
      expect(node.parent, same(document.rootElement));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.descendants, isEmpty);
      expect(node.nodeType, XmlNodeType.TEXT);
      expect(node.nodeType.toString(), 'XmlNodeType.TEXT');
      expect(node.toString(), 'Am I or are the other crazy?');
    });
    test('text (character references)', () {
      XmlDocument document = parse('<data>&lt;&gt;&amp;&apos;&quot;</data>');
      XmlText node = document.rootElement.children.single;
      expect(node.text, '<>&\'"');
      expect(node.toString(), '&lt;>&amp;\'"');
    });
    test('text (nested)', () {
      XmlDocument root = parse(
          '<p>Am <i>I</i> or are the <b>other</b><!-- very --> crazy?</p>');
      expect(root.rootElement.text, 'Am I or are the other crazy?');
    });
    test('cdata', () {
      XmlDocument document = parse('<data>'
          '<![CDATA[Methinks <word> it <word> is like a weasel!]]>'
          '</data>');
      expect(document.rootElement.text,
          'Methinks <word> it <word> is like a weasel!');
      XmlCDATA node = document.rootElement.children.single;
      expect(node.text, 'Methinks <word> it <word> is like a weasel!');
      expect(node.parent, same(document.rootElement));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.nodeType, XmlNodeType.CDATA);
      expect(node.nodeType.toString(), 'XmlNodeType.CDATA');
      expect(node.toString(),
          '<![CDATA[Methinks <word> it <word> is like a weasel!]]>');
      expect(node.descendants, isEmpty);
    });
    test('processing', () {
      XmlDocument document = parse('<?xml version="1.0"?><data/>');
      XmlProcessing node = document.firstChild;
      expect(node.target, 'xml');
      expect(node.text, 'version="1.0"');
      expect(node.parent, same(document));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.nodeType, XmlNodeType.PROCESSING);
      expect(node.nodeType.toString(), 'XmlNodeType.PROCESSING');
      expect(node.toString(), '<?xml version="1.0"?>');
      expect(node.descendants, isEmpty);
    });
    test('comment', () {
      XmlDocument document =
          parse('<data><!--Am I or are the other crazy?--></data>');
      XmlComment node = document.rootElement.children.single;
      expect(node.parent, same(document.rootElement));
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.descendants, isEmpty);
      expect(node.text, 'Am I or are the other crazy?');
      expect(node.nodeType, XmlNodeType.COMMENT);
      expect(node.nodeType.toString(), 'XmlNodeType.COMMENT');
      expect(node.toString(), '<!--Am I or are the other crazy?-->');
    });
    test('document', () {
      XmlDocument document = parse('<data />');
      XmlDocument node = document.document;
      expect(node.parent, isNull);
      expect(node.root, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, hasLength(1));
      expect(node.descendants, hasLength(1));
      expect(node.text, isNull);
      expect(node.nodeType, XmlNodeType.DOCUMENT);
      expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT');
      expect(node.toString(), '<data />');
    });
    test('document definition', () {
      XmlDocument document = parse('<?xml version="1.0" encoding="UTF-8" ?>'
          '<element />');
      XmlDocument node = document.document;
      expect(node.children, hasLength(2));
      expect(node.descendants, hasLength(2));
      expect(
          node.toString(),
          '<?xml version="1.0" encoding="UTF-8" ?>'
          '<element />');
    });
    test('document comments and whitespace', () {
      XmlDocument document = parse('<?xml version="1.0" encoding="UTF-8"?> '
          '<!-- before -->\n<element />\t<!-- after -->');
      XmlDocument node = document.document;
      expect(node.children, hasLength(7));
      expect(node.descendants, hasLength(7));
      expect(
          node.toString(),
          '<?xml version="1.0" encoding="UTF-8"?> '
          '<!-- before -->\n<element />\t<!-- after -->');
      expect(
          node.toXmlString(pretty: true),
          '<?xml version="1.0" encoding="UTF-8"?>\n'
          '<!-- before -->\n<element />\n<!-- after -->');
    });
    test('document empty', () {
      XmlDocument document = new XmlDocument();
      expect(document.doctypeElement, isNull);
      expect(() => document.rootElement, throwsStateError);
    });
    test('document type', () {
      XmlDocument document =
          parse('<!DOCTYPE html [<!-- internal subset -->]><data />');
      XmlDoctype node = document.doctypeElement;
      expect(node.parent, same(document));
      expect(node.document, same(document));
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.descendants, isEmpty);
      expect(node.text, 'html [<!-- internal subset -->]');
      expect(node.nodeType, XmlNodeType.DOCUMENT_TYPE);
      expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT_TYPE');
      expect(node.toString(), '<!DOCTYPE html [<!-- internal subset -->]>');
    });
    test('document fragment empty', () {
      XmlDocumentFragment node = new XmlDocumentFragment();
      assertCopyInvariants(node);
      expect(node.parent, isNull);
      expect(node.root, node);
      expect(node.document, isNull);
      expect(node.attributes, isEmpty);
      expect(node.children, isEmpty);
      expect(node.descendants, isEmpty);
      expect(node.text, isNull);
      expect(node.nodeType, XmlNodeType.DOCUMENT_FRAGMENT);
      expect(node.nodeType.toString(), 'XmlNodeType.DOCUMENT_FRAGMENT');
      expect(node.toString(), '#document-fragment');
      expect(const XmlVisitor().visit(node), isNull);
    });
  });
  group('namespaces', () {
    test('default namespace', () {
      XmlDocument document = parse('<html xmlns="http://www.w3.org/1999/xhtml">'
          '  <body lang="en"/>'
          '</html>');
      List<XmlNode> nodes = new List.from(document.descendants)..add(document);
      for (var node in nodes) {
        if (node is XmlAttribute || node is XmlElement) {
          expect((node as XmlNamed).name.namespaceUri,
              'http://www.w3.org/1999/xhtml');
        }
      }
    });
    test('prefix namespace', () {
      XmlDocument document =
          parse('<xhtml:html xmlns:xhtml="http://www.w3.org/1999/xhtml">'
              '  <xhtml:body xhtml:lang="en"/>'
              '</xhtml:html>');
      List<XmlNode> nodes = new List.from(document.descendants)..add(document);
      for (var node in nodes) {
        if ((node is XmlAttribute && node.name.prefix != 'xmlns') ||
            (node is XmlElement)) {
          expect((node as XmlNamed).name.namespaceUri,
              'http://www.w3.org/1999/xhtml');
        }
      }
    });
  });
  group('mutating', () {
    void mutatingTest(String description, String before,
        void action(XmlElement node), String after) {
      test(description, () {
        var document = parse(before);
        action(document.rootElement);
        document.normalize();
        expect(after, document.toXmlString(),
            reason: 'should have been modified');
        assertTreeInvariants(document);
      });
    }

    void throwingTest(String description, String before,
        void action(XmlElement node), Matcher matcher) {
      test(description, () {
        var document = parse(before);
        expect(() => action(document.rootElement), matcher);
        expect(document.toXmlString(), before,
            reason: 'should not have been modified');
        assertTreeInvariants(document);
      });
    }

    group('update', () {
      mutatingTest(
        'element (attribute value)',
        '<element attr="value" />',
        (node) => node.attributes.first.value = 'update',
        '<element attr="update" />',
      );
      throwingTest(
        'element (null attribute value)',
        '<element attr="value" />',
        (node) => node.attributes.first.value = null,
        throwsArgumentError,
      );
      mutatingTest(
        'cdata (text)',
        '<element><![CDATA[text]]></element>',
        (node) => (node.children.first as XmlCDATA).text = 'update',
        '<element><![CDATA[update]]></element>',
      );
      throwingTest(
        'cdata (null text)',
        '<element><![CDATA[text]]></element>',
        (node) => (node.children.first as XmlCDATA).text = null,
        throwsArgumentError,
      );
      mutatingTest(
        'comment (text)',
        '<element><!--comment--></element>',
        (node) => (node.children.first as XmlComment).text = 'update',
        '<element><!--update--></element>',
      );
      throwingTest(
        'comment (null text)',
        '<element><!--comment--></element>',
        (node) => (node.children.first as XmlComment).text = null,
        throwsArgumentError,
      );
      test('processing (text)', () {
        var document = parse('<?xml processing?><element />');
        (document.firstChild as XmlProcessing).text = 'update';
        expect(document.toXmlString(), '<?xml update?><element />');
      });
      test('processing (null text)', () {
        var document = parse('<?xml processing ?><element />');
        expect(() => (document.firstChild as XmlProcessing).text = null,
            throwsArgumentError);
      });
      mutatingTest(
        'text (text)',
        '<element>Hello World</element>',
        (node) => (node.children.first as XmlText).text = 'Dart rocks',
        '<element>Dart rocks</element>',
      );
      throwingTest(
        'text (null text)',
        '<element>Hello World</element>',
        (node) => (node.children.first as XmlText).text = null,
        throwsArgumentError,
      );
    });
    group('add', () {
      mutatingTest(
        'element (attributes)',
        '<element />',
        (node) =>
            node.attributes.add(new XmlAttribute(new XmlName('attr'), 'value')),
        '<element attr="value" />',
      );
      mutatingTest(
        'element (children)',
        '<element />',
        (node) => node.children.add(new XmlText('Hello World')),
        '<element>Hello World</element>',
      );
      mutatingTest(
        'element (copy attribute)',
        '<element1 attr="value"><element2 /></element1>',
        (node) =>
            node.children.first.attributes.add(node.attributes.first.copy()),
        '<element1 attr="value"><element2 attr="value" /></element1>',
      );
      mutatingTest(
        'element (copy children)',
        '<element1><element2 /></element1>',
        (node) => node.children.add(node.children.first.copy()),
        '<element1><element2 /><element2 /></element1>',
      );
      mutatingTest(
        'element (fragment children)',
        '<element1 />',
        (node) {
          var fragment = new XmlDocumentFragment([
            new XmlText('Hello'),
            new XmlElement(new XmlName('element2')),
            new XmlComment('comment'),
          ]);
          node.children.add(fragment);
        },
        '<element1>Hello<element2 /><!--comment--></element1>',
      );
      mutatingTest(
        'element (repeated fragment children)',
        '<element1 />',
        (node) {
          var fragment = new XmlDocumentFragment(
              [new XmlElement(new XmlName('element2'))]);
          node.children..add(fragment)..add(fragment);
        },
        '<element1><element2 /><element2 /></element1>',
      );
      throwingTest(
        'element (null attributes)',
        '<element />',
        (node) => node.attributes.add(null),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (null children)',
        '<element />',
        (node) => node.children.add(null),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (attribute children)',
        '<element />',
        (node) {
          XmlNode wrong = new XmlAttribute(new XmlName('invalid'), 'invalid');
          node.children.add(wrong);
        },
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (parent error)',
        '<element1><element2 /></element1>',
        (node) => node.children.add(node.firstChild),
        throwsA(isXmlParentError),
      );
    });
    group('addAll', () {
      mutatingTest(
        'element (attributes)',
        '<element />',
        (node) => node.attributes
            .addAll([new XmlAttribute(new XmlName('attr'), 'value')]),
        '<element attr="value" />',
      );
      mutatingTest(
        'element (children)',
        '<element />',
        (node) => node.children.addAll([new XmlText('Hello World')]),
        '<element>Hello World</element>',
      );
      mutatingTest(
        'element (copy attribute)',
        '<element1 attr="value"><element2 /></element1>',
        (node) => node.children.first.attributes
            .addAll([node.attributes.first.copy()]),
        '<element1 attr="value"><element2 attr="value" /></element1>',
      );
      mutatingTest(
        'element (copy children)',
        '<element1><element2 /></element1>',
        (node) => node.children.addAll([node.children.first.copy()]),
        '<element1><element2 /><element2 /></element1>',
      );
      mutatingTest(
        'element (fragment children)',
        '<element1 />',
        (node) {
          var fragment = new XmlDocumentFragment([
            new XmlText('Hello'),
            new XmlElement(new XmlName('element2')),
            new XmlComment('comment'),
          ]);
          node.children.addAll([fragment]);
        },
        '<element1>Hello<element2 /><!--comment--></element1>',
      );
      mutatingTest(
        'element (repeated fragment children)',
        '<element1 />',
        (node) {
          var fragment = new XmlDocumentFragment(
              [new XmlElement(new XmlName('element2'))]);
          node.children.addAll([fragment, fragment]);
        },
        '<element1><element2 /><element2 /></element1>',
      );
      throwingTest(
        'element (null attributes)',
        '<element />',
        (node) => node.attributes.addAll([null]),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (null children)',
        '<element />',
        (node) => node.children.addAll([null]),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (attribute children)',
        '<element />',
        (node) {
          XmlNode wrong = new XmlAttribute(new XmlName('invalid'), 'invalid');
          node.children.addAll([wrong]);
        },
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (parent error)',
        '<element1><element2 /></element1>',
        (node) => node.children.addAll([node.firstChild]),
        throwsA(isXmlParentError),
      );
    });
    group('insert', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" />',
        (node) => node.attributes
            .insert(1, new XmlAttribute(new XmlName('attr2'), 'value2')),
        '<element attr1="value1" attr2="value2" />',
      );
      mutatingTest(
        'element (children)',
        '<element>Hello</element>',
        (node) => node.children.insert(1, new XmlText(' World')),
        '<element>Hello World</element>',
      );
      mutatingTest(
        'element (copy attribute)',
        '<element1 attr1="value1"><element2 attr2="value2"/></element1>',
        (node) => node.children.first.attributes
            .insert(1, node.attributes.first.copy()),
        '<element1 attr1="value1"><element2 attr2="value2" attr1="value1" /></element1>',
      );
      mutatingTest(
        'element (copy children)',
        '<element1><element2 /></element1>',
        (node) => node.children.insert(1, node.children.first.copy()),
        '<element1><element2 /><element2 /></element1>',
      );
      mutatingTest(
        'element (fragment children)',
        '<element1><element2 /></element1>',
        (node) {
          var fragment = new XmlDocumentFragment([
            new XmlText('Hello'),
            new XmlElement(new XmlName('element3')),
            new XmlComment('comment'),
          ]);
          node.children.insert(1, fragment);
        },
        '<element1><element2 />Hello<element3 /><!--comment--></element1>',
      );
      mutatingTest(
        'element (repeated fragment children)',
        '<element1><element2 /></element1>',
        (node) {
          var fragment = new XmlDocumentFragment(
              [new XmlElement(new XmlName('element3'))]);
          node.children..insert(0, fragment)..insert(2, fragment);
        },
        '<element1><element3 /><element2 /><element3 /></element1>',
      );
      throwingTest(
        'element (attribute range error)',
        '<element attr1="value1" />',
        (node) => node.attributes
            .insert(2, new XmlAttribute(new XmlName('attr2'), 'value2')),
        throwsRangeError,
      );
      throwingTest(
        'element (null attributes)',
        '<element />',
        (node) => node.attributes.insert(0, null),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (children range error)',
        '<element>Hello</element>',
        (node) => node.children.insert(2, new XmlText(' World')),
        throwsRangeError,
      );
      throwingTest(
        'element (null children)',
        '<element />',
        (node) => node.children.insert(0, null),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (attribute children)',
        '<element />',
        (node) {
          XmlNode wrong = new XmlAttribute(new XmlName('invalid'), 'invalid');
          node.children.insert(0, wrong);
        },
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (parent error)',
        '<element1><element2 /></element1>',
        (node) => node.children.insert(0, node.firstChild),
        throwsA(isXmlParentError),
      );
    });
    group('insertAll', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" />',
        (node) => node.attributes
            .insertAll(1, [new XmlAttribute(new XmlName('attr2'), 'value2')]),
        '<element attr1="value1" attr2="value2" />',
      );
      mutatingTest(
        'element (children)',
        '<element>Hello</element>',
        (node) => node.children.insertAll(1, [new XmlText(' World')]),
        '<element>Hello World</element>',
      );
      mutatingTest(
        'element (copy attribute)',
        '<element1 attr1="value1"><element2 attr2="value2"/></element1>',
        (node) => node.children.first.attributes
            .insertAll(1, [node.attributes.first.copy()]),
        '<element1 attr1="value1"><element2 attr2="value2" attr1="value1" /></element1>',
      );
      mutatingTest(
        'element (copy children)',
        '<element1><element2 /></element1>',
        (node) => node.children.insertAll(1, [node.children.first.copy()]),
        '<element1><element2 /><element2 /></element1>',
      );
      mutatingTest(
        'element (fragment children)',
        '<element1><element2 /></element1>',
        (node) {
          var fragment = new XmlDocumentFragment([
            new XmlText('Hello'),
            new XmlElement(new XmlName('element3')),
            new XmlComment('comment'),
          ]);
          node.children.insertAll(1, [fragment]);
        },
        '<element1><element2 />Hello<element3 /><!--comment--></element1>',
      );
      mutatingTest(
        'element (repeated fragment children)',
        '<element1><element2 /></element1>',
        (node) {
          var fragment = new XmlDocumentFragment(
              [new XmlElement(new XmlName('element3'))]);
          node.children.insertAll(0, [fragment, fragment]);
        },
        '<element1><element3 /><element3 /><element2 /></element1>',
      );
      throwingTest(
        'element (attribute range error)',
        '<element attr1="value1" />',
        (node) => node.attributes
            .insertAll(2, [new XmlAttribute(new XmlName('attr2'), 'value2')]),
        throwsRangeError,
      );
      throwingTest(
        'element (null attributes)',
        '<element />',
        (node) => node.attributes.insertAll(0, [null]),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (children range error)',
        '<element>Hello</element>',
        (node) => node.children.insertAll(2, [new XmlText(' World')]),
        throwsRangeError,
      );
      throwingTest(
        'element (null children)',
        '<element />',
        (node) => node.children.insertAll(0, [null]),
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (attribute children)',
        '<element />',
        (node) {
          XmlNode wrong = new XmlAttribute(new XmlName('invalid'), 'invalid');
          node.children.insertAll(0, [wrong]);
        },
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (parent error)',
        '<element1><element2 /></element1>',
        (node) => node.children.insertAll(0, [node.firstChild]),
        throwsA(isXmlParentError),
      );
    });
    group('[]=', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" />',
        (node) => node.attributes[0] =
            new XmlAttribute(new XmlName('attr2'), 'value2'),
        '<element attr2="value2" />',
      );
      mutatingTest(
        'element (children)',
        '<element>Hello World</element>',
        (node) => node.children[0] = new XmlText('Dart rocks'),
        '<element>Dart rocks</element>',
      );
      throwingTest(
        'element (attribute range error)',
        '<element attr1="value1" />',
        (node) => node.attributes[2] =
            new XmlAttribute(new XmlName('attr2'), 'value2'),
        throwsRangeError,
      );
      throwingTest(
        'element (null attributes)',
        '<element attr="value" />',
        (node) => node.attributes[0] = null,
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (children range error)',
        '<element>Hello</element>',
        (node) => node.children[2] = new XmlText(' World'),
        throwsRangeError,
      );
      throwingTest(
        'element (null children)',
        '<element />',
        (node) => node.children[0] = null,
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (attribute children)',
        '<element1><element2 /></element1>',
        (node) {
          XmlNode wrong = new XmlAttribute(new XmlName('invalid'), 'invalid');
          node.children[0] = wrong;
        },
        throwsA(isXmlNodeTypeError),
      );
      throwingTest(
        'element (parent error)',
        '<element1><element2 /></element1>',
        (node) => node.children[0] = node.firstChild,
        throwsA(isXmlParentError),
      );
    });
    group('remove', () {
      mutatingTest(
        'element (attributes)',
        '<element attr="value" />',
        (node) => node.attributes.remove(node.attributes.first),
        '<element />',
      );
      mutatingTest(
        'element (children)',
        '<element>Hello World</element>',
        (node) => node.children.remove(node.children.first),
        '<element />',
      );
      mutatingTest(
        'element (null attributes)',
        '<element attr="value" />',
        (node) => node.attributes.remove(null),
        '<element attr="value" />',
      );
      mutatingTest(
        'element (cdata attributes)',
        '<element attr="value" />',
        (node) {
          XmlNode wrong = new XmlCDATA('invalid');
          node.attributes.remove(wrong);
        },
        '<element attr="value" />',
      );
      mutatingTest(
        'element (comment attributes)',
        '<element attr="value" />',
        (node) {
          XmlNode wrong = new XmlComment('invalid');
          node.attributes.remove(wrong);
        },
        '<element attr="value" />',
      );
      mutatingTest(
        'element (element attributes)',
        '<element attr="value" />',
        (node) {
          XmlNode wrong = new XmlElement(new XmlName('invalid'));
          node.attributes.remove(wrong);
        },
        '<element attr="value" />',
      );
      mutatingTest(
        'element (processing attributes)',
        '<element attr="value" />',
        (node) {
          XmlNode wrong = new XmlProcessing('invalid', 'invalid');
          node.attributes.remove(wrong);
        },
        '<element attr="value" />',
      );
      mutatingTest(
        'element (text attributes)',
        '<element attr="value" />',
        (node) {
          XmlNode wrong = new XmlText('invalid');
          node.attributes.remove(wrong);
        },
        '<element attr="value" />',
      );
      mutatingTest(
        'element (null children)',
        '<element>Hello World</element>',
        (node) => node.children.remove(null),
        '<element>Hello World</element>',
      );
      mutatingTest(
        'element (attribute children)',
        '<element>Hello World</element>',
        (node) {
          XmlNode wrong = new XmlAttribute(new XmlName('invalid'), 'invalid');
          node.children.remove(wrong);
        },
        '<element>Hello World</element>',
      );
    });
    group('removeAt', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.removeAt(1),
        '<element attr1="value1" />',
      );
      throwingTest(
        'element (attributes range error)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.removeAt(2),
        throwsRangeError,
      );
      mutatingTest(
        'element (children)',
        '<element>Hello World</element>',
        (node) => node.children.removeAt(0),
        '<element />',
      );
      throwingTest(
        'element (children range error',
        '<element>Hello World</element>',
        (node) => node.children.removeAt(2),
        throwsRangeError,
      );
    });
    group('removeWhere', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.removeWhere(
            (node) => node is XmlAttribute && node.name.local == 'attr2'),
        '<element attr1="value1" />',
      );
      mutatingTest(
        'element (children)',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.removeWhere(
            (node) => node is XmlElement && node.name.local == 'element3'),
        '<element1><element2 /></element1>',
      );
    });
    group('retainWhere', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.retainWhere(
            (node) => node is XmlAttribute && node.name.local == 'attr1'),
        '<element attr1="value1" />',
      );
      mutatingTest(
        'element (children)',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.retainWhere(
            (node) => node is XmlElement && node.name.local == 'element2'),
        '<element1><element2 /></element1>',
      );
    });
    group('clear', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.clear(),
        '<element />',
      );
      mutatingTest(
        'element (children)',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.clear(),
        '<element1 />',
      );
    });
    group('removeLast', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.removeLast(),
        '<element attr1="value1" />',
      );
      throwingTest(
        'element (attributes range error)',
        '<element />',
        (node) => node.attributes.removeLast(),
        throwsRangeError,
      );
      mutatingTest(
        'element (children)',
        '<element>Hello World</element>',
        (node) => node.children.removeLast(),
        '<element />',
      );
      throwingTest(
        'element (children range error',
        '<element />',
        (node) => node.children.removeLast(),
        throwsRangeError,
      );
    });
    group('removeRange', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.removeRange(0, 1),
        '<element attr2="value2" />',
      );
      throwingTest(
        'element (attributes range error)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.removeRange(0, 3),
        throwsRangeError,
      );
      mutatingTest(
        'element (children)',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.removeRange(1, 2),
        '<element1><element2 /></element1>',
      );
      throwingTest(
        'element (children range error',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.removeRange(0, 3),
        throwsRangeError,
      );
    });
    group('setRange', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes
            .setRange(0, 1, [new XmlAttribute(new XmlName('attr3'), 'value3')]),
        '<element attr3="value3" attr2="value2" />',
      );
      throwingTest(
        'element (attributes range error)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.setRange(0, 3, [null, null, null]),
        throwsRangeError,
      );
      mutatingTest(
        'element (children)',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children
            .setRange(1, 2, [new XmlElement(new XmlName('element4'))]),
        '<element1><element2 /><element4 /></element1>',
      );
      throwingTest(
        'element (children range error',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.setRange(0, 3, [null, null, null]),
        throwsRangeError,
      );
    });
    group('replaceRange', () {
      mutatingTest(
        'element (attributes)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.replaceRange(
            0, 1, [new XmlAttribute(new XmlName('attr3'), 'value3')]),
        '<element attr3="value3" attr2="value2" />',
      );
      throwingTest(
        'element (attributes range error)',
        '<element attr1="value1" attr2="value2" />',
        (node) => node.attributes.replaceRange(0, 3, [null, null, null]),
        throwsRangeError,
      );
      mutatingTest(
        'element (children)',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children
            .replaceRange(1, 2, [new XmlElement(new XmlName('element4'))]),
        '<element1><element2 /><element4 /></element1>',
      );
      throwingTest(
        'element (children range error',
        '<element1><element2 /><element3 /></element1>',
        (node) => node.children.replaceRange(0, 3, [null, null, null]),
        throwsRangeError,
      );
    });
    group('unsupported method', () {
      throwingTest(
        'fillRange',
        '<element />',
        (node) => node.children.fillRange(0, 1),
        throwsUnsupportedError,
      );
      throwingTest(
        'setAll',
        '<element />',
        (node) => node.children.setAll(0, []),
        throwsUnsupportedError,
      );
      throwingTest(
        'length',
        '<element />',
        (node) => node.children.length = 2,
        throwsUnsupportedError,
      );
    });
    group('normalizer', () {
      test('remove empty text', () {
        var element = new XmlElement(new XmlName('element'), [], [
          new XmlText(''),
          new XmlElement(new XmlName('element1')),
          new XmlText(''),
          new XmlElement(new XmlName('element2')),
          new XmlText(''),
        ]);
        element.normalize();
        expect(element.children.length, 2);
        expect(element.toXmlString(),
            '<element><element1 /><element2 /></element>');
      });
      test('join adjacent text', () {
        var element = new XmlElement(new XmlName('element'), [], [
          new XmlText('aaa'),
          new XmlText('bbb'),
          new XmlText('ccc'),
        ]);
        element.normalize();
        expect(element.children.length, 1);
        expect(element.toXmlString(), '<element>aaabbbccc</element>');
      });
      test('document fragment', () {
        var fragment = new XmlDocumentFragment([
          new XmlText(''),
          new XmlText('aaa'),
          new XmlText(''),
          new XmlElement(new XmlName('element1')),
          new XmlText(''),
          new XmlText('bbb'),
          new XmlText(''),
          new XmlText('ccc'),
          new XmlText(''),
          new XmlElement(new XmlName('element2')),
          new XmlText(''),
          new XmlText('ddd'),
          new XmlText(''),
        ]);
        fragment.normalize();
        var element = new XmlElement(new XmlName('element'));
        element.children.add(fragment);
        expect(element.children.length, 5);
        expect(element.toXmlString(),
            '<element>aaa<element1 />bbbccc<element2 />ddd</element>');
      });
    });
  });
  group('entities', () {
    String decode(String input) =>
        parse('<data>$input</data>').rootElement.text;
    String encodeText(String input) => new XmlText(input).toString();
    String encodeAttributeValue(XmlAttributeType type, String input) {
      var attribute =
          new XmlAttribute(new XmlName('a'), input, type).toString();
      var quote = type == XmlAttributeType.SINGLE_QUOTE ? "'" : '"';
      expect(attribute.substring(0, 3), 'a=$quote');
      expect(attribute[attribute.length - 1], quote);
      return attribute.substring(3, attribute.length - 1);
    }

    test('decode &#xHHHH;', () {
      expect(decode('&#X41;'), 'A');
      expect(decode('&#x61;'), 'a');
      expect(decode('&#x7A;'), 'z');
    });
    test('decode &#dddd;', () {
      expect(decode('&#65;'), 'A');
      expect(decode('&#97;'), 'a');
      expect(decode('&#122;'), 'z');
    });
    test('decode &named;', () {
      expect(decode('&lt;'), '<');
      expect(decode('&gt;'), '>');
      expect(decode('&amp;'), '&');
      expect(decode('&apos;'), '\'');
      expect(decode('&quot;'), '"');
    });
    test('decode invalid', () {
      expect(decode('&invalid;'), '&invalid;');
    });
    test('decode incomplete', () {
      expect(decode('&amp'), '&amp');
    });
    test('decode empty', () {
      expect(decode('&;'), '&;');
    });
    test('decode surrounded', () {
      expect(decode('a&amp;b'), 'a&b');
      expect(decode('&amp;x&amp;'), '&x&');
    });
    test('decode sequence', () {
      expect(decode('&amp;&amp;'), '&&');
    });
    test('encode text', () {
      expect(encodeText('<'), '&lt;');
      expect(encodeText('&'), '&amp;');
      expect(encodeText('hello'), 'hello');
      expect(encodeText('<foo &amp;>'), '&lt;foo &amp;amp;>');
    });
    test('encode attribute (single quote)', () {
      expect(
          encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, "'"), '&apos;');
      expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '"'), '"');
      expect(
          encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '\t'), '&#x9;');
      expect(
          encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '\n'), '&#xA;');
      expect(
          encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '\r'), '&#xD;');
      expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, 'hello'),
          'hello');
      expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, "'hello'"),
          '&apos;hello&apos;');
      expect(encodeAttributeValue(XmlAttributeType.SINGLE_QUOTE, '"hello"'),
          '"hello"');
    });
    test('encode attribute (double quote)', () {
      expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, "'"), "'");
      expect(
          encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '"'), '&quot;');
      expect(
          encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '\t'), '&#x9;');
      expect(
          encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '\n'), '&#xA;');
      expect(
          encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '\r'), '&#xD;');
      expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, 'hello'),
          'hello');
      expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, "'hello'"),
          "'hello'");
      expect(encodeAttributeValue(XmlAttributeType.DOUBLE_QUOTE, '"hello"'),
          '&quot;hello&quot;');
    });
  });
  group('axis', () {
    var bookXml =
        '<book><title lang="en" price="12.00">XML</title><description/></book>';
    var book = parse(bookXml);
    void verifyIterator(Iterable iterable) {
      var iterator = iterable.iterator;
      while (iterator.moveNext()) {
        expect(iterator.current, isNotNull);
      }
      expect(iterator.current, isNull);
      expect(iterator.moveNext(), isFalse);
      expect(iterator.current, isNull);
    }

    test('ancestors', () {
      expect(book.ancestors, []);
      expect(book.children[0].ancestors, [book]);
      expect(book.children[0].children[0].ancestors, [book.children[0], book]);
      expect(book.children[0].children[0].attributes[0].ancestors,
          [book.children[0].children[0], book.children[0], book]);
      expect(book.children[0].children[0].attributes[1].ancestors,
          [book.children[0].children[0], book.children[0], book]);
      expect(book.children[0].children[0].children[0].ancestors,
          [book.children[0].children[0], book.children[0], book]);
      expect(book.children[0].children[1].ancestors, [book.children[0], book]);
      verifyIterator(book.children[0].children[1].ancestors);
    });
    test('preceding', () {
      expect(book.preceding, []);
      expect(book.children[0].preceding, [book]);
      expect(book.children[0].children[0].preceding, [book, book.children[0]]);
      expect(book.children[0].children[0].attributes[0].preceding,
          [book, book.children[0], book.children[0].children[0]]);
      expect(book.children[0].children[0].attributes[1].preceding, [
        book,
        book.children[0],
        book.children[0].children[0],
        book.children[0].children[0].attributes[0]
      ]);
      expect(book.children[0].children[0].children[0].preceding, [
        book,
        book.children[0],
        book.children[0].children[0],
        book.children[0].children[0].attributes[0],
        book.children[0].children[0].attributes[1]
      ]);
      expect(book.children[0].children[1].preceding, [
        book,
        book.children[0],
        book.children[0].children[0],
        book.children[0].children[0].attributes[0],
        book.children[0].children[0].attributes[1],
        book.children[0].children[0].children[0]
      ]);
      verifyIterator(book.children[0].children[1].preceding);
    });
    test('descendants', () {
      expect(book.descendants, [
        book.children[0],
        book.children[0].children[0],
        book.children[0].children[0].attributes[0],
        book.children[0].children[0].attributes[1],
        book.children[0].children[0].children[0],
        book.children[0].children[1]
      ]);
      expect(book.children[0].descendants, [
        book.children[0].children[0],
        book.children[0].children[0].attributes[0],
        book.children[0].children[0].attributes[1],
        book.children[0].children[0].children[0],
        book.children[0].children[1]
      ]);
      expect(book.children[0].children[0].descendants, [
        book.children[0].children[0].attributes[0],
        book.children[0].children[0].attributes[1],
        book.children[0].children[0].children[0]
      ]);
      expect(book.children[0].children[0].attributes[0].descendants, []);
      expect(book.children[0].children[0].attributes[1].descendants, []);
      expect(book.children[0].children[0].children[0].descendants, []);
      expect(book.children[0].children[1].descendants, []);
      verifyIterator(book.descendants);
    });
    test('following', () {
      expect(book.following, []);
      expect(book.children[0].following, []);
      expect(book.children[0].children[0].following,
          [book.children[0].children[1]]);
      expect(book.children[0].children[0].attributes[0].following, [
        book.children[0].children[0].attributes[1],
        book.children[0].children[0].children[0],
        book.children[0].children[1]
      ]);
      expect(book.children[0].children[0].attributes[1].following, [
        book.children[0].children[0].children[0],
        book.children[0].children[1]
      ]);
      expect(book.children[0].children[0].children[0].following,
          [book.children[0].children[1]]);
      expect(book.children[0].children[1].following, []);
      verifyIterator(book.following);
    });
  });
  group('querying elements', () {
    var bookstore = parse(bookstoreXml).rootElement;
    var shiporder = parse(shiporderXsd).rootElement;
    var xsd = 'http://www.w3.org/2001/XMLSchema';
    test('invalid', () {
      expect(() => bookstore.findElements(null), throwsArgumentError);
    });
    test('name defined, namespace undefined', () {
      var books = bookstore.findElements('book');
      expect(books.length, 2);
      var orders = shiporder.findElements('element');
      expect(orders.length, 0);
    });
    test('name defined, namespace wildcard', () {
      var books = bookstore.findElements('book', namespace: '*');
      expect(books.length, 2);
      var orders = shiporder.findElements('element', namespace: '*');
      expect(orders.length, 2);
    });
    test('name defined, namespace defined', () {
      var books = bookstore.findElements('book', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findElements('element', namespace: xsd);
      expect(orders.length, 2);
    });
    test('name wildcard, namespace undefined', () {
      var books = bookstore.findElements('*');
      expect(books.length, 2);
      var orders = shiporder.findElements('*');
      expect(orders.length, 7);
    });
    test('name wildcard, namespace wildcard', () {
      var books = bookstore.findElements('*', namespace: '*');
      expect(books.length, 2);
      var orders = shiporder.findElements('*', namespace: '*');
      expect(orders.length, 7);
    });
    test('name wildcard, namespace defined', () {
      var books = bookstore.findElements('*', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findElements('*', namespace: xsd);
      expect(orders.length, 7);
    });
  });
  group('querying all elements', () {
    var bookstore = parse(bookstoreXml);
    var shiporder = parse(shiporderXsd);
    var xsd = 'http://www.w3.org/2001/XMLSchema';
    test('invalid', () {
      expect(() => bookstore.findAllElements(null), throwsArgumentError);
    });
    test('name defined, namespace undefined', () {
      var books = bookstore.findAllElements('book');
      expect(books.length, 2);
      var orders = shiporder.findAllElements('element');
      expect(orders.length, 0);
    });
    test('name defined, namespace wildcard', () {
      var books = bookstore.findAllElements('book', namespace: '*');
      expect(books.length, 2);
      var orders = shiporder.findAllElements('element', namespace: '*');
      expect(orders.length, 17);
    });
    test('name defined, namespace defined', () {
      var books = bookstore.findAllElements('book', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findAllElements('element', namespace: xsd);
      expect(orders.length, 17);
    });
    test('name wildcard, namespace undefined', () {
      var books = bookstore.findAllElements('*');
      expect(books.length, 7);
      var orders = shiporder.findAllElements('*');
      expect(orders.length, 37);
    });
    test('name wildcard, namespace wildcard', () {
      var books = bookstore.findAllElements('*', namespace: '*');
      expect(books.length, 7);
      var orders = shiporder.findAllElements('*', namespace: '*');
      expect(orders.length, 37);
    });
    test('name wildcard, namespace defined', () {
      var books = bookstore.findAllElements('*', namespace: xsd);
      expect(books.length, 0);
      var orders = shiporder.findAllElements('*', namespace: xsd);
      expect(orders.length, 37);
    });
  });
  group('builder', () {
    test('basic', () {
      var builder = new XmlBuilder();
      builder.processing('xml', 'version="1.0" encoding="UTF-8"');
      builder.processing('xml-stylesheet',
          'href="/style.css" type="text/css" title="default stylesheet"');
      builder.element('bookstore', nest: () {
        builder.comment('Only one book?');
        builder.element('book', nest: () {
          builder.element('title', nest: () {
            builder.attribute('lang', 'en');
            builder.text('Harry ');
            builder.cdata('Potter');
          });
          builder.element('price', nest: 29.99);
          builder.element('special');
        });
      });
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected = '<?xml version="1.0" encoding="UTF-8"?>'
          '<?xml-stylesheet href="/style.css" type="text/css" title="default stylesheet"?>'
          '<bookstore>'
          '<!--Only one book?-->'
          '<book>'
          '<title lang="en">Harry <![CDATA[Potter]]></title>'
          '<price>29.99</price>'
          '<special />'
          '</book>'
          '</bookstore>';
      expect(actual, expected);
    });
    test('all', () {
      var builder = new XmlBuilder();
      builder.processing('processing', 'instruction');
      builder.element('element1', attributes: {'attribute1': 'value1'},
          nest: () {
        builder.attribute('attribute2', 'value2',
            attributeType: XmlAttributeType.DOUBLE_QUOTE);
        builder.attribute('attribute3', 'value3',
            attributeType: XmlAttributeType.SINGLE_QUOTE);
        builder.element('element2');
        builder.comment('comment');
        builder.cdata('cdata');
        builder.text('textual');
      });
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected = '<?processing instruction?>'
          '<element1 attribute1="value1" attribute2="value2" attribute3=\'value3\'>'
          '<element2 />'
          '<!--comment-->'
          '<![CDATA[cdata]]>'
          'textual'
          '</element1>';
      expect(actual, expected);
    });
    test('nested string', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: 'string');
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected = '<element>string</element>';
      expect(actual, expected);
    });
    test('nested iterable', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: [
        () => builder.text('st'),
        'ri',
        ['n', 'g']
      ]);
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected = '<element>string</element>';
      expect(actual, expected);
    });
    test('nested node (element)', () {
      var builder = new XmlBuilder();
      var nested = new XmlElement(new XmlName('nested'));
      builder.element('element', nest: nested);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].children[0].toXmlString(), nested.toXmlString());
      expect(xml.children[0].children[0], isNot(same(nested)));
      var actual = xml.toString();
      var expected = '<element><nested /></element>';
      expect(actual, expected);
    });
    test('nested node (element, repeated)', () {
      var builder = new XmlBuilder();
      var nested = new XmlElement(new XmlName('nested'));
      builder.element('element', nest: [nested, nested]);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].children[0].toXmlString(), nested.toXmlString());
      expect(xml.children[0].children[0], isNot(same(nested)));
      expect(xml.children[0].children[1].toXmlString(), nested.toXmlString());
      expect(xml.children[0].children[1], isNot(same(nested)));
      var actual = xml.toString();
      var expected = '<element><nested /><nested /></element>';
      expect(actual, expected);
    });
    test('nested node (text)', () {
      var builder = new XmlBuilder();
      var nested = new XmlText('text');
      builder.element('element', nest: nested);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].children[0].toXmlString(), nested.toXmlString());
      expect(xml.children[0].children[0], isNot(same(nested)));
      var actual = xml.toString();
      var expected = '<element>text</element>';
      expect(actual, expected);
    });
    test('nested node (text, repeated)', () {
      var builder = new XmlBuilder();
      var nested = new XmlText('text');
      builder.element('element', nest: [nested, nested]);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].children[0].text, 'texttext');
      expect(xml.children[0].children[0], isNot(same(nested)));
      var actual = xml.toString();
      var expected = '<element>texttext</element>';
      expect(actual, expected);
    });
    test('nested node (data)', () {
      var builder = new XmlBuilder();
      var nested = new XmlComment('abc');
      builder.element('element', nest: nested);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].children[0].toXmlString(), nested.toXmlString());
      expect(xml.children[0].children[0], isNot(same(nested)));
      var actual = xml.toString();
      var expected = '<element><!--abc--></element>';
      expect(actual, expected);
    });
    test('nested node (attribute)', () {
      var builder = new XmlBuilder();
      var nested = new XmlAttribute(new XmlName('foo'), 'bar');
      builder.element('element', nest: nested);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].attributes[0].toXmlString(), nested.toXmlString());
      expect(xml.children[0].attributes[0], isNot(same(nested)));
      var actual = xml.toString();
      var expected = '<element foo="bar" />';
      expect(actual, expected);
    });
    test('nested node (document)', () {
      var builder = new XmlBuilder();
      var nested = new XmlDocument([]);
      expect(
          () => builder.element('element', nest: nested), throwsArgumentError);
    });
    test('nested node (document fragment)', () {
      var builder = new XmlBuilder();
      var nested =
          new XmlDocumentFragment([new XmlText('foo'), new XmlComment('bar')]);
      builder.element('element', nest: nested);
      var xml = builder.build();
      assertTreeInvariants(xml);
      expect(xml.children[0].children[0].toXmlString(),
          nested.children[0].toXmlString());
      expect(xml.children[0].children[0], isNot(same(nested.children[0])));
      expect(xml.children[0].children[1].toXmlString(),
          nested.children[1].toXmlString());
      expect(xml.children[0].children[1], isNot(same(nested.children[1])));
      var actual = xml.toString();
      var expected = '<element>foo<!--bar--></element>';
      expect(actual, expected);
    });
    test('invalid attributes', () {
      var builder = new XmlBuilder();
      expect(() => builder.attribute('key', 'value'), throwsArgumentError);
    });
    test('text', () {
      var builder = new XmlBuilder();
      builder.element('text', nest: () {
        builder.text('abc');
        builder.text('');
        builder.text('def');
      });
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected = '<text>abcdef</text>';
      expect(actual, expected);
    });
    test('namespace binding', () {
      var uri = 'http://www.w3.org/2001/XMLSchema';
      var builder = new XmlBuilder();
      builder.element('schema', nest: () {
        builder.namespace(uri, 'xsd');
        builder.attribute('lang', 'en', namespace: uri);
        builder.element('element', namespace: uri);
      }, namespace: uri);
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected =
          '<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xsd:lang="en">'
          '<xsd:element />'
          '</xsd:schema>';
      expect(actual, expected);
    });
    test('default namespace binding', () {
      var uri = 'http://www.w3.org/2001/XMLSchema';
      var builder = new XmlBuilder();
      builder.element('schema', nest: () {
        builder.namespace(uri);
        builder.attribute('lang', 'en', namespace: uri);
        builder.element('element', namespace: uri);
      }, namespace: uri);
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected =
          '<schema xmlns="http://www.w3.org/2001/XMLSchema" lang="en">'
          '<element />'
          '</schema>';
      expect(actual, expected);
    });
    test('undefined namespace', () {
      var builder = new XmlBuilder();
      expect(() => builder.element('element', namespace: 'http://1.foo.com/'),
          throwsArgumentError);
    });
    test('invalid namespace', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: () {
        expect(() => builder.namespace('http://1.foo.com/', 'xml'),
            throwsArgumentError);
        expect(() => builder.namespace('http://2.foo.com/', 'xmlns'),
            throwsArgumentError);
      });
      var actual = builder.build().toString();
      var expected = '<element />';
      expect(actual, expected);
    });
    test('conflicting namespace', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: () {
        builder.namespace('http://1.foo.com/', 'foo');
        expect(() => builder.namespace('http://2.foo.com/', 'foo'),
            throwsArgumentError);
      }, namespace: 'http://1.foo.com/');
      var actual = builder.build().toString();
      var expected = '<foo:element xmlns:foo="http://1.foo.com/" />';
      expect(actual, expected);
    });
    test('unused namespace', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: () {
        builder.namespace('http://1.foo.com/', 'foo');
      });
      var actual = builder.build().toString();
      var expected = '<element xmlns:foo="http://1.foo.com/" />';
      expect(actual, expected);
    });
    test('unused namespace (optimized)', () {
      var builder = new XmlBuilder(optimizeNamespaces: true);
      builder.element('element', nest: () {
        builder.namespace('http://1.foo.com/', 'foo');
      });
      var actual = builder.build().toString();
      var expected = '<element />';
      expect(actual, expected);
    });
    test('duplicate namespace', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: () {
        builder.namespace('http://1.foo.com/', 'foo');
        builder.element('outer', nest: () {
          builder.namespace('http://1.foo.com/', 'foo');
          builder.element('inner', nest: () {
            builder.namespace('http://1.foo.com/', 'foo');
            builder.attribute('lang', 'en', namespace: 'http://1.foo.com/');
          });
        });
      });
      var actual = builder.build().toString();
      var expected = '<element xmlns:foo="http://1.foo.com/">'
          '<outer xmlns:foo="http://1.foo.com/">'
          '<inner xmlns:foo="http://1.foo.com/" foo:lang="en" />'
          '</outer>'
          '</element>';
      expect(actual, expected);
    });
    test('duplicate namespace on attribute (optimized)', () {
      var builder = new XmlBuilder(optimizeNamespaces: true);
      builder.element('element', nest: () {
        builder.namespace('http://1.foo.com/', 'foo');
        builder.element('outer', nest: () {
          builder.namespace('http://1.foo.com/', 'foo');
          builder.element('inner', nest: () {
            builder.namespace('http://1.foo.com/', 'foo');
            builder.attribute('lang', 'en', namespace: 'http://1.foo.com/');
          });
        });
      });
      var actual = builder.build().toString();
      var expected = '<element xmlns:foo="http://1.foo.com/">'
          '<outer>'
          '<inner foo:lang="en" />'
          '</outer>'
          '</element>';
      expect(actual, expected);
    });
    test('duplicate namespace on element (optimized)', () {
      var builder = new XmlBuilder(optimizeNamespaces: true);
      builder.element('element', nest: () {
        builder.namespace('http://1.foo.com/', 'foo');
        builder.element('outer', nest: () {
          builder.namespace('http://1.foo.com/', 'foo');
          builder.element('inner', namespace: 'http://1.foo.com/');
        });
      });
      var actual = builder.build().toString();
      var expected = '<element xmlns:foo="http://1.foo.com/">'
          '<outer>'
          '<foo:inner />'
          '</outer>'
          '</element>';
      expect(actual, expected);
    });
    test('entities cdata escape', () {
      var builder = new XmlBuilder();
      builder.element('element', nest: '<test><![CDATA[string]]></test>');
      var xml = builder.build();
      assertTreeInvariants(xml);
      var actual = xml.toString();
      var expected =
          '<element>&lt;test>&lt;![CDATA[string]]&gt;&lt;/test></element>';
      expect(actual, expected);
    });
  });
  group('examples', () {
    test('books', () {
      assetParseInvariants(booksXml);
    });
    test('bookstore', () {
      assetParseInvariants(bookstoreXml);
    });
    test('atom', () {
      assetParseInvariants(atomXml);
    });
    test('shiporder', () {
      assetParseInvariants(shiporderXsd);
    });
  });
  group('regressions', () {
    test('https://github.com/renggli/dart-xml/issues/38', () {
      var input = '<?xml?><InstantaneousDemand><DeviceMacId>'
          '0xd8d5b9000000b3e8</DeviceMacId><MeterMacId>0x00135003007c27b4'
          '</MeterMacId><TimeStamp>0x2244aeb3</TimeStamp><Demand>0x0006c1'
          '</Demand><Multiplier>0x00000001</Multiplier><Divisor>0x000003e8'
          '</Divisor><DigitsRight>0x03</DigitsRight><DigitsLeft>0x0f'
          '</DigitsLeft><SuppressLeadingZero>Y</SuppressLeadingZero>'
          '</InstantaneousDemand>';
      assetParseInvariants(input);
    });
  });
}
