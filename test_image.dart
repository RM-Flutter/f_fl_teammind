import 'dart:io';

void main() {
  var file = File('assets/images/png/home-app-bar.png');
  var bytes = file.readAsBytesSync();
  print('Image size: ${bytes.length} bytes');
}
