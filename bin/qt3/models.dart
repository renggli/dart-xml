import 'dart:convert';
import 'dart:io';

import 'package:xml/src/xpath/evaluation/context.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import 'options.dart';
import 'utils.dart';
import 'verifier.dart';

/// The root catalog containing environments and test sets.
class TestCatalog {
  new(this.file);

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

  void run(TestResult result, RunnerOptions options) {
    for (final testSet in testSets) {
      if (options.maxErrors != null &&
          result.failureCount >= options.maxErrors!) {
        break;
      }
      if (!options.matchesSuite(testSet.name)) {
        continue;
      }
      if (isSupported(testSet.document.rootElement)) {
        testSet.run(result, options);
      }
    }
  }
}

/// A suite / set of related test cases.
class TestSet {
  new(this.catalog, this.name, this.file);

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

  void run(TestResult result, RunnerOptions options) {
    final matchingCases = testCases
        .where((tc) => options.matchesTest(tc.name))
        .toList();
    if (matchingCases.isEmpty) return;

    result.testSuites++;
    options.onSuiteStart?.call(this);

    for (final testCase in matchingCases) {
      if (options.maxErrors != null &&
          result.failureCount >= options.maxErrors!) {
        break;
      }
      testCase.run(result, options);
    }
  }
}

/// A single test case execution unit.
class TestCase {
  new(this.catalog, this.testSet, this.element);

  final TestCatalog catalog;
  final TestSet testSet;
  final XmlElement element;

  late final name = element.getAttribute('name')!;

  void run(TestResult result, RunnerOptions options) {
    result.testCases++;

    final stopwatch = Stopwatch()..start();
    try {
      _test();
      stopwatch.stop();
      result.successes++;
      options.onTestResult?.call(
        TestCaseResult(this, TestStatus.success, duration: stopwatch.elapsed),
      );
    } on TestFailure catch (error) {
      stopwatch.stop();
      result.failures++;
      options.onTestResult?.call(
        TestCaseResult(
          this,
          TestStatus.failure,
          duration: stopwatch.elapsed,
          detail: error.message,
        ),
      );
    } catch (error) {
      stopwatch.stop();
      result.errors++;
      final message = switch (error) {
        final StateError error => error.message,
        final UnsupportedError error => error.message ?? 'Unsupported',
        _ => error.toString(),
      };
      options.onTestResult?.call(
        TestCaseResult(
          this,
          TestStatus.error,
          duration: stopwatch.elapsed,
          detail: message,
        ),
      );
    }
  }

  void _test() {
    final context = _getEnvironment().context;
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

/// An XML test execution environment with sources, parameters, and base URIs.
class TestEnvironment {
  new(this.directory, this.element);

  final Directory directory;
  final XmlElement element;

  late final String name = element.getAttribute('name') ?? '<inline>';

  late final XmlNode? source = _getSource();

  late final Map<String, XmlNode> documents = _getDocuments();

  late final Map<String, Object> variables = _getVariables();

  late final String? baseUri = _getBaseUri();

  late final Map<String, TestResource> resources = _getResources();

  XPathContext get context => XPathConfiguration(
    documents: documents,
    variables: variables,
    environment: Platform.environment,
    baseUri: baseUri,
    unparsedTextLoader: _unparsedTextLoader,
  ).context(source ?? XPathSequence.empty);

  String? _getBaseUri() {
    final staticBaseUriElement = element
        .findElements('static-base-uri')
        .singleOrNull;
    if (staticBaseUriElement != null) {
      final uri = staticBaseUriElement.getAttribute('uri');
      if (uri == '#UNDEFINED') return null;
      return uri;
    }
    return directory.uri.toString();
  }

  Map<String, TestResource> _getResources() {
    final results = <String, TestResource>{};
    for (final el in element.findElements('resource')) {
      final file = el.getAttribute('file');
      if (file == null) continue;
      final uri = el.getAttribute('uri');
      final encoding = el.getAttribute('encoding');
      final resource = TestResource(file, encoding);
      if (uri != null) {
        results[uri] = resource;
      }
      results[file] = resource;
    }
    return results;
  }

  String? _unparsedTextLoader(String uri, String? requestedEncoding) {
    final resource = resources[uri];
    if (resource == null) return null;
    final file = File('${directory.path}/${resource.file}');
    if (!file.existsSync()) return null;
    final encoding = Encoding.getByName(requestedEncoding ?? resource.encoding);
    return file.readAsStringSync(encoding: encoding ?? utf8);
  }

  Map<String, XmlNode> _getDocuments() {
    final results = <String, XmlNode>{};
    for (final element in element.findElements('source')) {
      final file = element.getAttribute('file');
      if (file == null) continue;
      final uri = element.getAttribute('uri');
      final node = XmlDocument.parse(
        File('${directory.path}/$file').readAsStringSync(),
      );
      results[file] = node;
      if (uri != null) {
        results[uri] = node;
      }
    }
    return results;
  }

  XmlNode? _getSource() {
    final sources = element.findElements('source');
    final source =
        sources.where((e) => e.getAttribute('role') == '.').singleOrNull ??
        sources.singleOrNull;
    final file = source?.getAttribute('file');
    return documents[file];
  }

  Map<String, Object> _getVariables() {
    final variables = <String, Object>{};
    for (final param in element.findElements('param')) {
      final name = param.getAttribute('name');
      final select = param.getAttribute('select');
      final sourceContext = param.getAttribute('source');
      if (name != null && select != null) {
        // Try to evaluate the param with respect to a specific document source.
        final item = documents[sourceContext] ?? source ?? XPathSequence.empty;
        variables[name] = XPathConfiguration.standard()
            .context(item)
            .evaluate(select);
      }
    }
    for (final source in element.findElements('source')) {
      final role = source.getAttribute('role');
      final file = source.getAttribute('file');
      if (role != null && role.startsWith(r'$') && file != null) {
        final node = documents[file];
        if (node != null) {
          variables[role.substring(1)] = node;
        }
      }
    }
    return variables;
  }
}
