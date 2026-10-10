import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../../utils/checks.dart';

void main() {
  group('XPathQName', () {
    test('construction and basic properties', () {
      const name = XmlName('elem', 'ns');
      const qname = XPathQName(name);
      check(qname.type).equals(xsQName);
      check(qname.value).equals(name);
      check(qname.stringValue).equals('ns:elem');
      check(qname.toString()).equals('ns:elem');
    });

    test('effectiveBooleanValue throws', () {
      const qname = XPathQName(XmlName('elem'));
      check(() => qname.effectiveBooleanValue)
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException());
    });

    test('equality and hashCode', () {
      const q1 = XPathQName(XmlName.qualified('p:elem', namespaceUri: 'ns'));
      const q2 = XPathQName(XmlName.qualified('p:elem', namespaceUri: 'ns'));
      const q3 = XPathQName(XmlName.qualified('p:elem', namespaceUri: 'other'));
      const q4 = XPathQName(XmlName.qualified('p:other', namespaceUri: 'ns'));

      check(q1).equals(q2);
      check(q1.hashCode).equals(q2.hashCode);
      check(q1 == q3).isFalse();
      check(q1 == q4).isFalse();
      check(q1 == Object()).isFalse();
    });
  });
}
