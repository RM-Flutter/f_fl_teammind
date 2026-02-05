// Stub for Directory on web platform
// This file is only used on web, where dart:io is not available
class Directory {
  final String path;
  Directory(this.path);
  
  Future<bool> exists() async => false;
  
  // Add other methods that might be used
  String get absolute => path;
}

