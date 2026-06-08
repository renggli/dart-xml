import 'dart:typed_data';
import 'package:collection/collection.dart';

/// Representation of an XPath base64Binary value (xs:base64Binary).
class XPathBase64Binary extends DelegatingList<int> {
  XPathBase64Binary(Uint8List super.base);
}

/// Representation of an XPath hexBinary value (xs:hexBinary).
class XPathHexBinary extends DelegatingList<int> {
  XPathHexBinary(Uint8List super.base);
}
