// Stub for Directory on web platform
// This file is only used on web, where dart:io is not available
class Directory {
  final String path;
  Directory(this.path);

  Future<bool> exists() async => false;

  /// Stub: not used on web (_getDownloadDirectory throws before creating dirs).
  Future<void> create({bool recursive = false}) async {}

  String get absolute => path;
}

