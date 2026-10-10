import 'package:checks/checks.dart';
import 'package:test/scaffolding.dart';
import 'package:xml/xml.dart';

import '../utils/checks.dart';

void main() {
  test('default namespace', () {
    final document = XmlDocument.parse(
      '<html width="" xmlns="http://www.w3.org/1999/xhtml" height="">'
      '  <body lang="en"/>'
      '</html>',
    );
    check(document).hasNamespaces({
      'html': 'http://www.w3.org/1999/xhtml',
      'width': 'http://www.w3.org/1999/xhtml',
      'xmlns': 'http://www.w3.org/2000/xmlns/',
      'height': 'http://www.w3.org/1999/xhtml',
      'body': 'http://www.w3.org/1999/xhtml',
      'lang': 'http://www.w3.org/1999/xhtml',
    });
  });
  test('prefix namespace', () {
    final document = XmlDocument.parse(
      '<html:html html:width="" xmlns:html="http://www.w3.org/1999/xhtml" html:height="">'
      '  <html:body html:lang="en"/>'
      '</html:html>',
    );
    check(document).hasNamespaces({
      'html:html': 'http://www.w3.org/1999/xhtml',
      'html:width': 'http://www.w3.org/1999/xhtml',
      'xmlns:html': 'http://www.w3.org/2000/xmlns/',
      'html:height': 'http://www.w3.org/1999/xhtml',
      'html:body': 'http://www.w3.org/1999/xhtml',
      'html:lang': 'http://www.w3.org/1999/xhtml',
    });
  });
  test('default namespace override', () {
    final document = XmlDocument.parse(
      '<html xmlns="http://www.w3.org/1999/xhtml">'
      '  <other xmlns=""/>'
      '  <div/>'
      '</html>',
    );
    check(document).hasNamespaces({
      'html': 'http://www.w3.org/1999/xhtml',
      'xmlns': 'http://www.w3.org/2000/xmlns/',
      'other': null,
      'div': 'http://www.w3.org/1999/xhtml',
    });
  });
  test('prefix namespace override', () {
    final document = XmlDocument.parse(
      '<default:html xmlns:default="http://www.w3.org/1999/xhtml">'
      '  <default:svg xmlns:default="http://www.w3.org/2000/svg"/>'
      '  <default:div/>'
      '</default:html>',
    );
    check(document).hasNamespaces({
      'default:html': 'http://www.w3.org/1999/xhtml',
      'xmlns:default': 'http://www.w3.org/2000/xmlns/',
      'default:svg': 'http://www.w3.org/2000/svg',
      'default:div': 'http://www.w3.org/1999/xhtml',
    });
  });
  test('default namespace reset', () {
    final document = XmlDocument.parse(
      '<html xmlns="http://www.w3.org/1999/xhtml">'
      '  <svg xmlns="http://www.w3.org/2000/svg"/>'
      '  <div/>'
      '</html>',
    );
    check(document).hasNamespaces({
      'html': 'http://www.w3.org/1999/xhtml',
      'xmlns': 'http://www.w3.org/2000/xmlns/',
      'svg': 'http://www.w3.org/2000/svg',
      'div': 'http://www.w3.org/1999/xhtml',
    });
  });
  test('prefix namespace reset', () {
    final document = XmlDocument.parse(
      '<default:html xmlns:default="http://www.w3.org/1999/xhtml">'
      '  <default:other xmlns:default=""/>'
      '  <default:div/>'
      '</default:html>',
    );
    check(document).hasNamespaces({
      'default:html': 'http://www.w3.org/1999/xhtml',
      'xmlns:default': 'http://www.w3.org/2000/xmlns/',
      'default:other': null,
      'default:div': 'http://www.w3.org/1999/xhtml',
    });
  });
  test('special xml namespace', () {
    final document = XmlDocument.parse(
      '<feed xml:lang="en" xml:space="preserve" xml:base="." xml:id="f1"/>',
    );
    check(document).hasNamespaces({
      'feed': null,
      'xml:lang': 'http://www.w3.org/XML/1998/namespace',
      'xml:space': 'http://www.w3.org/XML/1998/namespace',
      'xml:base': 'http://www.w3.org/XML/1998/namespace',
      'xml:id': 'http://www.w3.org/XML/1998/namespace',
    });
  });
  test('no namespaces', () {
    final document = XmlDocument.parse('<element attribute=""/>');
    check(document).hasNamespaces({'element': null, 'attribute': null});
  });
  test('unknown namespaces', () {
    final document = XmlDocument.parse(
      '<unknown:element unknown:attribute=""/>',
    );
    check(document)
        .hasNamespaces({'unknown:element': null, 'unknown:attribute': null});
  });
}
