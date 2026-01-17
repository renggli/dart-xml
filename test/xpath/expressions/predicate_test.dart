import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  const input =
      '<?xml version="1.0"?>'
      '<r><e1 a="1"/><e2 a="2" b="3"/><e3 b="4"/></r>';
  final document = XmlDocument.parse(input);
  final current = document.rootElement;
  test('index', () {
    expectXPath(current, 'e1[1]', ['<e1 a="1"/>']);
    expectXPath(current, 'e1[2]', []);
  });
  test('expression', () {
    expectXPath(current, '*[@a]', ['<e1 a="1"/>', '<e2 a="2" b="3"/>']);
    expectXPath(current, '*[@b]', ['<e2 a="2" b="3"/>', '<e3 b="4"/>']);
  });
  test('multiple', () {
    expectXPath(current, '*[@a][@b]', ['<e2 a="2" b="3"/>']);
    expectXPath(current, '*[@a][1]', ['<e1 a="1"/>']);
    expectXPath(current, '*[1][@a]', ['<e1 a="1"/>']);
    expectXPath(current, '*[position()=1]', ['<e1 a="1"/>']);
    expectXPath(current, '*[last()=3]', [
      '<e1 a="1"/>',
      '<e2 a="2" b="3"/>',
      '<e3 b="4"/>',
    ]);
    expectXPath(current, '*[last()]', ['<e3 b="4"/>']);
  });
}
