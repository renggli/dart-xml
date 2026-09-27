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
    expectXPath(current, 'e1[1.0]', ['<e1 a="1"/>']);
    expectXPath(current, 'e1[1.5]', []);
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
    expectXPath(current, 'e1[0]', []);
    expectXPath(current, 'e1[-1]', []);
    expectXPath(current, 'e1[1][2]', []);
  });

  group('Milestone 2: positional predicate early-exit and edge cases', () {
    final largeDoc = XmlDocument.build((builder) {
      builder.element(
        'root',
        nest: () {
          for (var i = 0; i < 1000; i++) {
            builder.element('item', attributes: {'id': '$i'});
          }
        },
      );
    });

    test('first index [1]', () {
      expectXPath(largeDoc, '/root/item[1]', ['<item id="0"/>']);
    });

    test('mid index [50]', () {
      expectXPath(largeDoc, '/root/item[50]', ['<item id="49"/>']);
    });

    test('last index [1000]', () {
      expectXPath(largeDoc, '/root/item[1000]', ['<item id="999"/>']);
    });

    test('out-of-bounds index [1001]', () {
      expectXPath(largeDoc, '/root/item[1001]', []);
    });

    test('zero index [0]', () {
      expectXPath(largeDoc, '/root/item[0]', []);
    });

    test('negative index [-5]', () {
      expectXPath(largeDoc, '/root/item[-5]', []);
    });

    test('fractional index [1.5]', () {
      expectXPath(largeDoc, '/root/item[1.5]', []);
    });

    test('integer float [1.0]', () {
      expectXPath(largeDoc, '/root/item[1.0]', ['<item id="0"/>']);
    });

    test('enormous BigInt index', () {
      expectXPath(largeDoc, '/root/item[999999999999999999999999999999]', []);
    });

    test('compound predicate with early-exit: item[@id = "500"][1]', () {
      expectXPath(largeDoc, '/root/item[@id = "500"][1]', ['<item id="500"/>']);
    });
  });
}
