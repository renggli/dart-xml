import 'name.dart';
import 'namespace.dart';

/// An XML entity name with a prefix.
class XmlPrefixName extends XmlName {
  @override
  final String prefix;

  @override
  final String local;

  @override
  final String qualified;

  final String _namespaceUri;

  @override
  String get namespaceUri =>
    _namespaceUri ?? lookupAttribute(parent, xmlns, prefix)?.value;

  XmlPrefixName(this.prefix, this.local, this.qualified, {String namespaceUri}):
    _namespaceUri = namespaceUri,
    super.internal();
}
