import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

void main() {
  test('document type', () {
    final document = XmlDocument.parse(
      '<!DOCTYPE html [<!-- internal subset -->]><data />',
    );
    final node = document.doctypeElement!;
    check(node.parent).identicalTo(document);
    check(node.parentElement).isNull();
    check(node.document).identicalTo(document);
    check(node.depth).equals(1);
    check(node.attributes).isEmpty();
    check(node.elementAttributes).isEmpty();
    check(node.namespaces).isEmpty();
    check(node.children).isEmpty();
    check(node.name).equals('html');
    check(node.externalId).isNull();
    check(node.internalSubset).equals('<!-- internal subset -->');
    check(node.nodeType).equals(XmlNodeType.DOCUMENT_TYPE);
    check(node.toString()).equals('<!DOCTYPE html [<!-- internal subset -->]>');
  });
}
