library xml.utils.writable;

import 'package:xml/src/xml/visitors/pretty_writer.dart';
import 'package:xml/src/xml/visitors/visitable.dart';
import 'package:xml/src/xml/visitors/writer.dart';

/// Mixin to serialize XML to a [StringBuffer].
mixin XmlWritable implements XmlVisitable {
  /// Write this object to a `buffer`.
  void writeTo(StringBuffer buffer) {
    XmlWriter(buffer).visit(this);
  }

  /// Write this object in a 'pretty' format to a `buffer`.
  void writePrettyTo(StringBuffer buffer, int level, String indent) {
    XmlPrettyWriter(buffer, level, indent).visit(this);
  }

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
  String toXmlString({bool pretty = false, String indent = '  '}) {
    final buffer = StringBuffer();
    if (pretty) {
      writePrettyTo(buffer, 0, indent);
    } else {
      writeTo(buffer);
    }
    return buffer.toString();
  }
}
