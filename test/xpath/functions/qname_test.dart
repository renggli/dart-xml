import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/qname.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

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
      check(
        () => fnNamespaceUriForPrefix(context, [
          XPathSequence.empty,
          seq(document),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('returns uri for prefix', () {
      check(
        fnNamespaceUriForPrefix(context, [seq('p'), seq(document.rootElement)]),
      ).isXPathSequence(['uri']);
    });

    test('returns empty for unknown prefix', () {
      check(
        fnNamespaceUriForPrefix(context, [
          seq('unknown'),
          seq(document.rootElement),
        ]),
      ).isXPathSequence(isEmpty);
    });
  });

  group('fn:resolve-QName', () {
    test('resolves QName', () {
      check(
        fnResolveQName(context, [seq('p:local'), seq(document.rootElement)]),
      ).isXPathSequence([isA<XmlName>()]);
    });

    test('returns empty for empty sequence', () {
      check(
        fnResolveQName(context, [
          XPathSequence.empty,
          seq(document.rootElement),
        ]),
      ).isXPathSequence(isEmpty);
    });

    test('throws for unknown prefix', () {
      check(
        () => fnResolveQName(context, [
          seq('unknown:local'),
          seq(document.rootElement),
        ]),
      ).throws<XPathEvaluationException>().which(isXPathEvaluationException());
    });

    test('throws for non-element node', () {
      check(() => fnResolveQName(context, [seq('p:local'), seq(document)]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(
              errorCode: XPathErrorCode.XPTY0004,
              message: 'Expected element',
            ),
          );
    });

    test('resolves with untypedAtomic', () {
      check(
        fnResolveQName(context, [
          const XPathSequence.single(XPathUntypedAtomic('p:local')),
          seq(document.rootElement),
        ]),
      ).isXPathSequence([isA<XmlName>()]);
    });
  });

  group('fn:QName', () {
    test('creates QName with prefix and uri', () {
      final result = fnQName(context, [seq('uri'), seq('p:local')]);
      check(result).isXPathSequence([isA<XmlName>()]);
      final qname = result.single as XPathQName;
      check(qname.value.prefix).equals('p');
      check(qname.value.local).equals('local');
      check(qname.value.namespaceUri).equals('uri');
    });

    test('creates QName without prefix', () {
      final result = fnQName(context, [seq('uri'), seq('local')]);
      check(result).isXPathSequence([isA<XmlName>()]);
      final qname = result.single as XPathQName;
      check(qname.value.prefix).isNull();
      check(qname.value.local).equals('local');
      check(qname.value.namespaceUri).equals('uri');
    });

    test('creates QName with empty uri matching absent namespace', () {
      final result = fnQName(context, [seq(''), seq('local')]);
      final qname = result.single as XPathQName;
      check(qname.value.namespaceUri).equals('');
      check(qname == const XPathQName(XmlName.qualified('local'))).isTrue();
    });

    test('throws FOCA0002 for invalid lexical QName', () {
      check(() => fnQName(context, [seq('uri'), seq('1invalid')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(() => fnQName(context, [seq('uri'), seq(':local')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(() => fnQName(context, [seq('uri'), seq('prefix:')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(() => fnQName(context, [seq('uri'), seq('a:b:c')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(() => fnQName(context, [seq('uri'), seq('invalid name')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
    });

    test('throws FOCA0002 when prefix is given with empty or null uri', () {
      check(() => fnQName(context, [XPathSequence.empty, seq('p:local')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(() => fnQName(context, [seq(''), seq('p:local')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
    });

    test('throws FOCA0002 for xmlns prefix or reserved xmlns uri', () {
      check(
            () =>
                fnQName(context, [seq('http://example.com'), seq('xmlns:foo')]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(
            () => fnQName(context, [
              seq('http://www.w3.org/2000/xmlns/'),
              seq('foo'),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(
        () => fnQName(context, [
          seq('http://www.w3.org/XML/1998/namespace'),
          seq('foo'),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          errorCode: XPathErrorCode.FOCA0002,
          message: 'must have prefix "xml"',
        ),
      );
    });

    test('throws XPTY0004 for sequence cardinality violations', () {
      check(
        () => fnQName(context, [
          XPathSequence(const [XPathString('a'), XPathString('b')]),
          seq('c'),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          errorCode: XPathErrorCode.XPTY0004,
          message: 'Argument 1 to fn:QName accepts at most one item',
        ),
      );
      check(
        () => fnQName(context, [
          seq('a'),
          XPathSequence(const [XPathString('b'), XPathString('c')]),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(
          errorCode: XPathErrorCode.XPTY0004,
          message: 'Argument 2 to fn:QName must be exactly one item',
        ),
      );
    });

    test('throws FOCA0002 for xml prefix mismatch', () {
      check(() => fnQName(context, [seq('http://wrong.uri'), seq('xml:foo')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
      check(
            () => fnQName(context, [
              seq('http://www.w3.org/XML/1998/namespace'),
              seq('other:foo'),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOCA0002'));
    });

    test('throws XPTY0004 for non-string arguments', () {
      check(
            () => fnQName(context, [
              XPathSequence.single(XPathInteger.fromInt(100)),
              seq('foo'),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XPTY0004'));
      check(
            () => fnQName(context, [
              seq('uri'),
              XPathSequence.single(XPathInteger.fromInt(100)),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'XPTY0004'));
    });
  });

  group('fn:prefix-from-QName', () {
    test('returns prefix', () {
      const qname = XmlName.qualified('p:local');
      check(fnPrefixFromQName(context, [seq(qname)])).isXPathSequence(['p']);
    });

    test('returns empty for empty sequence', () {
      check(fnPrefixFromQName(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:local-name-from-qname', () {
    test('returns local name', () {
      const qname = XmlName.qualified('p:local');
      check(fnLocalNameFromQName(context, [seq(qname)]))
          .isXPathSequence(['local']);
    });

    test('returns empty for empty sequence', () {
      check(fnLocalNameFromQName(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:namespace-uri-from-QName', () {
    test('returns empty if no namespace', () {
      const qname = XmlName.qualified('p:local');
      check(fnNamespaceUriFromQName(context, [seq(qname)]))
          .isXPathSequence(isEmpty);
    });

    test('returns namespace uri', () {
      final qnameWithUri = XmlName.parse('p:local', namespaceUri: 'uri');
      check(fnNamespaceUriFromQName(context, [seq(qnameWithUri)]))
          .isXPathSequence(['uri']);
    });
  });

  group('fn:in-scope-prefixes', () {
    test('throws for non-element', () {
      check(() => fnInScopePrefixes(context, [seq(document)]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('returns in-scope prefixes', () {
      check(fnInScopePrefixes(context, [seq(document.rootElement)]))
          .isXPathSequence(['p', 'xml']);
    });
  });
}
