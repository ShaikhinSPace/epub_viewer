import 'package:epub_viewer/src/helper.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EpubController {
  InAppWebViewController? webViewController;

  ///List of chapters from epub
  List<EpubChapter> chapters = [];

  setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
  }

  ///Move epub view to specific area using Cfi string or chapter href
  display({
    ///Cfi String of the desired location, also accepts chapter href
    required String cfi,
  }) {
    checkEpubLoaded();
    webViewController?.evaluateJavascript(source: 'toCfi("$cfi")');
  }

  ///Moves to next page in epub view
  next() {
    checkEpubLoaded();
    webViewController?.evaluateJavascript(source: 'next()');
  }

  ///Moves to previous page in epub view
  prev() {
    checkEpubLoaded();
    webViewController?.evaluateJavascript(source: 'previous()');
  }

  ///Returns current location of epub viewer
  Future<EpubLocation> getCurrentLocation() async {
    checkEpubLoaded();
    final result = await webViewController?.evaluateJavascript(
        source: 'getCurrentLocation()');
    return EpubLocation.fromJson(result);
  }

  ///Returns list of chapters from epub,
  /// should be called after onChaptersLoaded callback, otherwise returns empty list
  List<EpubChapter> getChapters() {
    checkEpubLoaded();
    return chapters;
  }

  ///Parsing chapters list form epub
  Future<List<EpubChapter>> parseChapters() async {
    checkEpubLoaded();
    final result =
        await webViewController!.evaluateJavascript(source: 'getChapters()');

    chapters =
        List<EpubChapter>.from(result.map((e) => EpubChapter.fromJson(e)));
    return chapters;
  }

  checkEpubLoaded() {
    if (webViewController == null) {
      throw Exception(
          "Epub viewer is not loaded, please call after onEpubLoaded callback");
    }
  }
}

class LocalServerController {
  final InAppLocalhostServer _localhostServer = InAppLocalhostServer(
      documentRoot: 'packages/epub_viewer/lib/assets/webpage');

  Future<void> initServer() async {
    if (_localhostServer.isRunning()) return;
    await _localhostServer.start();
  }

  Future<void> disposeServer() async {
    if (!_localhostServer.isRunning()) return;
    await _localhostServer.close();
  }
}
