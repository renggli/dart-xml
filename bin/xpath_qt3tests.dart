/// Runner of the official XPath and XQuery W3C test-suite.
///
/// This test-suite is not meant to replace unit-tests. It is purely used to
/// identify gaps and discrepancies of the library with the standard.
library;

import 'dart:io';

import 'package:args/args.dart';

import 'qt3/models.dart';
import 'qt3/options.dart';
import 'qt3/utils.dart';

export 'qt3/models.dart';
export 'qt3/options.dart';
export 'qt3/utils.dart';
export 'qt3/verifier.dart';

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
    stderr.writeln('Error: ${e.message}');
    stderr.writeln();
    stderr.writeln(parser.usage);
    exit(64);
  }

  if (argResults.flag('help')) {
    stdout.writeln(
      'Usage: dart run bin/xpath_qt3tests.dart [options] [patterns]',
    );
    stdout.writeln();
    stdout.writeln('Positional arguments are treated as test case filters.');
    stdout.writeln();
    stdout.writeln(parser.usage);
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

  final options = RunnerOptions(
    catalogFile: catalogFile,
    update: update,
    suitePatterns: suitePatterns,
    testPatterns: testPatterns,
    verbosity: verbosity,
    showTime: argResults.flag('time'),
    maxErrors: maxErrors,
  );

  runCatalog(catalogFile, options);
}

void runCatalog(File catalogFile, RunnerOptions options) {
  final stopwatch = Stopwatch()..start();
  final result = TestResult();
  TestCatalog(catalogFile).run(result, options);
  stopwatch.stop();

  stdout.writeln();
  stdout.writeln('Summary (${formatDuration(stopwatch.elapsed)})');
  for (final (label, count, total) in [
    ('Suites', result.testSuites, -1),
    ('Total', result.testCases, -1),
    ('Passed', result.successes, result.testCases),
    ('Skipped', result.skipped, result.testCases),
    ('Failed', result.failures, result.testCases),
    ('Errors', result.errors, result.testCases),
  ]) {
    final percentage = total > 0
        ? ' (${(100 * count / result.testCases).toStringAsFixed(1)}%)'
        : '';
    stdout.writeln('- $label: $count $percentage');
  }

  if (result.failureCount > 0) {
    exitCode = 1;
  }
}
