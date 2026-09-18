import 'dart:io';

import 'models.dart';

/// Outcome status of a test case.
enum TestStatus { success, failure, error }

/// A completed test case result with its status and optional failure/error detail.
class TestCaseResult {
  const new(this.testCase, this.status, {required this.duration, this.detail});

  final TestCase testCase;
  final TestStatus status;
  final Duration duration;
  final String? detail;
}

/// Aggregated results of a test execution.
class TestResult {
  var testSuites = 0;
  var testCases = 0;
  var successes = 0;
  var failures = 0;
  var errors = 0;

  int get totalReported => successes + failures + errors;
  int get failureCount => failures + errors;
}

/// Output verbosity level.
enum Verbosity {
  /// Only print the final summary table.
  quiet,

  /// Print all test cases (successes, failures, errors).
  all,

  /// Print failures and errors (hide passes).
  failures,

  /// Print only test errors (hide passes and assertion failures).
  errors,
}

/// Configuration options for the QT3 test runner.
class RunnerOptions {
  const new({
    this.catalogFile,
    this.update = false,
    this.suitePatterns = const [],
    this.testPatterns = const [],
    this.verbosity = Verbosity.failures,
    this.showTime = true,
    this.maxErrors,
    this.onSuiteStart,
    this.onTestResult,
  });

  /// Path to the catalog XML file.
  final File? catalogFile;

  /// Whether to download or git pull the QT3 test suite repository.
  final bool update;

  /// Patterns to filter test-set / test-suite names.
  final List<Pattern> suitePatterns;

  /// Patterns to filter individual test-case names.
  final List<Pattern> testPatterns;

  /// Verbosity of output.
  final Verbosity verbosity;

  /// Whether to print timing info per test.
  final bool showTime;

  /// Stop testing after reaching this many failures + errors.
  final int? maxErrors;

  /// Callback invoked whenever a test case completes.
  final void Function(TestCaseResult result)? onTestResult;

  /// Callback invoked when a suite with matching test cases starts running.
  final void Function(TestSet testSet)? onSuiteStart;

  /// Checks if a suite name matches the filter.
  bool matchesSuite(String name) {
    if (suitePatterns.isEmpty) return true;
    return suitePatterns.any((pattern) => pattern.allMatches(name).isNotEmpty);
  }

  /// Checks if a test case name matches the filter.
  bool matchesTest(String name) {
    if (testPatterns.isEmpty) return true;
    return testPatterns.any((pattern) => pattern.allMatches(name).isNotEmpty);
  }

  /// Checks if an outcome should be printed according to verbosity.
  bool shouldPrintOutcome(TestStatus status) => switch (verbosity) {
    Verbosity.quiet => false,
    Verbosity.all => true,
    Verbosity.failures => status != TestStatus.success,
    Verbosity.errors => status == TestStatus.error,
  };
}
