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

  @override
  String? get namespaceUri => lookupAttribute(parent, xmlns, prefix)?.value;

  XmlPrefixName(this.prefix, this.local, this.qualified) : super.internal();

  @override
  XmlPrefixName copy() => XmlPrefixName(prefix, local, qualified);
}
