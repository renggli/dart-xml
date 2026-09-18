import '../../evaluation/context.dart';
import '../../exceptions/evaluation_exception.dart';
import '../atomic/numeric.dart';
import '../function_item.dart';
import '../sequence.dart';
import '../types.dart';

/// Represents an XDM 3.1 array item (array(*)).
final class XPathArray extends XPathFunctionItem {
  const new([this.members = const []]);

  static const empty = XPathArray();

  /// Ordered members of the array (each member is an XPathSequence).
  final List<XPathSequence> members;

  @override
  XPathType get type => xsArray;

  @override
  int get arity => 1;

  int get length => members.length;

  bool get isEmpty => members.isEmpty;

  bool get isNotEmpty => members.isNotEmpty;

  XPathSequence operator [](int index) => members[index];

  @override
  List<Object?> toValue() => [for (final member in members) member.toValue()];

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 1) {
      throw XPathEvaluationException(
        'Arrays expect exactly 1 argument, but got ${arguments.length}',
      );
    }
    final arg = arguments.single.atomize().firstOrNull;
    if (arg is! XPathInteger) {
      throw XPathEvaluationException(
        'Array index must be an integer, got ${arg?.type}',
      );
    }
    final idx = arg.value.toInt();
    if (idx < 1 || idx > members.length) {
      throw XPathEvaluationException(
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
