library xml_events.codec.node_codec;

import 'dart:convert' show Codec, Converter;

import 'package:xml/src/xml_events/converters/node_decoder.dart';
import 'package:xml/src/xml_events/converters/node_encoder.dart';
import 'package:xml/src/xml_events/event.dart';
import 'package:xml/xml.dart' show XmlNode;

/// Converts between [XmlEvent] sequences and [XmlNode] trees.
class XmlNodeCodec extends Codec<List<XmlNode>, List<XmlEvent>> {
  const XmlNodeCodec();

  /// Decodes a sequence of [XmlEvent] objects to a forest of [XmlNode] objects.
  @override
  Converter<List<XmlEvent>, List<XmlNode>> get decoder =>
      const XmlNodeDecoder();

  /// Encodes a forest of [XmlNode] objects to a sequence of [XmlEvent] objects.
  @override
  Converter<List<XmlNode>, List<XmlEvent>> get encoder =>
      const XmlNodeEncoder();
}
