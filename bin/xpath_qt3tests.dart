/// Runner of the official XPath and XQuery W3C test-suite.
///
/// This test-suite is not meant to replace unit-tests. It is purely used to
/// identify gaps and discrepancies of the library with the standard.
library;

import 'dart:io';

// ignore: depend_on_referenced_packages internal tool
import 'package:args/args.dart';

import 'qt3/models.dart';
import 'qt3/options.dart';
import 'qt3/utils.dart';

final parser = ArgParser()
  ..addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this usage information and exit.',
  )
  ..addFlag(
    'update',
    abbr: 'u',
    negatable: false,
    help: 'Update or clone the QT3 test-suite repository.',
  )
  ..addOption(
    'catalog',
    abbr: 'c',
    valueHelp: 'file',
    help: 'Path to QT3 catalog XML file.',
  )
  ..addMultiOption(
    'suite',
    abbr: 's',
    valueHelp: 'pattern',
    help: 'Filter test suites by pattern.',
  )
  ..addMultiOption(
    'test',
    abbr: 't',
    valueHelp: 'pattern',
    help: 'Filter test cases by pattern.',
  )
  ..addFlag(
    'all',
    abbr: 'a',
    negatable: false,
    help: 'Show all tests, including passes (defaults to failures & errors).',
  )
  ..addFlag(
    'errors-only',
    abbr: 'e',
    negatable: false,
    help: 'Show only errors (hide assertion failures and passes).',
  )
  ..addFlag(
    'quiet',
    abbr: 'q',
    negatable: false,
    help: 'Suppress test output and print only summary.',
  )
  ..addFlag(
    'time',
    defaultsTo: true,
    help: 'Display elapsed duration per test.',
  )
  ..addOption(
    'max-errors',
    abbr: 'm',
    valueHelp: 'count',
    help: 'Halt execution after reaching this number of failures/errors.',
  );

void main(List<String> arguments) {
  final ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln('Error: ${e.message}\n\n${parser.usage}');
    exit(64);
  }

  if (argResults.flag('help')) {
    stdout.writeln(
      'Usage: dart run bin/xpath_qt3tests.dart [options] [patterns]\n\n'
      'Positional arguments are treated as test case filters.\n\n'
      '${parser.usage}',
    );
    return;
  }

  final catalogFile = argResults.option('catalog') != null
      ? File(argResults.option('catalog')!).absolute
      : defaultCatalogFile;

  final update = !catalogFile.existsSync() || argResults.flag('update');
  if (update) downloadAndUpdateTestData(catalogFile);

  if (!catalogFile.existsSync()) {
    stderr.writeln('Error: Catalog file not found at ${catalogFile.path}');
    stderr.writeln('Run with --update to clone the test suite.');
    exit(1);
  }

  final suitePatterns = argResults
      .multiOption('suite')
      .map(RegExp.new)
      .toList();

  final testPatterns = [
    ...argResults.multiOption('test'),
    ...argResults.rest,
  ].map(RegExp.new).toList();

  final verbosity = switch ((
    argResults.flag('quiet'),
    argResults.flag('errors-only'),
    argResults.flag('all'),
  )) {
    (true, _, _) => Verbosity.quiet,
    (_, true, _) => Verbosity.errors,
    (_, _, true) => Verbosity.all,
    _ => Verbosity.failures,
  };

  final maxErrorsStr = argResults.option('max-errors');
  final maxErrors = maxErrorsStr != null ? int.tryParse(maxErrorsStr) : null;
  if (maxErrorsStr != null && maxErrors == null) {
    stderr.writeln('Error: --max-errors must be an integer.');
    exit(64);
  }

  var currentSuiteName = '';
  var printedSuiteHeader = false;
  final showTime = argResults.flag('time');

  final options = RunnerOptions(
    suitePatterns: suitePatterns,
    testPatterns: testPatterns,
    verbosity: verbosity,
    showTime: showTime,
    maxErrors: maxErrors,
    onSuiteStart: (suite) {
      currentSuiteName = suite.name;
      printedSuiteHeader = false;
    },
    onTestResult: (result) {
      final shouldPrint = switch (verbosity) {
        Verbosity.quiet => false,
        Verbosity.all => true,
        Verbosity.failures => result.status != TestStatus.success,
        Verbosity.errors => result.status == TestStatus.error,
      };
      if (!shouldPrint) return;

      if (!printedSuiteHeader) {
        stdout.writeln(currentSuiteName);
        printedSuiteHeader = true;
      }

      final (badge, detail) = switch (result.status) {
        TestStatus.success => ('PASS', null),
        TestStatus.failure => ('FAIL', result.detail),
        TestStatus.error => ('ERROR', result.detail),
      };

      final buffer = StringBuffer('  [$badge] ${result.testCase.name}');
      if (showTime) {
        buffer.write(' (${formatDuration(result.duration)})');
      }
      if (detail != null && detail.isNotEmpty) {
        buffer.write(': ${formatMessage(detail)}');
      }
      stdout.writeln(buffer.toString());
    },
  );

  final result = TestResult();
  TestCatalog(catalogFile).run(result, options);

  stdout.writeln();
  for (final (label, count, total) in [
    ('Suites', result.testSuites, -1),
    ('Total', result.testCases, -1),
    ('Passed', result.successes, result.testCases),
    ('Failed', result.failures, result.testCases),
    ('Errors', result.errors, result.testCases),
  ]) {
    stdout.writeln(
      [
        '$label:'.padRight(10),
        count.toString().padLeft(10),
        if (total > 0)
          '${(100 * count / total).toStringAsFixed(1)}%'.padLeft(10),
      ].join(''),
    );
  }

  if (result.failureCount > 0) {
    exitCode = 1;
  }
}
