import 'package:meta/meta.dart';

/// Predicate function of type [T].
@Deprecated('Use `bool Function(T value)` instead')
typedef Predicate<T> = bool Function(T value);

@internal
bool Function(T) toPredicate<T>(
  bool Function(T)? predicate,
  bool? all, {
  bool otherwise = false,
}) {
  assert(
    predicate == null || all == null,
    'Only specify the predicate or a boolean value, not both',
  );
  if (predicate != null) return predicate;
  if (all != null) return (node) => all;
  return (node) => otherwise;
}
