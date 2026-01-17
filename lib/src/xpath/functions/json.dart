import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import '../types/sequence.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-parse-json
XPathSequence fnParseJson(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:parse-json', arguments, 1, 2);
  throw UnimplementedError('fn:parse-json');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-doc
XPathSequence fnJsonDoc(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount('fn:json-doc', arguments, 1, 2);
  throw UnimplementedError('fn:json-doc');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-json-to-xml
XPathSequence fnJsonToXml(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(
    'fn:json-to-xml',
    arguments,
    1,
    2,
  );
  throw UnimplementedError('fn:json-to-xml');
}

/// https://www.w3.org/TR/xpath-functions-31/#func-xml-to-json
XPathSequence fnXmlToJson(XPathContext context, List<XPathSequence> arguments) {
  XPathEvaluationException.checkArgumentCount(
    'fn:xml-to-json',
    arguments,
    1,
    2,
  );
  throw UnimplementedError('fn:xml-to-json');
}
