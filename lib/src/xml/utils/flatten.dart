extension XmlFlattenIterableExtension<T> on Iterable<Iterable<T>> {
  /// Flattens an [Iterable] of [Iterable] values of type [T] to a [Iterable] of
  /// values of type [T].
  Iterable<T> flatten() => expand((values) => values);
}
