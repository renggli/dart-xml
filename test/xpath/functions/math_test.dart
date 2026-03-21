import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/math.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';
import '../../utils/matchers.dart';

final context = XPathContext.empty(XmlDocument());
void main() {
  group('math:pi', () {
    test('returns pi', () {
      expect(mathPi(context, []), isXPathSequence([math.pi]));
    });
  });

  group('math:sqrt', () {
    test('returns square root', () {
      expect(
        mathSqrt(context, [const XPathSequence.single(4)]),
        isXPathSequence([2.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathSqrt(context, [XPathSequence.empty]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:exp', () {
    test('returns exp', () {
      expect(
        mathExp(context, [const XPathSequence.single(0)]),
        isXPathSequence([1.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(mathExp(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:exp10', () {
    test('returns exp10', () {
      expect(
        mathExp10(context, [const XPathSequence.single(0)]),
        isXPathSequence([1.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathExp10(context, [XPathSequence.empty]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:log', () {
    test('returns log', () {
      expect(
        mathLog(context, [const XPathSequence.single(math.e)]),
        isXPathSequence([1.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(mathLog(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:log10', () {
    test('returns log10', () {
      expect(
        mathLog10(context, [const XPathSequence.single(10)]),
        isXPathSequence([1.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathLog10(context, [XPathSequence.empty]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:pow', () {
    test('returns power', () {
      expect(
        mathPow(context, [
          const XPathSequence.single(2),
          const XPathSequence.single(3),
        ]),
        isXPathSequence([8.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathPow(context, [XPathSequence.empty, const XPathSequence.single(2)]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:sin', () {
    test('returns sine', () {
      expect(
        mathSin(context, [const XPathSequence.single(0)]),
        isXPathSequence([0.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(mathSin(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:cos', () {
    test('returns cosine', () {
      expect(
        mathCos(context, [const XPathSequence.single(0)]),
        isXPathSequence([1.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(mathCos(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:tan', () {
    test('returns tangent', () {
      expect(
        mathTan(context, [const XPathSequence.single(0)]),
        isXPathSequence([0.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(mathTan(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:asin', () {
    test('returns arcsine', () {
      expect(
        mathAsin(context, [const XPathSequence.single(0)]),
        isXPathSequence([0.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathAsin(context, [XPathSequence.empty]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:acos', () {
    test('returns arccosine', () {
      expect(
        mathAcos(context, [const XPathSequence.single(1)]),
        isXPathSequence([0.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathAcos(context, [XPathSequence.empty]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:atan', () {
    test('returns arctangent', () {
      expect(
        mathAtan(context, [const XPathSequence.single(0)]),
        isXPathSequence([0.0]),
      );
    });

    test('returns empty for empty sequence', () {
      expect(
        mathAtan(context, [XPathSequence.empty]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:atan2', () {
    test('returns arctangent2', () {
      expect(
        mathAtan2(context, [
          const XPathSequence.single(0),
          const XPathSequence.single(1),
        ]),
        isXPathSequence([0.0]),
      );
    });
  });
}
