import 'package:test/test.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/functions/error.dart';
import 'package:xml/src/xpath/types/string.dart' as v31;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

final document = XmlDocument.parse('<r><a>1</a><b>2</b></r>');
final context = XPathContext(document);

void main() {
  test('fn:error', () {
    expect(
      () => fnError(context, const <XPathSequence>[]),
      throwsA(isXPathEvaluationException(message: '')),
    );
    expect(
      () => fnError(context, [const XPathSequence.single('code')]),
      throwsA(isXPathEvaluationException(message: 'code')),
    );
    expect(
      () => fnError(context, [
        const XPathSequence.single('code'),
        const XPathSequence.single('description'),
      ]),
      throwsA(isXPathEvaluationException(message: 'code: description')),
    );
    expect(
      () => fnError(context, [
        const XPathSequence.single('code'),
        const XPathSequence.single('description'),
        const XPathSequence([1, 2, 3]),
      ]),
      throwsA(
        isXPathEvaluationException(message: 'code: description (1, 2, 3)'),
      ),
    );
  });
  test('fn:trace (without handler)', () {
    const value = XPathSequence.single('value');
    const label = XPathSequence.single('label');
    expect(fnTrace(context, [value]), ['value']);
    expect(fnTrace(context, [value, label]), ['value']);
  });
  test('fn:trace (with handler)', () {
    const value = XPathSequence.single('value');
    const label = XPathSequence.single('label');
    final traceLog = <(XPathSequence, v31.XPathString?)>[];
    final traceContext = context.copy(
      onTraceCallback: (value, label) => traceLog.add((value, label)),
    );
    expect(fnTrace(traceContext, [value]), ['value']);
    expect(fnTrace(traceContext, [value, label]), ['value']);
    expect(traceLog, [(value, null), (value, label.single)]);
  });
}
