import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xml/enums/node_type.dart';

void main() {
  group('XmlNodeType collections', () {
    test('documentChildrenNodeTypes contains valid child types', () {
      check(documentChildrenNodeTypes).contains(XmlNodeType.ELEMENT);
      check(documentChildrenNodeTypes).contains(XmlNodeType.COMMENT);
      check(documentChildrenNodeTypes).contains(XmlNodeType.PROCESSING);
      check(documentChildrenNodeTypes).contains(XmlNodeType.DECLARATION);
      check(documentChildrenNodeTypes).contains(XmlNodeType.DOCUMENT_TYPE);
      check(documentChildrenNodeTypes).contains(XmlNodeType.CDATA);
      check(documentChildrenNodeTypes).contains(XmlNodeType.TEXT);
      check(documentChildrenNodeTypes)
          .not((s) => s.contains(XmlNodeType.ATTRIBUTE));
    });

    test('elementChildrenNodeTypes excludes declaration and doctype', () {
      check(elementChildrenNodeTypes).contains(XmlNodeType.ELEMENT);
      check(elementChildrenNodeTypes).contains(XmlNodeType.COMMENT);
      check(elementChildrenNodeTypes).contains(XmlNodeType.PROCESSING);
      check(elementChildrenNodeTypes).contains(XmlNodeType.CDATA);
      check(elementChildrenNodeTypes).contains(XmlNodeType.TEXT);
      check(elementChildrenNodeTypes)
          .not((s) => s.contains(XmlNodeType.DECLARATION));
      check(elementChildrenNodeTypes)
          .not((s) => s.contains(XmlNodeType.DOCUMENT_TYPE));
      check(elementChildrenNodeTypes)
          .not((s) => s.contains(XmlNodeType.ATTRIBUTE));
    });

    test('attributeNodeTypes contains only ATTRIBUTE', () {
      check(attributeNodeTypes).unorderedEquals([XmlNodeType.ATTRIBUTE]);
    });
  });
}
