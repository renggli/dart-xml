/// Runner of the official XPath and XQpery W3C test-suite.
///
/// This test-suite is not meant to replace unit-tests. It is purely used to
/// identify gaps and discrepancies of the library with the standard.
library;

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/types/boolean.dart';
import 'package:xml/src/xpath/types/node.dart';
import 'package:xml/src/xpath/types/number.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

/// URL of the official XPath and XQpery W3C test-suite.
const githubRepository = 'https://github.com/w3c/qt3tests.git';

/// Path to the local catalog file.
final catalogFile = File('.qt3tests/catalog.xml').absolute;

/// Test names that are skipped.
const skippedTests = <String>{};

void main() {
  downloadAndUpdateTestData();
  runFullTestCatalog();
}

void downloadAndUpdateTestData() {
  const depthParameter = '--depth=1';
  final dataDirectory = catalogFile.parent;
  if (!dataDirectory.existsSync()) {
    final result = Process.runSync('git', [
      'clone',
      githubRepository,
      dataDirectory.path,
      depthParameter,
    ]);
    if (result.exitCode != 0) {
      throw StateError('Could not download QT3 test suite: ${result.stderr}');
    }
  } else {
    final result = Process.runSync('git', [
      '-C',
      dataDirectory.path,
      'pull',
      depthParameter,
    ]);
    if (result.exitCode != 0) {
      throw StateError('Could not update QT3 test suite: ${result.stderr}');
    }
  }
}

void runFullTestCatalog() {
  final result = TestResult();
  TestCatalog(catalogFile).run(result);
  stdout.writeln();
  stdout.writeln('${result.testSuites} test-suites');
  stdout.writeln('${result.testCases} test-cases');
  stdout.writeln();
  for (final MapEntry(key: label, value: count) in {
    'successes': result.successes,
    'skipped': result.skipped,
    'failures': result.failures,
    'errors': result.errors,
  }.entries) {
    stdout.writeln(
      '${count.toString().padLeft(5)} '
      '${(100 * count / result.testCases).toStringAsFixed(1).padLeft(4)}% '
      '$label',
    );
  }
}

class TestCatalog {
  TestCatalog(this.file);

  final File file;

  late final XmlDocument document = XmlDocument.parse(file.readAsStringSync());
  late final Map<String, TestEnvironment> environments = Map.fromEntries(
    document.rootElement
        .findElements('environment')
        .map((element) => TestEnvironment(file.parent, element))
        .map((environment) => MapEntry(environment.name, environment)),
  );
  late final List<TestSet> testSets = document.rootElement
      .findElements('test-set')
      .map(
        (node) => TestSet(
          this,
          node.getAttribute('name')!,
          File('${file.parent.path}/${node.getAttribute('file')!}'),
        ),
      )
      .toList();

  void run(TestResult result) {
    for (final testSet in testSets) {
      if (isSupported(testSet.document.rootElement)) {
        testSet.run(result);
      }
    }
  }
}

class TestSet {
  TestSet(this.catalog, this.name, this.file);

  final TestCatalog catalog;
  final String name;
  final File file;

  late final XmlDocument document = XmlDocument.parse(file.readAsStringSync());
  late final Map<String, TestEnvironment> environments = Map.fromEntries(
    document.rootElement
        .findElements('environment')
        .map((element) => TestEnvironment(file.parent, element))
        .map((environment) => MapEntry(environment.name, environment)),
  );
  late final Iterable<TestCase> testCases = document.rootElement
      .findAllElements('test-case')
      .where(isSupported)
      .map((element) => TestCase(catalog, this, element));

  void run(TestResult result) {
    result.testSuites++;
    stdout.writeln(name);
    for (final testCase in testCases) {
      testCase.run(result);
    }
  }
}

class TestCase {
  TestCase(this.catalog, this.testSet, this.element);

  final TestCatalog catalog;
  final TestSet testSet;
  final XmlElement element;

  late final name = element.getAttribute('name')!;

  void run(TestResult result) {
    result.testCases++;
    stdout.write('\t$name');
    if (skippedTests.contains(name)) {
      stdout.writeln(': SKIPPED');
      result.skipped++;
      return;
    }
    final stopwatch = Stopwatch()..start();
    try {
      _test();
      stopwatch.stop();
      stdout.writeln(': OK ${formatStopwatch(stopwatch)}');
      result.successes++;
    } on TestFailure catch (error) {
      stopwatch.stop();
      stdout.writeln(
        ': FAILURE ${formatStopwatch(stopwatch)} - ${formatMessage(error.message)}',
      );
      result.failures++;
    } catch (error) {
      final message = error is StateError
          ? error.message
          : error is UnsupportedError
          ? (error.message ?? 'Unsupported')
          : error.toString();
      stdout.writeln(
        ': ERROR ${formatStopwatch(stopwatch)} - ${formatMessage(message)}',
      );
      result.errors++;
    }
  }

  void _test() {
    final environment = _getEnvironment();
    final context = environment.context;
    final test = _getTest();
    if (test == null) {
      throw StateError('Test expression not found: $element');
    }
    final result = _getResult();
    if (result == null) {
      throw StateError('Test result not found: $element');
    }
    late final Object evaluation;
    try {
      // Force evaluation of lazy sequences.
      evaluation = XPathSequence(context.evaluate(test).toList());
    } catch (exception) {
      evaluation = exception;
    }
    verifyResult(result, evaluation, context);
  }

