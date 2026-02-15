import 'dart:convert' show Codec, Converter;

import '../../xml/entities/entity_mapping.dart';
import '../converters/event_decoder.dart';
import '../converters/event_encoder.dart';
import '../event.dart';

/// Converts between [String] and [XmlEvent] sequences.
class XmlEventCodec extends Codec<List<XmlEvent>, String> {
  /// Creates a new [XmlEventCodec].
  ///
  /// See [XmlEventDecoder] for information about the parameters.
  XmlEventCodec({
    XmlEntityMapping? entityMapping,
    bool validateDocument = false,
    bool validateNamespace = false,
    bool validateNesting = false,
    bool withLocation = false,
    bool withNamespace = false,
    bool withParent = false,
  }) : decoder = XmlEventDecoder(
         entityMapping: entityMapping,
         validateDocument: validateDocument,
         validateNamespace: validateNamespace,
         validateNesting: validateNesting,
         withLocation: withLocation,
         withNamespace: withNamespace,
         withParent: withParent,
       ),
       encoder = XmlEventEncoder(entityMapping: entityMapping);

  /// Decodes a [String] to a sequence of [XmlEvent] objects.
  @override
  final Converter<String, List<XmlEvent>> decoder;

  /// Encodes a sequence of [XmlEvent] objects to a [String].
  @override
  final Converter<List<XmlEvent>, String> encoder;
}
