import 'package:petitparser/petitparser.dart' show Parser, Context;

import '../xml/entities/entity_mapping.dart';
import '../xml/exceptions/parser_exception.dart';
import 'annotations/annotator.dart';
import 'event.dart';
import 'parser.dart';

class XmlEventIterator extends Iterator<XmlEvent> {
  XmlEventIterator(
      String input, XmlEntityMapping entityMapping, this._annotator)
      : _eventParser = eventParserCache[entityMapping],
        _context = Context(input);

  final Parser<XmlEvent> _eventParser;
  final XmlAnnotator _annotator;

  Context? _context;
  XmlEvent? _current;

  @override
  XmlEvent get current => _current!;

  @override
  bool moveNext() {
    final context = _context;
    if (context != null) {
      final position = context.position;
      _eventParser.parseOn(context);
      if (context.isSuccess) {
        _annotator.annotate(
          _current = context.value as XmlEvent,
          buffer: context.buffer,
          start: position,
          stop: context.position,
        );
        return true;
      } else if (position < context.end) {
        // In case of an error, skip one character and throw an exception.
        final errorPosition = context.position;
        context.position = position + 1;
        throw XmlParserException(context.message,
            buffer: context.buffer, position: errorPosition);
      } else {
        // In case of reaching the end, terminate the iterator.
        _context = _current = null;
        _annotator.close(
          buffer: context.buffer,
          position: context.position,
        );
        return false;
      }
    }
    return false;
  }
}
