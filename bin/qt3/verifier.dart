import 'package:collection/collection.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/operators/comparison.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import 'utils.dart';

/// Exception thrown when a test assertion fails.
class TestFailure extends StateError {
  new(super.message);
}

/// Verifies that [result] matches the expected assertion defined in [element].
void verifyResult(XmlElement element, Object result, XPathContext context) {
  // First handle primitive operations.
  switch (element.localName) {
    case 'error':
      if (result is! Error && result is! Exception) {
        throw TestFailure('Expected error, but got $result');
      }
      final code = element.getAttribute('code');
      if (code != null && code != '*' && result is XPathEvaluationException) {
        final expectedCode = code.startsWith('Q{')
            ? code.split('}').last
            : (code.contains(':') ? code.split(':').last : code);
        if (result.errorCode.name != expectedCode &&
            result.errorCode.code != expectedCode &&
            result.errorCode.qname.stringValue != code) {
          throw TestFailure(
            'Expected error code $code, but got ${result.errorCode.name} (${result.message})',
          );
        }
      }
      return;
    case 'all-of':
      for (final child in element.childElements) {
        verifyResult(child, result, context);
      }
      return;
    case 'any-of':
      final errors = <Object>[];
      for (final child in element.childElements) {
        try {
          verifyResult(child, result, context);
          return;
        } catch (error) {
          errors.add(error);
        }
      }
      throw errors.first;
  }

  // If we don't have a sequence at this point, this must be an error.
  if (result is! XPathSequence) throw result;

  // Execute the different assertion types.
  switch (element.localName) {
    case 'assert':
      final evaluation = context.configuration
          .copy(variables: {'result': result})
          .context()
          .evaluate(element.innerText);
      if (evaluation.ebv != true) {
        throw TestFailure(
          'Expected true for ${element.innerText} with result=$result, '
          'but got $evaluation',
        );
      }
    case 'assert-eq':
      final expected = context.evaluate(element.innerText);
      final resultString = formatSequence(result);
      final expectedString = formatSequence(expected);
      if (resultString != expectedString) {
        try {
          final eq = opValueEqual(result, expected);
          if (eq.ebv != true) {
            throw TestFailure(
              'Expected $expectedString, but got $resultString',
            );
          }
        } catch (e) {
          if (e is TestFailure) rethrow;
          throw TestFailure('Expected $expectedString, but got $resultString');
        }
      }
    case 'assert-deep-eq':
      final expected = context.evaluate(element.innerText);
      final comparison = context.configuration
          .getFunctionByString('fn:deep-equal', 2)
          .call(context, [result, expected]);
      if (comparison.ebv != true) {
        throw TestFailure(
          'Expected $result to be deep-equal to ${element.innerText} ($expected)',
        );
      }
    case 'assert-empty':
      if (result.isNotEmpty) {
        throw TestFailure('Expected empty, but got $result');
      }
    case 'assert-true':
      if (result.ebv != true) {
        throw TestFailure('Expected true, but got $result');
      }
    case 'assert-false':
      if (result.ebv != false) {
        throw TestFailure('Expected false, but got $result');
      }
    case 'assert-string-value':
      final string = result.map((item) => item.stringValue).join(' ');
      if (string != element.innerText) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-number-value':
      final first = result.atomize().firstOrNull;
      final numVal = switch (first) {
        final XPathNumeric n => n.toDouble(),
        _ => double.nan,
      };
      if (numVal != double.parse(element.innerText)) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-xml':
      final ignorePrefixes = element.getAttribute('ignore-prefixes') == 'true';
      final expectedFragment = XmlDocumentFragment.parse(element.innerText);
      final expectedNodes = _flatten(expectedFragment.children);
      final resultNodes = _flatten(result.nodes);
      final expectedStr = _serializeNodes(
        expectedNodes,
        ignorePrefixes: ignorePrefixes,
      );
      final resultStr = _serializeNodes(
        resultNodes,
        ignorePrefixes: ignorePrefixes,
      );
      if (expectedStr != resultStr) {
        throw TestFailure(
          'Expected:\n$expectedStr\n\n'
          'But got:\n$resultStr',
        );
      }
    case 'assert-type':
      final evaluation = context.configuration
          .copy(variables: {'result': result})
          .context()
          .evaluate(r'$result instance of ' + element.innerText);
      if (evaluation.ebv != true) {
        throw TestFailure(
          'Expected true for ${element.innerText} with result=$result, '
          'to be of type ${element.innerText}',
        );
      }
    case 'assert-permutation':
      final expected = XPathConfiguration.standard().context().evaluate(
        element.innerText,
      );
      if (const SetEquality<Object>().equals(
        result.toSet(),
        expected.toSet(),
      )) {
        return;
      }
      throw TestFailure(
        'Expected $result to be a permutation of ${element.innerText}',
      );
    case 'assert-count':
      final actual = result.length;
      final expected = int.parse(element.innerText);
      if (actual != expected) {
        throw TestFailure('Expected $expected items, but got $actual $result');
      }
    default:
      throw StateError('Unknown result type: $element');
  }
}

List<XmlNode> _flatten(Iterable<XmlNode> nodes) {
  final list = <XmlNode>[];
  for (final node in nodes) {
    if (node is XmlDocument || node is XmlDocumentFragment) {
      list.addAll(_flatten(node.children));
    } else {
      list.add(node);
    }
  }
  return list;
}

String _serializeNodes(List<XmlNode> nodes, {required bool ignorePrefixes}) {
  final buffer = StringBuffer();
  final writer = _TestRunnerPrettyWriter(
    buffer,
    ignorePrefixes: ignorePrefixes,
  );
  writer.writeIterable(
    writer.normalizeText(nodes),
    writer.newLine + writer.indent * writer.level,
  );
  return buffer.toString();
}

class _TestRunnerPrettyWriter extends XmlPrettyWriter {
  new(super.buffer, {required this.ignorePrefixes})
    : super(
        sortAttributes: (first, second) =>
            (ignorePrefixes ? first.name.local : first.name.qualified)
                .compareTo(
                  ignorePrefixes ? second.name.local : second.name.qualified,
                ),
      );

  final bool ignorePrefixes;

  @override
  void visitName(XmlName name) {
    if (ignorePrefixes) {
      buffer.write(name.local);
    } else {
      super.visitName(name);
    }
  }

  @override
  void visitDeclaration(XmlDeclaration node) {
    // Ignore XML declarations
  }

  @override
  void visitProcessing(XmlProcessing node) {
    if (node.target == 'xml') {
      // Ignore pseudo-xml declarations
      return;
    }
    super.visitProcessing(node);
  }

  @override
  List<XmlNode> normalizeText(List<XmlNode> nodes) {
    final filtered = nodes.where(
      (node) =>
          node is! XmlDeclaration &&
          !(node is XmlProcessing && node.target == 'xml'),
    );
    return super.normalizeText(filtered.toList());
  }

  @override
  List<XmlAttribute> normalizeAttributes(List<XmlAttribute> attributes) {
    final filtered = attributes.where(
      (attr) => attr.name.prefix != 'xmlns' && attr.name.local != 'xmlns',
    );
    return super.normalizeAttributes(filtered.toList());
  }
}
