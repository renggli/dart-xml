import '../functions/boolean.dart' as boolean_func;
import '../functions/nodes.dart' as nodes_func;
import '../functions/number.dart' as number_func;
import '../functions/string.dart' as string_func;
import 'context.dart';
import 'expression.dart';
import 'values.dart';

/// Type definition for all XPath functions.
typedef XPathFunction = XPathValue Function(
    XPathContext context, List<XPathExpression> arguments);

/// The standard XPath functions.
const Map<String, XPathFunction> standardFunctions = {
  // Node Set Functions
  'last': nodes_func.last,
  'position': nodes_func.position,
  'count': nodes_func.count,
  'id': nodes_func.id,
  'local-name': nodes_func.localName,
  'namespace-uri': nodes_func.namespaceUri,
  'name': nodes_func.name,
  // String Functions
  'concat': string_func.concat,
  'starts-with': string_func.startsWith,
  'contains': string_func.contains,
  'substring-before': string_func.substringBefore,
  'substring-after': string_func.substringAfter,
  'substring': string_func.substring,
  'string-length': string_func.stringLength,
  'string': string_func.string,
  'normalize-space': string_func.normalizeSpace,
  'translate': string_func.translate,
  // Number Functions
  'abs': number_func.abs,
  'number': number_func.number,
  'sum': number_func.sum,
  'floor': number_func.floor,
  'ceiling': number_func.ceiling,
  'round': number_func.round,
  // Boolean Functions
  'boolean': boolean_func.boolean,
  'not': boolean_func.not,
  'true': boolean_func.trueValue,
  'false': boolean_func.falseValue,
  'lang': boolean_func.lang,
};
