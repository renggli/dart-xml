import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  final root = XmlDocument.parse('<root/>');
  void expectEval(String expr, Object expected) =>
      expectEvaluate(root, expr, expected);

  group('value comparison', () {
    group('eq', () {
      test('integers', () {
        expectEval('1 eq 1', [true]);
        expectEval('1 eq 2', [false]);
      });
      test('strings', () {
        expectEval('"a" eq "a"', [true]);
        expectEval('"a" eq "b"', [false]);
      });
      test('empty', () {
        expectEval('() eq 1', []);
        expectEval('1 eq ()', []);
      });
    });

    group('ne', () {
      test('integers', () {
        expectEval('1 ne 1', [false]);
        expectEval('1 ne 2', [true]);
      });
      test('strings', () {
        expectEval('"a" ne "a"', [false]);
        expectEval('"a" ne "b"', [true]);
      });
    });

    group('lt', () {
      test('integers', () {
        expectEval('1 lt 2', [true]);
        expectEval('2 lt 1', [false]);
        expectEval('1 lt 1', [false]);
      });
      test('strings', () {
        expectEval('"a" lt "b"', [true]);
        expectEval('"b" lt "a"', [false]);
      });
    });

    group('le', () {
      test('integers', () {
        expectEval('1 le 2', [true]);
        expectEval('2 le 1', [false]);
        expectEval('1 le 1', [true]);
      });
    });

    group('gt', () {
      test('integers', () {
        expectEval('2 gt 1', [true]);
        expectEval('1 gt 2', [false]);
        expectEval('1 gt 1', [false]);
      });
    });

    group('ge', () {
      test('integers', () {
        expectEval('2 ge 1', [true]);
        expectEval('1 ge 2', [false]);
        expectEval('1 ge 1', [true]);
      });
    });
  });
}
