import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/qname.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  test('op:QName-equal', () {
    expect(opQNameEqual(XPathSequence.empty, XPathSequence.empty), isEmpty);
  });
}
