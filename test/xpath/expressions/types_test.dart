import 'package:test/test.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

void main() {
  final xml = XmlDocument.parse('<root/>');

  group('instance of', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 instance of xs:integer', orderedEquals([true]));
      expectEvaluate(xml, '1 instance of xs:string', orderedEquals([false]));
      expectEvaluate(xml, "'foo' instance of xs:string", orderedEquals([true]));
      expectEvaluate(
        xml,
        "'foo' instance of xs:integer",
        orderedEquals([false]),
      );
    });

    test('sequence types', () {
      expectEvaluate(
        xml,
        '(1, 2) instance of xs:integer+',
        orderedEquals([true]),
      );
      expectEvaluate(xml, '() instance of xs:integer*', orderedEquals([true]));
      expectEvaluate(
        xml,
        '() instance of empty-sequence()',
        orderedEquals([true]),
      );
    });
  });

  group('castable as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' castable as xs:integer", orderedEquals([true]));
      expectEvaluate(
        xml,
        "'foo' castable as xs:integer",
        orderedEquals([false]),
      );
    });
  });

  group('cast as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' cast as xs:integer", orderedEquals([1]));
      expectEvaluate(xml, '1 cast as xs:string', orderedEquals(['1']));
    });
  });

  group('treat as', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 treat as xs:integer', orderedEquals([1]));
    });
  });
}
