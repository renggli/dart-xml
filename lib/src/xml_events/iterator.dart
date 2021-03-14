import 'package:petitparser/petitparser.dart'
    show Parser, Result, Success, Token;

import '../xml/entities/entity_mapping.dart';
import '../xml/utils/exceptions.dart';
import 'event.dart';
import 'parser.dart';

class XmlEventIterator extends Iterator<XmlEvent> {
  XmlEventIterator(String input, XmlEntityMapping entityMapping)
      : _eventParser = eventParserCache[entityMapping],
        _context = Success(input, 0, null);

  final Parser _eventParser;
  Result? _context;
  late XmlEvent _current;

  @override
  XmlEvent get current => _current;

  @override
  bool moveNext() {
    final context = _context;
    if (context != null) {
      final result = _eventParser.parseOn(context);
      if (result.isSuccess) {
        _context = result;
        _current = result.value;
        return true;
      } else if (context.position < context.buffer.length) {
        // In case of an error, skip one character and throw an exception.
        _context = context.failure(result.message, context.position + 1);
        final lineAndColumn =
            Token.lineAndColumnOf(result.buffer, result.position);
        throw XmlParserException(result.message,
            buffer: result.buffer,
            position: result.position,
            line: lineAndColumn[0],
            column: lineAndColumn[1]);
      } else {
        // In case of reaching the end, terminate the iterator.
        _context = null;
        return false;
      }
    }
    return false;
  }
}
