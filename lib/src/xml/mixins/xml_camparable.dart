import 'package:collection/collection.dart';

/// Mixin for comparable XML nodes
///
/// Please note, this mixin does not aim to check whether XmlNodes are composed
/// the same way, but implements some checks on whether XML encoded *data* is
/// equal in two XmlNode representations.
///
/// Features ignored in comparisons:
/// - namespace prefixes - only the namespace URLs are compared
/// - namespace declarations
/// - empty text nodes
/// - comments
///
/// This code is mostly based on parts of `package:equatable`
mixin XmlComparable {
  /// List of properties to be compared
  List<Object?> get comparable;

  /// additional comparison to be applied on each == operator
  ///
  /// return values:
  /// - false: objects are not equal
  /// - true:objects are equal
  /// - null: rely on default [comparable] fallback
  bool? additionalComparator(Object other) => null;

  @override
  int get hashCode => _finish(comparable.fold(0, _combine));

  @override
  bool operator ==(Object other) {
    final additionalComparison = additionalComparator(other);
    // in case the custom comparison is `false` or `true`, immediately return
    return additionalComparison != false &&
        (additionalComparison == true ||
            identical(other, this) ||
            (other is XmlComparable && other.hashCode == hashCode));
  }

  /// Jenkins Hash Functions
  /// https://en.wikipedia.org/wiki/Jenkins_hash_function
  int _combine(int hash, dynamic object) {
    if (object is Map) {
      object.keys
          .sorted((dynamic a, dynamic b) => a.hashCode - b.hashCode)
          .forEach((dynamic key) {
        hash = hash ^ _combine(hash, <dynamic>[key, (object as Map)[key]]);
      });
      return hash;
    }
    if (object is Set) {
      object =
          object.sorted(((dynamic a, dynamic b) => a.hashCode - b.hashCode));
    }
    if (object is Iterable) {
      for (final value in object) {
        hash = hash ^ _combine(hash, value);
      }
      return hash ^ object.length;
    }

    hash = 0x1fffffff & (hash + object.hashCode);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  int _finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}
