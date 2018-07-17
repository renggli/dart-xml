library xml.test.all_tests;

import 'package:test/test.dart';

import 'axis_test.dart' as axis_test;
import 'builder_test.dart' as builder_test;
import 'entity_test.dart' as entity_test;
import 'example_test.dart' as example_test;
import 'mutate_test.dart' as mutate_test;
import 'namespace_test.dart' as namespace_test;
import 'node_test.dart' as node_test;
import 'parse_test.dart' as parse_test;
import 'query_test.dart' as query_test;
import 'reader_test.dart' as reader_test;
import 'regression_test.dart' as regression_test;

void main() {
  group('axis', axis_test.main);
  group('builder', builder_test.main);
  group('entity', entity_test.main);
  group('example', example_test.main);
  group('mutate', mutate_test.main);
  group('namespace', namespace_test.main);
  group('node', node_test.main);
  group('parse', parse_test.main);
  group('query', query_test.main);
  group('reader', reader_test.main);
  group('regression', regression_test.main);
}
