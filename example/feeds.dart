/// A simple command-line based RSS feed reader.
library feeds;

import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:xml/xml.dart';

abstract class RssCommand extends Command<void> {
  String get feedsName =>
      globalResults!['feeds'] as String? ?? 'example/feeds.xml';

  File get feedsFile => File(feedsName);

  Future<XmlDocument> readFeeds() async {
    try {
      final input = await feedsFile.readAsString();
      return XmlDocument.parse(input);
    } catch (exception) {
      stdout.writeln('Unable to read "$feedsName" due to $exception');
      exit(1);
    }
  }

  Future<void> writeFeeds(XmlDocument document) =>
      feedsFile.writeAsString(document.toXmlString(pretty: true));
}

class AddCommand extends RssCommand {
  @override
  String get name => 'add';

  @override
  String get description => 'Adds a feed URL.';

  @override
  Future<void> run() async {
    final document = await readFeeds();
    for (final feed in argResults!.rest) {
      final builder = XmlBuilder()..element('url', nest: feed);
      document.rootElement.children.add(builder.buildFragment());
    }
    await writeFeeds(document);
  }
}

class RemoveCommand extends RssCommand {
  @override
  String get name => 'rm';

  @override
  String get description => 'Removes a feed URL.';

  @override
  Future<void> run() async {
    final urls = {...argResults!.rest};
    final document = await readFeeds();
    for (final element in document.findAllElements('url').toList()) {
      if (urls.contains(element.innerText.trim())) {
        element.remove();
      }
    }
    await writeFeeds(document);
  }
}

class ListCommand extends RssCommand {
  @override
  String get name => 'list';

  @override
  String get description => 'Lists the feed URLs.';

  @override
  Future<void> run() async {
    final document = await readFeeds();
    for (final element in document.findAllElements('url')) {
      stdout.writeln(element.innerText.trim());
    }
  }
}

class ReadCommand extends RssCommand {
  @override
  String get name => 'read';

  @override
  String get description => 'Reads the feeds.';

  @override
  Future<void> run() async {
    final feeds = await readFeeds();
    final documents = feeds
        .findAllElements('url')
        .map((element) => _get(Uri.parse(element.innerText.trim())));
    await Stream.fromFutures(documents).listen((document) {
      for (final item in document.findAllElements('item')) {
        final title = item.findElements('title').firstOrNull?.innerText;
        final link = item.findElements('link').firstOrNull?.innerText;
        if (title != null && link != null) {
          stdout.writeln('$title ($link)');
        }
      }
    }, onError: (dynamic error) => stderr.writeln(error)).asFuture<void>();
  }

  final httpClient = HttpClient();

  Future<XmlDocument> _get(Uri uri) async {
    final request = await httpClient.getUrl(uri);
    final response = await request.close();
    final input = await response.transform(utf8.decoder).join();
    return XmlDocument.parse(input);
  }
}

final runner = CommandRunner<void>('feeds', 'Manages and reads RSS feeds.')
  ..addCommand(AddCommand())
  ..addCommand(RemoveCommand())
  ..addCommand(ListCommand())
  ..addCommand(ReadCommand());

Future<void> main(List<String> arguments) async {
  runner.argParser.addOption('feeds', help: 'path to current feeds');
  await runner.run(arguments).catchError((Object error) {
    stdout.writeln(error);
    exit(1);
  }, test: (error) => error is UsageException);
}
