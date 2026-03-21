import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/qname.dart';

import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r xmlns:p="uri"><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:namespace-uri-for-prefix', () {
    test('throws for invalid element', () {
      expect(
        () => fnNamespaceUriForPrefix(context, [
          XPathSequence.empty,
          XPathSequence.single(document),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('returns uri for prefix', () {
      expect(
        fnNamespaceUriForPrefix(context, [
          const XPathSequence.single('p'),
          XPathSequence.single(document.rootElement),
        ]),
        isXPathSequence(['uri']),
      );
    });

    test('returns empty for unknown prefix', () {
      expect(
        fnNamespaceUriForPrefix(context, [
          const XPathSequence.single('unknown'),
          XPathSequence.single(document.rootElement),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:resolve-QName', () {
    test('resolves QName', () {
      expect(
        fnResolveQName(context, [
          const XPathSequence.single('p:local'),
          XPathSequence.single(document.rootElement),
        ]),
        isXPathSequence([isA<XmlName>()]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnResolveQName(context, [
          XPathSequence.empty,
          XPathSequence.single(document.rootElement),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('throws for unknown prefix', () {
      expect(
        () => fnResolveQName(context, [
          const XPathSequence.single('unknown:local'),
          XPathSequence.single(document.rootElement),
        ]),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('fn:QName', () {
    test('creates QName', () {
      expect(
        fnQName(context, [
          const XPathSequence.single('uri'),
          const XPathSequence.single('p:local'),
        ]),
        isXPathSequence([isA<XmlName>()]),
      );
    });
  });

  group('fn:prefix-from-QName', () {
    test('returns prefix', () {
      const qname = XmlName.qualified('p:local');
      expect(
        fnPrefixFromQName(context, [const XPathSequence.single(qname)]),
        isXPathSequence(['p']),
      );
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
        fnLocalNameFromQName(context, [const XPathSequence.single(qname)]),
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
        fnNamespaceUriFromQName(context, [const XPathSequence.single(qname)]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns namespace uri', () {
      final qnameWithUri = XmlName.parse('p:local', namespaceUri: 'uri');
      expect(
        fnNamespaceUriFromQName(context, [XPathSequence.single(qnameWithUri)]),
        isXPathSequence(['uri']),
      );
    });
  });

  group('fn:in-scope-prefixes', () {
    test('throws for non-element', () {
      expect(
        () => fnInScopePrefixes(context, [XPathSequence.single(document)]),
        throwsA(isXPathEvaluationException()),
      );
    });

    test('returns in-scope prefixes', () {
      expect(
        fnInScopePrefixes(context, [
          XPathSequence.single(document.rootElement),
        ]),
        isXPathSequence(['p', 'xml']),
      );
    });
  });
}
