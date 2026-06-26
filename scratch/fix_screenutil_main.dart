import 'dart:io';

void main() {
  var files = [
    'lib/features/main_layout/views/main_layout_screen.dart',
  ];

  for (var file in files) {
    var f = File(file);
    if (!f.existsSync()) continue;
    
    var content = f.readAsStringSync();
    
    content = content.replaceAllMapped(RegExp(r'(\d+|\d+\.\d+|AppSizes\.s\d+)\.(w|h|r|sp)'), (match) {
      return match.group(1)!;
    });

    f.writeAsStringSync(content);
    print('Cleaned $file');
  }
}
