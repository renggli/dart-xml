import 'dart:typed_data';
import 'package:collection/collection.dart';

class XPathBase64Binary extends DelegatingList<int> {
  XPathBase64Binary(Uint8List super.base);
}

class XPathHexBinary extends DelegatingList<int> {
  XPathHexBinary(Uint8List super.base);
}
