import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/binary.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

final context = XPathContext(XmlDocument());
void main() {
  test('xs:base64Binary', () {
    const input = 'SGVsbG8gV29ybGQ=';
    final expected = Uint8List.fromList(utf8.encode('Hello World'));
    expect(
      fnBase64BinaryFromString(context, [const XPathSequence.single(input)]),
      [expected],
    );
    expect(fnBase64BinaryFromString(context, [XPathSequence.empty]), isEmpty);
  });
  test('xs:hexBinary', () {
    const input = '48656C6C6F20576F726C64';
    final expected = Uint8List.fromList(utf8.encode('Hello World'));
    expect(
      fnHexBinaryFromString(context, [const XPathSequence.single(input)]),
      [expected],
    );
    expect(fnHexBinaryFromString(context, [XPathSequence.empty]), isEmpty);
  });
}
