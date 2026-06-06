import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/uri.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

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
        fnEnvironmentVariable(emptyContext, [
          const XPathSequence.single('TEST_VAR'),
        ]),
        isXPathSequence(isEmpty),
      );
    });

    test('returns variable value when present', () {
      expect(
        fnEnvironmentVariable(populatedContext, [
          const XPathSequence.single('TEST_VAR'),
        ]),
        isXPathSequence(['hello']),
      );
      expect(
        fnEnvironmentVariable(populatedContext, [
          const XPathSequence.single('ANOTHER_VAR'),
        ]),
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
      expect(result.toSet(), equals({'TEST_VAR', 'ANOTHER_VAR'}));
    });
  });

  group('fn:unparsed-text', () {
    final textContext = XPathConfiguration.raw(
      baseUri: 'http://example.com/dir/',
      unparsedTextLoader: (uri, encoding) {
        if (uri == 'http://example.com/dir/hello.txt') {
          if (encoding == 'invalid') {
            throw XPathEvaluationException('Unsupported encoding: $encoding');
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
        fnUnparsedText(textContext, [
          const XPathSequence.single('http://example.com/dir/hello.txt'),
        ]),
        isXPathSequence(['hello world']),
      );
    });

    test('resolves relative URI against baseUri', () {
      expect(
        fnUnparsedText(textContext, [const XPathSequence.single('hello.txt')]),
        isXPathSequence(['hello world']),
      );
    });

    test('throws when static base URI is undefined for relative URI', () {
      expect(
        () => fnUnparsedText(emptyContext, [
          const XPathSequence.single('hello.txt'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when URI contains fragment identifier', () {
      expect(
        () => fnUnparsedText(textContext, [
          const XPathSequence.single('hello.txt#frag'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when encoding is unsupported', () {
      expect(
        () => fnUnparsedText(textContext, [
          const XPathSequence.single('hello.txt'),
          const XPathSequence.single('invalid'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when resource is not found', () {
      expect(
        () => fnUnparsedText(textContext, [
          const XPathSequence.single('missing.txt'),
        ]),
        throwsA(isA<XPathEvaluationException>()),
      );
    });

    test('throws when resource contains invalid XML characters', () {
      expect(
        () => fnUnparsedText(textContext, [
          const XPathSequence.single('invalid-chars.txt'),
        ]),
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
          const XPathSequence.single('http://example.com/lines.txt'),
        ]),
        isXPathSequence(['line1', 'line2', 'line3', 'line4']),
      );
    });

    test('returns empty sequence for empty file', () {
      expect(
        fnUnparsedTextLines(multiLineContext, [
          const XPathSequence.single('http://example.com/empty.txt'),
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
          const XPathSequence.single('http://example.com/ok.txt'),
        ]),
        isXPathSequence([true]),
      );
    });

    test('returns false when resource is missing', () {
      expect(
        fnUnparsedTextAvailable(availableContext, [
          const XPathSequence.single('http://example.com/missing.txt'),
        ]),
        isXPathSequence([false]),
      );
    });

    test('returns false when resource contains invalid characters', () {
      expect(
        fnUnparsedTextAvailable(availableContext, [
          const XPathSequence.single('http://example.com/invalid.txt'),
        ]),
        isXPathSequence([false]),
      );
    });
  });
}