  TestEnvironment _getEnvironment() {
    final envElement = element.findElements('environment').singleOrNull;
    final ref = envElement?.getAttribute('ref');
    if (ref != null) {
      final environment =
          catalog.environments[ref] ?? testSet.environments[ref];
      if (environment == null) {
        throw StateError('Environment "$ref" not found');
      }
      return environment;
    }
    if (envElement != null) {
      return TestEnvironment(testSet.file.parent, envElement);
    }
    final empty =
        catalog.environments['empty'] ?? testSet.environments['empty'];
    if (empty == null) {
      throw StateError('Environment "empty" not found');
    }
    return empty;
  }

  String? _getTest() => element.findElements('test').singleOrNull?.innerText;

  XmlElement? _getResult() =>
      element.findElements('result').singleOrNull?.childElements.singleOrNull;
}

class TestEnvironment {
  TestEnvironment(this.directory, this.element);

  final Directory directory;
  final XmlElement element;

  late final String name = element.getAttribute('name') ?? '<inline>';

  late final XmlDocument? source = _getSource();

  XPathContext get context => XPathContext.canonical(
    source ?? XPathSequence.empty,
  ).copy(variables: _getParams());

  XmlDocument? _getSource() {
    final file = element
        .findElements('source')
        .singleOrNull
        ?.getAttribute('file');
    if (file == null) return null;
    return XmlDocument.parse(
      File('${directory.path}/$file').readAsStringSync(),
    );
  }

  Map<String, Object> _getParams() {
    final params = <String, Object>{};
    for (final param in element.findElements('param')) {
      final name = param.getAttribute('name');
      final select = param.getAttribute('select');
      if (name != null && select != null) {
        params[name] = XPathContext.canonical(
          source ?? XPathSequence.empty,
        ).evaluate(select);
      }
    }
    return params;
  }
}

class TestResult {
  var testSuites = 0;
  var testCases = 0;
  var skipped = 0;
  var successes = 0;
  var failures = 0;
  var errors = 0;
}

class TestFailure extends StateError {
  TestFailure(super.message);
}

void verifyResult(XmlElement element, Object result, XPathContext context) {
  // First handle the primitive operations.
  switch (element.localName) {
    case 'error':
      if (result is! Error && result is! Exception) {
        throw TestFailure('Expected error, but got $result');
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
      final evaluation = XPathContext.canonical(
        XPathSequence.empty,
      ).copy(variables: {'result': result}).evaluate(element.innerText);
      if (xsBoolean.cast(evaluation) != true) {
        throw TestFailure(
          'Expected true for ${element.innerText} with result=$result, '
          'but got $evaluation',
        );
      }
    case 'assert-eq':
    case 'assert-deep-eq':
      final expected = context.evaluate(element.innerText);
      final resultString = formatSequence(result);
      final expectedString = formatSequence(expected);
      if (resultString != expectedString) {
        throw TestFailure('Expected $expectedString, but got $resultString');
      }
    case 'assert-empty':
      if (result.isNotEmpty) {
        throw TestFailure('Expected empty, but got $result');
      }
    case 'assert-true':
      if (xsBoolean.cast(result) != true) {
        throw TestFailure('Expected true, but got $result');
      }
    case 'assert-false':
      if (xsBoolean.cast(result) != false) {
        throw TestFailure('Expected false, but got $result');
      }
    case 'assert-string-value':
      final string = result.map(xsString.cast).join(' ');
      if (string != element.innerText) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-number-value':
      if (xsNumeric.cast(result) != double.parse(element.innerText)) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-xml':
      final xml = XmlDocument.parse(element.innerText);
      if (xsNode.cast(result).toXmlString(pretty: true) !=
          xml.rootElement.toXmlString(pretty: true)) {
        throw TestFailure('Expected $xml, but got $result');
      }
    case 'assert-type':
      final evaluation = XPathContext.canonical(XPathSequence.empty)
          .copy(variables: {'result': result})
          .evaluate('\$result instance of ${element.innerText}');
      if (xsBoolean.cast(evaluation) != true) {
        throw TestFailure(
          'Expected true for ${element.innerText} with result=$result, '
          'to be of type ${element.innerText}',
        );
      }
    case 'assert-permutation':
      final expected = XPathContext.canonical(
        XPathSequence.empty,
      ).evaluate(element.innerText);
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

/// We only support XPath tests.
bool isSupported(XmlElement element) {
  for (final dependency in element.findElements('dependency')) {
    if (dependency.getAttribute('type') == 'spec') {
      final value = dependency.getAttribute('value') ?? '';
      final specs = value.split(' ');
      if (specs.any((spec) => spec.startsWith('XP'))) {
        return true; // XPath tests are supported.
      }
      if (specs.any((spec) => spec.startsWith('XQ'))) {
        return false; // XQuery tests are not supported.
      }
    }
  }
  return true;
}

/// Helper to textualize a sequence for comparison.
String formatSequence(XPathSequence sequence) =>
    '(${sequence.map((item) {
      try {
        return xsString.cast(item);
      } catch (_) {
        return item.toString();
      }
    }).join(', ')})';

/// Helper to format a stopwatch duration.
String formatStopwatch(Stopwatch stopwatch) =>
    '[${(stopwatch.elapsed.inMicroseconds / 1000).toStringAsFixed(3)}ms]';

/// Helper to format a error message.
String formatMessage(String message) {
  final normalize = message.trim().replaceAll(RegExp(r'\s+'), ' ');
  return normalize.length > 80 ? '${normalize.substring(0, 75)}...' : normalize;
}
