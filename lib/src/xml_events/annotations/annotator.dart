import '../../xml/exceptions/tag_exception.dart';
import '../event.dart';
import '../events/end_element.dart';
import '../events/start_element.dart';

/// Annotates [XmlEvent] instances with metadata, such as the underlying buffer,
/// the position in said buffer, and the parent event. This class also has the
/// ability to validate the parent relationship.
class XmlAnnotator {
  XmlAnnotator({
    required this.validateNesting,
    required this.withBuffer,
    required this.withLocation,
    required this.withParent,
  });

  final bool validateNesting;
  final bool withBuffer;
  final bool withLocation;
  final bool withParent;

  final List<XmlStartElementEvent> _parents = [];

  void annotate(XmlEvent event, {String? buffer, int? start, int? stop}) {
    // Attach the buffer.
    if (withBuffer) {
      event.attachBuffer(buffer);
    }
    // Attach the buffer location.
    if (withLocation) {
      event.attachLocation(start, stop);
    }
    // Attach the parent event.
    if (withParent || validateNesting) {
      if (withParent && _parents.isNotEmpty) {
        event.attachParent(_parents.last);
      }
      if (event is XmlStartElementEvent) {
        if (withParent) {
          for (final attribute in event.attributes) {
            attribute.attachParent(event);
          }
        }
        if (!event.isSelfClosing) {
          _parents.add(event);
        }
      } else if (event is XmlEndElementEvent) {
        // Validate the parent relationship.
        if (validateNesting) {
          if (_parents.isEmpty) {
            throw XmlTagException.unexpectedClosingTag(event.name,
                buffer: buffer, position: start);
          } else if (_parents.last.name != event.name) {
            throw XmlTagException.mismatchClosingTag(
                _parents.last.name, event.name,
                buffer: buffer, position: start);
          }
        }
        if (_parents.isNotEmpty) {
          _parents.removeLast();
        }
      }
    }
  }

  void close({String? buffer, int? position}) {
    // Validate the parent relationship.
    if (validateNesting && _parents.isNotEmpty) {
      throw XmlTagException.missingClosingTag(_parents.last.name,
          buffer: buffer, position: position);
    }
  }
}
