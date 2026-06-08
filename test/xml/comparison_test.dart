import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('compareDocumentPosition', () {
    test('identical node', () {
      final doc = XmlDocument.parse('<root><child/></root>');
      final root = doc.rootElement;
      final child = root.children.first;

      expect(root.compareDocumentPosition(root).value, 0);
      expect(child.compareDocumentPosition(child).value, 0);
    });

    test('ancestor / descendant', () {
      final doc = XmlDocument.parse('<root><child/></root>');
      final root = doc.rootElement;
      final child = root.children.first;

      // root contains child, child is contained by root
      // root.compareDocumentPosition(child) -> child is descendant of root (following, containedBy)
      final rootToChild = root.compareDocumentPosition(child);
      expect(rootToChild.isContainedBy, isTrue);
      expect(rootToChild.isContains, isFalse);
      expect(rootToChild.isFollowing, isTrue);
      expect(rootToChild.isPreceding, isFalse);
      expect(rootToChild.isDisconnected, isFalse);
      expect(rootToChild.isImplementationSpecific, isFalse);

      // child.compareDocumentPosition(root) -> root is ancestor of child (preceding, contains)
      final childToRoot = child.compareDocumentPosition(root);
      expect(childToRoot.isContains, isTrue);
      expect(childToRoot.isContainedBy, isFalse);
      expect(childToRoot.isPreceding, isTrue);
      expect(childToRoot.isFollowing, isFalse);
      expect(childToRoot.isDisconnected, isFalse);
      expect(childToRoot.isImplementationSpecific, isFalse);
    });

    test('siblings preceding / following', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final a = doc.rootElement.children[0];
      final b = doc.rootElement.children[1];
      final c = doc.rootElement.children[2];

      final aToB = a.compareDocumentPosition(b);
      expect(aToB.isFollowing, isTrue);
      expect(aToB.isPreceding, isFalse);

      final bToA = b.compareDocumentPosition(a);
      expect(bToA.isPreceding, isTrue);
      expect(bToA.isFollowing, isFalse);

      final aToC = a.compareDocumentPosition(c);
      expect(aToC.isFollowing, isTrue);
      expect(aToC.isPreceding, isFalse);
    });

    test('disconnected trees', () {
      final doc1 = XmlDocument.parse('<root1/>');
      final doc2 = XmlDocument.parse('<root2/>');
      final r1 = doc1.rootElement;
      final r2 = doc2.rootElement;

      final p1 = r1.compareDocumentPosition(r2);
      expect(p1.isDisconnected, isTrue);
      expect(p1.isImplementationSpecific, isTrue);
      expect(p1.isPreceding || p1.isFollowing, isTrue);

      final p2 = r2.compareDocumentPosition(r1);
      expect(p2.isDisconnected, isTrue);
      expect(p2.isImplementationSpecific, isTrue);
      expect(p2.isPreceding || p2.isFollowing, isTrue);
      expect(p1.isPreceding, isNot(p2.isPreceding));
    });

    test('attribute and owner element', () {
      final doc = XmlDocument.parse('<root attr="val"/>');
      final root = doc.rootElement;
      final attr = root.attributes.first;

      // ownerElement contains attribute, attribute is contained by ownerElement
      // root.compareDocumentPosition(attr) -> attr is contained by root (following, containedBy)
      final rootToAttr = root.compareDocumentPosition(attr);
      expect(rootToAttr.isContainedBy, isTrue);
      expect(rootToAttr.isContains, isFalse);
      expect(rootToAttr.isFollowing, isTrue);
      expect(rootToAttr.isPreceding, isFalse);

      // attr.compareDocumentPosition(root) -> root is ancestor of attr (preceding, contains)
      final attrToRoot = attr.compareDocumentPosition(root);
      expect(attrToRoot.isContains, isTrue);
      expect(attrToRoot.isContainedBy, isFalse);
      expect(attrToRoot.isPreceding, isTrue);
      expect(attrToRoot.isFollowing, isFalse);
    });

    test('attributes on same element', () {
      final doc = XmlDocument.parse('<root a="1" b="2" c="3"/>');
      final root = doc.rootElement;
      final a = root.attributes[0];
      final b = root.attributes[1];
      final c = root.attributes[2];

      final aToB = a.compareDocumentPosition(b);
      expect(aToB.isImplementationSpecific, isTrue);
      expect(aToB.isFollowing, isTrue);
      expect(aToB.isPreceding, isFalse);

      final bToA = b.compareDocumentPosition(a);
      expect(bToA.isImplementationSpecific, isTrue);
      expect(bToA.isPreceding, isTrue);
      expect(bToA.isFollowing, isFalse);

      final aToC = a.compareDocumentPosition(c);
      expect(aToC.isImplementationSpecific, isTrue);
      expect(aToC.isFollowing, isTrue);
      expect(aToC.isPreceding, isFalse);
    });

    test('attributes on different elements', () {
      final doc = XmlDocument.parse('<root><el1 a="1"/><el2 b="2"/></root>');
      final el1 = doc.rootElement.children[0] as XmlElement;
      final el2 = doc.rootElement.children[1] as XmlElement;
      final a = el1.attributes.first;
      final b = el2.attributes.first;

      // a is under el1, b is under el2. Since el1 precedes el2, a should precede b.
      final aToB = a.compareDocumentPosition(b);
      expect(aToB.isPreceding, isFalse);
      expect(aToB.isFollowing, isTrue);
      expect(aToB.isDisconnected, isFalse);
      expect(aToB.isImplementationSpecific, isFalse);

      final bToA = b.compareDocumentPosition(a);
      expect(bToA.isPreceding, isTrue);
      expect(bToA.isFollowing, isFalse);
      expect(bToA.isDisconnected, isFalse);
      expect(bToA.isImplementationSpecific, isFalse);
    });
  });
}
