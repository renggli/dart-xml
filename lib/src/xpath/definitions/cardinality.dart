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
  const XPathCardinality(this.suffix);

  /// The suffix of the cardinality.
  final String suffix;

  @override
  String toString() => suffix;
}
