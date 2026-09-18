import 'dart:io';

import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

/// URL of the official XPath and XQuery W3C test-suite.
const githubRepository = 'https://github.com/w3c/qt3tests.git';

/// Default path to the local catalog file.
final defaultCatalogFile = File('.qt3tests/catalog.xml').absolute;

/// Test names that are skipped.
const skippedTests = <String>{};

/// Clones or pulls the QT3 test data repository.
void downloadAndUpdateTestData(File catalogFile) {
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
    '(${sequence.map((item) => item.stringValue).join(', ')})';

/// Helper to format a stopwatch duration.
String formatDuration(Duration duration) {
  final micros = duration.inMicroseconds;
  if (micros < 1000) {
    return '${micros}µs';
  } else if (micros < 1000000) {
    return '${(micros / 1000).toStringAsFixed(2)}ms';
  } else {
    return '${(micros / 1000000).toStringAsFixed(2)}s';
  }
}

/// Helper to format an error message concisely.
String formatMessage(String message) {
  final normalize = message.trim().replaceAll(RegExp(r'\s+'), ' ');
  return normalize.length > 80 ? '${normalize.substring(0, 77)}...' : normalize;
}

/// A test resource file specification.
class TestResource {
  const new(this.file, this.encoding);

  final String file;
  final String? encoding;
}
