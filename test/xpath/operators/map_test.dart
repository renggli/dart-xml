import 'package:test/test.dart';

import 'package:xml/src/xpath/operators/map.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xpath.dart';

void main() {
  test('op:same-key', () {
    expect(
      opSameKey(
        const XPathSequence.single('a'),
        const XPathSequence.single('a'),
      ),
      XPathSequence.trueSequence,
    );
    expect(
      opSameKey(
        const XPathSequence.single(double.nan),
        const XPathSequence.single(double.nan),
      ),
      XPathSequence.trueSequence,
    );
    expect(
      opSameKey(
        const XPathSequence.single('a'),
        const XPathSequence.single('b'),
      ),
      XPathSequence.falseSequence,
    );
  });
}
