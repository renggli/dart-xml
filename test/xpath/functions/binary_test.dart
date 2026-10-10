import 'dart:convert';
import 'dart:typed_data';

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/binary.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

final context = const XPathConfiguration.raw().context(XmlDocument());

void main() {
  group('xs:base64Binary', () {
    test('converts string to bytes', () {
      const input = 'SGVsbG8gV29ybGQ=';
      final expected = Uint8List.fromList(utf8.encode('Hello World'));
      check(
        fnBase64BinaryFromString(context, [
          const XPathSequence.single(XPathString(input)),
        ]),
      ).isXPathSequence([expected]);
    });

    test('returns empty for empty sequence', () {
      check(fnBase64BinaryFromString(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });

  group('xs:hexBinary', () {
    test('converts string to bytes', () {
      const input = '48656C6C6F20576F726C64';
      final expected = Uint8List.fromList(utf8.encode('Hello World'));
      check(
        fnHexBinaryFromString(context, [
          const XPathSequence.single(XPathString(input)),
        ]),
      ).isXPathSequence([expected]);
    });

    test('returns empty for empty sequence', () {
      check(fnHexBinaryFromString(context, [XPathSequence.empty]))
          .isXPathSequence(isEmpty);
    });
  });
}
