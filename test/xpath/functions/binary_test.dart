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
  test('xs:base64Binary', () {
    const input = 'SGVsbG8gV29ybGQ=';
    final expected = Uint8List.fromList(utf8.encode('Hello World'));
    expect(
      fnBase64BinaryFromString(context, [const XPathSequence.single(input)]),
      isXPathSequence([expected]),
    );
    expect(
      fnBase64BinaryFromString(context, [XPathSequence.empty]),
      isXPathSequence(isEmpty),
    );
  });
  test('xs:hexBinary', () {
    const input = '48656C6C6F20576F726C64';
    final expected = Uint8List.fromList(utf8.encode('Hello World'));
    expect(
      fnHexBinaryFromString(context, [const XPathSequence.single(input)]),
      isXPathSequence([expected]),
    );
    expect(
      fnHexBinaryFromString(context, [XPathSequence.empty]),
      isXPathSequence(isEmpty),
    );
  });
}
