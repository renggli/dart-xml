import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext.empty(document);

void main() {
  group('fn:resolve-uri', () {
    test('resolves uri', () {
      expect(
        fnResolveUri(context, [
          const XPathSequence.single('foo'),
          const XPathSequence.single('http://example.com/'),
        ]),
        isXPathSequence(['http://example.com/foo']),
      );
    });

    test('throws for invalid base uri', () {
      expect(
        () => fnResolveUri(context, [
          const XPathSequence.single('foo'),
          const XPathSequence.single('::invalid::'),
        ]),
        throwsA(
          isXPathEvaluationException(
            message: 'Invalid URI: Invalid empty scheme',
          ),
        ),
      );
    });

    test('handles empty relative uri', () {
      expect(
        fnResolveUri(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });

    test('handles absolute relative without base', () {
      expect(
        fnResolveUri(context, [
          const XPathSequence.single('http://example.com'),
        ]),
        isXPathSequence(['http://example.com']),
      );
    });

    test('handles relative without base', () {
      expect(
        fnResolveUri(context, [const XPathSequence.single('foo')]),
        isXPathSequence(['foo']),
      );
    });
  });

  group('fn:encode-for-uri', () {
    test('encodes for uri', () {
      expect(
        fnEncodeForUri(context, [const XPathSequence.single(' ')]),
        isXPathSequence(['%20']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnEncodeForUri(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:iri-to-uri', () {
    test('converts iri to uri', () {
      expect(
        fnIriToUri(context, [const XPathSequence.single(' ')]),
        isXPathSequence(['%20']),
      );
    });

    test('handles empty sequence', () {
      expect(fnIriToUri(context, [XPathSequence.empty]), isXPathSequence(['']));
    });
  });

  group('fn:escape-html-uri', () {
    test('escapes html uri', () {
      expect(
        fnEscapeHtmlUri(context, [const XPathSequence.single(' ')]),
        isXPathSequence(['%20']),
      );
    });

    test('handles empty sequence', () {
      expect(
        fnEscapeHtmlUri(context, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:unparsed-text', () {
    test('throws unimplemented', () {
      expect(
        () => fnUnparsedText(context, [const XPathSequence.single('a')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('fn:unparsed-text-lines', () {
    test('throws unimplemented', () {
      expect(
        () => fnUnparsedTextLines(context, [const XPathSequence.single('a')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('fn:unparsed-text-available', () {
    test('throws unimplemented', () {
      expect(
        () =>
            fnUnparsedTextAvailable(context, [const XPathSequence.single('a')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('fn:environment-variable', () {
    test('throws unimplemented', () {
      expect(
        () => fnEnvironmentVariable(context, [const XPathSequence.single('a')]),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });

  group('fn:available-environment-variables', () {
    test('throws unimplemented', () {
      expect(
        () => fnAvailableEnvironmentVariables(context, []),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
