library xml_events.iterator;

import 'package:petitparser/petitparser.dart';
import 'package:xml/xml.dart';

import 'event.dart';
import 'parser.dart';

final _eventParser = XmlEventDefinition().build();

class XmlEventIterator extends Iterator<XmlEvent> {
  XmlEventIterator(String input) : context = Success(input, 0, null);

  Result context;

  @override
  XmlEvent current;

  @override
  bool moveNext() {
    if (context == null) {
      return false;
    }
    final result = _eventParser.parseOn(context);
    if (result.isSuccess) {
      context = result;
      current = result.value;
      return true;
    } else {
      if (context.position < context.buffer.length) {
        // In case of an error, skip one character and throw an exception.
        context = context.failure(context.message, context.position + 1);
        current = null;
        final position = Token.lineAndColumnOf(result.buffer, result.position);
        throw XmlParserException(result.message, position[0], position[1]);
      } else {
        // In case of reaching the end, terminate the iterator.
        context = null;
        current = null;
        return false;
      }
    }
  }
}
