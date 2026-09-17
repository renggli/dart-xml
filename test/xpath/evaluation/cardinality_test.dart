import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/cardinality.dart';

void main() {
  group('XPathCardinality', () {
    test('accessors', () {
      expect('${XPathCardinality.exactlyOne}', '');
      expect('${XPathCardinality.zeroOrOne}', '?');
      expect('${XPathCardinality.oneOrMore}', '+');
      expect('${XPathCardinality.zeroOrMore}', '*');
    });
  });
}
