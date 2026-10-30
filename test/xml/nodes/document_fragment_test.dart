import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../../utils/assertions.dart';

void main() {
  test('basic', () {
    final node = XmlDocumentFragment.parse('<!--Am I a joke to you?-->No');
    assertFragmentInvariants(node);
    check(node.parent).isNull();
    check(node.parentElement).isNull();
    check(node.root).equals(node);
    check(node.document).isNull();
    check(node.depth).equals(0);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).length.equals(2);
    check(node.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('No');
    check(node.nodeType).equals(XmlNodeType.DOCUMENT_FRAGMENT);
    check(node.toString()).equals('<!--Am I a joke to you?-->No');
  });
  test('empty', () {
    final node = XmlDocumentFragment();
    assertFragmentInvariants(node);
    check(node.parent).isNull();
    check(node.parentElement).isNull();
    check(node.root).equals(node);
    check(node.document).isNull();
    check(node.depth).equals(0);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.value).isNull();
    // ignore: deprecated_member_use_from_same_package
    check(node.text).equals('');
    check(node.nodeType).equals(XmlNodeType.DOCUMENT_FRAGMENT);
    check(node.toString()).equals('');
  });
  test('builder', () {
    final node = XmlDocumentFragment.build((builder) {
      builder.element('one');
      builder.element('two');
    });
    assertFragmentInvariants(node);
    check(node.innerXml).equals('<one/><two/>');
  });
  test('empties on insertion', () {
    final fragment = XmlDocumentFragment.parse('<one/><two/>');
    check(fragment.children).length.equals(2);
    final element = XmlElement(const XmlName('root'));
    element.children.add(fragment);
    check(fragment.children).isEmpty();
    check(element.children).length.equals(2);
  });
}
