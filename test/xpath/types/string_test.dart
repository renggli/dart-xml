import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/types/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');

  group('xsString', () {
    test('name', () {
      expect(xsString.name, 'xs:string');
    });
    test('matches', () {
      expect(xsString.matches('abc'), isTrue);
      expect(xsString.matches(123), isFalse);
    });
    group('cast', () {
      test('from string', () {
        expect(xsString.cast('abc'), 'abc');
        expect(xsString.cast(''), '');
      });
      test('from boolean', () {
        expect(xsString.cast(true), 'true');
        expect(xsString.cast(false), 'false');
      });
      test('from number', () {
        expect(xsString.cast(123), '123');
        expect(xsString.cast(123.45), '123.45');
        expect(xsString.cast(123.0), '123');
        expect(xsString.cast(0), '0');
        expect(xsString.cast(0.0), '0');
        expect(xsString.cast(-0.0), '0');
        expect(xsString.cast(double.nan), 'NaN');
        expect(xsString.cast(double.infinity), 'INF');
        expect(xsString.cast(double.negativeInfinity), '-INF');
      });
      test('from node', () {
        expect(xsString.cast(document), '123');
        expect(xsString.cast(document.rootElement), '123');
        expect(xsString.cast(document.findAllElements('b').first), '23');
        expect(xsString.cast(XmlText('foo')), 'foo');
        expect(xsString.cast(XmlCDATA('bar')), 'bar');
        expect(xsString.cast(XmlComment('baz')), 'baz');
        expect(xsString.cast(XmlProcessing('target', 'qux')), 'qux');
      });
      test('from sequence', () {
        expect(xsString.cast(XPathSequence.empty), '');
        expect(xsString.cast(const XPathSequence.single('abc')), 'abc');
        expect(xsString.cast(const XPathSequence.single(123)), '123');
        expect(
          () => xsString.cast(const XPathSequence(['a', 'b'])),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from (a, b) to xs:string',
            ),
          ),
        );
      });
      test('from duration', () {
        expect(xsString.cast(const Duration(days: 1, hours: 2)), 'P1DT2H');
        expect(xsString.cast(const Duration(hours: 2)), 'PT2H');
        expect(xsString.cast(const Duration(minutes: 30)), 'PT30M');
        expect(
          xsString.cast(const Duration(seconds: 45, milliseconds: 500)),
          'PT45.5S',
        );
        expect(xsString.cast(-const Duration(days: 1)), '-P1D');
      });
      test('from dateTime', () {
        expect(
          xsString.cast(DateTime.utc(2023, 10, 15, 14, 30, 0)),
          '2023-10-15T14:30:00.000Z',
        );
        expect(
          xsString.cast(DateTime.utc(2023, 1, 1, 0, 0, 0)),
          '2023-01-01T00:00:00.000Z',
        );
      });
      test('from binary', () {
        expect(
          xsString.cast(XPathBase64Binary(Uint8List.fromList([1, 2, 3, 4, 5]))),
          'AQIDBAU=',
        );
        expect(
          xsString.cast(XPathHexBinary(Uint8List.fromList([1, 2, 3, 4, 5]))),
          '0102030405',
        );
      });
      test('from qname', () {
        expect(xsString.cast(const XmlName.qualified('foo:bar')), 'foo:bar');
        expect(xsString.cast(const XmlName('baz')), 'baz');
      });
      test('from unsupported', () {
        expect(
          () => xsString.cast(Object()),
          throwsA(
            isXPathEvaluationException(
              message:
                  "Unsupported cast from Instance of 'Object' to xs:string",
            ),
          ),
        );
      });
    });
  });
}
