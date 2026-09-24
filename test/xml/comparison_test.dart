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

    test('namespace and owner element', () {
      final doc = XmlDocument.parse('<root xmlns:ns="http://example.com"/>');
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);

      // ownerElement contains namespace, namespace is contained by ownerElement
      final rootToNs = root.compareDocumentPosition(ns);
      expect(rootToNs.isContainedBy, isTrue);
      expect(rootToNs.isContains, isFalse);
      expect(rootToNs.isFollowing, isTrue);
      expect(rootToNs.isPreceding, isFalse);
      expect(rootToNs.isDisconnected, isFalse);
      expect(rootToNs.isImplementationSpecific, isFalse);

      final nsToRoot = ns.compareDocumentPosition(root);
      expect(nsToRoot.isContains, isTrue);
      expect(nsToRoot.isContainedBy, isFalse);
      expect(nsToRoot.isPreceding, isTrue);
      expect(nsToRoot.isFollowing, isFalse);
      expect(nsToRoot.isDisconnected, isFalse);
      expect(nsToRoot.isImplementationSpecific, isFalse);
    });

    test('namespaces on same element', () {
      final doc = XmlDocument.parse(
        '<root xmlns:a="http://a.com" xmlns:b="http://b.com"/>',
      );
      final root = doc.rootElement;
      final nsA = XmlNamespace('a', 'http://a.com')..attachParent(root);
      final nsB = XmlNamespace('b', 'http://b.com')..attachParent(root);

      final aToB = nsA.compareDocumentPosition(nsB);
      expect(aToB.isImplementationSpecific, isTrue);
      expect(aToB.isFollowing, isTrue);
      expect(aToB.isPreceding, isFalse);

      final bToA = nsB.compareDocumentPosition(nsA);
      expect(bToA.isImplementationSpecific, isTrue);
      expect(bToA.isPreceding, isTrue);
      expect(bToA.isFollowing, isFalse);
    });

    test('distinct namespace instances with same prefix on same element', () {
      final doc = XmlDocument.parse('<root xmlns:a="http://a.com"/>');
      final root = doc.rootElement;
      final ns1 = XmlNamespace('a', 'http://a.com')..attachParent(root);
      final ns2 = XmlNamespace('a', 'http://a.com')..attachParent(root);

      final p1 = ns1.compareDocumentPosition(ns2);
      final p2 = ns2.compareDocumentPosition(ns1);
      expect(p1.isImplementationSpecific, isTrue);
      expect(p2.isImplementationSpecific, isTrue);
      expect(p1.isFollowing, isNot(p2.isFollowing));
      expect(p1.isPreceding, isNot(p2.isPreceding));
    });

    test('namespace and attribute on same element', () {
      final doc = XmlDocument.parse(
        '<root xmlns:ns="http://example.com" attr="val"/>',
      );
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);
      final attr = root.attributes.first;

      // In document order, namespace nodes precede attribute nodes.
      final nsToAttr = ns.compareDocumentPosition(attr);
      expect(nsToAttr.isImplementationSpecific, isTrue);
      expect(nsToAttr.isFollowing, isTrue);
      expect(nsToAttr.isPreceding, isFalse);

      final attrToNs = attr.compareDocumentPosition(ns);
      expect(attrToNs.isImplementationSpecific, isTrue);
      expect(attrToNs.isPreceding, isTrue);
      expect(attrToNs.isFollowing, isFalse);
    });

    test('attribute and child of same owner element', () {
      final doc = XmlDocument.parse('<root attr="val"><child/></root>');
      final root = doc.rootElement;
      final attr = root.attributes.first;
      final child = root.children.first;

      // Attributes precede child nodes of their owner element.
      final attrToChild = attr.compareDocumentPosition(child);
      expect(attrToChild.isFollowing, isTrue);
      expect(attrToChild.isPreceding, isFalse);
      expect(attrToChild.isContains, isFalse);
      expect(attrToChild.isContainedBy, isFalse);

      final childToAttr = child.compareDocumentPosition(attr);
      expect(childToAttr.isPreceding, isTrue);
      expect(childToAttr.isFollowing, isFalse);
      expect(childToAttr.isContains, isFalse);
      expect(childToAttr.isContainedBy, isFalse);
    });

    test('namespace and child of same owner element', () {
      final doc = XmlDocument.parse(
        '<root xmlns:ns="http://example.com"><child/></root>',
      );
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);
      final child = root.children.first;

      // Namespaces precede child nodes of their owner element.
      final nsToChild = ns.compareDocumentPosition(child);
      expect(nsToChild.isFollowing, isTrue);
      expect(nsToChild.isPreceding, isFalse);
      expect(nsToChild.isContains, isFalse);
      expect(nsToChild.isContainedBy, isFalse);

      final childToNs = child.compareDocumentPosition(ns);
      expect(childToNs.isPreceding, isTrue);
      expect(childToNs.isFollowing, isFalse);
      expect(childToNs.isContains, isFalse);
      expect(childToNs.isContainedBy, isFalse);
    });

    test('namespaces on different elements', () {
      final doc = XmlDocument.parse(
        '<root><el1 xmlns:a="http://a.com"/><el2 xmlns:b="http://b.com"/></root>',
      );
      final el1 = doc.rootElement.children[0] as XmlElement;
      final el2 = doc.rootElement.children[1] as XmlElement;
      final nsA = XmlNamespace('a', 'http://a.com')..attachParent(el1);
      final nsB = XmlNamespace('b', 'http://b.com')..attachParent(el2);

      // el1 precedes el2, so nsA precedes nsB.
      final aToB = nsA.compareDocumentPosition(nsB);
      expect(aToB.isPreceding, isFalse);
      expect(aToB.isFollowing, isTrue);
      expect(aToB.isDisconnected, isFalse);
      expect(aToB.isImplementationSpecific, isFalse);

      final bToA = nsB.compareDocumentPosition(nsA);
      expect(bToA.isPreceding, isTrue);
      expect(bToA.isFollowing, isFalse);
      expect(bToA.isDisconnected, isFalse);
      expect(bToA.isImplementationSpecific, isFalse);
    });

    test('namespace and attribute on different elements', () {
      final doc = XmlDocument.parse(
        '<root><el1 xmlns:a="http://a.com"/><el2 b="2"/></root>',
      );
      final el1 = doc.rootElement.children[0] as XmlElement;
      final el2 = doc.rootElement.children[1] as XmlElement;
      final nsA = XmlNamespace('a', 'http://a.com')..attachParent(el1);
      final attrB = el2.attributes.first;

      final aToB = nsA.compareDocumentPosition(attrB);
      expect(aToB.isFollowing, isTrue);
      expect(aToB.isPreceding, isFalse);
      expect(aToB.isDisconnected, isFalse);

      final bToA = attrB.compareDocumentPosition(nsA);
      expect(bToA.isPreceding, isTrue);
      expect(bToA.isFollowing, isFalse);
      expect(bToA.isDisconnected, isFalse);
    });

    test('unparented / disconnected namespace', () {
      final doc = XmlDocument.parse('<root/>');
      final root = doc.rootElement;
      final detachedNs = XmlNamespace('ns', 'http://example.com');

      final nsToRoot = detachedNs.compareDocumentPosition(root);
      expect(nsToRoot.isDisconnected, isTrue);
      expect(nsToRoot.isImplementationSpecific, isTrue);

      final rootToNs = root.compareDocumentPosition(detachedNs);
      expect(rootToNs.isDisconnected, isTrue);
      expect(rootToNs.isImplementationSpecific, isTrue);
    });

    test('identical namespace', () {
      final ns = XmlNamespace('ns', 'http://example.com');
      final result = ns.compareDocumentPosition(ns);
      expect(result.value, 0);
      expect(result.isSame, isTrue);
    });
  });

  group('isEqualNode', () {
    test('identical nodes', () {
      final el = XmlElement(const XmlName('a'));
      expect(el.isEqualNode(el), isTrue);
    });

    test('namespaces with same prefix and uri', () {
      final ns1 = XmlNamespace('p', 'http://example.com');
      final ns2 = XmlNamespace('p', 'http://example.com');
      expect(ns1.isEqualNode(ns2), isTrue);
      expect(ns2.isEqualNode(ns1), isTrue);
    });

    test('namespaces with different uri', () {
      final ns1 = XmlNamespace('p', 'http://example.com/1');
      final ns2 = XmlNamespace('p', 'http://example.com/2');
      expect(ns1.isEqualNode(ns2), isFalse);
      expect(ns2.isEqualNode(ns1), isFalse);
    });

    test('namespaces with different prefix', () {
      final ns1 = XmlNamespace('p1', 'http://example.com');
      final ns2 = XmlNamespace('p2', 'http://example.com');
      expect(ns1.isEqualNode(ns2), isFalse);
      expect(ns2.isEqualNode(ns1), isFalse);
    });

    test('namespace vs other node type', () {
      final ns = XmlNamespace('a', 'http://example.com');
      final el = XmlElement(const XmlName('a'));
      expect(ns.isEqualNode(el), isFalse);
      expect(el.isEqualNode(ns), isFalse);
    });
  });

  group('contains', () {
    test('ancestor and descendant', () {
      final doc = XmlDocument.parse('<root><parent><child/></parent></root>');
      final root = doc.rootElement;
      final parent = root.children.first;
      final child = parent.children.first;

      expect(root.contains(parent), isTrue);
      expect(root.contains(child), isTrue);
      expect(parent.contains(child), isTrue);

      expect(child.contains(parent), isFalse);
      expect(child.contains(root), isFalse);
      expect(parent.contains(root), isFalse);
    });

    test('element and attribute', () {
      final doc = XmlDocument.parse('<root attr="val"/>');
      final root = doc.rootElement;
      final attr = root.attributes.first;

      expect(root.contains(attr), isTrue);
      expect(attr.contains(root), isFalse);
    });

    test('element and namespace', () {
      final doc = XmlDocument.parse('<root xmlns:ns="http://example.com"/>');
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);

      expect(root.contains(ns), isTrue);
      expect(ns.contains(root), isFalse);
    });

    test('attribute and child', () {
      final doc = XmlDocument.parse('<root attr="val"><child/></root>');
      final root = doc.rootElement;
      final attr = root.attributes.first;
      final child = root.children.first;

      expect(attr.contains(child), isFalse);
      expect(child.contains(attr), isFalse);
    });

    test('namespace and child', () {
      final doc = XmlDocument.parse(
        '<root xmlns:ns="http://example.com"><child/></root>',
      );
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);
      final child = root.children.first;

      expect(ns.contains(child), isFalse);
      expect(child.contains(ns), isFalse);
    });

    test('disconnected nodes', () {
      final el1 = XmlElement(const XmlName('a'));
      final el2 = XmlElement(const XmlName('b'));
      expect(el1.contains(el2), isFalse);
      expect(el2.contains(el1), isFalse);
    });
  });
}
