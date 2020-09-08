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
  Result _context;

  @override
  XmlEvent get current => _context.value;

  @override
  bool moveNext() {
    final result = _eventParser.parseOn(_context);
    if (result.isSuccess) {
      _context = result;
      return true;
    } else {
      if (_context.position < _context.buffer.length) {
        // In case of an error, skip one character and throw an exception.
        _context = _context.failure(_context.message, _context.position + 1);
        final lineAndColumn =
            Token.lineAndColumnOf(result.buffer, result.position);
        throw XmlParserException(result.message,
            buffer: result.buffer,
            position: result.position,
            line: lineAndColumn[0],
            column: lineAndColumn[1]);
      } else {
        // In case of reaching the end, terminate the iterator.
        _context = result;
        return false;
      }
    }
  }
}
