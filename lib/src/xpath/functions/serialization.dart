import '../../xml/utils/name.dart';
import '../xdm/atomic/string.dart';
import '../xdm/function_item.dart';
import '../xdm/sequence.dart';
import 'serialization_parameters.dart';
import 'serialization_writers.dart';

export 'serialization_parameters.dart';
export 'serialization_writers.dart';

/// https://www.w3.org/TR/xpath-functions-31/#func-serialize
final fnSerialize = XPathFunctionItem.overloaded(
  const XmlName.qualified('fn:serialize'),
  {
    1: XPathFunctionItem.fn1(
      const XmlName.qualified('fn:serialize'),
      (context, arg) => XPathSequence.single(
        XPathString(serializeSequence(arg, SerializationParameters())),
      ),
    ),
    2: XPathFunctionItem.fn2(
      const XmlName.qualified('fn:serialize'),
      (context, arg, params) => XPathSequence.single(
        XPathString(
          serializeSequence(arg, SerializationParameters.fromSequence(params)),
        ),
      ),
    ),
  },
);
