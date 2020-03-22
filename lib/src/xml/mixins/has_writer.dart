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
  /// The option `indent` is used only when pretty formatting to customize the
  /// indention of nodes, by default nodes are indented with 2 spaces.
  ///
  /// The option `newLine` is used only when pretty formatting to customize the
  /// printing of new lines, by default the standard new-line `'\n'` character
  /// is used.
  ///
  /// The option `level` is used only when pretty formatting to customize the
  /// initial indention level, by default this is `0`.
  String toXmlString(
      {bool pretty = false,
      XmlEntityMapping entityMapping = const XmlDefaultEntityMapping.xml(),
      int level = 0,
      String indent = '  ',
      String newLine = '\n'}) {
    final buffer = StringBuffer();
    final writer = pretty
        ? XmlPrettyWriter(buffer,
            entityMapping: entityMapping,
            level: level,
            indent: indent,
            newLine: newLine)
        : XmlWriter(buffer, entityMapping: entityMapping);
    writer.visit(this);
    return buffer.toString();
  }
}
