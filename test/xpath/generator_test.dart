import 'package:test/test.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../utils/examples.dart';

void main() {
  group('generator', () {
    for (final MapEntry(key: key, value: value) in allXml.entries) {
      test(key, () {
        final document = XmlDocument.parse(value);
        for (final node in [document, ...document.descendants]) {
          final expression = node.xpathGenerate(byId: 'id');
          final result = document.xpath(expression);
          expect(result.single, node, reason: expression);
        }
      });
    }
    test('element without siblings', () {
      final element = XmlElement.tag('node');
      final expression = element.xpathGenerate();
      expect(expression, 'node');
    });
  });
}
