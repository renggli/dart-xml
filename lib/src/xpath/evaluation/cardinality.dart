/// The cardinality of a sequence.
enum XPathCardinality {
  /// The sequence must have exactly one value.
  exactlyOne(''),

  /// The sequence must have zero or one value `?`.
  zeroOrOne('?'),

  /// The sequence must have one or more values `+`.
  oneOrMore('+'),

  /// The sequence can have any number of values `*`.
  zeroOrMore('*');

  /// The cardinality of the sequence.
  new(this.suffix);

  /// The suffix of the cardinality.
  final String suffix;

  /// Returns `true` if this cardinality is a subset of [other].
  bool isSubtypeOf(XPathCardinality other) => switch (this) {
    XPathCardinality.exactlyOne => true,
    XPathCardinality.zeroOrOne =>
      other == XPathCardinality.zeroOrOne ||
          other == XPathCardinality.zeroOrMore,
    XPathCardinality.oneOrMore =>
      other == XPathCardinality.oneOrMore ||
          other == XPathCardinality.zeroOrMore,
    XPathCardinality.zeroOrMore => other == XPathCardinality.zeroOrMore,
  };

  @override
  String toString() => suffix;
}
