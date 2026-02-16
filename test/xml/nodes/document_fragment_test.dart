import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../utils/assertions.dart';

void main() {
  test('basic', () {
    final node = XmlDocumentFragment.parse('<!--Am I a joke to you?-->No');
    assertFragmentInvariants(node);
    expect(node.parent, isNull);
    expect(node.parentElement, isNull);
    expect(node.root, node);
    expect(node.document, isNull);
    expect(node.depth, 0);
    expect(node.attributes, isEmpty);
    expect(node.children, hasLength(2));
    expect(node.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, 'No');
    expect(node.nodeType, XmlNodeType.DOCUMENT_FRAGMENT);
    expect(node.toString(), '#document-fragment');
  });
  test('empty', () {
    final node = XmlDocumentFragment();
    assertFragmentInvariants(node);
    expect(node.parent, isNull);
    expect(node.parentElement, isNull);
    expect(node.root, node);
    expect(node.document, isNull);
    expect(node.depth, 0);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.value, isNull);
    // ignore: deprecated_member_use_from_same_package
    expect(node.text, '');
    expect(node.nodeType, XmlNodeType.DOCUMENT_FRAGMENT);
    expect(node.toString(), '#document-fragment');
  });
  test('builder', () {
    final node = XmlDocumentFragment.build((builder) {
      builder.element('one');
      builder.element('two');
    });
    assertFragmentInvariants(node);
    expect(node.innerXml, '<one/><two/>');
  });
}
