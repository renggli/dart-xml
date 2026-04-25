// ignore_for_file: unnecessary_lambdas

import 'package:xml/xml.dart';
import 'package:xml/xml_events.dart';

import '../test/utils/examples.dart';
import 'benchmark.dart';

String characterData() {
  const string = '''a&bc<def"gehi'jklm>nopqr''';
  final builder = XmlBuilder();
  builder.processing('xml', 'version="1.0"');
  builder.element(
    'character',
    nest: () {
      for (var i = 0; i < 20; i++) {
        builder.text('$string$string$string$string$string$string');
        builder.element(
          'foo',
          nest: () {
            builder.attribute('key', '$string$string$string$string');
          },
        );
      }
    },
  );
  return builder.buildDocument().toString();
}

void buildRecursive(XmlBuilder builder, XmlNode node) {
  if (node is XmlElement) {
    builder.element(
      node.localName,
      namespaceUri: node.namespaceUri,
      nest: () {
        for (final attribute in node.attributes) {
          builder.attribute(
            attribute.localName,
            attribute.value,
            namespaceUri: attribute.namespaceUri,
          );
        }
        for (final child in node.children) {
          buildRecursive(builder, child);
        }
      },
    );
  } else if (node is XmlText) {
    builder.text(node.text);
  } else if (node is XmlCDATA) {
    builder.cdata(node.text);
  } else if (node is XmlComment) {
    builder.comment(node.text);
  } else if (node is XmlProcessing) {
    builder.processing(node.target, node.value);
  } else if (node is XmlDoctype) {
    builder.doctype(
      node.name,
      publicId: node.externalId?.publicId,
      systemId: node.externalId?.systemId,
      internalSubset: node.internalSubset,
    );
  } else if (node is XmlDeclaration) {
    builder.declaration(
      version: node.version ?? '1.0',
      encoding: node.encoding,
      standalone: node.standalone,
      attributes: {
        for (final attribute in node.attributes)
          attribute.localName: attribute.value,
      },
    );
  } else {
    throw UnsupportedError('Unsupported node type: ${node.runtimeType}');
  }
}

final Map<String, String> benchmarks = {
  'atom': atomXml,
  'books': booksXml,
  'bookstore': bookstoreXml,
  'complicated': complicatedXml,
  'shiporder': shiporderXsd,
  'decoding': characterData(),
};

void main(List<String> args) {
  final report = XmlDocument.build(
    createReport(
      benchmarks.entries.map((entry) {
        final source = entry.value;
        final document = XmlDocument.parse(source);
        final parser = benchmark(() => XmlDocument.parse(source));
        final streamEvents = benchmark(() => XmlEventDecoder().convert(source));
        final streamNodes = benchmark(
          () =>
              const XmlNodeDecoder().convert(XmlEventDecoder().convert(source)),
        );
        final iterator = benchmark(() => parseEvents(source).toList());
        final serialize = benchmark(() => document.toXmlString());
        final serializePretty = benchmark(
          () => document.toXmlString(pretty: true),
        );
        final copy = benchmark(() => document.copy());
        final builder = benchmark(() {
          final builder = XmlBuilder();
          for (final node in document.children) {
            buildRecursive(builder, node);
          }
          builder.buildDocument();
        });
        return createBenchmark(entry.key, [
          createMeasure('parser', parser),
          createMeasure('streamEvents', streamEvents, parser),
          createMeasure('streamNodes', streamNodes, parser),
          createMeasure('iterator', iterator, parser),
          createMeasure('serialize', serialize),
          createMeasure('serializePretty', serializePretty, serialize),
          createMeasure('copy', copy),
          createMeasure('builder', builder, copy),
        ]);
      }),
    ),
  );
  printReport(report, xml: !args.contains('--no-xml'));
}
