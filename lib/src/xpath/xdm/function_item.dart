import '../../xml/utils/name.dart';
import '../evaluation/context.dart';
import '../exceptions/evaluation_exception.dart';
import 'atomic.dart';
import 'item.dart';
import 'sequence.dart';
import 'types.dart';

typedef XPathFunction0 = XPathSequence Function(XPathContext context);
typedef XPathFunction1 = XPathSequence Function(
  XPathContext context,
  XPathSequence a1,
);
typedef XPathFunction2 = XPathSequence Function(
  XPathContext context,
  XPathSequence a1,
  XPathSequence a2,
);
typedef XPathFunction3 = XPathSequence Function(
  XPathContext context,
  XPathSequence a1,
  XPathSequence a2,
  XPathSequence a3,
);
typedef XPathFunctionN = XPathSequence Function(
  XPathContext context,
  List<XPathSequence> args,
);

/// Base class for all function items (functions, maps, arrays) in XDM 3.1.
abstract class XPathFunctionItem implements XPathItem {
  const new();

  /// Creates a general function item taking a list of arguments.
  const factory function({
    XmlName? name,
    required int arity,
    required XPathFunctionN function,
  }) = _XPathFunctionN.named;

  /// Creates a function item with 0 arguments.
  const factory fn0(XmlName? name, XPathFunction0 function) = _XPathFunction0;

  /// Creates a function item with 1 argument.
  const factory fn1(XmlName? name, XPathFunction1 function) = _XPathFunction1;

  /// Creates a function item with 2 arguments.
  const factory fn2(XmlName? name, XPathFunction2 function) = _XPathFunction2;

  /// Creates a function item with 3 arguments.
  const factory fn3(XmlName? name, XPathFunction3 function) = _XPathFunction3;

  /// Creates a function item with [arity] arguments taking a list.
  const factory fnN(XmlName? name, int arity, XPathFunctionN function) =
      _XPathFunctionN;

  /// Creates a variadic function item with minimum arity [minArity].
  const factory variadic(XmlName? name, int minArity, XPathFunctionN function) =
      _XPathVariadicFunction;

  /// Creates an overloaded function item that dispatches across arities.
  const factory overloaded(XmlName? name, Map<int, XPathFunctionItem> byArity) =
      XPathOverloadedFunction;

  /// The name of the function, if named.
  XmlName? get name => null;

  /// The arity (number of required arguments) of the function item.
  int get arity;

  /// Returns `true` if this function accepts variable arguments (at least [arity]).
  bool get isVariadic => false;

  @override
  XPathType get type => xsFunction;

  @override
  XPathAtomic atomize() => throw XPathEvaluationException(
    'Cannot atomize a map or function item [err:FOTY0013]',
  );

  @override
  String get stringValue => throw XPathEvaluationException(
    'String value not defined for function item: $this',
  );

  @override
  bool get effectiveBooleanValue => throw XPathEvaluationException(
    'Cannot compute EBV for a function item: $this',
  );

  /// Invokes the function item with the given arguments.
  XPathSequence call(XPathContext context, List<XPathSequence> arguments);

  @override
  String toString() =>
      name != null ? '${name!.qualified}#$arity' : '(anonymous)#$arity';
}

class _XPathFunction0 extends XPathFunctionItem {
  const new(this.name, this._function);

  @override
  final XmlName? name;

  final XPathFunction0 _function;

  @override
  int get arity => 0;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.isNotEmpty) {
      throw XPathEvaluationException(
        'Function ${name?.qualified ?? '(anonymous)'} expects 0 arguments, but got ${arguments.length}.',
      );
    }
    return _function(context);
  }
}

class _XPathFunction1 extends XPathFunctionItem {
  const new(this.name, this._function);

  @override
  final XmlName? name;

  final XPathFunction1 _function;

  @override
  int get arity => 1;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 1) {
      throw XPathEvaluationException(
        'Function ${name?.qualified ?? '(anonymous)'} expects 1 argument, but got ${arguments.length}.',
      );
    }
    return _function(context, arguments[0]);
  }
}

class _XPathFunction2 extends XPathFunctionItem {
  const new(this.name, this._function);

  @override
  final XmlName? name;

  final XPathFunction2 _function;

  @override
  int get arity => 2;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 2) {
      throw XPathEvaluationException(
        'Function ${name?.qualified ?? '(anonymous)'} expects 2 arguments, but got ${arguments.length}.',
      );
    }
    return _function(context, arguments[0], arguments[1]);
  }
}

class _XPathFunction3 extends XPathFunctionItem {
  const new(this.name, this._function);

  @override
  final XmlName? name;

  final XPathFunction3 _function;

  @override
  int get arity => 3;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != 3) {
      throw XPathEvaluationException(
        'Function ${name?.qualified ?? '(anonymous)'} expects 3 arguments, but got ${arguments.length}.',
      );
    }
    return _function(context, arguments[0], arguments[1], arguments[2]);
  }
}

class _XPathFunctionN extends XPathFunctionItem {
  const new(this.name, this.arity, this._function);

  const new named({this.name, required this.arity, required this._function});

  @override
  final XmlName? name;

  @override
  final int arity;

  final XPathFunctionN _function;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length != arity) {
      throw XPathEvaluationException(
        'Function ${name?.qualified ?? '(anonymous)'} expects $arity arguments, but got ${arguments.length}.',
      );
    }
    return _function(context, arguments);
  }
}

/// An [XPathFunctionItem] that represents an overloaded function group keyed by arity.
class XPathOverloadedFunction extends XPathFunctionItem {
  const new(this.name, this.byArity);

  @override
  final XmlName? name;

  final Map<int, XPathFunctionItem> byArity;

  @override
  int get arity => byArity.keys.reduce((a, b) => a < b ? a : b);

  XPathFunctionItem? getForArity(int arity) => byArity[arity];

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    final func = byArity[arguments.length];
    if (func != null) {
      return func.call(context, arguments);
    }
    throw XPathEvaluationException(
      'Function ${name?.qualified ?? '(anonymous)'} does not support arity ${arguments.length}. Available arities: ${byArity.keys.toList()..sort()}.',
    );
  }
}

class _XPathVariadicFunction extends XPathFunctionItem {
  const new(this.name, this.minArity, this._function);

  @override
  final XmlName? name;

  final int minArity;

  @override
  int get arity => minArity;

  @override
  bool get isVariadic => true;

  final XPathFunctionN _function;

  @override
  XPathSequence call(XPathContext context, List<XPathSequence> arguments) {
    if (arguments.length < minArity) {
      throw XPathEvaluationException(
        'Function ${name?.qualified ?? '(anonymous)'} expects at least $minArity arguments, but got ${arguments.length}.',
      );
    }
    return _function(context, arguments);
  }
}
