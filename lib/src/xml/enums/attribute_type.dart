// ignore_for_file: constant_identifier_names

/// Enum of the attribute quote types.
enum XmlAttributeType {
  SINGLE_QUOTE("'"),
  DOUBLE_QUOTE('"');

  const XmlAttributeType(this.token);

  final String token;
}
