import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../../utils/assertions.dart';

void main() {
  group('move from other parent', () {
    test('add moves node from other element', () {
      final doc = XmlDocument.parse('<root><a/><b/></root>');
      final root = doc.rootElement;
      final a = root.children[0] as XmlElement;
      final b = root.children[1] as XmlElement;

      final target = XmlElement(const XmlName.qualified('target'));
      target.children.add(a);

      expect(root.children, [b]);
      expect(target.children, [a]);
      expect(a.parent, target);
      assertDocumentTreeInvariants(doc);
    });

    test('add moves node from one document into another', () {
      final doc1 = XmlDocument.parse('<root><child/></root>');
      final doc2 = XmlDocument.parse('<root/>');
      final child = doc1.rootElement.firstChild!;

      doc2.rootElement.children.add(child);

      expect(doc1.rootElement.children, isEmpty);
      expect(doc2.rootElement.children.length, 1);
      expect(child.parent, doc2.rootElement);
      assertDocumentTreeInvariants(doc1);
      assertDocumentTreeInvariants(doc2);
    });

    test('addAll moves multiple nodes from different parents', () {
      final doc1 = XmlDocument.parse('<root><a/><b/></root>');
      final doc2 = XmlDocument.parse('<root><c/></root>');
      final a = doc1.rootElement.children[0];
      final b = doc1.rootElement.children[1];
      final c = doc2.rootElement.children[0];
      final target = XmlDocument.parse('<root/>');

      target.rootElement.children.addAll([a, b, c]);

      expect(doc1.rootElement.children, isEmpty);
      expect(doc2.rootElement.children, isEmpty);
      expect(target.rootElement.children, [a, b, c]);
      assertDocumentTreeInvariants(doc1);
      assertDocumentTreeInvariants(doc2);
      assertDocumentTreeInvariants(target);
    });

    test('[]= moves node from another element into slot', () {
      final doc1 = XmlDocument.parse('<root><a/></root>');
      final doc2 = XmlDocument.parse('<root><b/><c/></root>');
      final a = doc1.rootElement.children[0];
      final b = doc2.rootElement.children[0];
      final c = doc2.rootElement.children[1];

      // Replace <b> (slot 0) in doc2 with <a> from doc1.
      doc2.rootElement.children[0] = a;

      expect(doc1.rootElement.children, isEmpty);
      expect(doc2.rootElement.children, [a, c]);
      expect(a.parent, doc2.rootElement);
      expect(b.parent, isNull);
      assertDocumentTreeInvariants(doc1);
      assertDocumentTreeInvariants(doc2);
    });

    test('insert moves node and adjusts index for gap', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];
      final c = root.children[2];

      root.children.insert(1, c); // c is at index 2, moved to 1

      expect(root.children, [a, c, b]);
      assertDocumentTreeInvariants(doc);
    });

    test('insertAll with multiple same-list nodes adjusts index correctly', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/><d/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];
      final c = root.children[2];
      final d = root.children[3];

      // Move c (idx 2) and d (idx 3) to position 1.
      // After removing c and d, list is [a, b]; adjusted index = 1-0 = 1.
      root.children.insertAll(1, [c, d]);

      expect(root.children, [a, c, d, b]);
      assertDocumentTreeInvariants(doc);
    });

    test('add moves attribute from one element to another', () {
      final doc = XmlDocument.parse('<root><a x="1"/><b/></root>');
      final root = doc.rootElement;
      final a = root.children[0] as XmlElement;
      final b = root.children[1] as XmlElement;
      final attr = a.attributes.first;

      b.attributes.add(attr); // move attr from <a> to <b>

      expect(a.attributes, isEmpty);
      expect(b.attributes, [attr]);
      expect(attr.parent, b);
      assertDocumentTreeInvariants(doc);
    });
  });

  group('same-list move', () {
    test('add moves node to end of same list', () {
      final doc = XmlDocument.parse('<root><a/><b/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];

      root.children.add(a);

      expect(root.children, [b, a]);
      assertDocumentTreeInvariants(doc);
    });

    test('insert moves node forward', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];
      final c = root.children[2];

      // Move <a> (idx 0) to position 2; after removal adjusted index is 1.
      root.children.insert(2, a);

      expect(root.children, [b, a, c]);
      assertDocumentTreeInvariants(doc);
    });

    test('insert moves node backward', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];
      final c = root.children[2];

      root.children.insert(0, c);

      expect(root.children, [c, a, b]);
      assertDocumentTreeInvariants(doc);
    });

    test('[]= replacing same slot is a no-op', () {
      final doc = XmlDocument.parse('<root><a/></root>');
      final root = doc.rootElement;
      final a = root.children[0];

      root.children[0] = a;

      expect(root.children, [a]);
      assertDocumentTreeInvariants(doc);
    });

    test('[]= moves node from another slot, displaces original', () {
      final doc = XmlDocument.parse('<root><a/><b/></root>');
      final root = doc.rootElement;
      final b = root.children[1];

      root.children[0] = b; // <a> is removed, <b> moves to slot 0

      expect(root.children, [b]);
      assertDocumentTreeInvariants(doc);
    });

    test('replaceRange with node inside replaced range re-inserts it', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final root = doc.rootElement;
      final b = root.children[1];
      final c = root.children[2];

      // Replace [a, b] with [b]: b (index 1) is inside range [0,2).
      root.children.replaceRange(0, 2, [b]);

      expect(root.children, [b, c]);
      assertDocumentTreeInvariants(doc);
    });

    test('replaceRange with node before range adjusts start index', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final c = root.children[2];

      // Replace [b] (range 1..2) with [a]: a (index 0) is before range.
      // a is removed first → list becomes [b, c] → range [0,1) → b detached
      // → replaceRange(0, 1, [a]) → [a, c].
      root.children.replaceRange(1, 2, [a]);

      expect(root.children, [a, c]);
      assertDocumentTreeInvariants(doc);
    });

    test('replaceRange with node after range does not affect range bounds', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/></root>');
      final root = doc.rootElement;
      final b = root.children[1];
      final c = root.children[2];

      // Replace [a] (range 0..1) with [c]: c (index 2) is after range.
      // c removed first → [a, b] → range [0,1) → a detached
      // → replaceRange(0, 1, [c]) → [c, b].
      root.children.replaceRange(0, 1, [c]);

      expect(root.children, [c, b]);
      assertDocumentTreeInvariants(doc);
    });

    test(
      'replaceRange with nodes from before and after the range moved in',
      () {
        final doc = XmlDocument.parse('<root><a/><b/><c/><d/><e/></root>');
        final root = doc.rootElement;
        final a = root.children[0];
        final e = root.children[4];

        // Replace [b, c, d] (range 1..4) with [e, a].
        root.children.replaceRange(1, 4, [e, a]);

        expect(root.children, [e, a]);
        assertDocumentTreeInvariants(doc);
      },
    );

    test('replaceRange with inside, before, and after nodes moved in', () {
      final doc = XmlDocument.parse('<root><a/><b/><c/><d/><e/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];
      final c = root.children[2];
      final e = root.children[4];

      // Replace [c, d] (range 2..4) with [e, c, a].
      root.children.replaceRange(2, 4, [e, c, a]);

      expect(root.children, [b, e, c, a]);
      assertDocumentTreeInvariants(doc);
    });

    test(
      'insertAll with multiple nodes from before and after insertion point',
      () {
        final doc = XmlDocument.parse('<root><a/><b/><c/><d/><e/></root>');
        final root = doc.rootElement;
        final a = root.children[0];
        final b = root.children[1];
        final c = root.children[2];
        final d = root.children[3];
        final e = root.children[4];

        // insert at index 2 (before c). nodes to insert: e (after), a (before).
        root.children.insertAll(2, [e, a]);

        expect(root.children, [b, e, a, c, d]);
        assertDocumentTreeInvariants(doc);
      },
    );

    test(
      'replaceRange with repeated same-list elements deduplicates and adjusts',
      () {
        final doc = XmlDocument.parse('<root><a/><b/><c/><d/><e/></root>');
        final root = doc.rootElement;
        final a = root.children[0];
        final d = root.children[3];
        final e = root.children[4];

        // Replace [b, c] (range 1..3) with [e, a, e, a].
        root.children.replaceRange(1, 3, [e, a, e, a]);

        expect(root.children, [e, a, d]);
        assertDocumentTreeInvariants(doc);
      },
    );
  });

  group('deduplication', () {
    test('repeated node in addAll is inserted only once', () {
      final doc = XmlDocument.parse('<root/>');
      final root = doc.rootElement;
      final a = XmlElement(const XmlName.qualified('a'));

      root.children.addAll([a, a]);

      expect(root.children, [a]);
      expect(a.parent, root);
      assertDocumentTreeInvariants(doc);
    });

    test('repeated same-list node in addAll moves it only once', () {
      final doc = XmlDocument.parse('<root><a/><b/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];

      root.children.addAll([b, a, a]); // second <a> is duplicate

      expect(root.children, [b, a]);
      assertDocumentTreeInvariants(doc);
    });

    test(
      'same fragment used twice in addAll contributes children only once',
      () {
        final doc = XmlDocument.parse('<root/>');
        final root = doc.rootElement;
        final fragment = XmlDocumentFragment([
          XmlElement(const XmlName.qualified('a')),
        ]);

        root.children.addAll([fragment, fragment]);

        expect(root.children.length, 1);
        expect((root.children[0] as XmlElement).localName, 'a');
        assertDocumentTreeInvariants(doc);
      },
    );

    test('same fragment used in two separate add calls: second is empty', () {
      final doc = XmlDocument.parse('<root/>');
      final root = doc.rootElement;
      final fragment = XmlDocumentFragment([
        XmlElement(const XmlName.qualified('a')),
      ]);

      root.children.add(fragment);
      root.children.add(fragment); // now empty

      expect(root.children.length, 1);
      assertDocumentTreeInvariants(doc);
    });
  });

  group('atomicity', () {
    test('addAll rolls back on type error, no nodes moved', () {
      final doc = XmlDocument.parse('<root><a/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final wrongType = XmlAttribute(const XmlName.qualified('x'), 'y');

      expect(
        () => root.children.addAll([a, wrongType]),
        throwsA(isA<XmlNodeTypeException>()),
      );

      // <a> must NOT have been moved; list is unchanged.
      expect(root.children, [a]);
      expect(a.parent, root);
      assertDocumentTreeInvariants(doc);
    });

    test('insertAll rolls back on type error, no nodes moved', () {
      final doc = XmlDocument.parse('<root><a/></root>');
      final root = doc.rootElement;
      final wrongType = XmlAttribute(const XmlName.qualified('x'), 'y');

      expect(
        () => root.children.insertAll(0, [
          XmlElement(const XmlName.qualified('ok')),
          wrongType,
        ]),
        throwsA(isA<XmlNodeTypeException>()),
      );

      expect(root.children.length, 1);
      assertDocumentTreeInvariants(doc);
    });

    test('replaceRange rolls back on type error, original nodes intact', () {
      final doc = XmlDocument.parse('<root><a/><b/></root>');
      final root = doc.rootElement;
      final a = root.children[0];
      final b = root.children[1];
      final wrongType = XmlAttribute(const XmlName.qualified('x'), 'y');

      expect(
        () => root.children.replaceRange(0, 1, [wrongType]),
        throwsA(isA<XmlNodeTypeException>()),
      );

      expect(root.children, [a, b]);
      assertDocumentTreeInvariants(doc);
    });

    test(
      'fragment type error before insertion leaves source fragment intact',
      () {
        final doc = XmlDocument.parse('<root/>');
        final root = doc.rootElement;
        final fragment = XmlDocumentFragment([
          XmlElement(const XmlName.qualified('a')),
          XmlDeclaration(), // invalid for element children
        ]);

        expect(
          () => root.children.add(fragment),
          throwsA(isA<XmlNodeTypeException>()),
        );

        expect(root.children, isEmpty);
        // Fragment children must still be in the fragment.
        expect(fragment.children.length, 2);
        assertDocumentTreeInvariants(doc);
      },
    );
  });
}
