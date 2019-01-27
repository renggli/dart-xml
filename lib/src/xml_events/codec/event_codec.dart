library xml_events.codec.event_codec;

import 'dart:convert' show Codec, Converter;

import 'package:xml/src/xml_events/converters/event_decoder.dart';
import 'package:xml/src/xml_events/converters/event_encoder.dart';
import 'package:xml/src/xml_events/event.dart';

/// Converts between [String] and [XmlEvent] sequences.
class XmlEventCodec extends Codec<List<XmlEvent>, String> {
  const XmlEventCodec();

  /// Decodes a [String] to a sequence of [XmlEvent] objects.
  @override
  Converter<String, List<XmlEvent>> get decoder => const XmlEventDecoder();

  /// Encodes a sequence of [XmlEvent] objects to a [String].
  @override
  Converter<List<XmlEvent>, String> get encoder => const XmlEventEncoder();
}
