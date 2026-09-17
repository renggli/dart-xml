import 'package:test/test.dart';
import 'package:xml/src/xpath/xdm/atomic/qname.dart';
import 'package:xml/src/xpath/xdm/types.dart';
import 'package:xml/xml.dart';

import '../../../utils/matchers.dart';

void main() {
  group('XPathQName', () {
    test('construction and basic properties', () {
      const name = XmlName('elem', 'ns');
      const qname = XPathQName(name);
      expect(qname.type, equals(xsQName));
      expect(qname.value, equals(name));
      expect(qname.stringValue, equals('ns:elem'));
      expect(qname.toString(), equals('ns:elem'));
    });

    test('effectiveBooleanValue throws', () {
      const qname = XPathQName(XmlName('elem'));
      expect(
        () => qname.effectiveBooleanValue,
        throwsA(isXPathEvaluationException()),
      );
    });

    test('equality and hashCode', () {
      const q1 = XPathQName(XmlName.qualified('p:elem', namespaceUri: 'ns'));
      const q2 = XPathQName(XmlName.qualified('p:elem', namespaceUri: 'ns'));
      const q3 = XPathQName(XmlName.qualified('p:elem', namespaceUri: 'other'));
      const q4 = XPathQName(XmlName.qualified('p:other', namespaceUri: 'ns'));

      expect(q1, equals(q2));
      expect(q1.hashCode, equals(q2.hashCode));
      expect(q1 == q3, isFalse);
      expect(q1 == q4, isFalse);
      expect(q1 == Object(), isFalse);
    });
  });
}
