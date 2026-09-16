import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/qname.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r xmlns:p="uri"><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

XPathSequence seq(Object value) => XPathSequence.single(switch (value) {
  final XPathItem item => item,
  final XmlNode node => XPathNode(node),
  final XmlName name => XPathQName(name),
  final String str => XPathString(str),
  _ => throw ArgumentError.value(value),
});

void main() {
  group('fn:namespace-uri-for-prefix', () {
    test('throws for invalid element', () {
      expect(
        () => fnNamespaceUriForPrefix(context, [
          XPathSequence.empty,
          seq(document),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('returns uri for prefix', () {
      expect(
        fnNamespaceUriForPrefix(context, [seq('p'), seq(document.rootElement)]),
        isXPathSequence(['uri']),
      );
    });

    test('returns empty for unknown prefix', () {
      expect(
        fnNamespaceUriForPrefix(context, [
          seq('unknown'),
          seq(document.rootElement),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:resolve-QName', () {
    test('resolves QName', () {
      expect(
        fnResolveQName(context, [seq('p:local'), seq(document.rootElement)]),
        isXPathSequence([isA<XmlName>()]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnResolveQName(context, [
          XPathSequence.empty,
          seq(document.rootElement),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('throws for unknown prefix', () {
      expect(
        () => fnResolveQName(context, [
          seq('unknown:local'),
          seq(document.rootElement),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:QName', () {
    test('creates QName', () {
      expect(
        fnQName(context, [seq('uri'), seq('p:local')]),
        isXPathSequence([isA<XmlName>()]),
      );
    });
  });

  group('fn:prefix-from-QName', () {
    test('returns prefix', () {
      const qname = XmlName.qualified('p:local');
      expect(fnPrefixFromQName(context, [seq(qname)]), isXPathSequence(['p']));
    });

    test('returns empty for empty sequence', () {
      expect(
        fnPrefixFromQName(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:local-name-from-qname', () {
    test('returns local name', () {
      const qname = XmlName.qualified('p:local');
      expect(
        fnLocalNameFromQName(context, [seq(qname)]),
        isXPathSequence(['local']),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnLocalNameFromQName(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:namespace-uri-from-QName', () {
    test('returns empty if no namespace', () {
      const qname = XmlName.qualified('p:local');
      expect(
        fnNamespaceUriFromQName(context, [seq(qname)]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns namespace uri', () {
      final qnameWithUri = XmlName.parse('p:local', namespaceUri: 'uri');
      expect(
        fnNamespaceUriFromQName(context, [seq(qnameWithUri)]),
        isXPathSequence(['uri']),
      );
    });
  });

  group('fn:in-scope-prefixes', () {
    test('throws for non-element', () {
      expect(
        () => fnInScopePrefixes(context, [seq(document)]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('returns in-scope prefixes', () {
      expect(
        fnInScopePrefixes(context, [seq(document.rootElement)]),
        isXPathSequence(['p', 'xml']),
      );
    });
  });
}
