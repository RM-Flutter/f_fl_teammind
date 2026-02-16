
// Stub file for dart:html to allow compilation on non-web platforms
// This file is used when dart.library.io is true (mobile/desktop)

class HtmlWindow {
  final LocalStorage localStorage = LocalStorage();
  final HtmlNavigator navigator = HtmlNavigator();
  Future<dynamic> fetch(String url) async => null;
  void open(String url, String name) {}
}

class LocalStorage {
  String? operator [](String key) => null;
  void operator []=(String key, String value) {}
}

class HtmlNavigator {
  String get userAgent => '';
}

final window = HtmlWindow();

class Url {
  static String createObjectUrlFromBlob(dynamic blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  AnchorElement({this.href});
  String? href;
  String? download;
  final Style style = Style();
  void click() {}
  void remove() {}
}

class Style {
  String display = '';
}

class HtmlDocument {
  final HtmlBody? body = HtmlBody();
}

class HtmlBody {
  void append(dynamic element) {}
}

final document = HtmlDocument();
