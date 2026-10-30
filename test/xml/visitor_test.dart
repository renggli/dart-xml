import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  group('normalizer', () {
    test('remove empty text', () {
      final element = XmlElement.tag(
        'element',
        children: [
          XmlText(''),
          XmlElement(const XmlName.qualified('element1')),
          XmlText(''),
          XmlElement(const XmlName.qualified('element2')),
          XmlText(''),
        ],
      );
      element.normalize();
      check(element.children.length).equals(2);
      check(element.toXmlString())
          .equals('<element><element1/><element2/></element>');
    });
    test('join adjacent text', () {
      final element = XmlElement.tag(
        'element',
        children: [XmlText('aaa'), XmlText('bbb'), XmlText('ccc')],
      );
      element.normalize();
      check(element.children.length).equals(1);
      check(element.toXmlString()).equals('<element>aaabbbccc</element>');
    });
    test('trim whitespace', () {
      final element = XmlElement.tag(
        'element',
        children: [XmlText(' a '), XmlText(' b ')],
      );
      element.normalize(trimAllWhitespace: true);
      check(element.children.length).equals(1);
      check(element.toXmlString()).equals('<element>a  b</element>');
    });
    test('selectively trim whitespace', () {
      final element = XmlElement.tag(
        'element',
        children: [
          XmlElement.tag('a', children: [XmlText(' 1 ')]),
          XmlElement.tag('b', children: [XmlText(' 2 ')]),
        ],
      );
      element.normalize(trimWhitespace: (node) => node.value == ' 2 ');
      check(element.toXmlString())
          .equals('<element><a> 1 </a><b>2</b></element>');
    });
    test('collapse whitespace', () {
      final element = XmlElement.tag(
        'element',
        children: [XmlText(' a '), XmlText(' b ')],
      );
      element.normalize(collapseAllWhitespace: true);
      check(element.children.length).equals(1);
      check(element.toXmlString()).equals('<element> a b </element>');
    });
    test('selectively collapse whitespace', () {
      final element = XmlElement.tag(
        'element',
        children: [
          XmlElement.tag('a', children: [XmlText('1  1')]),
          XmlElement.tag('b', children: [XmlText('2  2')]),
        ],
      );
      element.normalize(collapseWhitespace: (node) => node.value == '2  2');
      check(element.toXmlString())
          .equals('<element><a>1  1</a><b>2 2</b></element>');
    });
    test('normalize newlines', () {
      final element = XmlElement.tag(
        'element',
        children: [
          XmlElement.tag('xD', children: [XmlText('\r')]),
          XmlElement.tag('xD-xA', children: [XmlText('\r\n')]),
          XmlElement.tag('xD-x85', children: [XmlText('\r\u0085')]),
          XmlElement.tag('x85', children: [XmlText('\u0085')]),
          XmlElement.tag('x2028', children: [XmlText('\u2028')]),
        ],
      );
      element.normalize(normalizeAllNewline: true);
      check(element.children.map((child) => child.innerText))
          .every((it) => it.equals('\n'));
    });
    test('selectively normalize newlines', () {
      final element = XmlElement.tag(
        'element',
        children: [
          XmlElement.tag('xD', children: [XmlText('\r')]),
          XmlElement.tag('xD-xA', children: [XmlText('\r\n')]),
          XmlElement.tag('xD-x85', children: [XmlText('\r\u0085')]),
          XmlElement.tag('x85', children: [XmlText('\u0085')]),
          XmlElement.tag('x2028', children: [XmlText('\u2028')]),
        ],
      );
      element.normalize(normalizeNewline: (node) => node.value.length > 1);
      check(element.children.map((child) => child.innerText))
          .deepEquals(['\r', '\n', '\n', '\u0085', '\u2028']);
    });
    test('document fragment', () {
      final fragment = XmlDocumentFragment([
        XmlText(''),
        XmlText('aaa'),
        XmlText(''),
        XmlElement(const XmlName.qualified('element1')),
        XmlText(''),
        XmlText('bbb'),
        XmlText(''),
        XmlText('ccc'),
        XmlText(''),
        XmlElement(const XmlName.qualified('element2')),
        XmlText(''),
        XmlText('ddd'),
        XmlText(''),
      ]);
      fragment.normalize();
      final element = XmlElement(const XmlName.qualified('element'));
      element.children.add(fragment);
      check(element.children.length).equals(5);
      check(element.toXmlString())
          .equals('<element>aaa<element1/>bbbccc<element2/>ddd</element>');
    });
  });
  group('writer', () {
    final document = XmlDocument.parse(
      '<body>\n'
      '  <a>\tWhat\r the  heck?\n</a>\n'
      '  <b>\tWhat\r the  heck?\n</b>\n'
      '</body>',
    );
    test('default', () {
      final output = document.toXmlString();
      check(output).equals(
        '<body>\n'
        '  <a>\tWhat\r the  heck?\n</a>\n'
        '  <b>\tWhat\r the  heck?\n</b>\n'
        '</body>',
      );
    });
    test('pretty', () {
      final output = document.toXmlString(pretty: true);
      check(output).equals(
        '<body>\n'
        '  <a>What the heck?</a>\n'
        '  <b>What the heck?</b>\n'
        '</body>',
      );
    });
    test('indent', () {
      final output = document.toXmlString(pretty: true, indent: '\t');
      check(output).equals(
        '<body>\n'
        '\t<a>What the heck?</a>\n'
        '\t<b>What the heck?</b>\n'
        '</body>',
      );
    });
    test('newline', () {
      final output = document.toXmlString(pretty: true, newLine: '\r\n');
      check(output).equals(
        '<body>\r\n'
        '  <a>What the heck?</a>\r\n'
        '  <b>What the heck?</b>\r\n'
        '</body>',
      );
    });
    group('whitespace', () {
      test('preserve all', () {
        final output = document.toXmlString(
          pretty: true,
          preserveWhitespace: (node) => true,
        );
        check(output).equals(
          '<body>\n'
          '  <a>\tWhat\r the  heck?\n</a>\n'
          '  <b>\tWhat\r the  heck?\n</b>\n'
          '</body>',
        );
      });
      test('preserve some', () {
        final output = document.toXmlString(
          pretty: true,
          preserveWhitespace: (node) =>
              node is XmlElement && node.localName == 'b',
        );
        check(output).equals(
          '<body>\n'
          '  <a>What the heck?</a>\n'
          '  <b>\tWhat\r the  heck?\n</b>\n'
          '</body>',
        );
      });
      test('preserve nested', () {
        final input = XmlDocument.parse(
          '<html><body>'
          '<p><b>bold</b>, <i>italic</i> and <b><i>both</i></b>.</p>'
          '</body></html>',
        );
        final output = input.toXmlString(
          pretty: true,
          preserveWhitespace: (node) =>
              node is XmlElement && node.localName == 'p',
        );
        check(output).equals(
          '<html>\n'
          '  <body>\n'
          '    <p><b>bold</b>, <i>italic</i> and <b><i>both</i></b>.</p>\n'
          '  </body>\n'
          '</html>',
        );
      });
      test('xml:space="preserve"', () {
        final input = XmlDocument.parse(
          '<html><body>'
          '<pre xml:space="preserve">  line 1\n  line 2\n</pre>'
          '</body></html>',
        );
        final output = input.toXmlString(pretty: true);
        check(output).equals(
          '<html>\n'
          '  <body>\n'
          '    <pre xml:space="preserve">  line 1\n  line 2\n</pre>\n'
          '  </body>\n'
          '</html>',
        );
      });
      test('xml:space="default" nested in preserve', () {
        final input = XmlDocument.parse(
          '<root xml:space="preserve">'
          '<raw>  keep  </raw>'
          '<pretty xml:space="default"><a>1</a><b>2</b></pretty>'
          '</root>',
        );
        final output = input.toXmlString(pretty: true);
        check(output).equals(
          '<root xml:space="preserve">'
          '<raw>  keep  </raw>'
          '<pretty xml:space="default">\n'
          '  <a>1</a>\n'
          '  <b>2</b>\n'
          '</pretty>'
          '</root>',
        );
      });
      test('normalize text', () {
        final input = XmlDocument([
          XmlElement.tag(
            'contents',
            children: [
              XmlText(' Hello '),
              XmlText('   '),
              XmlText(' World '),
              XmlText(' '),
            ],
          ),
        ]);
        final output = input.toXmlString(pretty: true);
        check(output).equals('<contents>Hello World</contents>');
      });
      test('normalize adjacent text without spaces', () {
        final input = XmlDocument([
          XmlElement.tag('contents', children: [XmlText('Hel'), XmlText('lo')]),
        ]);
        final output = input.toXmlString(pretty: true);
        check(output).equals('<contents>Hello</contents>');
      });
    });
    group('attributes', () {
      const input =
          '<body>'
          '<a a="1">AAA</a>'
          '<b a="1" b="2">BBB</b>'
          '<c a="1" b="2" c="3">CCC</c>'
          '</body>';
      final document = XmlDocument.parse(input);
      tearDown(
        () => check(
          because: 'Modified the original DOM.',
          document.toXmlString(),
        ).equals(input),
      );
      test('indent none', () {
        final output = document.toXmlString(
          pretty: true,
          indentAttribute: (node) => false,
        );
        check(output).equals(
          '<body>\n'
          '  <a a="1">AAA</a>\n'
          '  <b a="1" b="2">BBB</b>\n'
          '  <c a="1" b="2" c="3">CCC</c>\n'
          '</body>',
        );
      });
      test('indent all', () {
        final output = document.toXmlString(
          pretty: true,
          indentAttribute: (node) => true,
        );
        check(output).equals(
          '<body>\n'
          '  <a\n'
          '    a="1">AAA</a>\n'
          '  <b\n'
          '    a="1"\n'
          '    b="2">BBB</b>\n'
          '  <c\n'
          '    a="1"\n'
          '    b="2"\n'
          '    c="3">CCC</c>\n'
          '</body>',
        );
      });
      test('intend after first', () {
        final output = document.toXmlString(
          pretty: true,
          indentAttribute: (node) => node.parent!.attributes.first != node,
        );
        check(output).equals(
          '<body>\n'
          '  <a a="1">AAA</a>\n'
          '  <b a="1"\n'
          '    b="2">BBB</b>\n'
          '  <c a="1"\n'
          '    b="2"\n'
          '    c="3">CCC</c>\n'
          '</body>',
        );
      });
      test('indent when multiple', () {
        final output = document.toXmlString(
          pretty: true,
          indentAttribute: (node) => node.parent!.attributes.length > 1,
        );
        check(output).equals(
          '<body>\n'
          '  <a a="1">AAA</a>\n'
          '  <b\n'
          '    a="1"\n'
          '    b="2">BBB</b>\n'
          '  <c\n'
          '    a="1"\n'
          '    b="2"\n'
          '    c="3">CCC</c>\n'
          '</body>',
        );
      });
      test('indent every second', () {
        final output = document.toXmlString(
          pretty: true,
          indentAttribute: (node) {
            final index = node.parent!.attributes.indexOf(node);
            return index > 0 && index.isEven;
          },
        );
        check(output).equals(
          '<body>\n'
          '  <a a="1">AAA</a>\n'
          '  <b a="1" b="2">BBB</b>\n'
          '  <c a="1" b="2"\n'
          '    c="3">CCC</c>\n'
          '</body>',
        );
      });
      test('no indent in preserve mode', () {
        final output = document.toXmlString(
          pretty: true,
          preserveWhitespace: (node) => true,
          indentAttribute: (node) => true,
        );
        check(output).equals(
          '<body>'
          '<a a="1">AAA</a>'
          '<b a="1" b="2">BBB</b>'
          '<c a="1" b="2" c="3">CCC</c>'
          '</body>',
        );
      });
      test(
        'normalizeAttributes without sortAttributes returns original list',
        () {
          final buffer = StringBuffer();
          final writer = _TestPrettyWriter(buffer);
          final element = XmlElement(const XmlName('foo'), [
            XmlAttribute(const XmlName('a'), '1'),
          ]);
          check(
            identical(
              writer.testNormalizeAttributes(element.attributes),
              element.attributes,
            ),
          ).isTrue();
        },
      );
      test('sort reverse', () {
        final output = document.toXmlString(
          pretty: true,
          sortAttributes: (a, b) =>
              b.name.qualified.compareTo(a.name.qualified),
        );
        check(output).equals(
          '<body>\n'
          '  <a a="1">AAA</a>\n'
          '  <b b="2" a="1">BBB</b>\n'
          '  <c c="3" b="2" a="1">CCC</c>\n'
          '</body>',
        );
      });
      test('sort reverse in preserve mode', () {
        final output = document.toXmlString(
          pretty: true,
          preserveWhitespace: (n) => true,
          sortAttributes: (a, b) =>
              b.name.qualified.compareTo(a.name.qualified),
        );
        check(output).equals(
          '<body>'
          '<a a="1">AAA</a>'
          '<b b="2" a="1">BBB</b>'
          '<c c="3" b="2" a="1">CCC</c>'
          '</body>',
        );
      });
      test('insert space before self-closing', () {
        final element = XmlElement.tag(
          'base',
          children: [
            XmlElement(const XmlName.qualified('simple')),
            XmlElement.tag(
              'with-attributes',
              attributes: [
                XmlAttribute(const XmlName.qualified('attr'), 'val'),
              ],
            ),
            XmlElement(const XmlName.qualified('do-not-add')),
          ],
        );

        final output = element.toXmlString(
          pretty: true,
          spaceBeforeSelfClose: (node) =>
              node is XmlElement && node.localName != 'do-not-add',
        );
        check(output).equals(
          '<base>\n'
          '  <simple />\n'
          '  <with-attributes attr="val" />\n'
          '  <do-not-add/>\n'
          '</base>',
        );
      });
    });
    group('namespaces', () {
      test('default', () {
        final namespace = XmlNamespace('prefix', 'http://uri.com');
        check(namespace.toXmlString()).equals('xmlns:prefix="http://uri.com"');
      });
      test('empty prefix', () {
        final namespace = XmlNamespace('', 'http://uri.com');
        check(namespace.toXmlString()).equals('xmlns="http://uri.com"');
      });
      test('namespace prefix', () {
        final namespace = XmlNamespace('xmlns', 'http://uri.com');
        check(namespace.toXmlString()).equals('xmlns:xmlns="http://uri.com"');
      });
      group('repair', () {
        test('element with prefix and namespaceUri', () {
          final element = XmlElement(
            const XmlName.parts(
              'child',
              prefix: 'p',
              namespaceUri: 'http://foo',
            ),
          );
          check(element.toXmlString()).equals('<p:child/>');
          check(element.toXmlString(repairNamespaces: true))
              .equals('<p:child xmlns:p="http://foo"/>');
        });
        test('element with default namespaceUri', () {
          final element = XmlElement(
            const XmlName.parts('child', namespaceUri: 'http://foo'),
          );
          check(element.toXmlString()).equals('<child/>');
          check(element.toXmlString(repairNamespaces: true))
              .equals('<child xmlns="http://foo"/>');
        });
        test('attribute with prefix and namespaceUri', () {
          final element = XmlElement(const XmlName.qualified('root'), [
            XmlAttribute(
              const XmlName.parts(
                'attr',
                prefix: 'a',
                namespaceUri: 'http://bar',
              ),
              'value',
            ),
          ]);
          check(element.toXmlString(repairNamespaces: true))
              .equals('<root a:attr="value" xmlns:a="http://bar"/>');
        });
        test('nested elements share scope without duplicating declaration', () {
          final child = XmlElement(
            const XmlName.parts(
              'child',
              prefix: 'p',
              namespaceUri: 'http://foo',
            ),
          );
          final root = XmlElement(
            const XmlName.parts(
              'root',
              prefix: 'p',
              namespaceUri: 'http://foo',
            ),
            const [],
            [child],
          );
          check(root.toXmlString(repairNamespaces: true))
              .equals('<p:root xmlns:p="http://foo"><p:child/></p:root>');
        });
        test('nested element with new prefix', () {
          final child = XmlElement(
            const XmlName.parts(
              'child',
              prefix: 'c',
              namespaceUri: 'http://child',
            ),
          );
          final root = XmlElement(
            const XmlName.parts(
              'root',
              prefix: 'p',
              namespaceUri: 'http://root',
            ),
            const [],
            [child],
          );
          check(root.toXmlString(repairNamespaces: true)).equals(
            '<p:root xmlns:p="http://root">'
            '<c:child xmlns:c="http://child"/>'
            '</p:root>',
          );
        });
        test('preserves existing explicit xmlns declarations', () {
          final element = XmlElement(
            const XmlName.parts(
              'root',
              prefix: 'p',
              namespaceUri: 'http://foo',
            ),
            [
              XmlAttribute(
                const XmlName.parts('p', prefix: 'xmlns'),
                'http://foo',
              ),
            ],
          );
          check(element.toXmlString(repairNamespaces: true))
              .equals('<p:root xmlns:p="http://foo"/>');
        });
        test('preserves existing default xmlns declaration on children', () {
          final root = XmlElement(
            const XmlName.parts('root', namespaceUri: 'http://foo'),
            [XmlAttribute(const XmlName.parts('xmlns'), 'http://foo')],
            [
              XmlElement(
                const XmlName.parts('child', namespaceUri: 'http://foo'),
              ),
            ],
          );
          check(root.toXmlString(repairNamespaces: true))
              .equals('<root xmlns="http://foo"><child/></root>');
        });
        test('xml prefix does not synthesize declaration', () {
          final element = XmlElement(const XmlName.qualified('root'), [
            XmlAttribute(
              const XmlName.parts(
                'space',
                prefix: 'xml',
                namespaceUri: 'http://www.w3.org/XML/1998/namespace',
              ),
              'preserve',
            ),
          ]);
          check(element.toXmlString(repairNamespaces: true))
              .equals('<root xml:space="preserve"/>');
        });
        test('pretty printing with repairNamespaces', () {
          final child = XmlElement(
            const XmlName.parts(
              'child',
              prefix: 'p',
              namespaceUri: 'http://foo',
            ),
          );
          final root = XmlElement(
            const XmlName.parts(
              'root',
              prefix: 'p',
              namespaceUri: 'http://foo',
            ),
            const [],
            [child],
          );
          check(root.toXmlString(pretty: true, repairNamespaces: true)).equals(
            '<p:root xmlns:p="http://foo">\n'
            '  <p:child/>\n'
            '</p:root>',
          );
        });
      });
    });
    group('document fragment', () {
      test('default', () {
        final fragment = XmlDocumentFragment([
          XmlElement.tag('first'),
          XmlText('text'),
          XmlElement.tag('second'),
        ]);
        check(fragment.toXmlString()).equals('<first/>text<second/>');
      });
      test('pretty', () {
        final fragment = XmlDocumentFragment([
          XmlElement.tag('first'),
          XmlElement.tag('second'),
        ]);
        check(fragment.toXmlString(pretty: true)).equals('<first/>\n<second/>');
      });
    });
  });
}

class _TestPrettyWriter extends XmlPrettyWriter {
  new(super.buffer);

  List<XmlAttribute> testNormalizeAttributes(List<XmlAttribute> attributes) =>
      normalizeAttributes(attributes);
}
