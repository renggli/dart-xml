import 'name.dart';
import 'namespace.dart';

/// An XML entity name without a prefix.
class XmlSimpleName extends XmlName {
  @override
  String get prefix => null;

  @override
  final String local;

  @override
  String get qualified => local;

  final String _namespaceUri;

  @override
  String get namespaceUri =>
    _namespaceUri ?? lookupAttribute(parent, null, xmlns)?.value;

  XmlSimpleName(this.local, {String namespaceUri}) :
    _namespaceUri = namespaceUri,
    super.internal();
}
