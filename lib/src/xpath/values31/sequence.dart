import 'package:collection/collection.dart' show DelegatingIterable;

/// An XPath 3.1 sequence.
class XPathSequence extends DelegatingIterable<Object> {
  /// The empty sequence.
  static const empty = XPathSequence(<Object>[]);

  /// The true sequence.
  static const trueSequence = XPathSequence(<Object>[true]);

  /// The false sequence.
  static const falseSequence = XPathSequence(<Object>[false]);

  /// Creates a sequence from an [Iterable].
  const XPathSequence(super.base);

  /// Creates a sequence from a single [value].
  factory XPathSequence.single(Object value) => XPathSequence([value]);

  /// Creates a sequence from an integer range.
  factory XPathSequence.range(int start, int stop) {
    if (start > stop) return empty;
    return XPathSequence(
      Iterable.generate(stop - start + 1, (index) => start + index),
    );
  }
}

extension XPathSequenceExtension on Object {
  /// Converts an object to an XPath sequence.
  XPathSequence toXPathSequence() {
    final self = this;
    if (self is XPathSequence) return self;
    if (self is Iterable<Object>) return XPathSequence(self);
    return XPathSequence.single(self);
  }
}
