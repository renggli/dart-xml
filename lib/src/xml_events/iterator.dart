import 'package:petitparser/petitparser.dart'
    show Parser, Result, Success, Token;

import '../xml/entities/entity_mapping.dart';
import '../xml/utils/exceptions.dart';
import 'event.dart';
import 'parser.dart';

class XmlEventIterator extends Iterator<XmlEvent> {
  XmlEventIterator(String input, XmlEntityMapping entityMapping)
      : eventParser = eventParserCache[entityMapping],
        context = Success(input, 0, null);

  final Parser eventParser;
  Result context;

  @override
  XmlEvent current;

  @override
  bool moveNext() {
    if (context == null) {
      return false;
    }
    final result = eventParser.parseOn(context);
    if (result.isSuccess) {
      context = result;
      current = result.value;
      return true;
    } else {
      if (context.position < context.buffer.length) {
        // In case of an error, skip one character and throw an exception.
        context = context.failure(context.message, context.position + 1);
        current = null;
        final lineAndColumn =
            Token.lineAndColumnOf(result.buffer, result.position);
        throw XmlParserException(result.message,
            buffer: result.buffer,
            position: result.position,
            line: lineAndColumn[0],
            column: lineAndColumn[1]);
      } else {
        // In case of reaching the end, terminate the iterator.
        context = null;
        current = null;
        return false;
      }
    }
  }
}
