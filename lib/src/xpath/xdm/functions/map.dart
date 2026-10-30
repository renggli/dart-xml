import 'dart:collection';

import '../../evaluation/context.dart';
import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../atomic/numeric.dart';
import '../function_item.dart';
import '../sequence.dart';
import '../types.dart';

/// Represents an XDM 3.1 map item (map(*)).
final class XPathMap extends XPathFunctionItem {
  /// Creates a map item with [entries].
  const new([this.entries = const {}]);

  /// The canonical empty map.
  static const empty = XPathMap();

  /// Key-value map entries where values are sequences.
  final Map<XPathAtomic, XPathSequence> entries;

  @override
  XPathType get type => xsMap;

  @override
  int get arity => 1;

  /// The number of entries in the map.
  int get length => entries.length;

  /// Whether this map contains no entries.
  bool get isEmpty => entries.isEmpty;

  /// Whether this map contains at least one entry.
  bool get isNotEmpty => entries.isNotEmpty;

  /// The keys of this map.
  Iterable<XPathAtomic> get keys => entries.keys;

  /// Returns the sequence associated with [key], or `null` if not found.
  XPathSequence? get(XPathAtomic key) {
    final direct = entries[key];
    if (direct != null) return direct;
    if (entries.containsKey(key)) return entries[key];
    for (final entry in entries.entries) {
      if (sameKey(entry.key, key)) return entry.value;
    }
    return null;
  }

  /// Creates a map entry store using [sameKey] and [keyHashCode].
  static Map<XPathAtomic, XPathSequence> createEntries([
    Map<XPathAtomic, XPathSequence>? entries,
  ]) {
    final map = LinkedHashMap<XPathAtomic, XPathSequence>(
      equals: sameKey,
      hashCode: keyHashCode,
    );
    if (entries != null && entries.isNotEmpty) {
      map.addAll(entries);
    }
    return map;
  }

  /// Computes a hash code for [a] consistent with [sameKey].
  static int keyHashCode(XPathAtomic a) {
    if (a is XPathNumeric) {
      final d = a.toDouble();
      if (d.isNaN) return 0;
      return (d == 0.0 ? 0.0 : d).hashCode;
    }
    return a.hashCode;
  }

  @override
  Map<Object, Object?> toValue() => {
    for (final entry in entries.entries)
      entry.key.toValue(): entry.value.toValue(),
  };

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAP0001,
        'Maps expect exactly 1 argument, but got ${arguments.length}',
      );
    }
    final key = arguments.single.atomize().firstOrNull;
    if (key == null) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Map key cannot be empty sequence',
      );
    }
    return get(key) ?? XPathSequence.empty;
  }

  static bool sameKey(XPathAtomic a, XPathAtomic b) {
    if (identical(a, b)) return true;
    if (a is XPathNumeric && b is XPathNumeric) {
      final da = a.toDouble();
      final db = b.toDouble();
      if (da.isNaN && db.isNaN) return true;
      return da == db;
    }
    return a == b;
  }

  @override
  String toString() =>
      'map{${entries.entries.map((e) => '${e.key}: ${e.value}').join(', ')}}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XPathMap || other.length != length) return false;
    for (final entry in entries.entries) {
      final otherVal = other.get(entry.key);
      if (otherVal == null || otherVal != entry.value) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    var hash = 0;
    for (final entry in entries.entries) {
      hash = (hash + Object.hash(entry.key, entry.value)) & 0x3fffffff;
    }
    return hash;
  }
}
