import 'package:meta/meta.dart';

/// An XPath type with its Dart representation [T].
@optionalTypeArgs
abstract class XPathType<T extends Object> {
  const new({this.parent});

  /// The parent type in the type hierarchy, if any.
  final XPathType<Object>? parent;

  /// The type name.
  String get name;

  /// Returns `true` if this is an atomic type.
  bool get isAtomic => true;

  /// Returns `true` if this type is a subtype of [other].
  bool isSubtypeOf(XPathType<Object> other) {
    XPathType<Object>? current = this;
    while (current != null) {
      if (current == other) return true;
      current = current.parent;
    }
    return false;
  }

  /// Returns `true` if the [value] matches this type.
  bool matches(Object value);

  /// Casts the [value] to this type.
  T cast(Object value);

  /// Casts the [value] to its XPath string representation.
  String castToString(T value) => value.toString();

  @override
  String toString() => name;
}
