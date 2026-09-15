import 'package:test/test.dart';
import 'package:xml/xml.dart';

import 'helpers.dart';

void main() {
  test('PetitParserExamples XPath expression', () {
    final document = XmlDocument.parse('''
<?xml version="1.0" encoding="UTF-8"?>
<store name="Tech Depot">
  <category name="Laptops">
    <item id="101" stock="15">
      <name>Pro Laptop 15"</name>
      <price currency="USD">1299.99</price>
    </item>
    <item id="102" stock="0">
      <name>Air Ultrabook 13"</name>
      <price currency="USD">999.00</price>
    </item>
  </category>
  <category name="Accessories">
    <item id="201" stock="42">
      <name>Wireless Mouse</name>
      <price currency="USD">29.99</price>
    </item>
  </category>
</store>
''');
    expectXPath(document, '//item[@stock > 0 and price < 1000]/name/text()', [
      'Wireless Mouse',
    ]);
  });
}
