import '../atomic.dart';
import '../types.dart';

/// Represents an xs:boolean atomic value.
final class XPathBoolean extends XPathAtomic {
  const new _(this.value);

  /// The singleton true instance.
  static const trueInstance = XPathBoolean._(true);

  /// The singleton false instance.
  static const falseInstance = XPathBoolean._(false);

  /// Legacy / compatibility constants.
  static const xpathTrue = trueInstance;
  static const xpathFalse = falseInstance;

  /// Returns a boolean singleton for [val].
  factory(bool val) => val ? trueInstance : falseInstance;

  /// Creates an [XPathBoolean] from a Dart [bool].
  factory from(bool val) => val ? trueInstance : falseInstance;

  /// Creates an [XPathBoolean] from a Dart [bool].
  factory fromBool(bool val) => val ? trueInstance : falseInstance;

  @override
  final bool value;

  @override
  XPathType get type => xsBoolean;

  @override
  String get stringValue => value ? 'true' : 'false';

  @override
  bool get effectiveBooleanValue => value;

  @override
  int compareTo(XPathAtomic other) {
    if (other is XPathBoolean) {
      if (value == other.value) return 0;
      return value ? 1 : -1;
    }
    return super.compareTo(other);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is XPathBoolean) return value == other.value;
    if (other is bool) return value == other;
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}
