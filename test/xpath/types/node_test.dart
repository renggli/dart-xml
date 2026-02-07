import 'package:test/test.dart';
import 'package:xml/src/xpath/exceptions/evaluation_exception.dart';
import 'package:xml/src/xpath/types/node.dart';
import 'package:xml/src/xpath/types/sequence.dart';
import 'package:xml/xml.dart';

void main() {
  final document = XmlDocument.parse(
    '<r a="1"><a>1</a><b>2<c>3</c></b><!--c--><?p?></r>',
  );
  final root = document.rootElement;
  final attribute = root.attributes.single;
  final elementA = root.findAllElements('a').single;
  final text1 = elementA.firstChild!;
  final comment = root.children.whereType<XmlComment>().single;
  final processing = root.children.whereType<XmlProcessing>().single;

  group('xsNode', () {
    test('name', () {
      expect(xsNode.name, 'node');
    });
    test('matches', () {
      expect(xsNode.matches(document), isTrue);
      expect(xsNode.matches(root), isTrue);
      expect(xsNode.matches(attribute), isTrue);
      expect(xsNode.matches(text1), isTrue);
      expect(xsNode.matches(comment), isTrue);
      expect(xsNode.matches(processing), isTrue);
      expect(xsNode.matches('foo'), isFalse);
    });
    test('cast', () {
      expect(xsNode.cast(root), root);
      expect(xsNode.cast(XPathSequence.single(root)), root);
      expect(() => xsNode.cast(123), throwsA(isA<XPathEvaluationException>()));
      expect(
        () => xsNode.cast(XPathSequence.empty),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('xsDocument', () {
    test('name', () {
      expect(xsDocument.name, 'document');
    });
    test('matches', () {
      expect(xsDocument.matches(document), isTrue);
      expect(xsDocument.matches(root), isFalse);
    });
    test('cast', () {
      expect(xsDocument.cast(document), document);
      expect(
        () => xsDocument.cast(root),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('xsElement', () {
    test('name', () {
      expect(xsElement.name, 'element');
    });
    test('matches', () {
      expect(xsElement.matches(root), isTrue);
      expect(xsElement.matches(document), isFalse);
    });
    test('cast', () {
      expect(xsElement.cast(root), root);
      expect(
        () => xsElement.cast(document),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('xsAttribute', () {
    test('name', () {
      expect(xsAttribute.name, 'attribute');
    });
    test('matches', () {
      expect(xsAttribute.matches(attribute), isTrue);
      expect(xsAttribute.matches(root), isFalse);
    });
    test('cast', () {
      expect(xsAttribute.cast(attribute), attribute);
      expect(
        () => xsAttribute.cast(root),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('xsText', () {
    test('name', () {
      expect(xsText.name, 'text');
    });
    test('matches', () {
      expect(xsText.matches(text1), isTrue);
      expect(xsText.matches(root), isFalse);
    });
    test('cast', () {
      expect(xsText.cast(text1), text1);
      expect(() => xsText.cast(root), throwsA(isA<XPathEvaluationException>()));
    });
  });

  group('xsComment', () {
    test('name', () {
      expect(xsComment.name, 'comment');
    });
    test('matches', () {
      expect(xsComment.matches(comment), isTrue);
      expect(xsComment.matches(root), isFalse);
    });
    test('cast', () {
      expect(xsComment.cast(comment), comment);
      expect(
        () => xsComment.cast(root),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });

  group('xsProcessingInstruction', () {
    test('name', () {
      expect(xsProcessingInstruction.name, 'processing-instruction');
    });
    test('matches', () {
      expect(xsProcessingInstruction.matches(processing), isTrue);
      expect(xsProcessingInstruction.matches(root), isFalse);
    });
    test('cast', () {
      expect(xsProcessingInstruction.cast(processing), processing);
      expect(
        () => xsProcessingInstruction.cast(root),
        throwsA(isA<XPathEvaluationException>()),
      );
    });
  });
}
