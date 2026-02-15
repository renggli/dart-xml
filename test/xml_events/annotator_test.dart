import 'package:test/test.dart';
import 'package:xml/src/xml_events/annotations/has_name.dart';
import 'package:xml/xml.dart' hide XmlHasName;
import 'package:xml/xml_events.dart';

import '../utils/matchers.dart';

void verify(
  String input, {
  Iterable<XmlEvent> Function(String input)? iterable,
  Stream<List<XmlEvent>> Function(Stream<String> input)? stream,
  XmlEventCodec? codec,
  required List<String> Function(XmlEvent event) formatter,
  required List<String> exected,
}) {
  if (iterable != null) {
    final events = iterable(input);
    expect(events.expand(formatter), exected, reason: 'parseEvents');
  }
  if (stream != null) {
    final events = stream(
      Stream.value(input),
    ).expand((each) => each).expand(formatter);
    expect(events, emitsInOrder(exected), reason: 'toXmlEvents');
  }
  if (codec != null) {
    final events = codec.decode(input);
    expect(events.expand(formatter), exected, reason: 'XmlEventCodec');
  }
}

void verifyError(
  String input, {
  Iterable<XmlEvent> Function(String input)? iterable,
  Stream<List<XmlEvent>> Function(Stream<String> input)? stream,
  XmlEventCodec? codec,
  Matcher? matcher,
}) {
  if (iterable != null) {
    expect(
      () => iterable(input).toList(),
      throwsA(matcher),
      reason: 'parseEvents',
    );
    expect(
      () => parseEvents(input).toList(),
      returnsNormally,
      reason: 'parseEvents',
    );
  }
  if (stream != null) {
    expect(
      stream(Stream.value(input)),
      emitsInOrder([mayEmitMultiple(anything), emitsError(matcher)]),
      reason: 'toXmlEvents',
    );
    expect(
      Stream.value(input).toXmlEvents(),
      emitsInOrder([mayEmitMultiple(anything), emitsDone]),
      reason: 'toXmlEvents',
    );
  }
  if (codec != null) {
    expect(
      () => codec.decode(input),
      throwsA(matcher),
      reason: 'XmlEventCodec',
    );
    expect(
      () => XmlEventCodec().decode(input),
      returnsNormally,
      reason: 'XmlEventCodec',
    );
  }
}

