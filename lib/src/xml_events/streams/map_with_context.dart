import 'dart:convert' show ChunkedConversionSink;

import 'package:collection/collection.dart' show QueueList;

import '../../xml/utils/exceptions.dart';
import '../converters/list_converter.dart';
import '../event.dart';
import '../events/end_element.dart';
import '../events/start_element.dart';
import '../utils/flatten.dart';

extension XmlWithContextExtension on Stream<List<XmlEvent>> {
  /// Transforms each [XmlEvent] of this stream into a new stream element.
  ///
  /// The [callback] function performing the actual conversion gets the
  /// context passed in as the first argument. The context contains all the
  /// parent [XmlStartElementEvent] objects and is only valid during the
  /// execution of the callback. Don't forget to copy it, if you need it
  /// later.
  ///
  /// The default implementations of [onMismatchClosingTag],
  /// [onUnexpectedClosingTag] and [onMissingClosingTag] do throw an exception
  /// and abort the mapping, but alternate handlers can be provided.
  Stream<List<T>> mapWithContext<T>(
    MapWithContext<T> callback, {
    OnMismatchClosingTag<T> onMismatchClosingTag,
    OnUnexpectedClosingTag<T> onUnexpectedClosingTag,
    OnMissingClosingTag<T> onMissingClosingTag,
  }) =>
      transform<List<T>>(XmlMapWithContext<T>(
        callback,
        onMismatchClosingTag ?? _onMismatchClosingTag,
        onUnexpectedClosingTag ?? _onUnexpectedClosingTag,
        onMissingClosingTag ?? _onMissingClosingTag,
      ));

  /// Creates a new stream from this stream that discards some [XmlEvent].
  ///
  /// The [predicate] function performing the actual test gets the context
  /// passed in as the first argument. The context contains all the
  /// parent [XmlStartElementEvent] objects and is only valid during the
  /// execution of the callback.
  Stream<List<XmlEvent>> whereWithContext(MapWithContext<bool> predicate) =>
      mapWithContext<List<XmlEvent>>(
              (context, event) => predicate(context, event) ? [event] : [])
          .flatten();
}

/// A converter that does not touch the input, but validates the nesting
/// of [XmlStartElementEvent] and [XmlEndElementEvent].
class XmlMapWithContext<T> extends XmlListConverter<XmlEvent, T> {
  final MapWithContext<T> callback;
  final OnMismatchClosingTag<T> onMismatchClosingTag;
  final OnUnexpectedClosingTag<T> onUnexpectedClosingTag;
  final OnMissingClosingTag<T> onMissingClosingTag;

  XmlMapWithContext(
    this.callback,
    this.onMismatchClosingTag,
    this.onUnexpectedClosingTag,
    this.onMissingClosingTag,
  );

  @override
  ChunkedConversionSink<List<XmlEvent>> startChunkedConversion(
          Sink<List<T>> sink) =>
      XmlMapWithContextSink<T>(
        sink,
        callback,
        onMismatchClosingTag,
        onUnexpectedClosingTag,
        onMissingClosingTag,
      );
}

class XmlMapWithContextSink<T> extends ChunkedConversionSink<List<XmlEvent>> {
  final List<XmlStartElementEvent> stack = QueueList<XmlStartElementEvent>();

  final Sink<List<T>> sink;
  final MapWithContext<T> callback;
  final OnMismatchClosingTag<T> onMismatchClosingTag;
  final OnUnexpectedClosingTag<T> onUnexpectedClosingTag;
  final OnMissingClosingTag<T> onMissingClosingTag;

  XmlMapWithContextSink(
    this.sink,
    this.callback,
    this.onMismatchClosingTag,
    this.onUnexpectedClosingTag,
    this.onMissingClosingTag,
  );

  @override
  void add(List<XmlEvent> chunk) {
    final result = <T>[];
    for (final event in chunk) {
      if (event is XmlStartElementEvent) {
        result.add(callback(stack, event));
        if (!event.isSelfClosing) {
          stack.add(event);
        }
      } else if (event is XmlEndElementEvent) {
        if (stack.isEmpty) {
          result.add(onUnexpectedClosingTag(stack, event));
        } else if (stack.last.name != event.name) {
          result.add(onMismatchClosingTag(stack, stack.last, event));
        } else {
          result.add(callback(stack, event));
          stack.removeLast();
        }
      } else {
        result.add(callback(stack, event));
      }
    }
    if (result.isNotEmpty) {
      sink.add(result);
    }
  }

  @override
  void close() {
    if (stack.isNotEmpty) {
      final result = <T>[];
      do {
        final event = stack.removeLast();
        result.add(onMissingClosingTag(stack, event));
      } while (stack.isNotEmpty);
      sink.add(result);
    }
    sink.close();
  }
}

// Handler types and default implementations.

typedef MapWithContext<T> = T Function(
    List<XmlStartElementEvent> context, XmlEvent event);

typedef OnMismatchClosingTag<T> = T Function(List<XmlStartElementEvent> context,
    XmlStartElementEvent expected, XmlEndElementEvent actual);

T _onMismatchClosingTag<T>(List<XmlStartElementEvent> context,
        XmlStartElementEvent expected, XmlEndElementEvent actual) =>
    throw XmlTagException.mismatchClosingTag(expected.name, actual.name);

typedef OnUnexpectedClosingTag<T> = T Function(
    List<XmlStartElementEvent> context, XmlEndElementEvent expected);

T _onUnexpectedClosingTag<T>(
        List<XmlStartElementEvent> context, XmlEndElementEvent event) =>
    throw XmlTagException.unexpectedClosingTag(event.name);

typedef OnMissingClosingTag<T> = T Function(
    List<XmlStartElementEvent> context, XmlStartElementEvent actual);

T _onMissingClosingTag<T>(
        List<XmlStartElementEvent> context, XmlStartElementEvent event) =>
    throw XmlTagException.missingClosingTag(event.name);
