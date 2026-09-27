import 'package:test/test.dart';
import 'package:xml/src/xpath/expressions/axis.dart';
import 'package:xml/src/xpath/expressions/name.dart';
import 'package:xml/src/xpath/expressions/node.dart';
import 'package:xml/src/xpath/expressions/path.dart';
import 'package:xml/src/xpath/expressions/predicate.dart';
import 'package:xml/src/xpath/expressions/step.dart';
import 'package:xml/src/xpath/expressions/variable.dart';
import 'package:xml/src/xpath/grammars/parser.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

import '../../utils/matchers.dart';

void main() {
  group('step optimization', () {
    void expectOptimized(Axis stepAxis, Axis newAxis) {
      {
        // Applies optimization.
        final path = PathExpression([
          const StepExpression(DescendantOrSelfAxis()),
          StepExpression(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ]);
        expect(path.steps, hasLength(1));
        final actualStep = path.steps.single as StepExpression;
        expect(actualStep.axis.runtimeType, newAxis.runtimeType);
        expect(actualStep.nodeTest, const QualifiedNameTest('x'));
        expect(actualStep.predicates, isEmpty);
      }
      {
        // Incompatible initial step.
        final path = PathExpression([
          const StepExpression(SelfAxis()),
          StepExpression(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ]);
        expect(path.steps, hasLength(2));
      }
      {
        // Incompatible node test.
        final path = PathExpression([
          const StepExpression(
            DescendantOrSelfAxis(),
            nodeTest: CommentTypeTest(),
          ),
          StepExpression(stepAxis, nodeTest: const QualifiedNameTest('x')),
        ]);
        expect(path.steps, hasLength(2));
      }
      {
        // Incompatible predicate.
        final path = PathExpression([
          const StepExpression(DescendantOrSelfAxis()),
          StepExpression(
            stepAxis,
            nodeTest: const QualifiedNameTest('x'),
            predicates: [
              Predicate(
                LiteralExpression(
                  XPathSequence.single(XPathInteger.fromInt(1)),
                ),
              ),
            ],
          ),
        ]);
        expect(path.steps, hasLength(2));
      }
    }

    test(
      '//child::x => descendant::x',
      () => expectOptimized(const ChildAxis(), const DescendantAxis()),
    );
    test(
      '//self::x => descendant-or-self::x',
      () => expectOptimized(const SelfAxis(), const DescendantOrSelfAxis()),
    );
    test(
      '//descendant::x => descendant::x',
      () => expectOptimized(const DescendantAxis(), const DescendantAxis()),
    );
    test(
      '//descendant-or-self::x => descendant-or-self::x',
      () => expectOptimized(
        const DescendantOrSelfAxis(),
        const DescendantOrSelfAxis(),
      ),
    );
  });
  group('order preservation', () {
    test('anyStep (selfStep | attributeStep)*', () {
      expect(
        PathExpression(const [StepExpression(AncestorOrSelfAxis())])
            .isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(AncestorOrSelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(AncestorOrSelfAxis()),
          StepExpression(DescendantAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
    });
    test('(selfStep | childStep)+ (descendantStep | descendantOrSelfStep)? (selfStep | attributeStep)*', () {
      expect(
        PathExpression(const [
          StepExpression(ChildAxis()),
          StepExpression(ChildAxis()),
          StepExpression(SelfAxis()),
          StepExpression(DescendantAxis()),
          StepExpression(SelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(ChildAxis()),
          StepExpression(ChildAxis()),
          StepExpression(SelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(ChildAxis()),
          StepExpression(ChildAxis()),
          StepExpression(SelfAxis()),
          StepExpression(DescendantOrSelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          StepExpression(ChildAxis()),
          StepExpression(ChildAxis()),
          StepExpression(SelfAxis()),
          StepExpression(ParentAxis()),
          StepExpression(SelfAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isFalse,
      );
    });
  });

  group('evaluation edge cases', () {
    final context = XPathConfiguration().context(XmlDocument.parse('<root/>'));
    test('empty steps throw ArgumentError', () {
      expect(() => PathExpression([]), throwsArgumentError);
    });
    test(
      'non-node items on path step without order preserved throws Exception',
      () {
        final path = PathExpression([
          const LiteralExpression(XPathSequence.single(XPathString('text'))),
          const StepExpression(ChildAxis()),
        ]);
        expect(path.isOrderPreserved, isFalse);
        expect(
          () => path(context),
          throwsA(
            isXPathEvaluationException(
              message: 'Path operator / requires sequence of nodes, but got text [err:XPTY0019]',
            ),
          ),
        );
      },
    );
    test(
      'non-node items on path step with order preserved throws Exception',
      () {
        final path = PathExpression([
          const LiteralExpression(XPathSequence.single(XPathString('text'))),
          const StepExpression(ChildAxis()),
        ], isOrderPreserved: true);
        expect(path.isOrderPreserved, isTrue);
        expect(
          () => path(context),
          throwsA(
            isXPathEvaluationException(
              message: 'Path operator / requires sequence of nodes, but got text [err:XPTY0019]',
            ),
          ),
        );
      },
    );
    test('sort and deduplicate with non-nodes', () {
      final xml = XmlDocument.parse('<root><a><b/></a></root>');
      final path = PathExpression([
        const StepExpression(AncestorAxis()),
        LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
      ]);
      expect(path.isOrderPreserved, isFalse);
      final evalContext = XPathConfiguration().context(
        xml.rootElement.children.first,
      );
      expect(path(evalContext), isXPathSequence([1]));
    });
    test('sort and deduplicate with large node sets', () {
      final xml = XmlDocument.parse(
        '<root>${List.generate(60, (i) => '<a><b/></a>').join('')}</root>',
      );
      final path = PathExpression([
        const StepExpression(AncestorAxis()),
        const StepExpression(ChildAxis()),
      ]);
      expect(path.isOrderPreserved, isFalse);
      // Evaluate starting at a 'b' node
      final evalContext = XPathConfiguration().context(
        xml.findAllElements('b').first,
      );
      final result = path(evalContext);
      expect(result, hasLength(62));
    });
    test('sort and deduplicate with nodes from multiple documents', () {
      final xml1 = XmlDocument.parse(
        '<root>${List.generate(55, (i) => '<a><b/></a>').join('')}</root>',
      );
      final xml2 = XmlDocument.parse('<root2><a/><b/></root2>');
      final path = PathExpression([
        LiteralExpression(
          XPathSequence([
            ...xml1.findAllElements('b').map(XPathNode.new),
            ...xml2.rootElement.children.map(XPathNode.new),
          ]),
        ),
        const StepExpression(SelfAxis()),
      ]);
      expect(path.isOrderPreserved, isFalse);
      final result = path(context);
      // Expected to find 55 elements from xml1 + 2 elements from xml2 = 57
      expect(result, hasLength(57));
    });
  });

  group('order preservation with RootNodeExpression', () {
    test('RootNodeExpression alone', () {
      expect(
        PathExpression(const [RootNodeExpression()]).isOrderPreserved,
        isTrue,
      );
    });

    test('RootNodeExpression followed by any single step', () {
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(DescendantAxis()),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(DescendantOrSelfAxis()),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
    });

    test('RootNodeExpression (childStep)+', () {
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(ChildAxis()),
          StepExpression(ChildAxis()),
        ]).isOrderPreserved,
        isTrue,
      );
    });

    test('RootNodeExpression (childStep)* (descendantStep)? (selfStep | attributeStep)*', () {
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(DescendantAxis()),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(DescendantAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(DescendantAxis()),
          StepExpression(SelfAxis()),
          StepExpression(AttributeAxis(), nodeTest: QualifiedNameTest('id')),
        ]).isOrderPreserved,
        isTrue,
      );
    });

    test('RootNodeExpression followed by non-order-preserving steps', () {
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(ParentAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(AncestorAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(PrecedingAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(FollowingAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(PrecedingSiblingAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(ChildAxis()),
          StepExpression(FollowingSiblingAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression(const [
          RootNodeExpression(),
          StepExpression(DescendantAxis()),
          StepExpression(ChildAxis()),
        ]).isOrderPreserved,
        isFalse,
      );
      expect(
        PathExpression([
          const RootNodeExpression(),
          LiteralExpression(XPathSequence.single(XPathInteger.fromInt(1))),
        ]).isOrderPreserved,
        isFalse,
      );
    });
  });

  group('order preservation of parsed absolute paths', () {
    test('common absolute queries are order-preserved', () {
      expect(
        (parseExpression('/root/item/name') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('/root/item') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('/root') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('/root/@id') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('/root/item/@id') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('//item') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('//*') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('/root//item') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('//item/@id') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression('//item/.') as PathExpression).isOrderPreserved,
        isTrue,
      );
      expect(
        (parseExpression(
          '/root/item[1]/name',
        ) as PathExpression).isOrderPreserved,
        isTrue,
      );
    });

    test('absolute queries with reverse or non-preserving axes are not order-preserved', () {
      expect(
        (parseExpression('/root/item/..') as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression(
          '/root/item/ancestor::*',
        ) as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression(
          '/root/item/preceding::*',
        ) as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression(
          '/root/item/following::*',
        ) as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression(
          '/root/item/preceding-sibling::*',
        ) as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression(
          '/root/item/following-sibling::*',
        ) as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression('//root//item') as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression('//item/*') as PathExpression).isOrderPreserved,
        isFalse,
      );
      expect(
        (parseExpression(
          '//item/child::name',
        ) as PathExpression).isOrderPreserved,
        isFalse,
      );
    });
  });

  group('absolute path document order and deduplication evaluation', () {
    const xmlContent = '''
<tree id="0">
  <node id="1">
    <node id="1.1">
      <node id="1.1.1"/>
    </node>
    <node id="1.2"/>
  </node>
  <node id="2">
    <node id="2.1"/>
  </node>
</tree>''';

    List<String> evalIds(
      XmlDocument doc,
      String exprString, {
      XmlNode? contextNode,
    }) {
      final expr = parseExpression(exprString);
      final ctx = XPathConfiguration().context(contextNode ?? doc);
      final seq = expr(ctx);
      return seq.map((item) {
        final node = (item as XPathNode).node;
        if (node is XmlElement) return node.getAttribute('id')!;
        if (node is XmlAttribute) return node.value;
        return node.toString();
      }).toList();
    }

    test('preserves strict document order for absolute child paths', () {
      final doc = XmlDocument.parse(xmlContent);
      expect(evalIds(doc, '/tree/node'), ['1', '2']);
      expect(evalIds(doc, '/tree/node/node'), ['1.1', '1.2', '2.1']);
      expect(evalIds(doc, '/tree/node/node/node'), ['1.1.1']);
    });

    test('preserves strict document order for descendant queries', () {
      final doc = XmlDocument.parse(xmlContent);
      expect(evalIds(doc, '//node'), ['1', '1.1', '1.1.1', '1.2', '2', '2.1']);
      expect(evalIds(doc, '//*'), [
        '0',
        '1',
        '1.1',
        '1.1.1',
        '1.2',
        '2',
        '2.1',
      ]);
      expect(evalIds(doc, '/tree//node'), [
        '1',
        '1.1',
        '1.1.1',
        '1.2',
        '2',
        '2.1',
      ]);
      expect(evalIds(doc, '//node/@id'), [
        '1',
        '1.1',
        '1.1.1',
        '1.2',
        '2',
        '2.1',
      ]);
    });

    test('re-roots correctly when evaluated from a deep context node', () {
      final doc = XmlDocument.parse(xmlContent);
      final deepNode = doc
          .findAllElements('node')
          .firstWhere((e) => e.getAttribute('id') == '1.1.1');
      expect(evalIds(doc, '/tree/node', contextNode: deepNode), ['1', '2']);
      expect(evalIds(doc, '//node/@id', contextNode: deepNode), [
        '1',
        '1.1',
        '1.1.1',
        '1.2',
        '2',
        '2.1',
      ]);
    });

    test('deduplicates and sorts non-order-preserving paths', () {
      final doc = XmlDocument.parse(xmlContent);
      // //node/node without sorting would yield: 1.1, 1.2, 1.1.1, 2.1 (1.2 before 1.1.1).
      // Correct document order places 1.1.1 before 1.2:
      expect(evalIds(doc, '//node/node'), ['1.1', '1.1.1', '1.2', '2.1']);
      // //node/ancestor::node deduplicates shared ancestors (node 1 is shared by 1.1, 1.1.1, 1.2):
      expect(evalIds(doc, '//node/ancestor::node'), ['1', '1.1', '2']);
      // //node/.. deduplicates parents:
      expect(evalIds(doc, '//node/..'), ['0', '1', '1.1', '2']);
    });
  });

  group('namespace axis document order and deduplication evaluation', () {
    const nsXmlContent = '''
<root xmlns="http://example.com/default" xmlns:b="http://example.com/b" xmlns:a="http://example.com/a">
  <child xmlns:d="http://example.com/d" xmlns:c="http://example.com/c"/>
</root>''';

    List<String> evalNsWithParent(XmlNode node, String expression) =>
        node.xpath(expression).map((item) {
          final ns = item as XmlNamespace;
          final parentName = (ns.parent as XmlElement?)?.name.local ?? 'none';
          return '$parentName:${ns.toString()}';
        }).toList();

    void expectStrictDocumentOrder(Iterable<XmlNode> nodes) {
      final list = nodes.toList();
      for (var i = 0; i < list.length - 1; i++) {
        final pos = list[i].compareDocumentPosition(list[i + 1]);
        expect(
          pos.isFollowing,
          isTrue,
          reason:
              'Node at index $i (${list[i]}) must precede node at index '
              '${i + 1} (${list[i + 1]}), but compareDocumentPosition returned $pos',
        );
      }
    }

    test('sorts multiple namespaces on single element in DOM prefix order', () {
      final doc = XmlDocument.parse(nsXmlContent);
      final result = doc.xpath('/root/namespace::*').toList();
      expect(evalNsWithParent(doc, '/root/namespace::*'), [
        'root:xmlns="http://example.com/default"',
        'root:xmlns:a="http://example.com/a"',
        'root:xmlns:b="http://example.com/b"',
        'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ]);
      expectStrictDocumentOrder(result);
    });

    test(
      'sorts namespaces hierarchically across descendants in document order',
      () {
        final doc = XmlDocument.parse(nsXmlContent);
        final result = doc.xpath('//namespace::*').toList();
        expect(evalNsWithParent(doc, '//namespace::*'), [
          'root:xmlns="http://example.com/default"',
          'root:xmlns:a="http://example.com/a"',
          'root:xmlns:b="http://example.com/b"',
          'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
          'child:xmlns="http://example.com/default"',
          'child:xmlns:a="http://example.com/a"',
          'child:xmlns:b="http://example.com/b"',
          'child:xmlns:c="http://example.com/c"',
          'child:xmlns:d="http://example.com/d"',
          'child:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ]);
        expectStrictDocumentOrder(result);
      },
    );

    test(
      'deduplicates identical namespace node sets under path operations',
      () {
        final doc = XmlDocument.parse(nsXmlContent);
        final result = doc
            .xpath('(/root/namespace::* | /root/namespace::*)/.')
            .toList();
        expect(
          evalNsWithParent(doc, '(/root/namespace::* | /root/namespace::*)/.'),
          [
            'root:xmlns="http://example.com/default"',
            'root:xmlns:a="http://example.com/a"',
            'root:xmlns:b="http://example.com/b"',
            'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
          ],
        );
        expectStrictDocumentOrder(result);
      },
    );

    test('deduplicates overlapping namespace sets under path operations', () {
      final doc = XmlDocument.parse(nsXmlContent);
      expect(
        evalNsWithParent(doc, '(/root/namespace::* | /root/namespace::a)/.'),
        [
          'root:xmlns="http://example.com/default"',
          'root:xmlns:a="http://example.com/a"',
          'root:xmlns:b="http://example.com/b"',
          'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ],
      );
      final unionDescendant = doc
          .xpath('(//namespace::* | /root/namespace::*)/.')
          .toList();
      expect(evalNsWithParent(doc, '(//namespace::* | /root/namespace::*)/.'), [
        'root:xmlns="http://example.com/default"',
        'root:xmlns:a="http://example.com/a"',
        'root:xmlns:b="http://example.com/b"',
        'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        'child:xmlns="http://example.com/default"',
        'child:xmlns:a="http://example.com/a"',
        'child:xmlns:b="http://example.com/b"',
        'child:xmlns:c="http://example.com/c"',
        'child:xmlns:d="http://example.com/d"',
        'child:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ]);
      expectStrictDocumentOrder(unionDescendant);
    });

    test(
      'sorts disjoint namespaces under union operations in prefix order',
      () {
        final doc = XmlDocument.parse(nsXmlContent);
        expect(
          evalNsWithParent(doc, '/root/namespace::b | /root/namespace::a'),
          [
            'root:xmlns:a="http://example.com/a"',
            'root:xmlns:b="http://example.com/b"',
          ],
        );
        expect(
          evalNsWithParent(
            doc,
            '/root/namespace::xml | /root/namespace::b | /root/namespace::a',
          ),
          [
            'root:xmlns:a="http://example.com/a"',
            'root:xmlns:b="http://example.com/b"',
            'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
          ],
        );
      },
    );

    test('preserves distinct namespace identity across parent elements under union', () {
      final doc = XmlDocument.parse(nsXmlContent);
      final result = doc
          .xpath('/root/namespace::* | /root/child/namespace::*')
          .toList();
      expect(result, hasLength(10));
      expect(
        evalNsWithParent(doc, '/root/namespace::* | /root/child/namespace::*'),
        [
          'root:xmlns="http://example.com/default"',
          'root:xmlns:a="http://example.com/a"',
          'root:xmlns:b="http://example.com/b"',
          'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
          'child:xmlns="http://example.com/default"',
          'child:xmlns:a="http://example.com/a"',
          'child:xmlns:b="http://example.com/b"',
          'child:xmlns:c="http://example.com/c"',
          'child:xmlns:d="http://example.com/d"',
          'child:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
        ],
      );
      expectStrictDocumentOrder(result);
    });

    test('deduplicates namespaces across multi-step paths converging on same element', () {
      final doc = XmlDocument.parse(nsXmlContent);
      expect(evalNsWithParent(doc, '(/root/child/.. | /root)/namespace::*'), [
        'root:xmlns="http://example.com/default"',
        'root:xmlns:a="http://example.com/a"',
        'root:xmlns:b="http://example.com/b"',
        'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ]);
      expect(evalNsWithParent(doc, '(/root | /root)/namespace::*'), [
        'root:xmlns="http://example.com/default"',
        'root:xmlns:a="http://example.com/a"',
        'root:xmlns:b="http://example.com/b"',
        'root:xmlns:xml="http://www.w3.org/XML/1998/namespace"',
      ]);
    });
  });

  group('step collapsing with predicates', () {
    test('collapses //child::x with non-positional attribute predicate', () {
      final path = parseExpression('//item[@id="100"]') as PathExpression;
      expect(path.steps, hasLength(2));
      final step = path.steps[1] as StepExpression;
      expect(step.axis, isA<DescendantAxis>());
      expect(step.predicates, hasLength(1));
    });

    test('collapses //child::x with multiple non-positional predicates', () {
      final path = parseExpression('//item[@a="1"][@b="2"]') as PathExpression;
      expect(path.steps, hasLength(2));
      final step = path.steps[1] as StepExpression;
      expect(step.axis, isA<DescendantAxis>());
      expect(step.predicates, hasLength(2));
    });

    test('collapses //child::x with non-positional function predicate', () {
      final path = parseExpression('//item[not(@disabled)]') as PathExpression;
      expect(path.steps, hasLength(2));
      final step = path.steps[1] as StepExpression;
      expect(step.axis, isA<DescendantAxis>());
    });

    test('collapses //* with non-positional attribute predicate', () {
      final path = parseExpression('//*[@id="100"]') as PathExpression;
      expect(path.steps, hasLength(2));
      final step = path.steps[1] as StepExpression;
      expect(step.axis, isA<DescendantAxis>());
    });

    test('does NOT collapse //child::x with integer literal predicate', () {
      final path = parseExpression('//item[1]') as PathExpression;
      expect(path.steps, hasLength(3));
      expect(path.steps[1], isA<StepExpression>());
      expect(
        (path.steps[1] as StepExpression).axis,
        isA<DescendantOrSelfAxis>(),
      );
      expect(path.steps[2], isA<StepExpression>());
      expect((path.steps[2] as StepExpression).axis, isA<ChildAxis>());
    });

    test('does NOT collapse //child::x with last() predicate', () {
      final path = parseExpression('//item[last()]') as PathExpression;
      expect(path.steps, hasLength(3));
      expect(
        (path.steps[1] as StepExpression).axis,
        isA<DescendantOrSelfAxis>(),
      );
      expect((path.steps[2] as StepExpression).axis, isA<ChildAxis>());
    });

    test('does NOT collapse //child::x with position() comparison', () {
      final path = parseExpression('//item[position() > 1]') as PathExpression;
      expect(path.steps, hasLength(3));
      expect(
        (path.steps[1] as StepExpression).axis,
        isA<DescendantOrSelfAxis>(),
      );
      expect((path.steps[2] as StepExpression).axis, isA<ChildAxis>());
    });

    test('does NOT collapse //child::x with mixed compound predicates', () {
      final path1 = parseExpression('//item[@id="100"][1]') as PathExpression;
      expect(path1.steps, hasLength(3));
      expect(
        (path1.steps[1] as StepExpression).axis,
        isA<DescendantOrSelfAxis>(),
      );

      final path2 = parseExpression('//item[1][@id="100"]') as PathExpression;
      expect(path2.steps, hasLength(3));
      expect(
        (path2.steps[1] as StepExpression).axis,
        isA<DescendantOrSelfAxis>(),
      );
    });
  });
}