void main() {
  group('entityMapping', () {
    const input = '<a b="&amp;">&Aacute;&Abreve;';
    List<String> formatter(XmlEvent event) => [
      if (event is XmlTextEvent) event.value,
      if (event is XmlStartElementEvent)
        ...event.attributes.map((attr) => attr.value),
    ];
    test('default', () {
      verify(
        input,
        iterable: parseEvents,
        stream: (input) => input.toXmlEvents(),
        codec: XmlEventCodec(),
        formatter: formatter,
        exected: ['&', '&Aacute;&Abreve;'],
      );
    });
    test('null', () {
      verify(
        input,
        iterable: (input) =>
            parseEvents(input, entityMapping: const XmlNullEntityMapping()),
        stream: (input) =>
            input.toXmlEvents(entityMapping: const XmlNullEntityMapping()),
        codec: XmlEventCodec(entityMapping: const XmlNullEntityMapping()),
        formatter: formatter,
        exected: ['&amp;', '&Aacute;&Abreve;'],
      );
    });
    test('html5', () {
      verify(
        input,
        iterable: (input) => parseEvents(
          input,
          entityMapping: const XmlDefaultEntityMapping.html5(),
        ),
        stream: (input) => input.toXmlEvents(
          entityMapping: const XmlDefaultEntityMapping.html5(),
        ),
        codec: XmlEventCodec(
          entityMapping: const XmlDefaultEntityMapping.html5(),
        ),
        formatter: formatter,
        exected: ['&', 'ÁĂ'],
      );
    });
  });
  group('validateNesting', () {
    test('missing closing tag', () {
      verifyError(
        '<a>',
        iterable: (input) => parseEvents(input, validateNesting: true),
        stream: (input) => input.toXmlEvents(validateNesting: true),
        codec: XmlEventCodec(validateNesting: true),
        matcher: isXmlTagException(
          message: 'Missing closing tag </a>',
          position: 3,
        ),
      );
    });
    test('unexpected closing tag', () {
      verifyError(
        '</a>',
        iterable: (input) => parseEvents(input, validateNesting: true),
        stream: (input) => input.toXmlEvents(validateNesting: true),
        codec: XmlEventCodec(validateNesting: true),
        matcher: isXmlTagException(
          message: 'Unexpected closing tag </a>',
          position: 0,
        ),
      );
    });
    test('mismatched closing tag', () {
      verifyError(
        '<a></b>',
        iterable: (input) => parseEvents(input, validateNesting: true),
        stream: (input) => input.toXmlEvents(validateNesting: true),
        codec: XmlEventCodec(validateNesting: true),
        matcher: isXmlTagException(
          message: 'Expected </a>, but found </b>',
          position: 3,
        ),
      );
    });
  });
  group('validateNamespace', () {
    test('unknown namespace prefix', () {
      verifyError(
        '<ns:root/>',
        iterable: (input) => parseEvents(input, validateNamespace: true),
        stream: (input) => input.toXmlEvents(validateNamespace: true),
        codec: XmlEventCodec(validateNamespace: true),
        matcher: isXmlNamespaceException(
          message: 'Unknown namespace prefix: ns',
          position: 0,
        ),
      );
    });
    test('undefined namespace prefix', () {
      verifyError(
        '<ns:root xmlns:ns="http://example.com"><ns:child xmlns:ns=""/></root>',
        iterable: (input) => parseEvents(input, validateNamespace: true),
        stream: (input) => input.toXmlEvents(validateNamespace: true),
        codec: XmlEventCodec(validateNamespace: true),
        matcher: isXmlNamespaceException(
          message: 'Unknown namespace prefix: ns',
          position: 39,
        ),
      );
    });
  });
  group('validateDocument', () {
    test('at most one XML declaration', () {
      verifyError(
        '<?xml version="1.0"?><?xml encoding="utf-8"?>',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Expected at most one XML declaration',
          position: 21,
        ),
      );
    });
    test('unexpected XML declaration', () {
      verifyError(
        '<root/><?xml version="1.0"?>',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Unexpected XML declaration',
          position: 7,
        ),
      );
    });
    test('at most one doctype declaration', () {
      verifyError(
        '<!DOCTYPE note><!DOCTYPE note>',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Expected at most one doctype declaration',
          position: 15,
        ),
      );
    });
    test('unexpected doctype declaration', () {
      verifyError(
        '<root/><!DOCTYPE note>',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Unexpected doctype declaration',
          position: 7,
        ),
      );
    });
    test('unexpected root element', () {
      verifyError(
        '<r1/><r2/>',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Unexpected root element',
          position: 5,
        ),
      );
    });
    test('missing root element', () {
      verifyError(
        '<?xml version="1.0"?>',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Expected a single root element',
          position: 21,
        ),
      );
    });
    test('missing root element (empty document)', () {
      verifyError(
        '',
        iterable: (input) => parseEvents(input, validateDocument: true),
        stream: (input) => input.toXmlEvents(validateDocument: true),
        codec: XmlEventCodec(validateDocument: true),
        matcher: isXmlParserException(
          message: 'Expected a single root element',
          position: 0,
        ),
      );
    });
  });
  group('withBuffer', () {
    const input = '<a><b c="d"/><e:f>g</e:f></h>';
    List<String> formatter(XmlEvent event) => ['$event: ${event.buffer}'];
    test('false', () {
      verify(
        input,
        iterable: (input) => parseEvents(input, withBuffer: false),
        formatter: formatter,
        exected: [
          '<a>: null',
          '<b c="d"/>: null',
          '<e:f>: null',
          'g: null',
          '</e:f>: null',
          '</h>: null',
        ],
      );
    });
    test('true', () {
      verify(
        input,
        iterable: (input) => parseEvents(input, withBuffer: true),
        formatter: formatter,
        exected: [
          '<a>: $input',
          '<b c="d"/>: $input',
          '<e:f>: $input',
          'g: $input',
          '</e:f>: $input',
          '</h>: $input',
        ],
      );
    });
  });
  group('withLocation', () {
    const input = '<a><b c="d"/><e:f>g</e:f></h>';
    List<String> formatter(XmlEvent event) => [
      '$event: ${event.start}-${event.stop}',
    ];
    test('false', () {
      verify(
        input,
        iterable: (input) => parseEvents(input, withLocation: false),
        stream: (input) => input.toXmlEvents(withLocation: false),
        codec: XmlEventCodec(withLocation: false),
        formatter: formatter,
        exected: [
          '<a>: null-null',
          '<b c="d"/>: null-null',
          '<e:f>: null-null',
          'g: null-null',
          '</e:f>: null-null',
          '</h>: null-null',
        ],
      );
    });
    test('true', () {
      verify(
        input,
        iterable: (input) => parseEvents(input, withLocation: true),
        stream: (input) => input.toXmlEvents(withLocation: true),
        codec: XmlEventCodec(withLocation: true),
        formatter: formatter,
        exected: [
          '<a>: 0-3',
          '<b c="d"/>: 3-13',
          '<e:f>: 13-18',
          'g: 18-19',
          '</e:f>: 19-25',
          '</h>: 25-29',
        ],
      );
    });
  });
  group('withNamespace', () {
    List<String> formatter(XmlEvent event) => [
      if (event is XmlHasName)
        '${(event as XmlHasName).name}: ${(event as XmlHasName).namespaceUri}',
      if (event is XmlStartElementEvent)
        ...event.attributes.map((attr) => '${attr.name}: ${attr.namespaceUri}'),
    ];
    group('default namespace', () {
      const input = '<a xmlns="a-ns" b="c"><d xmlns="e-ns" e="f"/></a><g/>';
      test('false, default-namespace', () {
        verify(
          input,
          iterable: (input) => parseEvents(input, withNamespace: false),
          stream: (input) => input.toXmlEvents(withNamespace: false),
          codec: XmlEventCodec(withNamespace: false),
          formatter: formatter,
          exected: [
            'a: null',
            'xmlns: null',
            'b: null',
            'd: null',
            'xmlns: null',
            'e: null',
            'a: null',
            'g: null',
          ],
        );
      });
      test('true, default-namespace', () {
        verify(
          input,
          iterable: (input) => parseEvents(input, withNamespace: true),
          stream: (input) => input.toXmlEvents(withNamespace: true),
          codec: XmlEventCodec(withNamespace: true),
          formatter: formatter,
          exected: [
            'a: a-ns',
            'xmlns: http://www.w3.org/2000/xmlns/',
            'b: a-ns',
            'd: e-ns',
            'xmlns: http://www.w3.org/2000/xmlns/',
            'e: e-ns',
            'a: a-ns',
            'g: null',
          ],
        );
      });
    });
    group('standard namespace', () {
      const input =
          '<a:a xmlns:a="a-ns" a:b="c"><a:d xmlns:a="b-ns" a:e="f"/></a><a:g/>';
      test('false, standard-namespace', () {
        verify(
          input,
          iterable: (input) => parseEvents(input, withNamespace: false),
          stream: (input) => input.toXmlEvents(withNamespace: false),
          codec: XmlEventCodec(withNamespace: false),
          formatter: formatter,
          exected: [
            'a:a: null',
            'xmlns:a: null',
            'a:b: null',
            'a:d: null',
            'xmlns:a: null',
            'a:e: null',
            'a: null',
            'a:g: null',
          ],
        );
      });
      test('true, standard-namespace', () {
        verify(
          input,
          iterable: (input) => parseEvents(input, withNamespace: true),
          stream: (input) => input.toXmlEvents(withNamespace: true),
          codec: XmlEventCodec(withNamespace: true),
          formatter: formatter,
          exected: [
            'a:a: a-ns',
            'xmlns:a: http://www.w3.org/2000/xmlns/',
            'a:b: a-ns',
            'a:d: b-ns',
            'xmlns:a: http://www.w3.org/2000/xmlns/',
            'a:e: b-ns',
            'a: null',
            'a:g: null',
          ],
        );
      });
    });
  });
  group('withParent', () {
    const input = '<a><b c="d"/><e:f>g</e:f></h>';
    List<String> formatter(XmlEvent event) => ['$event: ${event.parent}'];
    test('false', () {
      verify(
        input,
        iterable: (input) => parseEvents(input, withParent: false),
        stream: (input) => input.toXmlEvents(withParent: false),
        codec: XmlEventCodec(withParent: false),
        formatter: formatter,
        exected: [
          '<a>: null',
          '<b c="d"/>: null',
          '<e:f>: null',
          'g: null',
          '</e:f>: null',
          '</h>: null',
        ],
      );
    });
    test('true', () {
      verify(
        input,
        iterable: (input) => parseEvents(input, withParent: true),
        stream: (input) => input.toXmlEvents(withParent: true),
        codec: XmlEventCodec(withParent: true),
        formatter: formatter,
        exected: [
          '<a>: null',
          '<b c="d"/>: <a>',
          '<e:f>: <a>',
          'g: <e:f>',
          '</e:f>: <e:f>',
          '</h>: <a>',
        ],
      );
    });
  });
}
