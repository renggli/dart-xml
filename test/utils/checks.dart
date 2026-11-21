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

final throwsStateError = Condition.it<void Function()>()..throws<StateError>();
final throwsArgumentError = Condition.it<void Function()>()
  ..throws<ArgumentError>();
final throwsUnsupportedError = Condition.it<void Function()>()
  ..throws<UnsupportedError>();
final throwsRangeError = Condition.it<void Function()>()..throws<RangeError>();
final throwsConcurrentModificationError = Condition.it<void Function()>()
  ..throws<ConcurrentModificationError>();

/// Domain-specific checks on [XmlNode].
extension XmlNodeChecks<T extends XmlNode> on Subject<T> {
  Subject<String> get outerXml => has('outerXml', (node) => node.outerXml);
  Subject<XmlNodeType> get nodeType => has('nodeType', (node) => node.nodeType);
  Subject<XmlNode?> get parent => has('parent', (node) => node.parent);
  Subject<int> get depth => has('depth', (node) => node.depth);
  Subject<List<XmlNode>> get children =>
      has('children', (node) => node.children);
  Subject<List<XmlAttribute>> get attributes =>
      has('attributes', (node) => node.attributes);

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
    'allNamespaces',
    (node) => [node, ...node.descendants]
        .whereType<XmlHasName>()
        .fold<Map<String, String?>>({}, (map, n) {
          map[n.qualifiedName] = n.namespaceUri;
          return map;
        }),
  );

  void hasNamespaces(Map<String, String?> expected) =>
      allNamespaces.deepEquals(expected);
}

/// Returns a [Condition] on [XmlNode] that checks string serialization or
/// structural equality.
Condition<T> isXmlNode<T extends XmlNode>(Object? expected) {
  final subject = Condition.it<T>();
  switch (expected) {
    case String():
      subject.has('outerXml', (n) => n.outerXml).equals(expected);
    case XmlNode():
      subject.isEqualNode(expected);
    default:
      throw ArgumentError.value(expected, 'expected', 'Invalid type');
  }
  return subject;
}

/// Domain-specific checks on [XmlName].
extension XmlNameChecks on Subject<XmlName> {
  Subject<String> get qualified => has('qualified', (name) => name.qualified);
  Subject<String?> get prefix => has('prefix', (name) => name.prefix);
  Subject<String> get local => has('local', (name) => name.local);
  Subject<String?> get namespaceUri =>
      has('namespaceUri', (name) => name.namespaceUri);
  Subject<String> get extendedQualified =>
      has('extendedQualified', (name) => name.extendedQualified);
  Subject<String> get asString => has('toString', (name) => name.toString());
}

/// Domain-specific checks on [XmlParentException].
extension XmlParentExceptionChecks on Subject<XmlParentException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<Object> get node => has('node', (e) => e.node);
  Subject<XmlNode?> get parent => has('parent', (e) => e.parent);
}

Condition<XmlParentException> isXmlParentException({
  Object? message,
  Object? node,
  Object? parent,
}) {
  final subject = Condition.it<XmlParentException>();
  if (message != null) {
    if (message is String) {
      subject.message.equals(message);
    } else if (message is Condition<String>) {
      subject.message.which(message);
    }
  } else {
    subject.message.isNotEmpty;
  }
  if (node != null) {
    if (node is Condition<Object>) {
      subject.node.which(node);
    } else {
      subject.node.equals(node);
    }
  }
  if (parent != null) {
    if (parent is Condition<XmlNode?>) {
      subject.parent.which(parent);
    } else {
      subject.parent.equals(parent as XmlNode?);
    }
  }
  return subject;
}

/// Domain-specific checks on [XmlParserException].
extension XmlParserExceptionChecks on Subject<XmlParserException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<String?> get buffer => has('buffer', (e) => e.buffer);
  Subject<int?> get position => has('position', (e) => e.position);
  Subject<int> get line => has('line', (e) => e.line);
  Subject<int> get column => has('column', (e) => e.column);
}

