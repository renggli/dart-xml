import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  group('compareDocumentPosition', () {
    test('identical node', () {
      final doc = XmlDocument.parse('<root><child/></root>');
      final root = doc.rootElement;
      final child = root.children.first;

      check(root.compareDocumentPosition(root).value).equals(0);
      check(child.compareDocumentPosition(child).value).equals(0);
    });

    test('ancestor / descendant', () {
      final doc = XmlDocument.parse('<root><child/></root>');
      final root = doc.rootElement;
      final child = root.children.first;

      // root contains child, child is contained by root
      // root.compareDocumentPosition(child) -> child is descendant of root (following, containedBy)
      final rootToChild = root.compareDocumentPosition(child);
      check(rootToChild.isContainedBy).isTrue();
      check(rootToChild.isContains).isFalse();
      check(rootToChild.isFollowing).isTrue();
      check(rootToChild.isPreceding).isFalse();
      check(rootToChild.isDisconnected).isFalse();
      check(rootToChild.isImplementationSpecific).isFalse();

      // child.compareDocumentPosition(root) -> root is ancestor of child (preceding, contains)
      final childToRoot = child.compareDocumentPosition(root);
      check(childToRoot.isContains).isTrue();
      check(childToRoot.isContainedBy).isFalse();
      check(childToRoot.isPreceding).isTrue();
      check(childToRoot.isFollowing).isFalse();
      check(childToRoot.isDisconnected).isFalse();
      check(childToRoot.isImplementationSpecific).isFalse();
    });

    test('siblings preceding / following', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final a = doc.rootElement.children[0];
      final b = doc.rootElement.children[1];
      final c = doc.rootElement.children[2];

      final aToB = a.compareDocumentPosition(b);
      check(aToB.isFollowing).isTrue();
      check(aToB.isPreceding).isFalse();

      final bToA = b.compareDocumentPosition(a);
      check(bToA.isPreceding).isTrue();
      check(bToA.isFollowing).isFalse();

      final aToC = a.compareDocumentPosition(c);
      check(aToC.isFollowing).isTrue();
      check(aToC.isPreceding).isFalse();
    });

    test('disconnected trees', () {
      final doc1 = XmlDocument.parse('<root1/>');
      final doc2 = XmlDocument.parse('<root2/>');
      final r1 = doc1.rootElement;
      final r2 = doc2.rootElement;

      final p1 = r1.compareDocumentPosition(r2);
      check(p1.isDisconnected).isTrue();
      check(p1.isImplementationSpecific).isTrue();
      check(p1.isPreceding || p1.isFollowing).isTrue();

      final p2 = r2.compareDocumentPosition(r1);
      check(p2.isDisconnected).isTrue();
      check(p2.isImplementationSpecific).isTrue();
      check(p2.isPreceding || p2.isFollowing).isTrue();
      check(p1.isPreceding).not((it) => it.equals(p2.isPreceding));
    });

    test('attribute and owner element', () {
      final doc = XmlDocument.parse('<root attr="val"/>');
      final root = doc.rootElement;
      final attr = root.attributes.first;

      // ownerElement contains attribute, attribute is contained by ownerElement
      // root.compareDocumentPosition(attr) -> attr is contained by root (following, containedBy)
      final rootToAttr = root.compareDocumentPosition(attr);
      check(rootToAttr.isContainedBy).isTrue();
      check(rootToAttr.isContains).isFalse();
      check(rootToAttr.isFollowing).isTrue();
      check(rootToAttr.isPreceding).isFalse();

      // attr.compareDocumentPosition(root) -> root is ancestor of attr (preceding, contains)
      final attrToRoot = attr.compareDocumentPosition(root);
      check(attrToRoot.isContains).isTrue();
      check(attrToRoot.isContainedBy).isFalse();
      check(attrToRoot.isPreceding).isTrue();
      check(attrToRoot.isFollowing).isFalse();
    });

    test('attribute and sibling child element under same parent', () {
      final doc = XmlDocument.parse('<root a="1"><child/></root>');
      final root = doc.rootElement;
      final a = root.attributes.first;
      final child = root.children.first;

      final aToChild = a.compareDocumentPosition(child);
      check(aToChild.isFollowing).isTrue();
      check(aToChild.isPreceding).isFalse();

      final childToA = child.compareDocumentPosition(a);
      check(childToA.isPreceding).isTrue();
      check(childToA.isFollowing).isFalse();
    });

    test('attribute and grandchild element under common parent', () {
      final doc = XmlDocument.parse(
        '<root a="1"><child><grandchild/></child></root>',
      );
      final root = doc.rootElement;
      final a = root.attributes.first;
      final grandchild = root.findAllElements('grandchild').single;

      final aToGrandchild = a.compareDocumentPosition(grandchild);
      check(aToGrandchild.isFollowing).isTrue();
      check(aToGrandchild.isPreceding).isFalse();

      final grandchildToA = grandchild.compareDocumentPosition(a);
      check(grandchildToA.isPreceding).isTrue();
      check(grandchildToA.isFollowing).isFalse();
    });

    test('attributes on same element', () {
      final doc = XmlDocument.parse('<root a="1" b="2" c="3"/>');
      final root = doc.rootElement;
      final a = root.attributes[0];
      final b = root.attributes[1];
      final c = root.attributes[2];

      final aToB = a.compareDocumentPosition(b);
      check(aToB.isImplementationSpecific).isTrue();
      check(aToB.isFollowing).isTrue();
      check(aToB.isPreceding).isFalse();

      final bToA = b.compareDocumentPosition(a);
      check(bToA.isImplementationSpecific).isTrue();
      check(bToA.isPreceding).isTrue();
      check(bToA.isFollowing).isFalse();

      final aToC = a.compareDocumentPosition(c);
      check(aToC.isImplementationSpecific).isTrue();
      check(aToC.isFollowing).isTrue();
      check(aToC.isPreceding).isFalse();
    });

    test('attributes on different elements', () {
      final doc = XmlDocument.parse('<root><el1 a="1"/><el2 b="2"/></root>');
      final el1 = doc.rootElement.children[0] as XmlElement;
      final el2 = doc.rootElement.children[1] as XmlElement;
      final a = el1.attributes.first;
      final b = el2.attributes.first;

      // a is under el1, b is under el2. Since el1 precedes el2, a should precede b.
      final aToB = a.compareDocumentPosition(b);
      check(aToB.isPreceding).isFalse();
      check(aToB.isFollowing).isTrue();
      check(aToB.isDisconnected).isFalse();
      check(aToB.isImplementationSpecific).isFalse();

      final bToA = b.compareDocumentPosition(a);
      check(bToA.isPreceding).isTrue();
      check(bToA.isFollowing).isFalse();
      check(bToA.isDisconnected).isFalse();
      check(bToA.isImplementationSpecific).isFalse();
    });

    test('namespace and owner element', () {
      final doc = XmlDocument.parse('<root xmlns:ns="http://example.com"/>');
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);

      // ownerElement contains namespace, namespace is contained by ownerElement
      final rootToNs = root.compareDocumentPosition(ns);
      check(rootToNs.isContainedBy).isTrue();
      check(rootToNs.isContains).isFalse();
      check(rootToNs.isFollowing).isTrue();
      check(rootToNs.isPreceding).isFalse();
      check(rootToNs.isDisconnected).isFalse();
      check(rootToNs.isImplementationSpecific).isFalse();

      final nsToRoot = ns.compareDocumentPosition(root);
      check(nsToRoot.isContains).isTrue();
      check(nsToRoot.isContainedBy).isFalse();
      check(nsToRoot.isPreceding).isTrue();
      check(nsToRoot.isFollowing).isFalse();
      check(nsToRoot.isDisconnected).isFalse();
      check(nsToRoot.isImplementationSpecific).isFalse();
    });

    test('namespaces on same element', () {
      final doc = XmlDocument.parse(
        '<root xmlns:a="http://a.com" xmlns:b="http://b.com"/>',
      );
      final root = doc.rootElement;
      final nsA = XmlNamespace('a', 'http://a.com')..attachParent(root);
      final nsB = XmlNamespace('b', 'http://b.com')..attachParent(root);

      final aToB = nsA.compareDocumentPosition(nsB);
      check(aToB.isImplementationSpecific).isTrue();
      check(aToB.isFollowing).isTrue();
      check(aToB.isPreceding).isFalse();

      final bToA = nsB.compareDocumentPosition(nsA);
      check(bToA.isImplementationSpecific).isTrue();
      check(bToA.isPreceding).isTrue();
      check(bToA.isFollowing).isFalse();
    });

    test('distinct namespace instances with same prefix on same element', () {
      final doc = XmlDocument.parse('<root xmlns:a="http://a.com"/>');
      final root = doc.rootElement;
      final ns1 = XmlNamespace('a', 'http://a.com')..attachParent(root);
      final ns2 = XmlNamespace('a', 'http://a.com')..attachParent(root);

      final p1 = ns1.compareDocumentPosition(ns2);
      final p2 = ns2.compareDocumentPosition(ns1);
      check(p1.isImplementationSpecific).isTrue();
      check(p2.isImplementationSpecific).isTrue();
      check(p1.isFollowing).not((it) => it.equals(p2.isFollowing));
      check(p1.isPreceding).not((it) => it.equals(p2.isPreceding));
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
      check(nsToAttr.isImplementationSpecific).isTrue();
      check(nsToAttr.isFollowing).isTrue();
      check(nsToAttr.isPreceding).isFalse();

      final attrToNs = attr.compareDocumentPosition(ns);
      check(attrToNs.isImplementationSpecific).isTrue();
      check(attrToNs.isPreceding).isTrue();
      check(attrToNs.isFollowing).isFalse();
    });

    test('attribute and child of same owner element', () {
      final doc = XmlDocument.parse('<root attr="val"><child/></root>');
      final root = doc.rootElement;
      final attr = root.attributes.first;
      final child = root.children.first;

      // Attributes precede child nodes of their owner element.
      final attrToChild = attr.compareDocumentPosition(child);
      check(attrToChild.isFollowing).isTrue();
      check(attrToChild.isPreceding).isFalse();
      check(attrToChild.isContains).isFalse();
      check(attrToChild.isContainedBy).isFalse();

      final childToAttr = child.compareDocumentPosition(attr);
      check(childToAttr.isPreceding).isTrue();
      check(childToAttr.isFollowing).isFalse();
      check(childToAttr.isContains).isFalse();
      check(childToAttr.isContainedBy).isFalse();
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
      check(nsToChild.isFollowing).isTrue();
      check(nsToChild.isPreceding).isFalse();
      check(nsToChild.isContains).isFalse();
      check(nsToChild.isContainedBy).isFalse();

      final childToNs = child.compareDocumentPosition(ns);
      check(childToNs.isPreceding).isTrue();
      check(childToNs.isFollowing).isFalse();
      check(childToNs.isContains).isFalse();
      check(childToNs.isContainedBy).isFalse();
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
      check(aToB.isPreceding).isFalse();
      check(aToB.isFollowing).isTrue();
      check(aToB.isDisconnected).isFalse();
      check(aToB.isImplementationSpecific).isFalse();

      final bToA = nsB.compareDocumentPosition(nsA);
      check(bToA.isPreceding).isTrue();
      check(bToA.isFollowing).isFalse();
      check(bToA.isDisconnected).isFalse();
      check(bToA.isImplementationSpecific).isFalse();
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
      check(aToB.isFollowing).isTrue();
      check(aToB.isPreceding).isFalse();
      check(aToB.isDisconnected).isFalse();

      final bToA = attrB.compareDocumentPosition(nsA);
      check(bToA.isPreceding).isTrue();
      check(bToA.isFollowing).isFalse();
      check(bToA.isDisconnected).isFalse();
    });

    test('unparented / disconnected namespace', () {
      final doc = XmlDocument.parse('<root/>');
      final root = doc.rootElement;
      final detachedNs = XmlNamespace('ns', 'http://example.com');

      final nsToRoot = detachedNs.compareDocumentPosition(root);
      check(nsToRoot.isDisconnected).isTrue();
      check(nsToRoot.isImplementationSpecific).isTrue();

      final rootToNs = root.compareDocumentPosition(detachedNs);
      check(rootToNs.isDisconnected).isTrue();
      check(rootToNs.isImplementationSpecific).isTrue();
    });

    test('identical namespace', () {
      final ns = XmlNamespace('ns', 'http://example.com');
      final result = ns.compareDocumentPosition(ns);
      check(result.value).equals(0);
      check(result.isSame).isTrue();
    });
  });

  group('isEqualNode', () {
    test('identical nodes', () {
      final el = XmlElement(const XmlName('a'));
      check(el.isEqualNode(el)).isTrue();
    });

    test('namespaces with same prefix and uri', () {
      final ns1 = XmlNamespace('p', 'http://example.com');
      final ns2 = XmlNamespace('p', 'http://example.com');
      check(ns1.isEqualNode(ns2)).isTrue();
      check(ns2.isEqualNode(ns1)).isTrue();
    });

    test('namespaces with different uri', () {
      final ns1 = XmlNamespace('p', 'http://example.com/1');
      final ns2 = XmlNamespace('p', 'http://example.com/2');
      check(ns1.isEqualNode(ns2)).isFalse();
      check(ns2.isEqualNode(ns1)).isFalse();
    });

    test('namespaces with different prefix', () {
      final ns1 = XmlNamespace('p1', 'http://example.com');
      final ns2 = XmlNamespace('p2', 'http://example.com');
      check(ns1.isEqualNode(ns2)).isFalse();
      check(ns2.isEqualNode(ns1)).isFalse();
    });

    test('namespace vs other node type', () {
      final ns = XmlNamespace('a', 'http://example.com');
      final el = XmlElement(const XmlName('a'));
      check(ns.isEqualNode(el)).isFalse();
      check(el.isEqualNode(ns)).isFalse();
    });
  });

  group('contains', () {
    test('ancestor and descendant', () {
      final doc = XmlDocument.parse('<root><parent><child/></parent></root>');
      final root = doc.rootElement;
      final parent = root.children.first;
      final child = parent.children.first;

      check(root.contains(parent)).isTrue();
      check(root.contains(child)).isTrue();
      check(parent.contains(child)).isTrue();

      check(child.contains(parent)).isFalse();
      check(child.contains(root)).isFalse();
      check(parent.contains(root)).isFalse();
    });

    test('element and attribute', () {
      final doc = XmlDocument.parse('<root attr="val"/>');
      final root = doc.rootElement;
      final attr = root.attributes.first;

      check(root.contains(attr)).isTrue();
      check(attr.contains(root)).isFalse();
    });

    test('element and namespace', () {
      final doc = XmlDocument.parse('<root xmlns:ns="http://example.com"/>');
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);

      check(root.contains(ns)).isTrue();
      check(ns.contains(root)).isFalse();
    });

    test('attribute and child', () {
      final doc = XmlDocument.parse('<root attr="val"><child/></root>');
      final root = doc.rootElement;
      final attr = root.attributes.first;
      final child = root.children.first;

      check(attr.contains(child)).isFalse();
      check(child.contains(attr)).isFalse();
    });

    test('namespace and child', () {
      final doc = XmlDocument.parse(
        '<root xmlns:ns="http://example.com"><child/></root>',
      );
      final root = doc.rootElement;
      final ns = XmlNamespace('ns', 'http://example.com')..attachParent(root);
      final child = root.children.first;

      check(ns.contains(child)).isFalse();
      check(child.contains(ns)).isFalse();
    });

    test('disconnected nodes', () {
      final el1 = XmlElement(const XmlName('a'));
      final el2 = XmlElement(const XmlName('b'));
      check(el1.contains(el2)).isFalse();
      check(el2.contains(el1)).isFalse();
    });
  });
}
