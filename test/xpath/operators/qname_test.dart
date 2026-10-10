import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/operators/qname.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

void main() {
  group('opQNameEqual', () {
    test('empty sequences', () {
      check(opQNameEqual(XPathSequence.empty, XPathSequence.empty)).isEmpty();
    });
    test('equal QNames', () {
      check(
        opQNameEqual(
          const XPathSequence.single(XPathQName(XmlName('a'))),
          const XPathSequence.single(XPathQName(XmlName('a'))),
        ),
      ).equals(XPathSequence.trueSequence);
    });
    test('different QNames', () {
      check(
        opQNameEqual(
          const XPathSequence.single(XPathQName(XmlName('a'))),
          const XPathSequence.single(XPathQName(XmlName('b'))),
        ),
      ).equals(XPathSequence.falseSequence);
    });
  });
}