Condition<XmlParserException> isXmlParserException({
  Object? message,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) {
  final subject = Condition.it<XmlParserException>();
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      subject.message.which(message);
    }
  } else {
    subject.message.isNotEmpty;
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      subject.buffer.which(buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      subject.position.which(position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      subject.line.which(line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      subject.column.which(column);
    } else {
      subject.column.equals(column as int);
    }
  }
  return subject;
}

/// Domain-specific checks on [XmlNodeTypeException].
extension XmlNodeTypeExceptionChecks on Subject<XmlNodeTypeException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<XmlNode> get node => has('node', (e) => e.node);
  Subject<Iterable<XmlNodeType>> get types => has('types', (e) => e.types);
}

Condition<XmlNodeTypeException> isXmlNodeTypeException({
  String? message,
  Condition<String>? messageCondition,
  XmlNode? node,
  Condition<XmlNode>? nodeCondition,
  Iterable<XmlNodeType>? types,
  Condition<Iterable<XmlNodeType>>? typesCondition,
}) {
  final subject = Condition.it<XmlNodeTypeException>();
  if (message != null) {
    subject.message.equals(message);
  } else if (messageCondition != null) {
    subject.message.which(messageCondition);
  } else {
    subject.message.isNotEmpty;
  }
  if (node != null) {
    subject.node.equals(node);
  } else if (nodeCondition != null) {
    subject.node.which(nodeCondition);
  }
  if (types != null) {
    subject.types.deepEquals(types);
  } else if (typesCondition != null) {
    subject.types.which(typesCondition);
  }
  return subject;
}

/// Domain-specific checks on [XmlTagException].
extension XmlTagExceptionChecks on Subject<XmlTagException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<String?> get expectedName =>
      has('expectedName', (e) => e.expectedName);
  Subject<String?> get actualName => has('actualName', (e) => e.actualName);
  Subject<String?> get buffer => has('buffer', (e) => e.buffer);
  Subject<int?> get position => has('position', (e) => e.position);
  Subject<int> get line => has('line', (e) => e.line);
  Subject<int> get column => has('column', (e) => e.column);
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
}) {
  final subject = Condition.it<XmlTagException>();
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      subject.message.which(message);
    }
  } else {
    subject.message.isNotEmpty;
  }
  if (expectedName != null) {
    subject.expectedName.equals(expectedName);
  } else if (expectedNameCondition != null) {
    subject.expectedName.which(expectedNameCondition);
  }
  if (actualName != null) {
    subject.actualName.equals(actualName);
  } else if (actualNameCondition != null) {
    subject.actualName.which(actualNameCondition);
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      subject.buffer.which(buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      subject.position.which(position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      subject.line.which(line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      subject.column.which(column);
    } else {
      subject.column.equals(column as int);
    }
  }
  return subject;
}

/// Domain-specific checks on [XmlNamespaceException].
extension XmlNamespaceExceptionChecks on Subject<XmlNamespaceException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<String?> get buffer => has('buffer', (e) => e.buffer);
  Subject<int?> get position => has('position', (e) => e.position);
  Subject<int> get line => has('line', (e) => e.line);
  Subject<int> get column => has('column', (e) => e.column);
}

Condition<XmlNamespaceException> isXmlNamespaceException({
  Object? message,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) {
  final subject = Condition.it<XmlNamespaceException>();
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      subject.message.which(message);
    }
  } else {
    subject.message.isNotEmpty;
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      subject.buffer.which(buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      subject.position.which(position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      subject.line.which(line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      subject.column.which(column);
    } else {
      subject.column.equals(column as int);
    }
  }
  return subject;
}

/// Domain-specific checks on [XPathParserException].
extension XPathParserExceptionChecks on Subject<XPathParserException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<String?> get buffer => has('buffer', (e) => e.buffer);
  Subject<int?> get position => has('position', (e) => e.position);
  Subject<int> get line => has('line', (e) => e.line);
  Subject<int> get column => has('column', (e) => e.column);
}

