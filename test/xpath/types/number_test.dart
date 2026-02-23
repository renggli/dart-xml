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
        expect(
          () => xsNumeric.cast('abc'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from abc to xs:numeric',
            ),
          ),
        );
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

  group('xsDecimal', () {
    test('name', () {
      expect(xsDecimal.name, 'xs:decimal');
    });
    test('matches', () {
      expect(xsDecimal.matches(1), isTrue);
      expect(xsDecimal.matches(1.5), isTrue);
      expect(xsDecimal.matches('1.5'), isFalse);
    });
    group('cast', () {
      test('from number', () {
        expect(xsDecimal.cast(123), 123);
        expect(xsDecimal.cast(123.45), 123.45);
      });
      test('from boolean', () {
        expect(xsDecimal.cast(true), 1);
        expect(xsDecimal.cast(false), 0);
      });
      test('from string', () {
        expect(xsDecimal.cast('123'), 123);
        expect(xsDecimal.cast('123.45'), 123.45);
        expect(xsDecimal.cast('.45'), 0.45);
        expect(xsDecimal.cast('123.'), 123.0);
        expect(
          () => xsDecimal.cast('1.2e3'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsDecimal.cast('INF'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsDecimal.cast('NaN'),
          throwsA(isXPathEvaluationException()),
        );
        expect(
          () => xsDecimal.cast('abc'),
          throwsA(isXPathEvaluationException()),
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
        expect(xsInteger.cast(123.6), 123);
        expect(xsInteger.cast(-123.6), -123);
      });
      test('from boolean', () {
        expect(xsInteger.cast(true), 1);
        expect(xsInteger.cast(false), 0);
      });
      test('from string', () {
        expect(xsInteger.cast('123'), 123);
        expect(
          () => xsInteger.cast('123.45'),
          throwsA(isXPathEvaluationException()),
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
        expect(
          () => xsDouble.cast('abc'),
          throwsA(
            isXPathEvaluationException(
              message: 'Unsupported cast from abc to xs:double',
            ),
          ),
        );
      });
    });
  });

  group('xsByte', () {
    test('name', () => expect(xsByte.name, 'xs:byte'));
    test('cast valid', () {
      expect(xsByte.cast(-128), -128);
      expect(xsByte.cast(0), 0);
      expect(xsByte.cast(127), 127);
    });
    test('cast out of range', () {
      expect(() => xsByte.cast(-129), throwsA(isXPathEvaluationException()));
      expect(() => xsByte.cast(128), throwsA(isXPathEvaluationException()));
    });
  });

  group('xsShort', () {
    test('name', () => expect(xsShort.name, 'xs:short'));
    test('cast valid', () {
      expect(xsShort.cast(-32768), -32768);
      expect(xsShort.cast(32767), 32767);
    });
    test('cast out of range', () {
      expect(() => xsShort.cast(-32769), throwsA(isXPathEvaluationException()));
      expect(() => xsShort.cast(32768), throwsA(isXPathEvaluationException()));
    });
  });

  group('xsInt', () {
    test('name', () => expect(xsInt.name, 'xs:int'));
    test('cast valid', () {
      expect(xsInt.cast(-2147483648), -2147483648);
      expect(xsInt.cast(2147483647), 2147483647);
    });
    test('cast out of range', () {
      expect(
        () => xsInt.cast(-2147483649),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xsInt.cast(2147483648),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsLong', () {
    test('name', () => expect(xsLong.name, 'xs:long'));
    test('cast valid', () {
      expect(xsLong.cast(0), 0);
      expect(xsLong.cast(-1), -1);
      // This should check for 9223372036854775807, but 9007199254740991 is the
      // largest we can represent in JavaScript.
      expect(xsLong.cast(9007199254740991), 9007199254740991);
    });
  });

  group('xsUnsignedByte', () {
    test('name', () => expect(xsUnsignedByte.name, 'xs:unsignedByte'));
    test('cast valid', () {
      expect(xsUnsignedByte.cast(0), 0);
      expect(xsUnsignedByte.cast(255), 255);
    });
    test('cast out of range', () {
      expect(
        () => xsUnsignedByte.cast(-1),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xsUnsignedByte.cast(256),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsUnsignedShort', () {
    test('name', () => expect(xsUnsignedShort.name, 'xs:unsignedShort'));
    test('cast valid', () {
      expect(xsUnsignedShort.cast(0), 0);
      expect(xsUnsignedShort.cast(65535), 65535);
    });
    test('cast out of range', () {
      expect(
        () => xsUnsignedShort.cast(-1),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xsUnsignedShort.cast(65536),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsUnsignedInt', () {
    test('name', () => expect(xsUnsignedInt.name, 'xs:unsignedInt'));
    test('cast valid', () {
      expect(xsUnsignedInt.cast(0), 0);
      expect(xsUnsignedInt.cast(4294967295), 4294967295);
    });
    test('cast out of range', () {
      expect(
        () => xsUnsignedInt.cast(-1),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xsUnsignedInt.cast(4294967296),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsUnsignedLong', () {
    test('name', () => expect(xsUnsignedLong.name, 'xs:unsignedLong'));
    test('cast valid', () {
      expect(xsUnsignedLong.cast(0), 0);
    });
    test('cast out of range', () {
      expect(
        () => xsUnsignedLong.cast(-1),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsNonNegativeInteger', () {
    test('name', () {
      expect(xsNonNegativeInteger.name, 'xs:nonNegativeInteger');
    });
    test('cast valid', () {
      expect(xsNonNegativeInteger.cast(0), 0);
      expect(xsNonNegativeInteger.cast(1), 1);
    });
    test('cast out of range', () {
      expect(
        () => xsNonNegativeInteger.cast(-1),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsNonPositiveInteger', () {
    test('name', () {
      expect(xsNonPositiveInteger.name, 'xs:nonPositiveInteger');
    });
    test('cast valid', () {
      expect(xsNonPositiveInteger.cast(0), 0);
      expect(xsNonPositiveInteger.cast(-1), -1);
    });
    test('cast out of range', () {
      expect(
        () => xsNonPositiveInteger.cast(1),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsPositiveInteger', () {
    test('name', () => expect(xsPositiveInteger.name, 'xs:positiveInteger'));
    test('cast valid', () {
      expect(xsPositiveInteger.cast(1), 1);
      expect(xsPositiveInteger.cast(100), 100);
    });
    test('cast out of range', () {
      expect(
        () => xsPositiveInteger.cast(0),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xsPositiveInteger.cast(-1),
        throwsA(isXPathEvaluationException()),
      );
    });
  });

  group('xsNegativeInteger', () {
    test('name', () => expect(xsNegativeInteger.name, 'xs:negativeInteger'));
    test('cast valid', () {
      expect(xsNegativeInteger.cast(-1), -1);
      expect(xsNegativeInteger.cast(-100), -100);
    });
    test('cast out of range', () {
      expect(
        () => xsNegativeInteger.cast(0),
        throwsA(isXPathEvaluationException()),
      );
      expect(
        () => xsNegativeInteger.cast(1),
        throwsA(isXPathEvaluationException()),
      );
    });
  });
}
