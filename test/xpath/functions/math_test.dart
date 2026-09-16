import 'dart:math' as math;

import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/functions/math.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/xml.dart';

import '../../utils/matchers.dart';
import '../helpers.dart';

final context = const XPathConfiguration.raw().context(XmlDocument());
void main() {
  group('math:pi', () {
    test('returns pi', () {
      expect(mathPi(context, []), isXPathSequence([math.pi]));
    });
  });

  group('math:sqrt', () {
    test('returns square root', () {
      expect(mathSqrt(context, [seq(4)]), isXPathSequence([2.0]));
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
      expect(mathExp(context, [seq(0)]), isXPathSequence([1.0]));
    });

    test('returns empty for empty sequence', () {
      expect(mathExp(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:exp10', () {
    test('returns exp10', () {
      expect(mathExp10(context, [seq(0)]), isXPathSequence([1.0]));
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
      expect(mathLog(context, [seq(math.e)]), isXPathSequence([1.0]));
    });

    test('returns empty for empty sequence', () {
      expect(mathLog(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:log10', () {
    test('returns log10', () {
      expect(mathLog10(context, [seq(10)]), isXPathSequence([1.0]));
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
      expect(mathPow(context, [seq(2), seq(3)]), isXPathSequence([8.0]));
    });

    test('returns empty for empty sequence', () {
      expect(
        mathPow(context, [XPathSequence.empty, seq(2)]),
        isXPathSequence(<num>[]),
      );
    });
  });

  group('math:sin', () {
    test('returns sine', () {
      expect(mathSin(context, [seq(0)]), isXPathSequence([0.0]));
    });

    test('returns empty for empty sequence', () {
      expect(mathSin(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:cos', () {
    test('returns cosine', () {
      expect(mathCos(context, [seq(0)]), isXPathSequence([1.0]));
    });

    test('returns empty for empty sequence', () {
      expect(mathCos(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:tan', () {
    test('returns tangent', () {
      expect(mathTan(context, [seq(0)]), isXPathSequence([0.0]));
    });

    test('returns empty for empty sequence', () {
      expect(mathTan(context, [XPathSequence.empty]), isXPathSequence(<num>[]));
    });
  });

  group('math:asin', () {
    test('returns arcsine', () {
      expect(mathAsin(context, [seq(0)]), isXPathSequence([0.0]));
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
      expect(mathAcos(context, [seq(1)]), isXPathSequence([0.0]));
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
      expect(mathAtan(context, [seq(0)]), isXPathSequence([0.0]));
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
      expect(mathAtan2(context, [seq(0), seq(1)]), isXPathSequence([0.0]));
    });
  });
}
