import '../atomic.dart';
import '../types.dart';

/// Represents an xs:string (or derived subtype) atomic value.
final class XPathString extends XPathAtomic {
  const new(this.value, [this.type = xsString]);

  /// Canonical empty string.
  static const empty = XPathString('');

  @override
  final String value;

  @override
  final XPathType type;

  @override
  String get stringValue => value;

  @override
  bool get effectiveBooleanValue => value.isNotEmpty;

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathString) return value.compareTo(other.value);
    if (other is XPathUntypedAtomic) return value.compareTo(other.value);
    if (other is XPathAnyUri) return value.compareTo(other.value);
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathString) return value == other.value;
    if (other is XPathUntypedAtomic) return value == other.value;
    if (other is XPathAnyUri) return value == other.value;
    if (other is String) return value == other;
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents an xs:untypedAtomic value.
final class XPathUntypedAtomic extends XPathAtomic {
  const new(this.value);

  @override
  final String value;

  @override
  XPathType get type => xsUntypedAtomic;

  @override
  String get stringValue => value;

  @override
  bool get effectiveBooleanValue => value.isNotEmpty;

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathUntypedAtomic) return value.compareTo(other.value);
    if (other is XPathString) return value.compareTo(other.value);
    if (other is XPathAnyUri) return value.compareTo(other.value);
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathUntypedAtomic) return value == other.value;
    if (other is XPathString) return value == other.value;
    if (other is XPathAnyUri) return value == other.value;
    if (other is String) return value == other;
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}

/// Represents an xs:anyURI atomic value.
final class XPathAnyUri extends XPathAtomic {
  const new(this.value);

  @override
  final String value;

  @override
  XPathType get type => xsAnyURI;

  @override
  String get stringValue => value;

  @override
  bool get effectiveBooleanValue => value.isNotEmpty;

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathAnyUri) return value.compareTo(other.value);
    if (other is XPathString) return value.compareTo(other.value);
    if (other is XPathUntypedAtomic) return value.compareTo(other.value);
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathAnyUri) return value == other.value;
    if (other is XPathString) return value == other.value;
    if (other is XPathUntypedAtomic) return value == other.value;
    if (other is String) return value == other;
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}
