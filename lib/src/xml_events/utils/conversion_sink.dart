/// A sink that executes [callback] for each addition.
class ConversionSink<T> implements Sink<T> {
  void Function(T data) callback;

  ConversionSink(this.callback);

  @override
  void add(T data) => callback(data);

  @override
  void close() {}
}
