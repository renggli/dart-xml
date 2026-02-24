import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  const input =
      '<?xml version="1.0"?>'
      '<r><a0/><a1><b1/></a1><a2 b1="1" b2="2"><c1/><c2>'
      '<d1></d1></c2></a2><a3><b2/></a3><a4/></r>';
  final document = XmlDocument.parse(input);
  final current = document.findAllElements('a2').single;
  test('..', () {
    expectXPath(current, '..', [document.rootElement]);
  });
  test('.', () {
    expectXPath(current, '.', [
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
    ]);
  });
  test('/', () {
    final document = XmlDocument.parse('<r/>');
    expectXPath(document, '/', [document]);
  });
  test('/*', () {
    expectXPath(current, '/*', [document.rootElement]);
  });
  test('//*', () {
    expectXPath(current, '//*', [
      document.rootElement,
      '<a0/>',
      '<a1><b1/></a1>',
      '<b1/>',
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
      '<c1/>',
      '<c2><d1></d1></c2>',
      '<d1></d1>',
      '<a3><b2/></a3>',
      '<b2/>',
      '<a4/>',
    ]);
  });
  test('@*', () {
    expectXPath(current, '@*', ['b1="1"', 'b2="2"']);
  });
  test('ancestor::*', () {
    expectXPath(current, 'ancestor::*', [document.rootElement]);
    expectXPath(current.firstElementChild, 'ancestor::*', [
      document.rootElement,
      current,
    ], axisDirection: AxisDirection.reverse);
  });
  test('ancestor-or-self::*', () {
    expectXPath(current, 'ancestor-or-self::*', [
      document.rootElement,
      current,
    ], axisDirection: AxisDirection.reverse);
  });
  test('attribute::*', () {
    expectXPath(current, 'attribute::*', [
      'b1="1"',
      'b2="2"',
    ], axisDirection: AxisDirection.forward);
  });
  test('child::*', () {
    expectXPath(current, 'child::*', [
      '<c1/>',
      '<c2><d1></d1></c2>',
    ], axisDirection: AxisDirection.forward);
  });
  test('descendant::*', () {
    expectXPath(current, 'descendant::*', [
      '<c1/>',
      '<c2><d1></d1></c2>',
      '<d1></d1>',
    ], axisDirection: AxisDirection.forward);
  });
  test('descendant-or-self::*', () {
    expectXPath(current, 'descendant-or-self::*', [
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
      '<c1/>',
      '<c2><d1></d1></c2>',
      '<d1></d1>',
    ], axisDirection: AxisDirection.forward);
  });
  test('following::*', () {
    expectXPath(current, 'following::*', [
      '<a3><b2/></a3>',
      '<b2/>',
      '<a4/>',
    ], axisDirection: AxisDirection.forward);
  });
  test('following-sibling::*', () {
    expectXPath(current, 'following-sibling::*', [
      '<a3><b2/></a3>',
      '<a4/>',
    ], axisDirection: AxisDirection.forward);
  });
  test('parent::*', () {
    expectXPath(current, 'parent::*', [
      document.rootElement,
    ], axisDirection: AxisDirection.forward);
  });
  test('namespace::*', () {
    expectXPath(current, 'namespace::*', [
      'xmlns:xml="http://www.w3.org/XML/1998/namespace"',
    ], axisDirection: AxisDirection.forward);
  });
  test('preceding::*', () {
    expectXPath(current, 'preceding::*', [
      '<a0/>',
      '<a1><b1/></a1>',
      '<b1/>',
    ], axisDirection: AxisDirection.reverse);
  });
  test('preceding-sibling::*', () {
    expectXPath(current, 'preceding-sibling::*', [
      '<a0/>',
      '<a1><b1/></a1>',
    ], axisDirection: AxisDirection.reverse);
  });
  test('self::*', () {
    expectXPath(current, 'self::*', [
      '<a2 b1="1" b2="2"><c1/><c2><d1></d1></c2></a2>',
    ], axisDirection: AxisDirection.forward);
  });
}
