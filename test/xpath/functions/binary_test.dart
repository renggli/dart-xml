import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

final context = XPathContext.empty(XmlDocument());

void main() {
  group('xs:base64Binary', () {
    test('converts string to bytes', () {
      const input = 'SGVsbG8gV29ybGQ=';
      final expected = Uint8List.fromList(utf8.encode('Hello World'));
      expect(
        fnBase64BinaryFromString(context, [const XPathSequence.single(input)]),
        isXPathSequence([expected]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnBase64BinaryFromString(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });

  group('xs:hexBinary', () {
    test('converts string to bytes', () {
      const input = '48656C6C6F20576F726C64';
      final expected = Uint8List.fromList(utf8.encode('Hello World'));
      expect(
        fnHexBinaryFromString(context, [const XPathSequence.single(input)]),
        isXPathSequence([expected]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        fnHexBinaryFromString(context, [XPathSequence.empty]),
        isXPathSequence(isEmpty),
      );
    });
  });
}
