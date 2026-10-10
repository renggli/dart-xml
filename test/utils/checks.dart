import 'package:checks/checks.dart';
import 'package:checks/context.dart';
import 'package:test/scaffolding.dart' show TestFailure;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

/// Returns `true`, if assertions are enabled.
bool hasAssertionsEnabled() {
  try {
    assert(false);
    return false;
  } catch (exception) {
    return true;
  }
}

void throwsStateError(Subject<void Function()> it) => it.throws<StateError>();
void throwsArgumentError(Subject<void Function()> it) =>
    it.throws<ArgumentError>();
void throwsUnsupportedError(Subject<void Function()> it) =>
    it.throws<UnsupportedError>();
void throwsRangeError(Subject<void Function()> it) => it.throws<RangeError>();
void throwsConcurrentModificationError(Subject<void Function()> it) =>
    it.throws<ConcurrentModificationError>();

/// Domain-specific checks on [XmlNode].
extension XmlNodeChecks<T extends XmlNode> on Subject<T> {
  Subject<String> get outerXml => has((node) => node.outerXml, 'outerXml');
  Subject<XmlNodeType> get nodeType => has((node) => node.nodeType, 'nodeType');
  Subject<XmlNode?> get parent => has((node) => node.parent, 'parent');
  Subject<int> get depth => has((node) => node.depth, 'depth');
  Subject<List<XmlNode>> get children =>
      has((node) => node.children, 'children');
  Subject<List<XmlAttribute>> get attributes =>
      has((node) => node.attributes, 'attributes');

  void isEqualNode(XmlNode other) {
    context.expect(() => ['is equal to node ${other.toXmlString()}'], (actual) {
      if (actual.isEqualNode(other)) return null;
      return Rejection(which: ['was ${actual.toXmlString()}']);
    });
  }

  void matchesNode(Object? expected) {
    switch (expected) {
      case String():
        outerXml.equals(expected);
      case XmlNode():
        isEqualNode(expected);
      default:
        throw ArgumentError.value(
          expected,
          'expected',
          'Invalid node expectation',
        );
    }
  }

  Subject<Map<String, String?>> get allNamespaces => has(
    (node) => [node, ...node.descendants]
        .whereType<XmlHasName>()
        .fold<Map<String, String?>>({}, (map, n) {
          map[n.qualifiedName] = n.namespaceUri;
          return map;
        }),
    'allNamespaces',
  );

  void hasNamespaces(Map<String, String?> expected) =>
      allNamespaces.deepEquals(expected);
}

/// Returns a [Condition] on [XmlNode] that checks string serialization or
/// structural equality.
Condition<XmlNode> isXmlNode<T extends XmlNode>(Object? expected) =>
    (Subject<XmlNode> subject) {
      final typed = subject.isA<T>();
      switch (expected) {
        case String():
          typed.has((n) => n.outerXml, 'outerXml').equals(expected);
        case XmlNode():
          typed.isEqualNode(expected);
        default:
          throw ArgumentError.value(expected, 'expected', 'Invalid type');
      }
    };

/// Domain-specific checks on [XmlName].
extension XmlNameChecks on Subject<XmlName> {
  Subject<String> get qualified => has((name) => name.qualified, 'qualified');
  Subject<String?> get prefix => has((name) => name.prefix, 'prefix');
  Subject<String> get local => has((name) => name.local, 'local');
  Subject<String?> get namespaceUri =>
      has((name) => name.namespaceUri, 'namespaceUri');
  Subject<String> get extendedQualified =>
      has((name) => name.extendedQualified, 'extendedQualified');
  Subject<String> get asString => has((name) => name.toString(), 'toString');
}

/// Domain-specific checks on [XmlParentException].
extension XmlParentExceptionChecks on Subject<XmlParentException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<Object> get node => has((e) => e.node, 'node');
  Subject<XmlNode?> get parent => has((e) => e.parent, 'parent');
}

Condition<XmlParentException> isXmlParentException({
  Object? message,
  Object? node,
  Object? parent,
}) => (Subject<XmlParentException> subject) {
  if (message != null) {
    if (message is String) {
      subject.message.equals(message);
    } else if (message is Condition<String>) {
      message(subject.message);
    }
  } else {
    subject.message.isNotEmpty();
  }
  if (node != null) {
    if (node is Condition<Object>) {
      node(subject.node);
    } else {
      subject.node.equals(node);
    }
  }
  if (parent != null) {
    if (parent is Condition<XmlNode?>) {
      parent(subject.parent);
    } else {
      subject.parent.equals(parent as XmlNode?);
    }
  }
};

/// Domain-specific checks on [XmlParserException].
extension XmlParserExceptionChecks on Subject<XmlParserException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<String?> get buffer => has((e) => e.buffer, 'buffer');
  Subject<int?> get position => has((e) => e.position, 'position');
  Subject<int> get line => has((e) => e.line, 'line');
  Subject<int> get column => has((e) => e.column, 'column');
}

