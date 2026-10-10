import 'dart:math' as math;

import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/evaluation/configuration.dart';
import 'package:xml/src/xpath/functions/math.dart';
import 'package:xml/src/xpath/xdm/sequence.dart';
import 'package:xml/xml.dart';

import '../helpers.dart';

final context = const XPathConfiguration.raw().context(XmlDocument());
void main() {
  group('math:pi', () {
    test('returns pi', () {
      check(mathPi(context, [])).isXPathSequence([math.pi]);
    });
  });

  group('math:sqrt', () {
    test('returns square root', () {
      check(mathSqrt(context, [seq(4)])).isXPathSequence([2.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathSqrt(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:exp', () {
    test('returns exp', () {
      check(mathExp(context, [seq(0)])).isXPathSequence([1.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathExp(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:exp10', () {
    test('returns exp10', () {
      check(mathExp10(context, [seq(0)])).isXPathSequence([1.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathExp10(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:log', () {
    test('returns log', () {
      check(mathLog(context, [seq(math.e)])).isXPathSequence([1.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathLog(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:log10', () {
    test('returns log10', () {
      check(mathLog10(context, [seq(10)])).isXPathSequence([1.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathLog10(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:pow', () {
    test('returns power', () {
      check(mathPow(context, [seq(2), seq(3)])).isXPathSequence([8.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathPow(context, [XPathSequence.empty, seq(2)]))
          .isXPathSequence(<num>[]);
    });
  });

  group('math:sin', () {
    test('returns sine', () {
      check(mathSin(context, [seq(0)])).isXPathSequence([0.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathSin(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:cos', () {
    test('returns cosine', () {
      check(mathCos(context, [seq(0)])).isXPathSequence([1.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathCos(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:tan', () {
    test('returns tangent', () {
      check(mathTan(context, [seq(0)])).isXPathSequence([0.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathTan(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:asin', () {
    test('returns arcsine', () {
      check(mathAsin(context, [seq(0)])).isXPathSequence([0.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathAsin(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:acos', () {
    test('returns arccosine', () {
      check(mathAcos(context, [seq(1)])).isXPathSequence([0.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathAcos(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:atan', () {
    test('returns arctangent', () {
      check(mathAtan(context, [seq(0)])).isXPathSequence([0.0]);
    });

    test('returns empty for empty sequence', () {
      check(mathAtan(context, [XPathSequence.empty])).isXPathSequence(<num>[]);
    });
  });

  group('math:atan2', () {
    test('returns arctangent2', () {
      check(mathAtan2(context, [seq(0), seq(1)])).isXPathSequence([0.0]);
    });
  });
}
