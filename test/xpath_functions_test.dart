import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions31/sequence.dart';
import 'package:xml/src/xpath/values31/sequence.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  group('sequence', () {
    group('general functions and operators on sequences', () {
      test('fn:empty', () {
        expect(
          fnEmpty(context, [XPathSequence.empty]),
          XPathSequence.trueSequence,
        );
        expect(
          fnEmpty(context, [XPathSequence.single(1)]),
          XPathSequence.falseSequence,
        );
      });

      test('fn:exists', () {
        expect(
          fnExists(context, [XPathSequence.empty]),
          XPathSequence.falseSequence,
        );
        expect(
          fnExists(context, [XPathSequence.single(1)]),
          XPathSequence.trueSequence,
        );
      });

      test('fn:head', () {
        expect(fnHead(context, [XPathSequence.empty]), XPathSequence.empty);
        expect(
          fnHead(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(1),
        );
      });

      test('fn:tail', () {
        expect(fnTail(context, [XPathSequence.empty]), XPathSequence.empty);
        expect(
          fnTail(context, [
            const XPathSequence([1]),
          ]),
          XPathSequence.empty,
        );
        expect(
          fnTail(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence([2, 3]),
        );
      });

      test('fn:insert-before', () {
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(1),
            XPathSequence.single(0),
          ]),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(2),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 0, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(3),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 0]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(0),
            XPathSequence.single(0),
          ]),
          const XPathSequence([0, 1, 2]),
        );
        expect(
          fnInsertBefore(context, [
            const XPathSequence([1, 2]),
            XPathSequence.single(10),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 0]),
        );
      });

      test('fn:remove', () {
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(2),
          ]),
          const XPathSequence([1, 3]),
        );
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(0),
          ]),
          const XPathSequence([1, 2, 3]),
        );
        expect(
          fnRemove(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(4),
          ]),
          const XPathSequence([1, 2, 3]),
        );
      });

      test('fn:reverse', () {
        expect(
          fnReverse(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          const XPathSequence([3, 2, 1]),
        );
        expect(fnReverse(context, [XPathSequence.empty]), XPathSequence.empty);
      });

      test('fn:subsequence', () {
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(2),
          ]),
          const XPathSequence([2, 3, 4, 5]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(2),
            XPathSequence.single(2),
          ]),
          const XPathSequence([2, 3]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(0),
            XPathSequence.single(2),
          ]),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(-1),
            XPathSequence.single(3),
          ]),
          const XPathSequence([1]),
        );
        expect(
          fnSubsequence(context, [
            const XPathSequence([1, 2, 3, 4, 5]),
            XPathSequence.single(0.5),
            XPathSequence.single(1),
          ]),
          const XPathSequence([1]),
        );
      });

      test('fn:unordered', () {
        const seq = XPathSequence([1, 2, 3]);
        expect(fnUnordered(context, [seq]), seq);
      });
    });

    group('functions that compare values in sequences', () {
      test('fn:distinct-values', () {
        expect(
          fnDistinctValues(context, [
            const XPathSequence([1, 2, 1, 3, 2]),
          ]),
          const XPathSequence([1, 2, 3]),
        );
      });

      test('fn:index-of', () {
        expect(
          fnIndexOf(context, [
            const XPathSequence([1, 2, 1, 3]),
            XPathSequence.single(1),
          ]),
          const XPathSequence([1, 3]),
        );
        expect(
          fnIndexOf(context, [
            const XPathSequence([1, 2, 3]),
            XPathSequence.single(4),
          ]),
          XPathSequence.empty,
        );
      });

      test('fn:deep-equal', () {
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2]),
          ]),
          XPathSequence.trueSequence,
        );
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 3]),
          ]),
          XPathSequence.falseSequence,
        );
        expect(
          fnDeepEqual(context, [
            const XPathSequence([1, 2]),
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.falseSequence,
        );
      });
    });

    group('functions that test the cardinality of sequences', () {
      test('fn:zero-or-one', () {
        expect(
          fnZeroOrOne(context, [XPathSequence.empty]),
          XPathSequence.empty,
        );
        expect(
          fnZeroOrOne(context, [XPathSequence.single(1)]),
          XPathSequence.single(1),
        );
        expect(
          () => fnZeroOrOne(context, [
            const XPathSequence([1, 2]),
          ]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });

      test('fn:one-or-more', () {
        expect(
          fnOneOrMore(context, [XPathSequence.single(1)]),
          XPathSequence.single(1),
        );
        expect(
          fnOneOrMore(context, [
            const XPathSequence([1, 2]),
          ]),
          const XPathSequence([1, 2]),
        );
        expect(
          () => fnOneOrMore(context, [XPathSequence.empty]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });

      test('fn:exactly-one', () {
        expect(
          fnExactlyOne(context, [XPathSequence.single(1)]),
          XPathSequence.single(1),
        );
        expect(
          () => fnExactlyOne(context, [XPathSequence.empty]),
          throwsA(isA<XPathEvaluationException>()),
        );
        expect(
          () => fnExactlyOne(context, [
            const XPathSequence([1, 2]),
          ]),
          throwsA(isA<XPathEvaluationException>()),
        );
      });
    });

    group('aggregate functions', () {
      test('fn:count', () {
        expect(
          fnCount(context, [XPathSequence.empty]),
          XPathSequence.single(0),
        );
        expect(
          fnCount(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(3),
        );
      });

      test('fn:avg', () {
        expect(
          fnAvg(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(2.0),
        );
        expect(fnAvg(context, [XPathSequence.empty]), XPathSequence.empty);
      });

      test('fn:max', () {
        expect(
          fnMax(context, [
            const XPathSequence([1, 3, 2]),
          ]),
          XPathSequence.single(3),
        );
        expect(fnMax(context, [XPathSequence.empty]), XPathSequence.empty);
      });

      test('fn:min', () {
        expect(
          fnMin(context, [
            const XPathSequence([3, 1, 2]),
          ]),
          XPathSequence.single(1),
        );
        expect(fnMin(context, [XPathSequence.empty]), XPathSequence.empty);
      });

      test('fn:sum', () {
        expect(fnSum(context, [XPathSequence.empty]), XPathSequence.single(0));
        expect(
          fnSum(context, [XPathSequence.empty, XPathSequence.single(42)]),
          XPathSequence.single(42),
        );
        expect(
          fnSum(context, [
            const XPathSequence([1, 2, 3]),
          ]),
          XPathSequence.single(6.0),
        );
      });
    });

    group('functions on node identifiers', () {
      test('fn:id', () {
        expect(
          () => fnId(context, [XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:element-with-id', () {
        expect(
          () => fnElementWithId(context, [XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:idref', () {
        expect(
          () => fnIdref(context, [XPathSequence.single('id')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:generate-id', () {
        expect(
          () => fnGenerateId(context, [XPathSequence.empty]),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('functions giving access to external information', () {
      test('fn:doc', () {
        expect(
          () => fnDoc(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:doc-available', () {
        expect(
          () => fnDocAvailable(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:collection', () {
        expect(
          () => fnCollection(context, []),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:uri-collection', () {
        expect(
          () => fnUriCollection(context, []),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text', () {
        expect(
          () => fnUnparsedText(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-lines', () {
        expect(
          () => fnUnparsedTextLines(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:unparsed-text-available', () {
        expect(
          () => fnUnparsedTextAvailable(context, [XPathSequence.single('uri')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:environment-variable', () {
        expect(
          () => fnEnvironmentVariable(context, [XPathSequence.single('name')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:available-environment-variables', () {
        expect(
          () => fnAvailableEnvironmentVariables(context, []),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('parsing and serializing', () {
      test('fn:serialize', () {
        expect(
          () => fnSerialize(context, [XPathSequence.empty]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml', () {
        expect(
          () => fnParseXml(context, [XPathSequence.single('<r/>')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
      test('fn:parse-xml-fragment', () {
        expect(
          () => fnParseXmlFragment(context, [XPathSequence.single('<r/>')]),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });
  });
}
