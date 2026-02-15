import 'package:meta/meta.dart';

import '../mixins/has_visitor.dart';
import '../mixins/has_writer.dart';
import '../visitors/visitor.dart';
import 'token.dart';

/// XML entity name.
@immutable
class XmlName with XmlHasVisitor, XmlHasWriter {
  /// Creates a qualified [XmlName].
  const XmlName(this.qualified, {this.namespaceUri});

  /// Create a [XmlName] by parsing the provided `qualified` name.
  @Deprecated('Use the `XmlName` const constructor instead.')
  factory XmlName.fromString(String qualified) = XmlName;

  /// The fully qualified name, including the namespace prefix.
  final String qualified;

  /// The namespace prefix, or `null`.
  String? get prefix {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0 ? qualified.substring(0, index) : null;
  }

  /// The local name, excluding the namespace prefix.
  String get local {
    final index = qualified.indexOf(XmlToken.namespace);
    return index > 0 ? qualified.substring(index + 1) : qualified;
  }

  /// The namespace URI, or `null`.
  final String? namespaceUri;

  @override
  String toString() => qualified;

  @override
  bool operator ==(Object other) =>
      other is XmlName &&
      other.qualified == qualified &&
      other.namespaceUri == namespaceUri;

  @override
  int get hashCode => Object.hash(qualified, namespaceUri);

  @override
  void accept(XmlVisitor visitor) => visitor.visitName(this);
}
