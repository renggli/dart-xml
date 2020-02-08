library xml.mixins.has_writer;

import '../entities/default_mapping.dart';
import '../entities/entity_mapping.dart';
import '../visitors/pretty_writer.dart';
import '../visitors/writer.dart';
import 'has_visitor.dart';

/// Mixin to serialize XML to a [StringBuffer].
mixin XmlHasWriter implements XmlHasVisitor {
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
