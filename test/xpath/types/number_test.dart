import 'package:test/test.dart';
import 'package:xml/src/xpath/types/number.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';

void main() {
  final document = XmlDocument.parse('<r><a>1</a><b>2<c>3</c></b></r>');
  final node = document.findAllElements('a').single;

  group('xsNumeric', () {
    test('name', () {
      expect(xsNumeric.name, 'xs:numeric');
    });
    test('matches', () {
      expect(xsNumeric.matches(1), isTrue);
      expect(xsNumeric.matches(1.5), isTrue);
      expect(xsNumeric.matches('1'), isFalse);
    });
    group('cast', () {
      test('from number', () {
        expect(xsNumeric.cast(123), 123);
        expect(xsNumeric.cast(123.45), 123.45);
      });
      test('from boolean', () {
        expect(xsNumeric.cast(true), 1);
        expect(xsNumeric.cast(false), 0);
      });
      test('from string', () {
        expect(xsNumeric.cast('123'), 123);
        expect(xsNumeric.cast('123.45'), 123.45);
        expect(xsNumeric.cast('INF'), double.infinity);
        expect(xsNumeric.cast('-INF'), double.negativeInfinity);
        expect(xsNumeric.cast('abc'), isNaN);
      });
      test('from node', () {
        expect(xsNumeric.cast(node), 1);
      });
      test('from sequence', () {
        expect(
          () => xsNumeric.cast(XPathSequence.empty),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from () to xs:numeric',
            ),
          ),
        );
        expect(xsNumeric.cast(const XPathSequence.single(123)), 123);
        expect(
          () => xsNumeric.cast(const XPathSequence([123, 456])),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from (123, 456) to xs:numeric',
            ),
          ),
        );
      });
    });
  });

  group('xsInteger', () {
    test('name', () {
      expect(xsInteger.name, 'xs:integer');
    });
    test('matches', () {
      expect(xsInteger.matches(1), isTrue);
      expect(xsInteger.matches(1.5), isFalse);
    });
    group('cast', () {
      test('from int', () {
        expect(xsInteger.cast(123), 123);
      });
      test('from double', () {
        expect(xsInteger.cast(123.45), 123); // rounds
        expect(xsInteger.cast(123.6), 124);
      });
      test('from boolean', () {
        expect(xsInteger.cast(true), 1);
        expect(xsInteger.cast(false), 0);
      });
      test('from string', () {
        expect(xsInteger.cast('123'), 123);
        // xsInteger casting from string might be more strict or default to num rule?
        // implementation: int.tryParse(value) then fallback to unsupported if null?
        // let's check implementation:
        // if (result != null) return result; else throw unsupported if not XmlNode/num/bool...
        // wait, implementation says: if (result != null) return result;
        // if not int, it falls through to throw?
        // Actually, looking at code:
        // } else if (value is String) { final result = int.tryParse(value); if (result != null) return result; }
        // It doesn't seem to parse doubles from strings and round them.
        expect(
          () => xsInteger.cast('123.45'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from 123.45 to xs:integer',
            ),
          ),
        );
      });
    });
  });

  group('xsDouble', () {
    test('name', () {
      expect(xsDouble.name, 'xs:double');
    });
    test('matches', () {
      expect(xsDouble.matches(1.5), isTrue);
      expect(xsDouble.matches('hello'), isFalse);
    });
    group('cast', () {
      test('from double', () {
        expect(xsDouble.cast(1.5), 1.5);
      });
      test('from int', () {
        expect(xsDouble.cast(1), 1.0);
      });
      test('from boolean', () {
        expect(xsDouble.cast(true), 1.0);
        expect(xsDouble.cast(false), 0.0);
      });
      test('from string', () {
        expect(xsDouble.cast('1.5'), 1.5);
        expect(xsDouble.cast('1'), 1.0);
        expect(xsDouble.cast('INF'), double.infinity);
        expect(xsDouble.cast('abc'), isNaN);
      });
    });
  });
}
