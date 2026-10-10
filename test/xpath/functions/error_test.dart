import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/src/xpath/functions/error.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/checks.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:error', () {
    test('throws with no arguments', () {
      check(() => fnError(context, []))
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: ''));
    });

    test('throws with code', () {
      check(
            () => fnError(context, [
              const XPathSequence.single(XPathQName(XmlName('code'))),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'code'));
    });

    test('throws with code and description', () {
      check(
            () => fnError(context, [
              const XPathSequence.single(XPathQName(XmlName('code'))),
              const XPathSequence.single(XPathString('description')),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'description'));
    });

    test('throws with code, description, and value', () {
      check(
            () => fnError(context, [
              const XPathSequence.single(XPathQName(XmlName('code'))),
              const XPathSequence.single(XPathString('description')),
              XPathSequence([
                XPathInteger.fromInt(1),
                XPathInteger.fromInt(2),
                XPathInteger.fromInt(3),
              ]),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'description (1, 2, 3)'));
    });

    test('throws with invalid code type', () {
      check(
        () => fnError(context, [
          const XPathSequence.single(XPathString('invalid')),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });

    test('throws with multiple codes', () {
      check(
        () => fnError(context, [
          XPathSequence(const [
            XPathQName(XmlName('c1')),
            XPathQName(XmlName('c2')),
          ]),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });

    test('throws with known code in custom namespace', () {
      check(
            () => fnError(context, [
              const XPathSequence.single(
                XPathQName(
                  XmlName.parts('FOER0000', namespaceUri: 'http://custom'),
                ),
              ),
            ]),
          )
          .throws<XPathEvaluationException>()
          .which(isXPathEvaluationException(message: 'FOER0000'));
    });

    test('throws with multiple descriptions', () {
      check(
        () => fnError(context, [
          XPathSequence.empty,
          XPathSequence(const [XPathString('a'), XPathString('b')]),
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
      check(
        () => fnError(context, [
          XPathSequence.empty,
          XPathSequence(const [XPathString('a'), XPathString('b')]),
          XPathSequence.empty,
        ]),
      ).throws<XPathEvaluationException>().which(
        isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004),
      );
    });
  });

  group('fn:trace', () {
    test('without handler returns value', () {
      const value = XPathSequence.single(XPathString('value'));
      const label = XPathSequence.single(XPathString('label'));
      check(fnTrace(context, [value])).isXPathSequence(['value']);
      check(fnTrace(context, [value, label])).isXPathSequence(['value']);
    });

    test('with handler logs and returns value', () {
      const value = XPathSequence.single(XPathString('value'));
      const label = XPathSequence.single(XPathString('label'));
      final traceLog = <(XPathSequence, String?)>[];
      final traceContext = context.configuration
          .copy(
            onTraceCallback: (XPathSequence value, String? label) =>
                traceLog.add((value, label)),
          )
          .context(context.item)
          .copy(variables: context.variables);
      check(fnTrace(traceContext, [value])).identicalTo(value);
      check(fnTrace(traceContext, [value, label])).identicalTo(value);
      check(traceLog).deepEquals([(value, null), (value, 'label')]);
    });
  });
}
