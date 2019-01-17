library xml_events.converter.codec;

import 'dart:convert';

import '../event.dart';
import 'decoder.dart';
import 'encoder.dart';

/// An [XmlCodec] decodes a [String] to a list of [XmlEvent] objects, and
/// encodes a list of [XmlEvent] objects to a serialized [String].
class XmlCodec extends Codec<List<XmlEvent>, String> {
  const XmlCodec();

  /// Decodes a [String] to an [Iterable] of [XmlEvent] objects.
  @override
  Converter<String, List<XmlEvent>> get decoder => const XmlDecoder();

  /// Encodes an [Iterable] of [XmlEvent] objects to a [String].
  @override
  Converter<List<XmlEvent>, String> get encoder => const XmlEncoder();
}
