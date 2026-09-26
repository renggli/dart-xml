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

    test('throws for non-element node', () {
      expect(
        () => fnResolveQName(context, [seq('p:local'), seq(document)]),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPTY0004,
            message: contains('Expected element'),
          ),
        ),
      );
    });

    test('resolves with untypedAtomic', () {
      expect(
        fnResolveQName(context, [
          const XPathSequence.single(XPathUntypedAtomic('p:local')),
          seq(document.rootElement),
        ]),
        isXPathSequence([isA<XmlName>()]),
      );
    });
  });

  group('fn:QName', () {
    test('creates QName with prefix and uri', () {
      final result = fnQName(context, [seq('uri'), seq('p:local')]);
      expect(result, isXPathSequence([isA<XmlName>()]));
      final qname = result.single as XPathQName;
      expect(qname.value.prefix, 'p');
      expect(qname.value.local, 'local');
      expect(qname.value.namespaceUri, 'uri');
    });

    test('creates QName without prefix', () {
      final result = fnQName(context, [seq('uri'), seq('local')]);
      expect(result, isXPathSequence([isA<XmlName>()]));
      final qname = result.single as XPathQName;
      expect(qname.value.prefix, isNull);
      expect(qname.value.local, 'local');
      expect(qname.value.namespaceUri, 'uri');
    });

    test('creates QName with empty uri matching absent namespace', () {
      final result = fnQName(context, [seq(''), seq('local')]);
      final qname = result.single as XPathQName;
      expect(qname.value.namespaceUri, isEmpty);
      expect(qname == const XPathQName(XmlName.qualified('local')), isTrue);
    });

    test('throws FOCA0002 for invalid lexical QName', () {
      expect(
        () => fnQName(context, [seq('uri'), seq('1invalid')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [seq('uri'), seq(':local')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [seq('uri'), seq('prefix:')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [seq('uri'), seq('a:b:c')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [seq('uri'), seq('invalid name')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
    });

    test('throws FOCA0002 when prefix is given with empty or null uri', () {
      expect(
        () => fnQName(context, [XPathSequence.empty, seq('p:local')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [seq(''), seq('p:local')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
    });

    test('throws FOCA0002 for xmlns prefix or reserved xmlns uri', () {
      expect(
        () => fnQName(context, [seq('http://example.com'), seq('xmlns:foo')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [
          seq('http://www.w3.org/2000/xmlns/'),
          seq('foo'),
        ]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [
          seq('http://www.w3.org/XML/1998/namespace'),
          seq('foo'),
        ]),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.FOCA0002,
            message: contains('must have prefix "xml"'),
          ),
        ),
      );
    });

    test('throws XPTY0004 for sequence cardinality violations', () {
      expect(
        () => fnQName(context, [
          XPathSequence(const [XPathString('a'), XPathString('b')]),
          seq('c'),
        ]),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPTY0004,
            message: contains(
              'Argument 1 to fn:QName accepts at most one item',
            ),
          ),
        ),
      );
      expect(
        () => fnQName(context, [
          seq('a'),
          XPathSequence(const [XPathString('b'), XPathString('c')]),
        ]),
        throwsA(
          isXPathEvaluationException(
            errorCode: XPathErrorCode.XPTY0004,
            message: contains(
              'Argument 2 to fn:QName must be exactly one item',
            ),
          ),
        ),
      );
    });

    test('throws FOCA0002 for xml prefix mismatch', () {
      expect(
        () => fnQName(context, [seq('http://wrong.uri'), seq('xml:foo')]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
      expect(
        () => fnQName(context, [
          seq('http://www.w3.org/XML/1998/namespace'),
          seq('other:foo'),
        ]),
        throwsA(isXPathEvaluationException(message: contains('FOCA0002'))),
      );
    });

    test('throws XPTY0004 for non-string arguments', () {
      expect(
        () => fnQName(context, [
          XPathSequence.single(XPathInteger.fromInt(100)),
          seq('foo'),
        ]),
        throwsA(isXPathEvaluationException(message: contains('XPTY0004'))),
      );
      expect(
        () => fnQName(context, [
          seq('uri'),
          XPathSequence.single(XPathInteger.fromInt(100)),
        ]),
        throwsA(isXPathEvaluationException(message: contains('XPTY0004'))),
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
