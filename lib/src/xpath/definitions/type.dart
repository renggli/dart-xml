import 'package:meta/meta.dart';

/// An XPath type with its Dart representation [T].
@optionalTypeArgs
abstract class XPathType<T extends Object> {
  const XPathType();

  /// The type name.
  String get name;

  /// Returns `true` if the [value] matches this type.
  bool matches(Object value);

  /// Casts the [value] to this type.
  T cast(Object value);

  @override
  String toString() => name;
}
