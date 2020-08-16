/// Function to populate the cache.
typedef XmlLoader<K, V> = V Function(K key);

/// Simple FIFO cache.
class XmlCache<K, V> {
  final XmlLoader _loader;
  final int _maxSize;
  final Map<K, V> _values = {};

  XmlCache(this._loader, this._maxSize);

  V operator [](K key) {
    var value = _values[key];
    if (value == null) {
      value = _loader(key);
      _values[key] = value;
    }
    while (_values.length > _maxSize) {
      _values.remove(_values.keys.first);
    }
    return value;
  }
}
