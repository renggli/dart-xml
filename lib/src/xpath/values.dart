import 'package:meta/meta.dart';

import '../xml/nodes/document.dart';
import '../xml/nodes/element.dart';
import '../xml/nodes/node.dart';
import '../xml/nodes/text.dart';
import 'context.dart';
import 'resolver.dart';

@immutable
sealed class Value implements Resolver {
  /// The wrapped value.
  dynamic get value;

  /// Returns the node-set of this value.
  Iterable<XmlNode> get nodes;

  /// Returns the string of this value.
  String get string;

  /// Returns the numerical of this value.
  num get number;

  /// Returns the boolean of this value.
  bool get boolean;
}

class NodesValue implements Value {
  const NodesValue(this.value);

  @override
  final Iterable<XmlNode> value;

  @override
  Iterable<XmlNode> get nodes => value;

  @override
  String get string {
    if (nodes.isEmpty) return '';
    final buffer = StringBuffer();
    _stringForNodeOn(nodes.first, buffer);
    return buffer.toString();
  }

  void _stringForNodeOn(XmlNode node, StringBuffer buffer) {
    if (node is XmlDocument) {
      node = node.rootElement;
    }
    if (node is XmlElement) {
      _stringForElementOn(node, buffer);
    } else {
      buffer.write(node.value ?? '');
    }
  }

  void _stringForElementOn(XmlElement element, StringBuffer buffer) {
    for (final child in element.children) {
      if (child is XmlText) {
        buffer.write(child.value);
      } else if (child is XmlElement) {
        _stringForElementOn(child, buffer);
      }
    }
  }

  @override
  num get number => num.tryParse(string) ?? double.nan;

  @override
  bool get boolean => value.isNotEmpty;

  @override
  Value call(Context context, Value value) => this;

  @override
  String toString() {
    final buffer = StringBuffer('[');
    final iterator = value.iterator;
    var i = 0;
    while (iterator.moveNext() && i++ < 3) {
      if (i > 0) buffer.write(' ,');
      final inner = StringBuffer();
      _stringForNodeOn(iterator.current, inner);
      if (inner.length > 20) {
        buffer.write(inner.toString().substring(0, 20));
        buffer.write('...');
      } else {
        buffer.write(inner.toString());
      }
    }
    if (i >= 3) buffer.write(', ...');
    buffer.write(']');
    return buffer.toString();
  }
}

class StringValue implements Value {
  const StringValue(this.value);

  @override
  final String value;

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert string to node-set');

  @override
  String get string => value;

  @override
  num get number => num.tryParse(string) ?? double.nan;

  @override
  bool get boolean => value.isNotEmpty;

  @override
  Value call(Context context, Value value) => this;

  @override
  String toString() => '"$value"';
}

class NumberValue implements Value {
  const NumberValue(this.value);

  @override
  final num value;

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert number to node-set');

  @override
  String get string => value.toString();

  @override
  num get number => value;

  @override
  bool get boolean => value == 0;

  @override
  Value call(Context context, Value value) => this;

  @override
  String toString() => value.toString();
}

class BooleanValue implements Value {
  factory BooleanValue(bool value) =>
      value ? const BooleanValue._(true) : const BooleanValue._(false);

  const BooleanValue._(this.value);

  @override
  final bool value;

  @override
  Iterable<XmlNode> get nodes =>
      throw StateError('Unable to convert boolean to node-set');

  @override
  String get string => value ? 'true' : 'false';

  @override
  num get number => value ? 1 : 0;

  @override
  bool get boolean => value;

  @override
  Value call(Context context, Value value) => this;

  @override
  String toString() => '$value()';
}
