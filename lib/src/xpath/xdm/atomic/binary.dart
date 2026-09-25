import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../types.dart';

/// Representation of binary atomic values (xs:base64Binary and xs:hexBinary).
final class XPathBinary extends XPathAtomic {
  /// Creates a new [XPathBinary].
  const new(this.value, [this.type = xsBase64Binary]);

  /// Creates a new [XPathBinary] from base64 encoded text.
  factory fromBase64(String text) => XPathBinary(
    base64Decode(text.replaceAll(RegExp(r'\s+'), '')),
    xsBase64Binary,
  );

  /// Creates a new [XPathBinary] from hex encoded text.
  factory fromHex(String text) {
    final clean = text.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    if (clean.length.isOdd) {
      throw XPathEvaluationException(
        XPathErrorCode.FORG0001,
        'Invalid hex length: ${clean.length}',
      );
    }
    final bytes = Uint8List(clean.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return XPathBinary(bytes, xsHexBinary);
  }

  @override
  final Uint8List value;

  @override
  final XPathType type;

  @override
  bool get effectiveBooleanValue => throw XPathEvaluationException(
    XPathErrorCode.FORG0006,
    'EBV not defined for binary values',
  );

  @override
  String get stringValue => type == xsHexBinary
      ? value
            .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
            .join()
      : base64Encode(value);

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathBinary && type == other.type) {
      final len = value.length < other.value.length
          ? value.length
          : other.value.length;
      for (var i = 0; i < len; i++) {
        final cmp = value[i].compareTo(other.value[i]);
        if (cmp != 0) return cmp;
      }
      return value.length.compareTo(other.value.length);
    }
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathBinary && type == other.type) {
      return const ListEquality<int>().equals(value, other.value);
    }
    return false;
  }

  @override
  int get hashCode => const ListEquality<int>().hash(value);
}
