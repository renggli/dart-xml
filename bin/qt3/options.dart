import 'dart:io';

/// Outcome status of a test case.
enum TestStatus {
  success,
  failure,
  error,
  skipped;

  static TestStatus? tryParse(String value) => switch (value.toLowerCase()) {
    'success' || 'successes' || 'ok' || 'pass' => TestStatus.success,
    'failure' || 'failures' || 'fail' => TestStatus.failure,
    'error' || 'errors' || 'err' => TestStatus.error,
    'skipped' || 'skip' => TestStatus.skipped,
    _ => null,
  };
}

/// Aggregated results of a test execution.
class TestResult {
  var testSuites = 0;
  var testCases = 0;
  var skipped = 0;
  var successes = 0;
  var failures = 0;
  var errors = 0;

  int get totalReported => successes + skipped + failures + errors;
  int get failureCount => failures + errors;
}

/// Output verbosity level.
enum Verbosity {
  /// Only print the final summary table.
  quiet,
  /// Print all test cases (successes, failures, errors, skipped).
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
