import 'name.dart';
import 'namespace.dart';

/// An XML entity name without a prefix.
class XmlSimpleName extends XmlName {
  @override
  String? get prefix => null;

  @override
  final String local;

  @override
  String get qualified => local;

  @override
  String? get namespaceUri => lookupAttribute(parent, null, xmlns)?.value;

  XmlSimpleName(this.local) : super.internal();

  @override
  XmlSimpleName copy() => XmlSimpleName(local);
}