Condition<XmlParserException> isXmlParserException({
  Object? message,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) => (Subject<XmlParserException> subject) {
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      message(subject.message);
    }
  } else {
    subject.message.isNotEmpty();
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      buffer(subject.buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      position(subject.position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      line(subject.line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      column(subject.column);
    } else {
      subject.column.equals(column as int);
    }
  }
};

/// Domain-specific checks on [XmlNodeTypeException].
extension XmlNodeTypeExceptionChecks on Subject<XmlNodeTypeException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<XmlNode> get node => has((e) => e.node, 'node');
  Subject<Iterable<XmlNodeType>> get types => has((e) => e.types, 'types');
}

Condition<XmlNodeTypeException> isXmlNodeTypeException({
  String? message,
  Condition<String>? messageCondition,
  XmlNode? node,
  Condition<XmlNode>? nodeCondition,
  Iterable<XmlNodeType>? types,
  Condition<Iterable<XmlNodeType>>? typesCondition,
}) => (Subject<XmlNodeTypeException> subject) {
  if (message != null) {
    subject.message.equals(message);
  } else if (messageCondition != null) {
    messageCondition(subject.message);
  } else {
    subject.message.isNotEmpty();
  }
  if (node != null) {
    subject.node.equals(node);
  } else if (nodeCondition != null) {
    nodeCondition(subject.node);
  }
  if (types != null) {
    subject.types.deepEquals(types);
  } else if (typesCondition != null) {
    typesCondition(subject.types);
  }
};

/// Domain-specific checks on [XmlTagException].
extension XmlTagExceptionChecks on Subject<XmlTagException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<String?> get expectedName =>
      has((e) => e.expectedName, 'expectedName');
  Subject<String?> get actualName => has((e) => e.actualName, 'actualName');
  Subject<String?> get buffer => has((e) => e.buffer, 'buffer');
  Subject<int?> get position => has((e) => e.position, 'position');
  Subject<int> get line => has((e) => e.line, 'line');
  Subject<int> get column => has((e) => e.column, 'column');
}

Condition<XmlTagException> isXmlTagException({
  Object? message,
  String? expectedName,
  Condition<String?>? expectedNameCondition,
  String? actualName,
  Condition<String?>? actualNameCondition,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) => (Subject<XmlTagException> subject) {
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      message(subject.message);
    }
  } else {
    subject.message.isNotEmpty();
  }
  if (expectedName != null) {
    subject.expectedName.equals(expectedName);
  } else if (expectedNameCondition != null) {
    expectedNameCondition(subject.expectedName);
  }
  if (actualName != null) {
    subject.actualName.equals(actualName);
  } else if (actualNameCondition != null) {
    actualNameCondition(subject.actualName);
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      buffer(subject.buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      position(subject.position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      line(subject.line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      column(subject.column);
    } else {
      subject.column.equals(column as int);
    }
  }
};

/// Domain-specific checks on [XmlNamespaceException].
extension XmlNamespaceExceptionChecks on Subject<XmlNamespaceException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<String?> get buffer => has((e) => e.buffer, 'buffer');
  Subject<int?> get position => has((e) => e.position, 'position');
  Subject<int> get line => has((e) => e.line, 'line');
  Subject<int> get column => has((e) => e.column, 'column');
}

Condition<XmlNamespaceException> isXmlNamespaceException({
  Object? message,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) => (Subject<XmlNamespaceException> subject) {
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      message(subject.message);
    }
  } else {
    subject.message.isNotEmpty();
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      buffer(subject.buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      position(subject.position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      line(subject.line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      column(subject.column);
    } else {
      subject.column.equals(column as int);
    }
  }
};

/// Domain-specific checks on [XPathParserException].
extension XPathParserExceptionChecks on Subject<XPathParserException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<String?> get buffer => has((e) => e.buffer, 'buffer');
  Subject<int?> get position => has((e) => e.position, 'position');
  Subject<int> get line => has((e) => e.line, 'line');
  Subject<int> get column => has((e) => e.column, 'column');
}

Condition<XPathParserException> isXPathParserException({
  Object? message,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) => (Subject<XPathParserException> subject) {
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      message(subject.message);
    }
  } else {
    subject.message.isNotEmpty();
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      buffer(subject.buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      position(subject.position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      line(subject.line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      column(subject.column);
    } else {
      subject.column.equals(column as int);
    }
  }
};

/// Domain-specific checks on [XPathEvaluationException].
extension XPathEvaluationExceptionChecks on Subject<XPathEvaluationException> {
  Subject<String> get message => has((e) => e.message, 'message');
  Subject<XPathErrorCode?> get errorCode =>
      has((e) => e.errorCode, 'errorCode');
}

Condition<XPathEvaluationException> isXPathEvaluationException({
  Object? message,
  XPathErrorCode? errorCode,
}) => (Subject<XPathEvaluationException> subject) {
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      message(subject.message);
    }
  } else {
    subject.message.isNotEmpty();
  }
  if (errorCode != null) {
    subject.errorCode.equals(errorCode);
  }
};

