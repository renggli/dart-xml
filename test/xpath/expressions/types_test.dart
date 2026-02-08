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

    test('duration to numeric', () {
      expectEvaluate(
        xml,
        "xs:dayTimeDuration('PT1H') castable as xs:numeric",
        orderedEquals([true]),
      );
      expectEvaluate(
        xml,
        "xs:dayTimeDuration('PT1S') castable as xs:integer",
        orderedEquals([true]),
      );
    });

    test('date with timezone to dateTime', () {
      expectEvaluate(
        xml,
        "xs:date('1970-01-01Z') castable as xs:dateTime",
        orderedEquals([true]),
      );
      expectEvaluate(
        xml,
        "xs:date('2002-03-07-05:00') castable as xs:dateTime",
        orderedEquals([true]),
      );
    });

    test('time with timezone to dateTime', () {
      expectEvaluate(
        xml,
        "xs:time('00:00:00Z') castable as xs:dateTime",
        orderedEquals([true]),
      );
      expectEvaluate(
        xml,
        "xs:time('13:20:00+05:00') castable as xs:dateTime",
        orderedEquals([true]),
      );
    });
  });

  group('cast as', () {
    test('atomic types', () {
      expectEvaluate(xml, "'1' cast as xs:integer", orderedEquals([1]));
      expectEvaluate(xml, '1 cast as xs:string', orderedEquals(['1']));
    });

    test('duration to xs:numeric', () {
      // 1 second = 1,000,000 microseconds
      expectEvaluate(
        xml,
        "xs:numeric(xs:dayTimeDuration('PT1S'))",
        orderedEquals([1000000]),
      );
      // 1 hour = 3,600,000,000 microseconds
      expectEvaluate(
        xml,
        "xs:numeric(xs:dayTimeDuration('PT1H'))",
        orderedEquals([3600000000]),
      );
    });

    test('duration to xs:integer', () {
      expectEvaluate(
        xml,
        "xs:integer(xs:dayTimeDuration('PT1S'))",
        orderedEquals([1000000]),
      );
    });

    test('duration to xs:double', () {
      expectEvaluate(
        xml,
        "xs:double(xs:dayTimeDuration('PT1S'))",
        orderedEquals([1000000.0]),
      );
    });

    test('xs:date with timezone to xs:dateTime', () {
      // Date with Z timezone
      expectEvaluate(xml, "xs:dateTime(xs:date('1970-01-01Z'))", isNotEmpty);
      // Date with timezone offset
      expectEvaluate(
        xml,
        "xs:dateTime(xs:date('2002-03-07-05:00'))",
        isNotEmpty,
      );
    });

    test('xs:time with timezone to xs:dateTime', () {
      // Time with Z timezone
      expectEvaluate(xml, "xs:dateTime(xs:time('00:00:00Z'))", isNotEmpty);
      // Time with timezone offset
      expectEvaluate(xml, "xs:dateTime(xs:time('13:20:00+05:00'))", isNotEmpty);
    });
  });

  group('treat as', () {
    test('atomic types', () {
      expectEvaluate(xml, '1 treat as xs:integer', orderedEquals([1]));
    });
  });
}
