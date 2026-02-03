// Stub for dart:html on non-web platforms
// This file is only used on non-web platforms where dart:html is not available

class AnchorElement {
  final String href;
  String? download;
  String? target;
  final Style style = Style();
  AnchorElement({required this.href});
  void click() {}
  void remove() {}
}

class Style {
  String display = '';
}

class Document {
  BodyElement? get body => null;
}

final Document document = Document();

class BodyElement {
  void append(dynamic element) {}
}

class Storage {
  String? operator [](String key) => null;
  void operator []=(String key, String value) {}
}

class Navigator {
  String get userAgent => '';
}

class Window {
  void open(String url, String target) {}
  Future<dynamic> fetch(String url) => Future.value(null);
  Storage get localStorage => Storage();
  Navigator get navigator => Navigator();
}

final Window window = Window();

class Url {
  static String createObjectUrlFromBlob(dynamic blob) => '';
  static void revokeObjectUrl(String url) {}
}

// Note: Response and Blob are only available in dart:html, not in stub
// These are placeholders for non-web platforms

