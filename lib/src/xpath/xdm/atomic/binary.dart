import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';

import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic.dart';
import '../types.dart';

/// Base class for binary atomic types.
abstract class XPathBinary extends XPathAtomic {
  const new(this.value);

  @override
  final Uint8List value;

  @override
  bool get effectiveBooleanValue => throw XPathEvaluationException(
    XPathErrorCode.FORG0006,
    'EBV not defined for binary values',
  );

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

/// Represents an xs:base64Binary atomic value.
final class XPathBase64Binary extends XPathBinary {
  const new(super.value);

  factory fromBase64(String text) =>
      XPathBase64Binary(base64Decode(text.replaceAll(RegExp(r'\s+'), '')));

  @override
  XPathType get type => xsBase64Binary;

  @override
  String get stringValue => base64Encode(value);
}

/// Represents an xs:hexBinary atomic value.
final class XPathHexBinary extends XPathBinary {
  const new(super.value);

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
    return XPathHexBinary(bytes);
  }

  @override
  XPathType get type => xsHexBinary;

  @override
  String get stringValue => value
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join();
}
