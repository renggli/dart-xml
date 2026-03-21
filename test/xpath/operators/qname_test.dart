import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/qname.dart';
import 'package:xml/src/xpath/types/sequence.dart';

void main() {
  test('op:QName-equal', () {
    expect(opQNameEqual(XPathSequence.empty, XPathSequence.empty), isEmpty);
    expect(
      opQNameEqual(
        const XPathSequence.single('a'),
        const XPathSequence.single('a'),
      ),
      [true],
    );
    expect(
      opQNameEqual(
        const XPathSequence.single('a'),
        const XPathSequence.single('b'),
      ),
      [false],
    );
  });
}
