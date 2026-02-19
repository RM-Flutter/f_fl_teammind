// Stub for dart:io on web (File not used on web for CV save path).
class File {
  final String path;
  File(this.path);
  Future<File> writeAsBytes(List<int> bytes) async =>
      throw UnsupportedError('File not available on web');
}
