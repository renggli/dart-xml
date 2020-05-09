library xml.parse;

import 'package:petitparser/petitparser.dart';

import 'entities/default_mapping.dart';
import 'entities/entity_mapping.dart';
import 'nodes/document.dart';
import 'parser.dart';
import 'utils/cache.dart';
import 'utils/exceptions.dart';

/// Internal cache of parsers for a specific entity mapping.
final XmlCache<XmlEntityMapping, Parser> _parserCache =
    XmlCache((entityMapping) => XmlParserDefinition(entityMapping).build(), 5);

/// Internal helper to parse an input string.
XmlDocument parse(String input,
    {XmlEntityMapping entityMapping = const XmlDefaultEntityMapping.xml()}) {
  final result = _parserCache[entityMapping].parse(input);
  if (result.isFailure) {
    final lineAndColumn = Token.lineAndColumnOf(result.buffer, result.position);
    throw XmlParserException(result.message,
        buffer: result.buffer,
        position: result.position,
        line: lineAndColumn[0],
        column: lineAndColumn[1]);
  }
  return result.value;
}