Condition<XPathParserException> isXPathParserException({
  Object? message,
  Object? buffer,
  Object? position,
  Object? line,
  Object? column,
}) {
  final subject = Condition.it<XPathParserException>();
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      subject.message.which(message);
    }
  } else {
    subject.message.isNotEmpty;
  }
  if (buffer != null) {
    if (buffer is Condition<String?>) {
      subject.buffer.which(buffer);
    } else {
      subject.buffer.equals(buffer as String?);
    }
  }
  if (position != null) {
    if (position is Condition<int?>) {
      subject.position.which(position);
    } else {
      subject.position.equals(position as int?);
    }
  }
  if (line != null) {
    if (line is Condition<int>) {
      subject.line.which(line);
    } else {
      subject.line.equals(line as int);
    }
  }
  if (column != null) {
    if (column is Condition<int>) {
      subject.column.which(column);
    } else {
      subject.column.equals(column as int);
    }
  }
  return subject;
}

/// Domain-specific checks on [XPathEvaluationException].
extension XPathEvaluationExceptionChecks on Subject<XPathEvaluationException> {
  Subject<String> get message => has('message', (e) => e.message);
  Subject<XPathErrorCode?> get errorCode =>
      has('errorCode', (e) => e.errorCode);
}

Condition<XPathEvaluationException> isXPathEvaluationException({
  Object? message,
  XPathErrorCode? errorCode,
}) {
  final subject = Condition.it<XPathEvaluationException>();
  if (message != null) {
    if (message is String) {
      subject.message.contains(message);
    } else if (message is Condition<String>) {
      subject.message.which(message);
    }
  } else {
    subject.message.isNotEmpty;
  }
  if (errorCode != null) {
    subject.errorCode.equals(errorCode);
  }
  return subject;
}

Object? unwrapXPathItem(XPathItem item) => item.toValue();

/// Condition or sentinel representing an empty sequence.
const isEmpty = _IsEmpty();

class _IsEmpty {
  const new();
  void call(Subject<Object?> subject) {
    subject
        .has('isEmpty', (o) {
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
        })
        .equals(true);
  }
}

/// Condition or sentinel representing NaN.
const isNaN = _IsNaN();

class _IsNaN {
  const new();
  void call(Subject<Object?> subject) {
    if (subject is Subject<num>) {
      subject.isNaN;
    } else if (subject is Subject<XPathDouble>) {
      subject.has('isNaN', (d) => d.value.isNaN).isTrue;
    }
  }
}

/// Condition checking that the subject is an instance of [T].
Condition<Object?> isA<T>() => Condition.it<Object?>()..isA<T>();

/// Domain-specific checks on [XPathSequence].
Condition<XPathSequence> isXPathSequence(Object? expected) =>
    Condition.it<XPathSequence>()..isXPathSequence(expected);

extension XPathSequenceChecks on Subject<XPathSequence> {
  Subject<int> get length => has('length', (s) => s.length);
  void get isEmpty => has('isEmpty', (s) => s.isEmpty).isTrue;
  void get isNotEmpty => has('isNotEmpty', (s) => s.isNotEmpty).isTrue;
  Subject<List<XPathItem>> get items => has('items', (s) => s.toList());
  Subject<List<Object?>> get unwrapped =>
      has('unwrapped', (s) => s.map(unwrapXPathItem).toList());

  void isXPathSequence(Object? expected) {
    if (expected == null || expected is _IsEmpty) {
      isEmpty;
    } else if (expected is Condition<XPathSequence>) {
      which(expected);
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
          if (exp is Condition<Object?>) {
            try {
              check<Object?>(act).which(exp);
              continue;
            } on TestFailure {
              try {
                check<Object?>(raw).which(exp);
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
