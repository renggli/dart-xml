/// Function to populate the cache.
typedef XmlLoader<K, V> = V Function(K key);

/// Simple FIFO cache.
class XmlCache<K, V> {
  final XmlLoader _loader;
  final int _maxSize;
  final Map<K, V> _values = {};

  XmlCache(this._loader, this._maxSize);

  V operator [](K key) {
    if (!_values.containsKey(key)) {
      final loaded = _loader(key);
      _values[key] = loaded;
      while (_values.length > _maxSize) {
        _values.remove(_values.keys.first);
      }
    }
    return _values[key]!;
  }
}
