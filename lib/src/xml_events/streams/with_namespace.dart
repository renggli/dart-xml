import 'dart:convert' show ChunkedConversionSink;

import '../../../xml_events.dart';
import '../../xml/utils/exceptions.dart';
import '../../xml/utils/namespace.dart';
import '../converters/list_converter.dart';
import '../event.dart';
import '../events/end_element.dart';
import '../events/start_element.dart';
import '../utils/named.dart';

extension XmlWithNamespaceExtension on Stream<List<XmlEvent>> {
  Stream<List<XmlEvent>> withNamespace() => transform(const XmlWithNamespace());
}

/// A converter that selects [XmlEvent] objects that are part of a sub-tree
/// started by an [XmlStartElementEvent] satisfying the provided predicate.
class XmlWithNamespace extends XmlListConverter<XmlEvent, XmlEvent> {
  const XmlWithNamespace();

  @override
  ChunkedConversionSink<List<XmlEvent>> startChunkedConversion(
          Sink<List<XmlEvent>> sink) =>
      _XmlWithNamespaceSink(sink);
}

class _XmlWithNamespaceSink extends ChunkedConversionSink<List<XmlEvent>> {
  final Sink<List<XmlEvent>> sink;
  final List<MapEntry<XmlStartElementEvent, Map<String, String>>> stack = [];

  _XmlWithNamespaceSink(this.sink);

  @override
  void add(List<XmlEvent> chunk) {
    final result = <XmlEvent>[];
    for (final event in chunk) {
      if (event is XmlStartElementEvent) {
        final namespaces = <String, String>{};
        for (final attribute in event.attributes) {
          if (attribute.name == xmlns) {
            namespaces.putIfAbsent(null, () => attribute.value);
          } else if (attribute.namespacePrefix == xmlns) {
            namespaces.putIfAbsent(attribute.localName, () => attribute.value);
          }
        }
        stack.add(MapEntry(event, namespaces));
        result.add(XmlStartElementEvent(
          event.name,
          event.attributes
              .map((attribute) => XmlEventAttribute(
                  attribute.name,
                  attribute.value,
                  attribute.attributeType,
                  lookupNamespaceUri(attribute)))
              .toList(growable: false),
          event.isSelfClosing,
          lookupNamespaceUri(event),
        ));
        if (event.isSelfClosing) {
          stack.removeLast();
        }
      } else if (event is XmlEndElementEvent) {
        XmlTagException.checkClosingTag(stack.last.key.name, event.name);
        result.add(XmlEndElementEvent(event.name, lookupNamespaceUri(event)));
        stack.removeLast();
      } else {
        result.add(event);
      }
    }
    if (result.isNotEmpty) {
      sink.add(result);
    }
  }

  @override
  void close() {
    sink.close();
  }

  String lookupNamespaceUri(XmlNamed named) {
    final prefix = named.namespacePrefix;
    if (prefix != null) {
      for (var i = stack.length - 1; i >= 0; i--) {
        final namespaces = stack[i].value;
        if (namespaces.containsKey(prefix)) {
          return namespaces[prefix];
        }
      }
    }
    return null;
  }
}
