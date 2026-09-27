import '../../evaluation/context.dart';
import '../../exceptions/error_code.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic/numeric.dart';
import '../function_item.dart';
import '../sequence.dart';
import '../types.dart';

/// Represents an XDM 3.1 array item (array(*)).
final class XPathArray extends XPathFunctionItem {
  /// Creates an array item with [members].
  const new([this.members = const []]);

  /// The canonical empty array.
  static const empty = XPathArray();

  /// The ordered members of the array (each member is an XPathSequence).
  final List<XPathSequence> members;

  @override
  XPathType get type => xsArray;

  @override
  int get arity => 1;

  /// The number of members in the array.
  int get length => members.length;

  /// Whether this array contains no members.
  bool get isEmpty => members.isEmpty;

  /// Whether this array contains at least one member.
  bool get isNotEmpty => members.isNotEmpty;

  /// Returns the member at the 0-based [index].
  XPathSequence operator [](int index) => members[index];

  @override
  List<Object?> toValue() => [for (final member in members) member.toValue()];

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 1) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAP0001,
        'Arrays expect exactly 1 argument, but got ${arguments.length}',
      );
    }
    final arg = arguments.single.atomize().firstOrNull;
    if (arg is! XPathInteger) {
      throw XPathEvaluationException(
        XPathErrorCode.XPTY0004,
        'Array index must be an integer, got ${arg?.type}',
      );
    }
    final idx = arg.value.toInt();
    if (idx < 1 || idx > members.length) {
      throw XPathEvaluationException(
        XPathErrorCode.FOAY0001,
        'Array index out of bounds: $idx (length: ${members.length})',
      );
    }
    return members[idx - 1];
  }

  @override
  String toString() => '[${members.join(', ')}]';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! XPathArray || other.length != length) return false;
    for (var i = 0; i < length; i++) {
      if (members[i] != other.members[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(members);
}
