import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

void main() {
  final emptyContext = const XPathConfiguration.raw().context(
    XPathSequence.empty,
  );
  final populatedContext = const XPathConfiguration.raw(
    environment: {'TEST_VAR': 'hello', 'ANOTHER_VAR': 'world'},
  ).context(XPathSequence.empty);

  group('fn:environment-variable', () {
    test('returns empty sequence when variable is missing', () {
      expect(
        fnEnvironmentVariable(emptyContext, [seq('TEST_VAR')]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns variable value when present', () {
      expect(
        fnEnvironmentVariable(populatedContext, [seq('TEST_VAR')]),
        isXPathSequence(['hello']),
      );
      expect(
        fnEnvironmentVariable(populatedContext, [seq('ANOTHER_VAR')]),
        isXPathSequence(['world']),
      );
    });
  });

  group('fn:available-environment-variables', () {
    test('returns empty sequence for empty environment', () {
      expect(
        fnAvailableEnvironmentVariables(emptyContext, []),
        isXPathSequence(isEmpty),
      );
    });

    test('returns all available variable names', () {
      final result = fnAvailableEnvironmentVariables(populatedContext, []);
      expect(result.length, equals(2));
      expect(
        result.map(unwrapXPathItem).toSet(),
        equals({'TEST_VAR', 'ANOTHER_VAR'}),
      );
    });
  });

  group('fn:unparsed-text', () {
    final textContext = XPathConfiguration.raw(
      baseUri: 'http://example.com/dir/',
      unparsedTextLoader: (uri, encoding) {
        if (uri == 'http://example.com/dir/hello.txt') {
          if (encoding == 'invalid') {
            throw XPathEvaluationException(
              XPathErrorCode.FOUT1190,
              'Unsupported encoding: $encoding',
            );
          }
          return 'hello world';
        }
        if (uri == 'http://example.com/dir/invalid-chars.txt') {
          return 'hello \x00 world';
        }
        if (uri == 'http://example.com/dir/empty.txt') {
          return '';
        }
        return null;
      },
    ).context(XPathSequence.empty);

    test('returns unparsed text from absolute URI', () {
      expect(
        fnUnparsedText(textContext, [seq('http://example.com/dir/hello.txt')]),
        isXPathSequence(['hello world']),
      );
    });

    test('resolves relative URI against baseUri', () {
      expect(
        fnUnparsedText(textContext, [seq('hello.txt')]),
        isXPathSequence(['hello world']),
      );
    });

    test('throws when static base URI is undefined for relative URI', () {
      expect(
        () => fnUnparsedText(emptyContext, [seq('hello.txt')]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when URI contains fragment identifier', () {
      expect(
        () => fnUnparsedText(textContext, [seq('hello.txt#frag')]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when encoding is unsupported', () {
      expect(
        () => fnUnparsedText(textContext, [seq('hello.txt'), seq('invalid')]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when resource is not found', () {
      expect(
        () => fnUnparsedText(textContext, [seq('missing.txt')]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when resource contains invalid XML characters', () {
      expect(
        () => fnUnparsedText(textContext, [seq('invalid-chars.txt')]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('fn:unparsed-text-lines', () {
    final multiLineContext = XPathConfiguration.raw(
      unparsedTextLoader: (uri, encoding) {
        if (uri == 'http://example.com/lines.txt') {
          return 'line1\r\nline2\nline3\rline4\n';
        }
        if (uri == 'http://example.com/empty.txt') {
          return '';
        }
        return null;
      },
    ).context(XPathSequence.empty);

    test('splits text into lines correctly', () {
      expect(
        fnUnparsedTextLines(multiLineContext, [
          seq('http://example.com/lines.txt'),
        ]),
        isXPathSequence(['line1', 'line2', 'line3', 'line4']),
      );
    });

    test('returns empty sequence for empty file', () {
      expect(
        fnUnparsedTextLines(multiLineContext, [
          seq('http://example.com/empty.txt'),
        ]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:unparsed-text-available', () {
    final availableContext = XPathConfiguration.raw(
      unparsedTextLoader: (uri, encoding) {
        if (uri == 'http://example.com/ok.txt') {
          return 'ok';
        }
        if (uri == 'http://example.com/invalid.txt') {
          return 'invalid \x00 character';
        }
        return null;
      },
    ).context(XPathSequence.empty);

    test('returns true when resource is available and valid', () {
      expect(
        fnUnparsedTextAvailable(availableContext, [
          seq('http://example.com/ok.txt'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('returns false when resource is missing', () {
      expect(
        fnUnparsedTextAvailable(availableContext, [
          seq('http://example.com/missing.txt'),
        ]),
        isXPathSequence([false]),
      );
    });

    test('returns false when resource contains invalid characters', () {
      expect(
        fnUnparsedTextAvailable(availableContext, [
          seq('http://example.com/invalid.txt'),
        ]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:resolve-uri', () {
    final baseContext = const XPathConfiguration.raw(
      baseUri: 'http://example.com/dir/',
    ).context(XPathSequence.empty);
    test('null relative returns empty', () {
      expect(
        fnResolveUri(baseContext, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
    test('absolute URI returned as-is', () {
      expect(
        fnResolveUri(baseContext, [seq('http://other.com/page')]),
        isXPathSequence(['http://other.com/page']),
      );
    });
    test('relative resolved against static base', () {
      expect(
        fnResolveUri(baseContext, [seq('file.xml')]),
        isXPathSequence(['http://example.com/dir/file.xml']),
      );
    });
    test('relative resolved against explicit base', () {
      expect(
        fnResolveUri(baseContext, [
          seq('file.xml'),
          seq('http://other.com/base/'),
        ]),
        isXPathSequence(['http://other.com/base/file.xml']),
      );
    });
    test('throws when static base undefined', () {
      expect(
        () => fnResolveUri(emptyContext, [seq('file.xml')]),
        throwsA(
          isXPathEvaluationException(message: 'Static base URI is undefined'),
        ),
      );
    });
    test('throws FORG0002 on invalid URI', () {
      expect(
        () => fnResolveUri(baseContext, [seq('http://[invalid')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FORG0002)),
      );
    });
  });

  group('fn:encode-for-uri', () {
    test('encodes special characters', () {
      expect(
        fnEncodeForUri(emptyContext, [seq('hello world')]),
        isXPathSequence(['hello%20world']),
      );
    });
    test('null returns empty string', () {
      expect(
        fnEncodeForUri(emptyContext, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:iri-to-uri', () {
    test('encodes IRI', () {
      expect(
        fnIriToUri(emptyContext, [seq('http://example.com/a b')]),
        isXPathSequence(['http://example.com/a%20b']),
      );
    });
    test('null returns empty string', () {
      expect(
        fnIriToUri(emptyContext, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:escape-html-uri', () {
    test('escapes HTML URI', () {
      expect(
        fnEscapeHtmlUri(emptyContext, [seq('http://example.com/a b')]),
        isXPathSequence(['http://example.com/a%20b']),
      );
    });
    test('null returns empty string', () {
      expect(
        fnEscapeHtmlUri(emptyContext, [XPathSequence.empty]),
        isXPathSequence(['']),
      );
    });
  });

  group('fn:unparsed-text null href', () {
    test('returns empty sequence', () {
      expect(
        fnUnparsedText(emptyContext, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:unparsed-text-lines null href', () {
    test('returns empty sequence', () {
      expect(
        fnUnparsedTextLines(emptyContext, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('fn:unparsed-text-available null href', () {
    test('returns false', () {
      expect(
        fnUnparsedTextAvailable(emptyContext, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:unparsed-text loader exception', () {
    final throwingContext = XPathConfiguration.raw(
      unparsedTextLoader: (uri, encoding) {
        throw StateError('loader failure');
      },
    ).context(XPathSequence.empty);
    test('wraps non-XPathEvaluationException', () {
      expect(
        () => fnUnparsedText(throwingContext, [
          seq('http://example.com/any.txt'),
        ]),
        throwsA(
          isXPathEvaluationException(
            message: contains('Failed to load resource'),
          ),
        ),
      );
    });
  });

  group('fn:unparsed-text valid encoding', () {
    final encodingContext = XPathConfiguration.raw(
      unparsedTextLoader: (uri, encoding) => 'content',
    ).context(XPathSequence.empty);
    test('accepts utf-8 encoding', () {
      expect(
        fnUnparsedText(encodingContext, [
          seq('http://example.com/file.txt'),
          seq('utf-8'),
        ]),
        isXPathSequence(['content']),
      );
    });
  });

  group('fn:doc', () {
    test('null uri returns empty', () {
      expect(
        fnDoc(emptyContext, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
    test('missing document throws', () {
      expect(
        () => fnDoc(emptyContext, [seq('http://example.com/missing.xml')]),
        throwsA(
          isXPathEvaluationException(message: contains('Document not found')),
        ),
      );
    });
  });

  group('fn:doc-available', () {
    test('null uri returns false', () {
      expect(
        fnDocAvailable(emptyContext, [XPathSequence.empty]),
        isXPathSequence([false]),
      );
    });
    test('missing document returns false', () {
      expect(
        fnDocAvailable(emptyContext, [seq('http://example.com/missing.xml')]),
        isXPathSequence([false]),
      );
    });
  });

  group('fn:collection', () {
    test('throws FODC0002 when no default collection', () {
      expect(
        () => fnCollection(emptyContext, []),
        throwsA(isXPathEvaluationException(message: contains('FODC0002'))),
      );
    });

    test('returns default collection when configured', () {
      final doc1 = XmlDocument.parse('<a/>');
      final doc2 = XmlDocument.parse('<b/>');
      final colContext = XPathConfiguration.raw(
        collections: {
          '': [doc1, doc2],
        },
      ).context(XPathSequence.empty);
      final result = fnCollection(colContext, []);
      expect(result.length, equals(2));
      expect((result.first as XPathNode).node, equals(doc1));
      expect((result.last as XPathNode).node, equals(doc2));
    });

    test('returns named collection', () {
      final doc = XmlDocument.parse('<c/>');
      final colContext = XPathConfiguration.raw(
        collections: {
          'http://example.com/c': [doc],
        },
      ).context(XPathSequence.empty);
      final result = fnCollection(colContext, [seq('http://example.com/c')]);
      expect(result.length, equals(1));
      expect((result.first as XPathNode).node, equals(doc));
    });

    test('throws FODC0002 for missing named collection', () {
      expect(
        () => fnCollection(emptyContext, [seq('http://example.com/missing')]),
        throwsA(isXPathEvaluationException(message: contains('FODC0002'))),
      );
    });
  });

  group('fn:uri-collection', () {
    test('throws FODC0002 when no default collection', () {
      expect(
        () => fnUriCollection(emptyContext, []),
        throwsA(isXPathEvaluationException(message: contains('FODC0002'))),
      );
    });

    test('returns URIs for collection documents', () {
      final doc = XmlDocument.parse('<d/>');
      final colContext = XPathConfiguration.raw(
        documents: {'http://example.com/d.xml': doc},
        collections: {
          '': [doc],
        },
      ).context(XPathSequence.empty);
      final result = fnUriCollection(colContext, []);
      expect(result, isXPathSequence(['http://example.com/d.xml']));
      expect(result.first.type, equals(xsAnyURI));
    });

    test('1-argument uri-collection with empty or resolved URI', () {
      final doc = XmlDocument.parse('<d/>');
      final colContext = XPathConfiguration.raw(
        baseUri: 'http://example.com/dir/',
        documents: {'http://example.com/d.xml': doc},
        collections: {
          '': [doc],
          'http://example.com/dir/col': [doc],
        },
      ).context(XPathSequence.empty);

      expect(
        fnUriCollection(colContext, [XPathSequence.empty]),
        isXPathSequence(['http://example.com/d.xml']),
      );
      expect(
        fnUriCollection(colContext, [seq('')]),
        isXPathSequence(['http://example.com/d.xml']),
      );
      expect(
        fnUriCollection(colContext, [seq('col')]),
        isXPathSequence(['http://example.com/d.xml']),
      );
      expect(
        () => fnUriCollection(colContext, [seq('missing')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FODC0002)),
      );
    });

    test('fn:doc invalid URI syntax and percent encoding errors FODC0005', () {
      void expectDocUriError(String uri) {
        expect(
          () => fnDoc(emptyContext, [seq(uri)]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FODC0005),
          ),
        );
      }

      expectDocUriError('http://example.com/bad path');
      expectDocUriError(r'http://example.com\bad');
      expectDocUriError('http://example.com/<tag>');
      expectDocUriError('http://example.com/test%');
      expectDocUriError('http://example.com/test%2');
      expectDocUriError('http://example.com/test%2G');
      expectDocUriError(':/invalid');
      expectDocUriError('http://[');
      expect(
        () => fnDoc(emptyContext, [seq('http://example.com/file%20name.xml')]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.FODC0002)),
      );
    });

    test('fn:collection 1-argument with empty or relative URI', () {
      final doc = XmlDocument.parse('<d/>');
      final colContext = XPathConfiguration.raw(
        baseUri: 'http://example.com/dir/',
        documents: {'http://example.com/d.xml': doc},
        collections: {
          '': [doc],
          'http://example.com/dir/col': [doc],
        },
      ).context(XPathSequence.empty);

      expect(fnCollection(colContext, [XPathSequence.empty]), hasLength(1));
      expect(fnCollection(colContext, [seq('')]), hasLength(1));
      expect(fnCollection(colContext, [seq('col')]), hasLength(1));
    });

    test(
      'unparsed-text errors on invalid URI, fragment, scheme, and null loader',
      () {
        expect(
          () => fnUnparsedText(emptyContext, [seq('http://[invalid')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
          ),
        );
        expect(
          () => fnUnparsedText(emptyContext, [
            seq('http://example.com/file#frag'),
          ]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
          ),
        );
        expect(
          () => fnUnparsedText(emptyContext, [seq('ftp://example.com/file')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
          ),
        );
        final invalidBaseContext = const XPathConfiguration.raw(
          baseUri: 'http://[',
        ).context(XPathSequence.empty);
        expect(
          () => fnUnparsedText(invalidBaseContext, [seq('file.txt')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
          ),
        );
        expect(
          () => fnUnparsedText(emptyContext, [seq('http://example.com/file')]),
          throwsA(
            isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1200),
          ),
        );
      },
    );

    test('2-argument fn:unparsed-text-lines and unparsed-text-available', () {
      final textContext = XPathConfiguration.raw(
        baseUri: 'http://example.com/',
        unparsedTextLoader: (uri, encoding) {
          if (uri == 'http://example.com/lines.txt') {
            return 'line1\r\nline2\nline3\n';
          }
          return null;
        },
      ).context(XPathSequence.empty);

      expect(
        fnUnparsedTextLines(textContext, [
          seq('http://example.com/lines.txt'),
          seq('utf-8'),
        ]),
        isXPathSequence(['line1', 'line2', 'line3']),
      );
      expect(
        fnUnparsedTextLines(textContext, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
      expect(
        fnUnparsedTextAvailable(textContext, [
          seq('http://example.com/lines.txt'),
          seq('utf-8'),
        ]),
        isXPathSequence([true]),
      );
      expect(
        fnUnparsedTextAvailable(textContext, [
          seq('http://example.com/missing.txt'),
          seq('utf-8'),
        ]),
        isXPathSequence([false]),
      );
    });
  });
}
