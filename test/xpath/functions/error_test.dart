import 'package:test/test.dart';
import 'package:xml/src/xpath/functions/error.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = const XPathConfiguration.raw().context(document);

void main() {
  group('fn:error', () {
    test('throws with no arguments', () {
      expect(
        () => fnError(context, []),
        throwsA(isXPathEvaluationException(message: '')),
      );
    });

    test('throws with code', () {
      expect(
        () => fnError(context, [
          const XPathSequence.single(XPathQName(XmlName('code'))),
        ]),
        throwsA(isXPathEvaluationException(message: 'code')),
      );
    });

    test('throws with code and description', () {
      expect(
        () => fnError(context, [
          const XPathSequence.single(XPathQName(XmlName('code'))),
          const XPathSequence.single(XPathString('description')),
        ]),
        throwsA(isXPathEvaluationException(message: 'description')),
      );
    });

    test('throws with code, description, and value', () {
      expect(
        () => fnError(context, [
          const XPathSequence.single(XPathQName(XmlName('code'))),
          const XPathSequence.single(XPathString('description')),
          XPathSequence([
            XPathInteger.fromInt(1),
            XPathInteger.fromInt(2),
            XPathInteger.fromInt(3),
          ]),
        ]),
        throwsA(isXPathEvaluationException(message: 'description (1, 2, 3)')),
      );
    });

    test('throws with invalid code type', () {
      expect(
        () => fnError(context, [
          const XPathSequence.single(XPathString('invalid')),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('throws with multiple codes', () {
      expect(
        () => fnError(context, [
          XPathSequence(const [
            XPathQName(XmlName('c1')),
            XPathQName(XmlName('c2')),
          ]),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });

    test('throws with known code in custom namespace', () {
      expect(
        () => fnError(context, [
          const XPathSequence.single(
            XPathQName(
              XmlName.parts('FOER0000', namespaceUri: 'http://custom'),
            ),
          ),
        ]),
        throwsA(isXPathEvaluationException(message: 'FOER0000')),
      );
    });

    test('throws with multiple descriptions', () {
      expect(
        () => fnError(context, [
          XPathSequence.empty,
          XPathSequence(const [XPathString('a'), XPathString('b')]),
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
      expect(
        () => fnError(context, [
          XPathSequence.empty,
          XPathSequence(const [XPathString('a'), XPathString('b')]),
          XPathSequence.empty,
        ]),
        throwsA(isXPathEvaluationException(errorCode: XPathErrorCode.XPTY0004)),
      );
    });
  });

  group('fn:trace', () {
    test('without handler returns value', () {
      const value = XPathSequence.single(XPathString('value'));
      const label = XPathSequence.single(XPathString('label'));
      expect(fnTrace(context, [value]), isXPathSequence(['value']));
      expect(fnTrace(context, [value, label]), isXPathSequence(['value']));
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
      expect(fnTrace(traceContext, [value]), same(value));
      expect(fnTrace(traceContext, [value, label]), same(value));
      expect(traceLog, [(value, null), (value, 'label')]);
    });
  });
}
