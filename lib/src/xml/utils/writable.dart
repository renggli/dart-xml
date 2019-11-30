library xml.utils.writable;

import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../visitors/pretty_writer.dart';
import '../visitors/visitable.dart';
import '../visitors/writer.dart';

/// Mixin to serialize XML to a [StringBuffer].
mixin XmlWritable implements XmlVisitable {
  /// Return a default XML string of this object.
  @override
  String toString() => toXmlString();

  /// Return an XML string of this object.
  ///
  /// If `pretty` is set to `true` the output is nicely reformatted, otherwise
  /// the tree is emitted verbatim.
  ///
  /// The option `indent` is only used when pretty formatting to customize the
  /// indention of nodes, by default nodes are indented with 2 spaces.
  String toXmlString(
      {bool pretty = false,
      String indent = '  ',
      XmlEntityMapping entityMapping = const XmlDefaultEntityMapping.xml()}) {
    final buffer = StringBuffer();
    if (pretty) {
      XmlPrettyWriter(buffer, entityMapping, 0, indent).visit(this);
    } else {
      XmlWriter(buffer, entityMapping).visit(this);
    }
    return buffer.toString();
  }
}
