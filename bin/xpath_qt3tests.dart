import 'dart:io';

import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/src/xpath/evaluation/functions.dart';
import 'package:xml/src/xpath/types/boolean.dart';
import 'package:xml/src/xpath/types/node.dart';
import 'package:xml/src/xpath/types/number.dart';
import 'package:xml/src/xpath/types/string.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

const githubRepository = 'https://github.com/w3c/qt3tests.git';
final catalogFile = File('.qt3tests/catalog.xml').absolute;

// These tests are skipped because they are extremely slow.
const skippedTests = {
  'cbcl-subsequence-010',
  'cbcl-subsequence-011',
  'cbcl-subsequence-012',
  'cbcl-subsequence-013',
  'cbcl-subsequence-014',
  'cbcl-codepoints-to-string-021',
};

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
      testSet.run(result);
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
    try {
      _test();
      stdout.writeln(': OK');
      result.successes++;
    } on TestFailure catch (error) {
      stdout.writeln(': FAILURE - ${error.message}');
      result.failures++;
    } catch (error) {
      final message = error is StateError
          ? error.message
          : error is UnsupportedError
          ? error.message
          : error.toString();
      stdout.writeln(': ERROR - $message');
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
      evaluation = context.evaluate(test);
    } catch (exception) {
      evaluation = exception;
    }
    verifyResult(result, evaluation);
  }

  TestEnvironment _getEnvironment() {
    final ref =
        element.findElements('environment').singleOrNull?.getAttribute('ref') ??
        'empty';
    final environment = catalog.environments[ref] ?? testSet.environments[ref];
    if (environment == null) {
      throw StateError('Environment "$ref" not found');
    }
    return environment;
  }

  String? _getTest() => element.findElements('test').singleOrNull?.innerText;

  XmlElement? _getResult() =>
      element.findElements('result').singleOrNull?.childElements.singleOrNull;
}

class TestEnvironment {
  TestEnvironment(this.directory, this.element);

  final Directory directory;
  final XmlElement element;

  late final String name = element.getAttribute('name')!;

  late final XmlDocument? source = _getSource();

  XPathContext get context =>
      XPathContext(source ?? XPathSequence.empty, functions: standardFunctions);

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

void verifyResult(XmlElement element, Object result) {
  switch (element.localName) {
    case 'error':
      if (result is! Error) {
        throw TestFailure('Expected error, but got $result');
      }
    case 'assert':
      final evaluation = XPathContext(
        XPathSequence.empty,
        variables: {'result': result.toXPathSequence()},
      ).evaluate(element.innerText);
      if (!evaluation.toXPathBoolean()) {
        throw TestFailure(
          'Expected true for ${element.innerText} with result=$result, '
          'but got $evaluation',
        );
      }
    case 'assert-eq':
    case 'assert-deep-eq':
      if (result.toXPathString() != element.innerText) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-empty':
      if (result is! XPathSequence || result.isNotEmpty) {
        throw TestFailure('Expected empty, but got $result');
      }
    case 'assert-true':
      if (result.toXPathBoolean() != true) {
        throw TestFailure('Expected true, but got $result');
      }
    case 'assert-false':
      if (result.toXPathBoolean() != false) {
        throw TestFailure('Expected false, but got $result');
      }
    case 'assert-string-value':
      if (result.toXPathString() != element.innerText) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-number-value':
      if (result.toXPathNumber() != double.parse(element.innerText)) {
        throw TestFailure('Expected ${element.innerText}, but got $result');
      }
    case 'assert-xml':
      final xml = XmlDocument.parse(element.innerText);
      if (result.toXPathNode().toXmlString(pretty: true) !=
          xml.rootElement.toXmlString(pretty: true)) {
        throw TestFailure('Expected $xml, but got $result');
      }
    case 'all-of':
      for (final child in element.childElements) {
        verifyResult(child, result);
      }
    case 'any-of':
      final errors = <Object>[];
      for (final child in element.childElements) {
        try {
          verifyResult(child, result);
          return;
        } catch (error) {
          errors.add(error);
        }
      }
      throw errors.first;
    case 'assert-type':
    case 'assert-permutation':
    default:
      throw StateError('Unknown result type: $element');
  }
}
