import 'dart:convert' show Codec, Converter;

import '../../xml/nodes/node.dart';
import '../converters/node_decoder.dart';
import '../converters/node_encoder.dart';
import '../event.dart';

/// Converts between [XmlEvent] sequences and [XmlNode] trees.
class XmlNodeCodec extends Codec<List<XmlNode>, List<XmlEvent>> {
  const XmlNodeCodec()
      : decoder = const XmlNodeDecoder(),
        encoder = const XmlNodeEncoder();

  /// Decodes a sequence of [XmlEvent] objects to a forest of [XmlNode] objects.
  @override
  final Converter<List<XmlEvent>, List<XmlNode>> decoder;

  /// Encodes a forest of [XmlNode] objects to a sequence of [XmlEvent] objects.
  @override
  final Converter<List<XmlNode>, List<XmlEvent>> encoder;
}
