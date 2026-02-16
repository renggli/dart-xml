import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  test('document type', () {
    final document = XmlDocument.parse(
      '<!DOCTYPE html [<!-- internal subset -->]><data />',
    );
    final node = document.doctypeElement!;
    expect(node.parent, same(document));
    expect(node.parentElement, isNull);
    expect(node.document, same(document));
    expect(node.depth, 1);
    expect(node.attributes, isEmpty);
    expect(node.children, isEmpty);
    expect(node.name, 'html');
    expect(node.externalId, isNull);
    expect(node.internalSubset, '<!-- internal subset -->');
    expect(node.nodeType, XmlNodeType.DOCUMENT_TYPE);
    expect(node.toString(), '<!DOCTYPE html [<!-- internal subset -->]>');
  });
}
