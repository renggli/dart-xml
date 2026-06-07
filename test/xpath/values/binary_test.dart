import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:xml/src/xpath/values/binary.dart';

void main() {
  group('XPathBase64Binary', () {
    test('instantiation and list operations', () {
      final data = Uint8List.fromList([1, 2, 3]);
      final binary = XPathBase64Binary(data);
      expect(binary, [1, 2, 3]);
      expect(binary.length, 3);
      expect(binary[0], 1);
    });
  });

  group('XPathHexBinary', () {
    test('instantiation and list operations', () {
      final data = Uint8List.fromList([4, 5, 6]);
      final binary = XPathHexBinary(data);
      expect(binary, [4, 5, 6]);
      expect(binary.length, 3);
      expect(binary[1], 5);
    });
  });
}
