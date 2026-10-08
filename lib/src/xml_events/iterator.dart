import 'package:petitparser/stream.dart';

import '../xml/entities/entity_mapping.dart';
import '../xml/exceptions/parser_exception.dart';
import 'annotations/annotator.dart';
import 'event.dart';
import 'parser.dart';

class XmlEventIterator implements Iterator<XmlEvent> {
  new(String input, XmlEntityMapping entityMapping, XmlAnnotator annotator)
    : _iterator = ParseIterator<XmlEvent>(
        eventParserCache[entityMapping],
        input,
        contiguous: true,
        onMatch: (event, {required start, required stop, required buffer}) {
          annotator.annotate(event, buffer: buffer, start: start, stop: stop);
        },
        onError: (failure) {
          throw XmlParserException(
            failure.message,
            buffer: failure.buffer,
            position: failure.position,
          );
        },
        onClose: ({required position, required buffer}) {
          annotator.close(buffer: buffer, position: position);
        },
      );

  final ParseIterator<XmlEvent> _iterator;

  @override
  XmlEvent get current => _iterator.current;

  @override
  bool moveNext() => _iterator.moveNext();
}
