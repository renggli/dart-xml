import '../xdm/function_item.dart';

const jsonNamespace = 'http://www.w3.org/2005/xpath-functions';

/// Options for JSON parsing defined in W3C XPath and XQuery Functions and Operators 3.1.
class JsonOptions {
  const new({
    this.liberal = false,
    this.duplicates = 'use-first',
    this.escape = false,
    this.validate = false,
    this.fallback,
  });

  final bool liberal;
  final String duplicates;
  final bool escape;
  final bool validate;
  final XPathFunctionItem? fallback;
}