Object? unwrapXPathItem(XPathItem item) => item.toValue();

/// Condition or sentinel representing an empty sequence.
const isEmpty = _IsEmpty();

class _IsEmpty {
  const new();
  void call(Subject<Object?> subject) {
    subject
        .has((o) {
          if (o is XPathSequence) return o.isEmpty;
          if (o is Iterable) return o.isEmpty;
          if (o is Map) return o.isEmpty;
          if (o is String) return o.isEmpty;
          if (o is XPathArray) return o.isEmpty;
          if (o is XPathMap) return o.isEmpty;
          throw ArgumentError.value(
            o,
            'subject',
            'Unsupported type for isEmpty',
          );
        }, 'isEmpty')
        .equals(true);
  }
}

/// Condition or sentinel representing NaN.
const isNaN = _IsNaN();

class _IsNaN {
  const new();
  void call(Subject<Object?> subject) {
    if (subject is Subject<num>) {
      subject.isNaN();
    } else if (subject is Subject<XPathDouble>) {
      subject.has((d) => d.value.isNaN, 'isNaN').isTrue();
    }
  }
}

/// Condition checking that the subject is an instance of [T].
Condition<Object?> isA<T>() =>
    (Subject<Object?> subject) => subject.isA<T>();

/// Domain-specific checks on [XPathSequence].
Condition<XPathSequence> isXPathSequence(Object? expected) =>
    (Subject<XPathSequence> subject) => subject.isXPathSequence(expected);

extension XPathSequenceChecks on Subject<XPathSequence> {
  Subject<int> get length => has((s) => s.length, 'length');
  void isEmpty() => has((s) => s.isEmpty, 'isEmpty').isTrue();
  void isNotEmpty() => has((s) => s.isNotEmpty, 'isNotEmpty').isTrue();
  Subject<List<XPathItem>> get items => has((s) => s.toList(), 'items');
  Subject<List<Object?>> get unwrapped =>
      has((s) => s.map(unwrapXPathItem).toList(), 'unwrapped');

  void isXPathSequence(Object? expected) {
    if (expected == null || expected is _IsEmpty) {
      isEmpty();
    } else if (expected is Condition<XPathSequence>) {
      expected(this);
    } else if (expected is Iterable) {
      final expectedList = expected.toList();
      context.expect(() => ['is XPathSequence with items: $expectedList'], (
        actual,
      ) {
        final actualItems = actual.toList();
        final actualUnwrapped = actual.map(unwrapXPathItem).toList();
        if (actualItems.length != expectedList.length) {
          return Rejection(
            which: [
              'has length ${actualItems.length} but expected ${expectedList.length}',
              'actual items: $actualItems',
            ],
          );
        }
        for (var i = 0; i < actualItems.length; i++) {
          final raw = actualItems[i];
          final act = actualUnwrapped[i];
          final exp = expectedList[i];
          if (raw == exp) {
            continue;
          }
          if (exp is _IsEmpty) {
            if (act is Iterable && act.isEmpty) continue;
            if (act is Map && act.isEmpty) continue;
            if (act is String && act.isEmpty) continue;
            if (raw is XPathArray && raw.isEmpty) continue;
            if (raw is XPathMap && raw.isEmpty) continue;
            return Rejection(
              which: [
                'at index $i: expected empty item but got $act [raw: $raw]',
              ],
            );
          }
          if (exp is void Function(Subject<Object?>)) {
            try {
              check(act).which(exp);
              continue;
            } on TestFailure {
              try {
                check(raw).which(exp);
                continue;
              } on TestFailure catch (e) {
                return Rejection(
                  which: ['at index $i: condition failed: ${e.message}'],
                );
              }
            }
          } else if ((exp is _IsNaN || (exp is num && exp.isNaN)) &&
              ((act is num && act.isNaN) ||
                  (raw is XPathDouble && raw.value.isNaN))) {
            continue;
          } else if (exp is XmlNode && (act is XmlNode || raw is XPathNode)) {
            final node = act is XmlNode ? act : (raw as XPathNode).node;
            if (node.isEqualNode(exp)) {
              continue;
            }
            return Rejection(
              which: [
                'at index $i: expected node ${exp.toXmlString()} but got ${node.toXmlString()}',
              ],
            );
          } else if (_deepEquals(act, exp) || _deepEquals(raw, exp)) {
            continue;
          }
          return Rejection(
            which: [
              'at index $i: expected $exp (${exp.runtimeType}) but got $act (${act.runtimeType}) [raw: $raw (${raw.runtimeType})]',
            ],
          );
        }
        return null;
      });
    } else {
      unwrapped.deepEquals([expected]);
    }
  }
}

bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b) || a == b) return true;
  if (a is num && a.isNaN && b is num && b.isNaN) return true;
  if (a is Iterable && b is Iterable) {
    if (a.length != b.length) return false;
    final itA = a.iterator;
    final itB = b.iterator;
    while (itA.moveNext() && itB.moveNext()) {
      if (!_deepEquals(itA.current, itB.current)) return false;
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }
  return false;
}
