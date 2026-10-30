import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

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
      check(fnEnvironmentVariable(emptyContext, [seq('TEST_VAR')]))
          .isXPathSequence(isEmpty);
    });

    test('returns variable value when present', () {
      check(fnEnvironmentVariable(populatedContext, [seq('TEST_VAR')]))
          .isXPathSequence(['hello']);
      check(fnEnvironmentVariable(populatedContext, [seq('ANOTHER_VAR')]))
          .isXPathSequence(['world']);
    });
  });

  group('fn:available-environment-variables', () {
    test('returns empty sequence for empty environment', () {
      check(fnAvailableEnvironmentVariables(emptyContext, []))
          .isXPathSequence(isEmpty);
    });

    test('returns all available variable names', () {
      final result = fnAvailableEnvironmentVariables(populatedContext, []);
      check(result.length).equals(2);
      check(result.map(unwrapXPathItem).toSet())
          .deepEquals({'TEST_VAR', 'ANOTHER_VAR'});
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
      check(
        fnUnparsedText(textContext, [seq('http://example.com/dir/hello.txt')]),
      ).isXPathSequence(['hello world']);
    });

    test('resolves relative URI against baseUri', () {
      check(fnUnparsedText(textContext, [seq('hello.txt')]))
          .isXPathSequence(['hello world']);
    });

    test('throws when static base URI is undefined for relative URI', () {
      check(() => fnUnparsedText(emptyContext, [seq('hello.txt')]))
          .throws<XPathEvaluationException>();
    });

    test('throws when URI contains fragment identifier', () {
      check(() => fnUnparsedText(textContext, [seq('hello.txt#frag')]))
          .throws<XPathEvaluationException>();
    });

    test('throws when encoding is unsupported', () {
      check(
        () => fnUnparsedText(textContext, [seq('hello.txt'), seq('invalid')]),
      ).throws<XPathEvaluationException>();
    });

    test('throws when resource is not found', () {
      check(() => fnUnparsedText(textContext, [seq('missing.txt')]))
          .throws<XPathEvaluationException>();
    });

    test('throws when resource contains invalid XML characters', () {
      check(() => fnUnparsedText(textContext, [seq('invalid-chars.txt')]))
          .throws<XPathEvaluationException>();
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
      check(
        fnUnparsedTextLines(multiLineContext, [
          seq('http://example.com/lines.txt'),
        ]),
      ).isXPathSequence(['line1', 'line2', 'line3', 'line4']);
    });

    test('returns empty sequence for empty file', () {
      check(
        fnUnparsedTextLines(multiLineContext, [
          seq('http://example.com/empty.txt'),
        ]),
      ).isXPathSequence(isEmpty);
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
      check(
        fnUnparsedTextAvailable(availableContext, [
          seq('http://example.com/ok.txt'),
        ]),
      ).isXPathSequence([true]);
    });

    test('returns false when resource is missing', () {
      check(
        fnUnparsedTextAvailable(availableContext, [
          seq('http://example.com/missing.txt'),
        ]),
      ).isXPathSequence([false]);
    });

    test('returns false when resource contains invalid characters', () {
      check(
        fnUnparsedTextAvailable(availableContext, [
          seq('http://example.com/invalid.txt'),
        ]),
      ).isXPathSequence([false]);
    });
  });

  group('fn:resolve-uri', () {
    final baseContext = const XPathConfiguration.raw(
      baseUri: 'http://example.com/dir/',
    ).context(XPathSequence.empty);
    test('null relative returns empty', () {
      check(fnResolveUri(baseContext, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
    test('absolute URI returned as-is', () {
      check(fnResolveUri(baseContext, [seq('http://other.com/page')]))
          .isXPathSequence(['http://other.com/page']);
    });
    test('relative resolved against static base', () {
      check(fnResolveUri(baseContext, [seq('file.xml')]))
          .isXPathSequence(['http://example.com/dir/file.xml']);
    });
    test('relative resolved against explicit base', () {
      check(
        fnResolveUri(baseContext, [
          seq('file.xml'),
          seq('http://other.com/base/'),
        ]),
      ).isXPathSequence(['http://other.com/base/file.xml']);
    });
    test('throws when static base undefined', () {
      check(() => fnResolveUri(emptyContext, [seq('file.xml')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(message: 'Static base URI is undefined'),
          );
    });
    test('throws FORG0002 on invalid URI', () {
      check(() => fnResolveUri(baseContext, [seq('http://[invalid')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FORG0002),
          );
    });
  });

  group('fn:encode-for-uri', () {
    test('encodes special characters', () {
      check(fnEncodeForUri(emptyContext, [seq('hello world')]))
          .isXPathSequence(['hello%20world']);
    });
    test('null returns empty string', () {
      check(fnEncodeForUri(emptyContext, [XPathSequence.empty]))
          .isXPathSequence(['']);
    });
  });

  group('fn:iri-to-uri', () {
    test('encodes IRI', () {
      check(fnIriToUri(emptyContext, [seq('http://example.com/a b')]))
          .isXPathSequence(['http://example.com/a%20b']);
    });
    test('null returns empty string', () {
      check(fnIriToUri(emptyContext, [XPathSequence.empty]))
          .isXPathSequence(['']);
    });
  });

  group('fn:escape-html-uri', () {
    test('escapes HTML URI', () {
      check(fnEscapeHtmlUri(emptyContext, [seq('http://example.com/a b')]))
          .isXPathSequence(['http://example.com/a%20b']);
    });
    test('null returns empty string', () {
      check(fnEscapeHtmlUri(emptyContext, [XPathSequence.empty]))
          .isXPathSequence(['']);
    });
  });

  group('fn:unparsed-text null href', () {
    test('returns empty sequence', () {
      check(fnUnparsedText(emptyContext, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:unparsed-text-lines null href', () {
    test('returns empty sequence', () {
      check(fnUnparsedTextLines(emptyContext, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('fn:unparsed-text-available null href', () {
    test('returns false', () {
      check(fnUnparsedTextAvailable(emptyContext, [XPathSequence.empty]))
          .isXPathSequence([false]);
    });
  });

  group('fn:unparsed-text loader exception', () {
    final throwingContext = XPathConfiguration.raw(
      unparsedTextLoader: (uri, encoding) {
        throw StateError('loader failure');
      },
    ).context(XPathSequence.empty);
    test('wraps non-XPathEvaluationException', () {
      check(
        () => fnUnparsedText(throwingContext, [
          seq('http://example.com/any.txt'),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(message: 'Failed to load resource'),
      );
    });
  });

  group('fn:unparsed-text valid encoding', () {
    final encodingContext = XPathConfiguration.raw(
      unparsedTextLoader: (uri, encoding) => 'content',
    ).context(XPathSequence.empty);
    test('accepts utf-8 encoding', () {
      check(
        fnUnparsedText(encodingContext, [
          seq('http://example.com/file.txt'),
          seq('utf-8'),
        ]),
      ).isXPathSequence(['content']);
    });
  });

  group('fn:doc', () {
    test('null uri returns empty', () {
      check(fnDoc(emptyContext, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
    test('missing document throws', () {
      check(() => fnDoc(emptyContext, [seq('http://example.com/missing.xml')]))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'Document not found'));
    });
  });

  group('fn:doc-available', () {
    test('null uri returns false', () {
      check(fnDocAvailable(emptyContext, [XPathSequence.empty]))
          .isXPathSequence([false]);
    });
    test('missing document returns false', () {
      check(
        fnDocAvailable(emptyContext, [seq('http://example.com/missing.xml')]),
      ).isXPathSequence([false]);
    });
  });

  group('fn:collection', () {
    test('throws FODC0002 when no default collection', () {
      check(() => fnCollection(emptyContext, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FODC0002'));
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
      check(result.length).equals(2);
      check((result.first as XPathNode).node).equals(doc1);
      check((result.last as XPathNode).node).equals(doc2);
    });

    test('returns named collection', () {
      final doc = XmlDocument.parse('<c/>');
      final colContext = XPathConfiguration.raw(
        collections: {
          'http://example.com/c': [doc],
        },
      ).context(XPathSequence.empty);
      final result = fnCollection(colContext, [seq('http://example.com/c')]);
      check(result.length).equals(1);
      check((result.first as XPathNode).node).equals(doc);
    });

    test('throws FODC0002 for missing named collection', () {
      check(
            () =>
                fnCollection(emptyContext, [seq('http://example.com/missing')]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FODC0002'));
    });
  });

  group('fn:uri-collection', () {
    test('throws FODC0002 when no default collection', () {
      check(() => fnUriCollection(emptyContext, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FODC0002'));
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
      check(result).isXPathSequence(['http://example.com/d.xml']);
      check(result.first.type).equals(xsAnyURI);
    });

    test('returns relative URIs for collection documents', () {
      final doc = XmlDocument.parse('<d/>');
      final colContext = XPathConfiguration.raw(
        documents: {'d.xml': doc},
        collections: {
          '': [doc],
        },
      ).context(XPathSequence.empty);
      final result = fnUriCollection(colContext, []);
      check(result).isXPathSequence(['d.xml']);
      check(result.first.type).equals(xsAnyURI);
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

      check(fnUriCollection(colContext, [XPathSequence.empty]))
          .isXPathSequence(['http://example.com/d.xml']);
      check(fnUriCollection(colContext, [seq('')]))
          .isXPathSequence(['http://example.com/d.xml']);
      check(fnUriCollection(colContext, [seq('col')]))
          .isXPathSequence(['http://example.com/d.xml']);
      check(() => fnUriCollection(colContext, [seq('missing')]))
          .throws<XPathEvaluationException>()
          .which(
            isXPathEvaluationException(errorCode: XPathErrorCode.FODC0002),
          );
    });

    test('fn:doc invalid URI syntax and percent encoding errors FODC0005', () {
      void expectDocUriError(String uri) {
        check(() => fnDoc(emptyContext, [seq(uri)]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FODC0005),
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
      check(
        () => fnDoc(emptyContext, [seq('http://example.com/file%20name.xml')]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.FODC0002),
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

      check(fnCollection(colContext, [XPathSequence.empty])).length.equals(1);
      check(fnCollection(colContext, [seq('')])).length.equals(1);
      check(fnCollection(colContext, [seq('col')])).length.equals(1);
    });

    test(
      'unparsed-text errors on invalid URI, fragment, scheme, and null loader',
      () {
        check(() => fnUnparsedText(emptyContext, [seq('http://[invalid')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
            );
        check(
          () => fnUnparsedText(emptyContext, [
            seq('http://example.com/file#frag'),
          ]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
        );
        check(
          () => fnUnparsedText(emptyContext, [seq('ftp://example.com/file')]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
        );
        final invalidBaseContext = const XPathConfiguration.raw(
          baseUri: 'http://[',
        ).context(XPathSequence.empty);
        check(() => fnUnparsedText(invalidBaseContext, [seq('file.txt')]))
            .throws<XPathEvaluationException>()
            .which(
              isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1170),
            );
        check(
          () => fnUnparsedText(emptyContext, [seq('http://example.com/file')]),
        ).throws<XPathEvaluationException>().which(
          isXPathEvaluationException(errorCode: XPathErrorCode.FOUT1200),
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

      check(
        fnUnparsedTextLines(textContext, [
          seq('http://example.com/lines.txt'),
          seq('utf-8'),
        ]),
      ).isXPathSequence(['line1', 'line2', 'line3']);
      check(fnUnparsedTextLines(textContext, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
      check(
        fnUnparsedTextAvailable(textContext, [
          seq('http://example.com/lines.txt'),
          seq('utf-8'),
        ]),
      ).isXPathSequence([true]);
      check(
        fnUnparsedTextAvailable(textContext, [
          seq('http://example.com/missing.txt'),
          seq('utf-8'),
        ]),
      ).isXPathSequence([false]);
    });
  });
}
