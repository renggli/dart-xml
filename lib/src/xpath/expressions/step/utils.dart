import 'package:collection/collection.dart';

extension ListReverseExtension<T> on List<T> {
  /// Reverses the elements of the list in place.
  void reverse() => reverseRange(0, length);
}

extension IterableReverseExtension<T> on Iterable<T> {
  /// Creates a reversed [List] containing the elements of this [Iterable].
  List<T> get reversed => toList()..reverse();
}
