import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

void main() {
  group('XPathQName', () {
    test('construction and basic properties', () {
      final name = XmlName('ns:elem');
      final qname = XPathQName(name);
      check(qname.type).equals(xsQName);
      check(qname.value).equals(name);
      check(qname.stringValue).equals('ns:elem');
      check(qname.toString()).equals('ns:elem');
    });

    test('effectiveBooleanValue throws', () {
      final qname = XPathQName(XmlName('elem'));
      check(() => qname.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('equality and hashCode', () {
      final q1 = XPathQName(XmlName('p:elem', namespaceUri: 'ns'));
      final q2 = XPathQName(XmlName('p:elem', namespaceUri: 'ns'));
      final q3 = XPathQName(XmlName('p:elem', namespaceUri: 'other'));
      final q4 = XPathQName(XmlName('p:other', namespaceUri: 'ns'));

      check(q1).equals(q2);
      check(q1.hashCode).equals(q2.hashCode);
      check(q1 == q3).isFalse();
      check(q1 == q4).isFalse();
      check(q1 == Object()).isFalse();
    });
  });
}
